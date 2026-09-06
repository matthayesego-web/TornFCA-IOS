import Foundation

struct BarSummary: Identifiable, Sendable {
    let id: String
    let label: String
    let current: Int
    let maximum: Int

    var fraction: Double {
        guard maximum > 0 else { return 0 }
        return min(1, max(0, Double(current) / Double(maximum)))
    }
}

struct CooldownSummary: Sendable {
    let drug: Int
    let medical: Int
    let booster: Int
}

struct TravelSummary: Sendable {
    let destination: String
    let method: String
    let timeLeft: Int
    let arrivalAt: Int
}

struct OrganizedCrimeSummary: Sendable {
    let assigned: Bool
    let name: String
    let status: String
    let difficulty: Int
    let position: String
    let checkpointPassRate: Int?
    let readyAt: Int
    let itemRequired: Bool
    let itemAvailable: Bool

    var summary: String {
        guard assigned else { return "You are not currently assigned to an organized crime." }
        var parts = [status]
        if difficulty > 0 { parts.append("Difficulty \(difficulty)") }
        if !position.isEmpty { parts.append("Your slot: \(position)") }
        if let checkpointPassRate { parts.append("CPR \(checkpointPassRate)%") }
        if itemRequired { parts.append(itemAvailable ? "Required item available" : "Required item missing") }
        return parts.joined(separator: " • ")
    }
}

struct FactionBalanceSummary: Sendable {
    let money: Int64
    let points: Int64
}

struct ChainSummary: Sendable {
    let current: Int
    let maximum: Int
    let timeout: Int

    var active: Bool { current > 0 }
}

struct WarSummary: Sendable {
    let present: Bool
    let warID: Int
    let start: Int
    let end: Int
    let target: Int
    let opponentFactionID: Int
    let opponent: String
    let ourScore: Int
    let opponentScore: Int

    static let none = WarSummary(present: false, warID: 0, start: 0, end: 0, target: 0, opponentFactionID: 0, opponent: "Opponent", ourScore: 0, opponentScore: 0)

    func isUpcoming(now: Int = Int(Date().timeIntervalSince1970)) -> Bool {
        present && start > now
    }

    func isLive(now: Int = Int(Date().timeIntervalSince1970)) -> Bool {
        present && start > 0 && now >= start && (end <= 0 || now < end)
    }

    func headline(now: Int = Int(Date().timeIntervalSince1970)) -> String {
        if !present { return "No ranked war currently scheduled" }
        if isUpcoming(now: now) { return "WAR STARTS IN \(Self.duration(start - now))" }
        if isLive(now: now) { return "WAR LIVE — \(ourScore) vs \(opponentScore)" }
        return "Latest ranked war ended"
    }

    func detail(now: Int = Int(Date().timeIntervalSince1970)) -> String {
        if !present { return "Your faction is currently between ranked wars." }
        let targetText = target > 0 ? " • target \(target)" : ""
        if isUpcoming(now: now) { return opponent + targetText }
        if isLive(now: now) { return opponent + targetText + " • " + Self.duration(max(0, now - start)) + " elapsed" }
        return opponent + " • final \(ourScore)–\(opponentScore)"
    }

    static func duration(_ seconds: Int) -> String {
        var remaining = max(0, seconds)
        let days = remaining / 86_400
        remaining %= 86_400
        let hours = remaining / 3_600
        remaining %= 3_600
        let minutes = remaining / 60
        let secs = remaining % 60
        if days > 0 { return "\(days)d \(hours)h \(minutes)m" }
        if hours > 0 { return "\(hours)h \(minutes)m \(secs)s" }
        return "\(minutes)m \(secs)s"
    }
}

struct WarHistoryItem: Identifiable, Sendable {
    let id: Int
    let opponent: String
    let ourScore: Int
    let opponentScore: Int
    let winnerFactionID: Int
    let end: Int

    func result(for factionID: Int) -> String {
        if winnerFactionID == 0 { return "DRAW" }
        return winnerFactionID == factionID ? "WIN" : "LOSS"
    }
}

struct MyDaySnapshot: Sendable {
    let bars: [BarSummary]
    let cooldowns: CooldownSummary?
    let travel: TravelSummary?
    let organizedCrime: OrganizedCrimeSummary
    let factionBalance: FactionBalanceSummary?
    let chain: ChainSummary?
    let war: WarSummary

    var priority: String {
        if war.isLive() { return "Ranked War is live. Check your war status and participation before using energy elsewhere." }
        if let chain, chain.active, chain.timeout > 0, chain.timeout <= 120 { return "The faction chain is active and its timer is getting low. If you're able to hit, this is the priority." }
        if organizedCrime.assigned && organizedCrime.itemRequired && !organizedCrime.itemAvailable { return "Your organized crime needs an item that Torn reports as unavailable. Check your OC before it is ready." }
        if let energy = bars.first(where: { $0.id == "energy" }), energy.maximum > 0, energy.current >= energy.maximum { return "Your energy is full. This is a good time to train or use it before regeneration is wasted." }
        if let chain, chain.active { return "The faction chain is active. Check Chain Status before deciding what to do next." }
        if let cooldowns, cooldowns.drug == 0 { return "Drug cooldown is clear. No urgent faction obligation is showing right now." }
        return "No urgent faction obligation is showing right now. Keep an eye on your OC, energy and upcoming war status."
    }
}

struct FactionOverviewSnapshot: Sendable {
    let organizedCrime: OrganizedCrimeSummary
    let chain: ChainSummary?
    let war: WarSummary
}

struct FactionMemberRow: Identifiable, Sendable {
    let id: Int
    let name: String
    let position: String
    let status: String
    let lastActionStatus: String
}

struct RankedWarSnapshot: Sendable {
    let current: WarSummary
    let history: [WarHistoryItem]
}
