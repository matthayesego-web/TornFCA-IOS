import Foundation

extension TornCommunityClient {
    func warPrepState(apiKey: String, warID: Int) async throws -> WarPrepSharedState? {
        let root = try await post(action: "warprep_state", apiKey: apiKey, fields: ["warId": warID])
        guard let warPrep = root["warPrep"] as? [String: Any] else { return nil }
        return readWarPrep(warPrep)
    }

    func saveWarPrepStatus(apiKey: String, warID: Int, completed: [String: Bool]) async throws -> WarPrepSharedState? {
        let root = try await post(action: "warprep_status_save", apiKey: apiKey, fields: ["warId": warID, "completed": completed])
        guard let warPrep = root["warPrep"] as? [String: Any] else { return nil }
        return readWarPrep(warPrep)
    }

    private func readWarPrep(_ value: [String: Any]) -> WarPrepSharedState {
        let prominent = value["prominent"] as? Bool ?? (value["prominent"] as? NSNumber)?.boolValue ?? true
        let itemRows = value["items"] as? [[String: Any]] ?? []
        let items = itemRows.enumerated().map { index, row in
            WarPrepItem(
                id: (row["id"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "item\(index + 1)",
                title: (row["title"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "Faction War Prep item"
            )
        }
        var completed: [String: Bool] = [:]
        if let status = value["status"] as? [String: Any], let raw = status["completed"] as? [String: Any] {
            for (key, value) in raw {
                if let bool = value as? Bool { completed[key] = bool }
                else if let number = value as? NSNumber { completed[key] = number.boolValue }
            }
        }
        return WarPrepSharedState(prominent: prominent, items: items, completed: completed)
    }
}
