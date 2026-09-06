import Foundation

struct WarPrepItem: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
}

struct WarPrepSharedState: Sendable {
    let prominent: Bool
    let items: [WarPrepItem]
    let completed: [String: Bool]

    static let empty = WarPrepSharedState(prominent: true, items: [], completed: [:])
}
