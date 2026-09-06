import Foundation

actor TornAPIClient {
    static let shared = TornAPIClient()

    enum ClientError: LocalizedError {
        case invalidKey
        case invalidURL
        case invalidResponse
        case api(String)
        case decoding(String)

        var errorDescription: String? {
            switch self {
            case .invalidKey:
                return "Torn API keys must be exactly 16 letters/numbers."
            case .invalidURL:
                return "The Torn API URL could not be created."
            case .invalidResponse:
                return "Torn returned an unexpected response."
            case .api(let message):
                return message
            case .decoding(let message):
                return message
            }
        }
    }

    private struct CacheEntry {
        let data: Data
        let expiresAt: Date
    }

    private let baseURL = URL(string: "https://api.torn.com/v2")!
    private let session: URLSession
    private var cache: [String: CacheEntry] = [:]
    private var requestTokens = 3.0
    private var tokenRefillAt = Date()
    private var requestsPerMinute = 30

    init(session: URLSession = .shared) {
        self.session = session
    }

    func configureRequestRate(_ requestedPerMinute: Int) {
        requestsPerMinute = min(80, max(10, requestedPerMinute))
        requestTokens = min(3.0, requestTokens)
        tokenRefillAt = Date()
    }

    func authenticate(_ apiKey: String) async throws -> AuthSession {
        try validateKey(apiKey)

        async let keyInfoData = requestData(path: "/key/info", apiKey: apiKey, ttl: 600)
        async let identityData = requestData(path: "/user?selections=profile,faction", apiKey: apiKey, ttl: 600)

        let (keyData, userData) = try await (keyInfoData, identityData)
        let keyRoot = try object(keyData)
        let identity = try object(userData)

        guard let info = keyRoot["info"] as? [String: Any] else {
            throw ClientError.decoding("Torn key information was unavailable.")
        }
        let access = info["access"] as? [String: Any]
        let accessLevel = int(access?["level"])
        let accessType = string(access?["type"])
        let customKey = accessType.lowercased().contains("custom")
        if !customKey && accessLevel < 3 {
            throw ClientError.api("TornFCA requires a Limited Access key or higher. Full Access is not required.")
        }

        guard let keyUser = info["user"] as? [String: Any], int(keyUser["id"]) > 0 else {
            throw ClientError.decoding("Torn key owner information was unavailable.")
        }
        let playerID = int(keyUser["id"])

        guard let profileObject = identity["profile"] as? [String: Any] else {
            throw ClientError.decoding("Torn player information was unavailable.")
        }
        let playerName = string(profileObject["name"], fallback: "Unknown")
        let level = int(profileObject["level"])
        let gender = string(profileObject["gender"])

        guard let faction = identity["faction"] as? [String: Any] else {
            throw ClientError.api("This Torn account is not currently in a faction.")
        }
        let factionID = int(faction["id"])
        let factionName = string(faction["name"])
        let position = string(faction["position"], fallback: "Member")
        guard factionID > 0, !factionName.isEmpty else {
            throw ClientError.decoding("Unable to verify the Torn faction.")
        }

        let factionAPIAccess = bool(access?["faction"])
        var abilities: [String] = []
        var permissionsResolved = false

        if factionAPIAccess {
            do {
                let positionsData = try await requestData(path: "/faction/positions", apiKey: apiKey, ttl: 600)
                let positionsRoot = try object(positionsData)
                if let rows = positionsRoot["positions"] as? [[String: Any]],
                   let match = rows.first(where: { string($0["name"]).caseInsensitiveCompare(position) == .orderedSame }) {
                    abilities = stringArray(match["abilities"])
                    permissionsResolved = true
                }
            } catch {
                // Individual protected endpoints remain authoritative. Authentication should still
                // succeed when Torn withholds the complete rank matrix from this key.
            }
        }

        if AccessPolicy.isLeaderPosition(position) {
            permissionsResolved = true
        }

        return AuthSession(
            profile: TornProfile(id: playerID, name: playerName, level: level, gender: gender),
            factionID: factionID,
            factionName: factionName,
            position: position,
            factionAPIAccess: factionAPIAccess,
            abilities: abilities,
            permissionsResolved: permissionsResolved
        )
    }

    func verifyAPIKey(_ apiKey: String) async throws -> TornProfile {
        try await authenticate(apiKey).profile
    }

    func requestData(path: String, apiKey: String, ttl: TimeInterval = 0) async throws -> Data {
        try validateKey(apiKey)
        let url = try tornURL(path)
        let cacheKey = "\(apiKey.hashValue):\(url.absoluteString)"
        if let hit = cache[cacheKey], hit.expiresAt > Date() {
            return hit.data
        }

        var lastError: Error?
        for attempt in 0..<3 {
            await waitForRequestSlot()
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 30
            request.setValue("ApiKey \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("TornFCA/iOS", forHTTPHeaderField: "User-Agent")

            do {
                let (data, response) = try await session.data(for: request)
                guard let http = response as? HTTPURLResponse else { throw ClientError.invalidResponse }

                if let apiMessage = apiErrorMessage(data) {
                    if attempt < 2, http.statusCode == 429 || http.statusCode >= 500 {
                        try? await Task.sleep(nanoseconds: UInt64((attempt + 1) * 3_000_000_000))
                        lastError = ClientError.api(apiMessage)
                        continue
                    }
                    throw ClientError.api(apiMessage)
                }

                if http.statusCode == 429 || http.statusCode >= 500 {
                    let error = ClientError.api("Torn API request failed (HTTP \(http.statusCode)).")
                    if attempt < 2 {
                        try? await Task.sleep(nanoseconds: UInt64((attempt + 1) * 3_000_000_000))
                        lastError = error
                        continue
                    }
                    throw error
                }
                guard (200..<300).contains(http.statusCode) else {
                    throw ClientError.api("Torn API request failed (HTTP \(http.statusCode)).")
                }

                if ttl > 0 {
                    cache[cacheKey] = CacheEntry(data: data, expiresAt: Date().addingTimeInterval(ttl))
                    trimCache()
                }
                return data
            } catch {
                lastError = error
                if attempt < 2 {
                    try? await Task.sleep(nanoseconds: UInt64((attempt + 1) * 1_000_000_000))
                }
            }
        }
        throw lastError ?? ClientError.invalidResponse
    }

    func clearMemoryCache() {
        cache.removeAll()
    }

    private func validateKey(_ key: String) throws {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count == 16,
              trimmed.unicodeScalars.allSatisfy({ CharacterSet.alphanumerics.contains($0) }) else {
            throw ClientError.invalidKey
        }
    }

    private func tornURL(_ path: String) throws -> URL {
        if let absolute = URL(string: path), absolute.scheme != nil {
            guard absolute.scheme == "https", absolute.host == "api.torn.com", absolute.path.hasPrefix("/v2") else {
                throw ClientError.invalidURL
            }
            return absolute
        }
        let normalized = path.hasPrefix("/") ? path : "/\(path)"
        guard let url = URL(string: baseURL.absoluteString + normalized) else { throw ClientError.invalidURL }
        return url
    }

    private func waitForRequestSlot() async {
        while true {
            let now = Date()
            let refillSeconds = 60.0 / Double(requestsPerMinute)
            let elapsed = max(0, now.timeIntervalSince(tokenRefillAt))
            if elapsed > 0 {
                requestTokens = min(3.0, requestTokens + elapsed / refillSeconds)
                tokenRefillAt = now
            }
            if requestTokens >= 1 {
                requestTokens -= 1
                return
            }
            let wait = max(0.025, (1 - requestTokens) * refillSeconds)
            try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
        }
    }

    private func apiErrorMessage(_ data: Data) -> String? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let error = root["error"] as? [String: Any] else { return nil }
        return string(error["error"], fallback: string(error["message"], fallback: "Torn rejected this API request."))
    }

    private func object(_ data: Data) throws -> [String: Any] {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ClientError.decoding("Torn returned data this version of TornFCA could not read.")
        }
        return root
    }

    private func int(_ value: Any?) -> Int {
        if let number = value as? NSNumber { return number.intValue }
        if let text = value as? String { return Int(text) ?? 0 }
        return 0
    }

    private func bool(_ value: Any?) -> Bool {
        if let number = value as? NSNumber { return number.boolValue }
        if let value = value as? Bool { return value }
        if let text = value as? String { return ["true", "1", "yes"].contains(text.lowercased()) }
        return false
    }

    private func string(_ value: Any?, fallback: String = "") -> String {
        if let value = value as? String, !value.isEmpty { return value }
        if let value = value as? NSNumber { return value.stringValue }
        return fallback
    }

    private func stringArray(_ value: Any?) -> [String] {
        if let values = value as? [String] { return values }
        if let values = value as? [Any] { return values.compactMap { $0 as? String } }
        return []
    }

    private func trimCache() {
        let now = Date()
        cache = cache.filter { $0.value.expiresAt > now }
        if cache.count > 120 {
            let keep = cache.sorted { $0.value.expiresAt > $1.value.expiresAt }.prefix(80)
            cache = Dictionary(uniqueKeysWithValues: keep.map { ($0.key, $0.value) })
        }
    }
}
