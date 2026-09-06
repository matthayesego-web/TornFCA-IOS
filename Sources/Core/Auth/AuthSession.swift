import Foundation

struct AuthSession: Equatable, Sendable {
    let profile: TornProfile
    let factionID: Int
    let factionName: String
    let position: String
    let factionAPIAccess: Bool
    let abilities: [String]
    let permissionsResolved: Bool

    var playerID: Int { profile.id }
    var playerName: String { profile.name }

    var isLiteralLeader: Bool { AccessPolicy.isLeaderPosition(position) }
    var hasLeadershipWorkspace: Bool { AccessPolicy.hasLeadershipWorkspace(position: position, abilities: abilities) }
    var canPeopleActivity: Bool { AccessPolicy.canPeopleActivity(position: position, abilities: abilities) }
    var canWarIntel: Bool { AccessPolicy.canWarIntel(position: position, abilities: abilities) }
    var canWarPayout: Bool { AccessPolicy.canWarPayout(position: position, abilities: abilities) }
    var canBanking: Bool { AccessPolicy.canBanking(position: position, abilities: abilities) }
    var canCacheAdvisor: Bool { AccessPolicy.canCacheAdvisor(position: position, abilities: abilities) }
    var canArmory: Bool { AccessPolicy.canArmory(position: position, abilities: abilities) }
    var canFactionAdmin: Bool { AccessPolicy.canFactionAdmin(position: position, abilities: abilities) }
    var canManageOC: Bool { AccessPolicy.canManageOC(position: position, abilities: abilities) }
    var canAttention: Bool { AccessPolicy.canAttention(position: position, abilities: abilities) }

    var accessLabel: String {
        if isLiteralLeader { return "Leader / Co-leader permissions" }
        if hasLeadershipWorkspace { return "Delegated faction permissions" }
        if permissionsResolved { return "Torn permissions verified" }
        return "Torn permissions not cached"
    }
}

enum AccessPolicy {
    private static let peopleAbilities = ["Application Management", "Kick Members", "Kick Member"]
    private static let warIntelAbilities = ["War Management"]
    private static let warPayoutAbilities = ["War Management", "Money Giving", "Balance Adjustment"]
    private static let bankingAbilities = ["Money Giving", "Balance Adjustment"]
    private static let cacheAdvisorAbilities = ["Money Giving", "Balance Adjustment", "Item Giving"]
    private static let armoryAbilities = ["Item Giving"]
    private static let noticeAbilities = ["Announcement Changes", "Newsletter Sending"]
    private static let ocAbilities = ["Organised Crimes", "Organized Crimes"]

    static func isLeaderPosition(_ position: String) -> Bool {
        let normalized = position
            .lowercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
        return normalized == "leader" || normalized == "coleader"
    }

    static func hasAbility(_ abilities: [String], _ names: [String]) -> Bool {
        let owned = Set(abilities.map(normalize))
        return names.contains { owned.contains(normalize($0)) }
    }

    static func canPeopleActivity(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position) || hasAbility(abilities, peopleAbilities)
    }

    static func canWarIntel(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position) || hasAbility(abilities, warIntelAbilities)
    }

    static func canWarPayout(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position) || hasAbility(abilities, warPayoutAbilities)
    }

    static func canBanking(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position) || hasAbility(abilities, bankingAbilities)
    }

    static func canCacheAdvisor(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position) || hasAbility(abilities, cacheAdvisorAbilities)
    }

    static func canArmory(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position) || hasAbility(abilities, armoryAbilities)
    }

    static func canPublishNotices(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position) || hasAbility(abilities, noticeAbilities)
    }

    static func canManageOC(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position) || hasAbility(abilities, ocAbilities)
    }

    static func canFactionAdmin(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position)
            || canPublishNotices(position: position, abilities: abilities)
            || canManageOC(position: position, abilities: abilities)
    }

    static func canAttention(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position)
            || canPeopleActivity(position: position, abilities: abilities)
            || canWarIntel(position: position, abilities: abilities)
    }

    static func hasLeadershipWorkspace(position: String, abilities: [String]) -> Bool {
        isLeaderPosition(position)
            || canPeopleActivity(position: position, abilities: abilities)
            || canWarIntel(position: position, abilities: abilities)
            || canWarPayout(position: position, abilities: abilities)
            || canBanking(position: position, abilities: abilities)
            || canCacheAdvisor(position: position, abilities: abilities)
            || canArmory(position: position, abilities: abilities)
            || canFactionAdmin(position: position, abilities: abilities)
    }

    private static func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
