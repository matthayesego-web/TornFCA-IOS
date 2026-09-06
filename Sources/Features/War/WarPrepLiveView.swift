import SwiftUI

struct WarPrepLiveView: View {
    @EnvironmentObject private var appState: AppState
    let session: AuthSession

    @State private var snapshot: MyDaySnapshot?
    @State private var items: [WarPrepItem] = Self.defaultItems
    @State private var completed: [String: Bool] = [:]
    @State private var prominent = true
    @State private var shared = false
    @State private var loading = true
    @State private var syncing = false
    @State private var error: String?

    private static let defaultItems: [WarPrepItem] = [
        WarPrepItem(id: "item1", title: "Reviewed current war mode and timing"),
        WarPrepItem(id: "item2", title: "Checked travel"),
        WarPrepItem(id: "item3", title: "Checked cooldowns & refills"),
        WarPrepItem(id: "item4", title: "Reviewed faction resources"),
        WarPrepItem(id: "item5", title: "Reviewed current instructions")
    ]

    private var warID: Int { snapshot?.war.warID ?? 0 }
    private var completeCount: Int { items.filter { completed[$0.id] == true }.count }
    private var storageKey: String {
        let cycle = warID > 0 ? "war\(warID)" : "general"
        return "tornfca.warprep.p\(session.playerID).f\(session.factionID).\(cycle)"
    }

    var body: some View {
        CommandDetailScaffold(title: "My War Prep", eyebrow: "WAR CENTER", subtitle: "\(session.factionName) • \(session.playerName) • personal readiness", accent: TornTheme.red) {
            if loading { LoadingCommandCard(text: "Checking cached war context and your personal readiness…", accent: TornTheme.red) }
            if let error { ErrorCommandCard(message: error) { Task { await load() } } }

            if let snapshot {
                if prominent && warID > 0 && completeCount < items.count {
                    checklistPanel(title: "War Readiness — Action Required", elevated: true)
                }

                WarStatusCommandCard(war: snapshot.war)

                if !snapshot.bars.isEmpty {
                    CommandPanel(title: "Personal Readiness", subtitle: "Live Torn bars") {
                        ForEach(snapshot.bars) { bar in
                            HStack {
                                Text(bar.label).font(.system(size: 12, weight: .bold)).foregroundStyle(TornTheme.text)
                                Spacer()
                                Text("\(bar.current) / \(bar.maximum)").font(.system(size: 11)).foregroundStyle(TornTheme.muted)
                            }
                        }
                    }
                }

                if let cooldowns = snapshot.cooldowns {
                    CommandPanel(title: "Cooldowns", subtitle: "Current readiness") {
                        Text("Drug: \(WarSummary.duration(cooldowns.drug))\nMedical: \(WarSummary.duration(cooldowns.medical))\nBooster: \(WarSummary.duration(cooldowns.booster))")
                            .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                    }
                }

                if let travel = snapshot.travel {
                    CommandPanel(title: "Travel", subtitle: "Travel in progress") {
                        Text("Traveling to \(travel.destination) • \(WarSummary.duration(travel.timeLeft)) remaining")
                            .font(.system(size: 12)).foregroundStyle(TornTheme.gold2)
                    }
                } else {
                    CommandPanel(title: "Travel", subtitle: "Travel clear") {
                        Text("Torn does not report you as currently traveling.")
                            .font(.system(size: 12)).foregroundStyle(TornTheme.green)
                    }
                }

                CommandPanel(title: "My OC", subtitle: "Current organized-crime readiness") {
                    Text(snapshot.organizedCrime.summary).font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                }

                if !(prominent && warID > 0 && completeCount < items.count) {
                    checklistPanel(title: "My Prep Checklist", elevated: false)
                }

                CommandPanel(title: "Prep Status", subtitle: "\(completeCount) / \(items.count) complete") {
                    Text(prominent ? "Persistent checklist prominence is ON for this faction." : "Persistent checklist prominence is OFF for this faction.")
                        .font(.system(size: 11.5)).foregroundStyle(TornTheme.muted)
                    Text(shared ? "Status is shared with faction leadership for this ranked-war cycle." : "Status is local to this device until shared War Prep is available for a verified ranked war.")
                        .font(.system(size: 11.5)).foregroundStyle(shared ? TornTheme.green : TornTheme.gold2)
                    if syncing { HStack { ProgressView().tint(TornTheme.blue); Text("Syncing…").font(.system(size: 10.5)).foregroundStyle(TornTheme.muted) } }
                }

                CommandPanel(title: "War Shortcuts", subtitle: "Continue from here") {
                    CommandActionRow(title: "Open Ranked War", subtitle: "Current matchup and history", value: "War", icon: "shield.fill", accent: TornTheme.red, route: .rankedWar)
                    CommandActionRow(title: "Open My Day", subtitle: "Personal readiness", value: "Day", icon: "calendar", accent: TornTheme.green, route: .myDay)
                    CommandActionRow(title: "Open Faction Resources", subtitle: "Guides and onboarding", value: "Guides", icon: "book.closed.fill", accent: TornTheme.gold, route: .resources)
                    CommandActionRow(title: "Open Faction Chat", subtitle: "Current faction community", value: "Chat", icon: "bubble.left.and.bubble.right.fill", accent: TornTheme.blue, route: .factionChat)
                }

                CommandPanel(title: "Scope", subtitle: "Per-war and per-faction") {
                    Text("Checklist state is isolated by player + verified faction + ranked-war cycle. A new ranked war automatically starts a fresh checklist.")
                        .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                }
            }
        }
        .task { await load() }
    }

    @ViewBuilder
    private func checklistPanel(title: String, elevated: Bool) -> some View {
        CommandPanel(title: title, subtitle: elevated ? "Finish War Prep before the checklist clears" : "Current ranked-war cycle") {
            ForEach(items) { item in
                Button { toggle(item) } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: completed[item.id] == true ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(completed[item.id] == true ? TornTheme.green : TornTheme.steel)
                        Text(item.title)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(TornTheme.text)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(elevated ? TornTheme.gold.opacity(0.75) : TornTheme.line))
    }

    private func load() async {
        loading = true; error = nil
        guard let key = appState.storedAPIKey() else { error = "Reconnect your Torn API key to use My War Prep."; loading = false; return }
        do {
            let current = try await TornLiveDataService.shared.loadMyDay(apiKey: key, session: session)
            snapshot = current
            loadLocal()
            if current.war.warID > 0 {
                do {
                    if let state = try await TornCommunityClient.shared.warPrepState(apiKey: key, warID: current.war.warID) {
                        prominent = state.prominent
                        if !state.items.isEmpty { items = state.items }
                        loadLocal()
                        for (id, value) in state.completed where value { completed[id] = true }
                        persistLocal()
                        shared = true
                    }
                } catch {
                    shared = false
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
        loading = false
    }

    private func loadLocal() {
        if let raw = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: Bool] { completed = raw }
        else { completed = [:] }
    }

    private func persistLocal() {
        UserDefaults.standard.set(completed, forKey: storageKey)
    }

    private func toggle(_ item: WarPrepItem) {
        completed[item.id] = !(completed[item.id] ?? false)
        persistLocal()
        guard warID > 0, let key = appState.storedAPIKey() else { return }
        let current = completed
        Task {
            syncing = true
            do {
                _ = try await TornCommunityClient.shared.saveWarPrepStatus(apiKey: key, warID: warID, completed: current)
                shared = true
            } catch {
                shared = false
            }
            syncing = false
        }
    }
}
