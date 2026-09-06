import Foundation

actor TornLiveDataService {
    static let shared = TornLiveDataService()
    private let api = TornAPIClient.shared

    func loadMyDay(apiKey: String, session: AuthSession) async throws -> MyDaySnapshot {
        async let selfData = loadSelfSnapshot(apiKey: apiKey)
        async let warData = api.requestData(path: "/faction/wars", apiKey: apiKey, ttl: 120)
        async let chainData = api.requestData(path: "/faction/chain", apiKey: apiKey, ttl: 45)

        let (selfRoot, warRaw, chainRaw) = try await (selfData, warData, chainData)
        let warRoot = try object(warRaw)
        let chainRoot = try object(chainRaw)

        return MyDaySnapshot(
            bars: readBars(selfRoot["bars"] as? [String: Any]),
            cooldowns: readCooldowns(selfRoot["cooldowns"] as? [String: Any]),
            travel: readTravel(selfRoot["travel"] as? [String: Any]),
            organizedCrime: readOC(selfRoot["organizedCrime"] as? [String: Any] ?? selfRoot["organizedcrime"] as? [String: Any], playerID: session.playerID),
            factionBalance: readFactionBalance(selfRoot["money"] as? [String: Any]),
            chain: readChain(chainRoot["chain"] as? [String: Any]),
            war: readWar(warRoot, factionID: session.factionID)
        )
    }

    func loadFactionOverview(apiKey: String, session: AuthSession) async throws -> FactionOverviewSnapshot {
        async let ocData = api.requestData(path: "/user/organizedcrime", apiKey: apiKey, ttl: 45)
        async let warData = api.requestData(path: "/faction/wars", apiKey: apiKey, ttl: 120)
        async let chainData = api.requestData(path: "/faction/chain", apiKey: apiKey, ttl: 45)
        let (ocRaw, warRaw, chainRaw) = try await (ocData, warData, chainData)
        let ocRoot = try object(ocRaw)
        let warRoot = try object(warRaw)
        let chainRoot = try object(chainRaw)
        return FactionOverviewSnapshot(
            organizedCrime: readOC(ocRoot["organizedCrime"] as? [String: Any] ?? ocRoot["organizedcrime"] as? [String: Any], playerID: session.playerID),
            chain: readChain(chainRoot["chain"] as? [String: Any]),
            war: readWar(warRoot, factionID: session.factionID)
        )
    }

    func loadFactionDirectory(apiKey: String) async throws -> [FactionMemberRow] {
        let data = try await api.requestData(path: "/faction/members", apiKey: apiKey, ttl: 120)
        let root = try object(data)
        guard let rows = root["members"] as? [[String: Any]] else { return [] }
        return rows.map { member in
            let statusObject = member["status"] as? [String: Any]
            let lastAction = member["last_action"] as? [String: Any]
            return FactionMemberRow(
                id: int(member["id"]),
                name: string(member["name"], fallback: "Member"),
                position: string(member["position"], fallback: "Member"),
                status: string(statusObject?["state"], fallback: string(statusObject?["description"], fallback: "Unknown")),
                lastActionStatus: string(lastAction?["status"], fallback: "")
            )
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func loadRankedWar(apiKey: String, session: AuthSession) async throws -> RankedWarSnapshot {
        async let currentData = api.requestData(path: "/faction/wars", apiKey: apiKey, ttl: 120)
        async let historyData = api.requestData(path: "/faction/\(session.factionID)/rankedwars?limit=8", apiKey: apiKey, ttl: 600)
        let (currentRaw, historyRaw) = try await (currentData, historyData)
        let current = readWar(try object(currentRaw), factionID: session.factionID)
        let historyRoot = try object(historyRaw)
        let historyRows = historyRoot["rankedwars"] as? [[String: Any]] ?? []
        let history = historyRows.map { row -> WarHistoryItem in
            let factions = row["factions"] as? [[String: Any]] ?? []
            var opponent = "Opponent"
            var ourScore = 0
            var theirScore = 0
            for faction in factions {
                if int(faction["id"]) == session.factionID {
                    ourScore = int(faction["score"])
                } else {
                    opponent = string(faction["name"], fallback: opponent)
                    theirScore = int(faction["score"])
                }
            }
            return WarHistoryItem(
                id: int(row["id"]),
                opponent: opponent,
                ourScore: ourScore,
                opponentScore: theirScore,
                winnerFactionID: int(row["winner"]),
                end: int(row["end"])
            )
        }
        return RankedWarSnapshot(current: current, history: history)
    }

    func loadOrganizedCrime(apiKey: String, playerID: Int) async throws -> OrganizedCrimeSummary {
        let data = try await api.requestData(path: "/user/organizedcrime", apiKey: apiKey, ttl: 45)
        let root = try object(data)
        return readOC(root["organizedCrime"] as? [String: Any] ?? root["organizedcrime"] as? [String: Any], playerID: playerID)
    }

    func loadChain(apiKey: String) async throws -> ChainSummary? {
        let data = try await api.requestData(path: "/faction/chain", apiKey: apiKey, ttl: 30)
        let root = try object(data)
        return readChain(root["chain"] as? [String: Any])
    }

    private func loadSelfSnapshot(apiKey: String) async throws -> [String: Any] {
        do {
            let data = try await api.requestData(path: "/user?selections=bars,cooldowns,travel,organizedcrime,money", apiKey: apiKey, ttl: 30)
            return try object(data)
        } catch {
            var root: [String: Any] = [:]
            await copy(path: "/user/bars", resultKey: "bars", apiKey: apiKey, into: &root)
            await copy(path: "/user/cooldowns", resultKey: "cooldowns", apiKey: apiKey, into: &root)
            await copy(path: "/user/travel", resultKey: "travel", apiKey: apiKey, into: &root)
            await copy(path: "/user/organizedcrime", resultKey: "organizedCrime", alternateKey: "organizedcrime", apiKey: apiKey, into: &root)
            await copy(path: "/user/money", resultKey: "money", apiKey: apiKey, into: &root)
            if root.isEmpty { throw error }
            return root
        }
    }

    private func copy(path: String, resultKey: String, alternateKey: String? = nil, apiKey: String, into root: inout [String: Any]) async {
        guard let data = try? await api.requestData(path: path, apiKey: apiKey, ttl: 30),
              let response = try? object(data) else { return }
        if let object = response[resultKey] as? [String: Any] { root[resultKey] = object; return }
        if let alternateKey, let object = response[alternateKey] as? [String: Any] { root[resultKey] = object }
    }

    private func readBars(_ bars: [String: Any]?) -> [BarSummary] {
        guard let bars else { return [] }
        return [("energy", "Energy"), ("nerve", "Nerve"), ("life", "Life"), ("happy", "Happy")].compactMap { key, label in
            guard let row = bars[key] as? [String: Any] else { return nil }
            return BarSummary(id: key, label: label, current: int(row["current"]), maximum: int(row["maximum"]))
        }
    }

    private func readCooldowns(_ value: [String: Any]?) -> CooldownSummary? {
        guard let value else { return nil }
        return CooldownSummary(drug: int(value["drug"]), medical: int(value["medical"]), booster: int(value["booster"]))
    }

    private func readTravel(_ value: [String: Any]?) -> TravelSummary? {
        guard let value, int(value["time_left"]) > 0 else { return nil }
        return TravelSummary(destination: string(value["destination"], fallback: "destination"), method: string(value["method"], fallback: "Unknown"), timeLeft: int(value["time_left"]), arrivalAt: int(value["arrival_at"]))
    }

    private func readFactionBalance(_ moneyRoot: [String: Any]?) -> FactionBalanceSummary? {
        guard let faction = moneyRoot?["faction"] as? [String: Any] else { return nil }
        return FactionBalanceSummary(money: int64(faction["money"]), points: int64(faction["points"]))
    }

    private func readChain(_ value: [String: Any]?) -> ChainSummary? {
        guard let value else { return nil }
        return ChainSummary(current: int(value["current"]), maximum: int(value["max"]), timeout: int(value["timeout"]))
    }

    private func readOC(_ crime: [String: Any]?, playerID: Int) -> OrganizedCrimeSummary {
        guard let crime else {
            return OrganizedCrimeSummary(assigned: false, name: "My OC", status: "Not assigned", difficulty: 0, position: "", checkpointPassRate: nil, readyAt: 0, itemRequired: false, itemAvailable: true)
        }
        let slots = crime["slots"] as? [[String: Any]] ?? []
        var position = ""
        var passRate: Int?
        var itemRequired = false
        var itemAvailable = true
        for slot in slots {
            guard let user = slot["user"] as? [String: Any], int(user["id"]) == playerID else { continue }
            position = string(slot["position"])
            if slot["checkpoint_pass_rate"] != nil { passRate = int(slot["checkpoint_pass_rate"]) }
            if let requirement = slot["item_requirement"] as? [String: Any] {
                itemRequired = true
                itemAvailable = bool(requirement["is_available"], fallback: true)
            }
            break
        }
        return OrganizedCrimeSummary(
            assigned: true,
            name: string(crime["name"], fallback: "Organized Crime"),
            status: string(crime["status"], fallback: "Unknown"),
            difficulty: int(crime["difficulty"]),
            position: position,
            checkpointPassRate: passRate,
            readyAt: int(crime["ready_at"]),
            itemRequired: itemRequired,
            itemAvailable: itemAvailable
        )
    }

    private func readWar(_ root: [String: Any], factionID: Int) -> WarSummary {
        guard let wars = root["wars"] as? [String: Any],
              let ranked = wars["ranked"] as? [String: Any] else { return .none }
        let factions = ranked["factions"] as? [[String: Any]] ?? []
        var opponentID = 0
        var opponent = "Opponent"
        var ourScore = 0
        var opponentScore = 0
        for faction in factions {
            if int(faction["id"]) == factionID {
                ourScore = int(faction["score"])
            } else {
                opponentID = int(faction["id"])
                opponent = string(faction["name"], fallback: opponent)
                opponentScore = int(faction["score"])
            }
        }
        return WarSummary(
            present: true,
            warID: int(ranked["war_id"]),
            start: int(ranked["start"]),
            end: int(ranked["end"]),
            target: int(ranked["target"]),
            opponentFactionID: opponentID,
            opponent: opponent,
            ourScore: ourScore,
            opponentScore: opponentScore
        )
    }

    private func object(_ data: Data) throws -> [String: Any] {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw TornAPIClient.ClientError.decoding("Torn returned unreadable data.")
        }
        return root
    }

    private func int(_ value: Any?) -> Int {
        if let number = value as? NSNumber { return number.intValue }
        if let text = value as? String { return Int(text) ?? 0 }
        return 0
    }

    private func int64(_ value: Any?) -> Int64 {
        if let number = value as? NSNumber { return number.int64Value }
        if let text = value as? String { return Int64(text) ?? 0 }
        return 0
    }

    private func string(_ value: Any?, fallback: String = "") -> String {
        if let text = value as? String, !text.isEmpty { return text }
        if let number = value as? NSNumber { return number.stringValue }
        return fallback
    }

    private func bool(_ value: Any?, fallback: Bool = false) -> Bool {
        if let value = value as? Bool { return value }
        if let number = value as? NSNumber { return number.boolValue }
        if let text = value as? String { return ["true", "1", "yes"].contains(text.lowercased()) }
        return fallback
    }
}
