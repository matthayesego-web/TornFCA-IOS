import Foundation

actor TornCommunityClient {
    static let shared = TornCommunityClient()

    enum CommunityError: LocalizedError {
        case notConfigured
        case invalidResponse
        case backend(String)

        var errorDescription: String? {
            switch self {
            case .notConfigured: return "TornFCA community backend is not configured yet."
            case .invalidResponse: return "Community backend returned an unreadable response."
            case .backend(let message): return message
            }
        }
    }

    // Matches the current Android development backend contract. This endpoint is public
    // configuration, not a credential. API keys remain user-scoped and are sent only for a request.
    private let backendURL = URL(string: "https://script.google.com/macros/s/AKfycbwphLmR-N82GJUChzwZlxQ8DGKVoaN6VCNiXvbpKfgJV6JUxlcwPOYVKgbI1h9tmjp-ig/exec")!
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func chatSnapshot(apiKey: String, channel: String) async throws -> CommunityChatSnapshot {
        let root = try await post(action: "chat_list", apiKey: apiKey, fields: ["channel": channel])
        let user = root["user"] as? [String: Any] ?? [:]
        let rows = root["messages"] as? [[String: Any]] ?? []
        return CommunityChatSnapshot(
            playerID: int(user["id"]),
            playerName: string(user["name"], fallback: "Member"),
            factionID: int(user["faction_id"]),
            factionName: string(user["faction_name"], fallback: "Faction"),
            position: string(user["position"]),
            messages: rows.compactMap(readMessage)
        )
    }

    func sendChatMessage(apiKey: String, channel: String, message: String, expectedFactionID: Int) async throws {
        var fields: [String: Any] = ["channel": channel, "message": message]
        if expectedFactionID > 0 { fields["faction_id"] = expectedFactionID }
        _ = try await post(action: "chat_send", apiKey: apiKey, fields: fields)
    }

    func reportChatMessage(apiKey: String, messageID: String, reason: String) async throws {
        _ = try await post(action: "chat_report", apiKey: apiKey, fields: ["messageId": messageID, "reason": reason])
    }

    func trainingLibrary(apiKey: String) async throws -> TrainingLibrary {
        let root = try await post(action: "training_library", apiKey: apiKey)
        var rules: TrainingRules?
        if let value = root["trainingRules"] as? [String: Any], !value.isEmpty {
            rules = TrainingRules(
                statGainTarget: string(value["stat_gain_target"]),
                xanaxTarget: string(value["xanax_target"]),
                notes: string(value["notes"]),
                updatedByName: string(value["updated_by_name"]),
                updatedAt: int(value["updated_at"])
            )
        }
        let guides = (root["guides"] as? [[String: Any]] ?? []).map { row in
            TrainingGuide(
                id: string(row["id"], fallback: UUID().uuidString),
                title: string(row["title"], fallback: "Faction guide"),
                category: string(row["category"], fallback: "Guide"),
                body: string(row["body"]),
                authorName: string(row["author_name"]),
                updatedAt: int(row["updated_at"])
            )
        }
        return TrainingLibrary(rules: rules, guides: guides)
    }

    func post(action: String, apiKey: String, fields: [String: Any] = [:]) async throws -> [String: Any] {
        var body = fields
        body["action"] = action
        body["apiKey"] = apiKey
        let data = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: backendURL)
        request.httpMethod = "POST"
        request.httpBody = data
        request.timeoutInterval = 20
        request.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TornFCA/iOS Community", forHTTPHeaderField: "User-Agent")

        let (responseData, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw CommunityError.invalidResponse }
        guard let root = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw CommunityError.invalidResponse
        }
        if !(200..<300).contains(http.statusCode) {
            throw CommunityError.backend("Community backend HTTP \(http.statusCode).")
        }
        guard bool(root["ok"]) else {
            throw CommunityError.backend(string(root["error"], fallback: "Community backend rejected this request."))
        }
        return root
    }

    private func readMessage(_ row: [String: Any]) -> CommunityChatMessage? {
        let id = string(row["id"])
        guard !id.isEmpty else { return nil }
        return CommunityChatMessage(
            id: id,
            factionID: int(row["faction_id"]),
            channel: string(row["channel"], fallback: "general"),
            authorID: int(row["author_id"]),
            authorName: string(row["author_name"], fallback: "Member"),
            message: string(row["message"]),
            createdAt: int(row["created_at"])
        )
    }

    private func int(_ value: Any?) -> Int {
        if let number = value as? NSNumber { return number.intValue }
        if let text = value as? String { return Int(text) ?? 0 }
        return 0
    }

    private func string(_ value: Any?, fallback: String = "") -> String {
        if let text = value as? String, !text.isEmpty { return text }
        if let number = value as? NSNumber { return number.stringValue }
        return fallback
    }

    private func bool(_ value: Any?) -> Bool {
        if let value = value as? Bool { return value }
        if let number = value as? NSNumber { return number.boolValue }
        if let text = value as? String { return ["true", "1", "yes"].contains(text.lowercased()) }
        return false
    }
}
