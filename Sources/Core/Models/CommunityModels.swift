import Foundation

struct CommunityChatMessage: Identifiable, Sendable, Hashable {
    let id: String
    let factionID: Int
    let channel: String
    let authorID: Int
    let authorName: String
    let message: String
    let createdAt: Int
}

struct CommunityChatSnapshot: Sendable {
    let playerID: Int
    let playerName: String
    let factionID: Int
    let factionName: String
    let position: String
    let messages: [CommunityChatMessage]
}

struct TrainingRules: Sendable {
    let statGainTarget: String
    let xanaxTarget: String
    let notes: String
    let updatedByName: String
    let updatedAt: Int
}

struct TrainingGuide: Identifiable, Sendable {
    let id: String
    let title: String
    let category: String
    let body: String
    let authorName: String
    let updatedAt: Int
}

struct TrainingLibrary: Sendable {
    let rules: TrainingRules?
    let guides: [TrainingGuide]
}
