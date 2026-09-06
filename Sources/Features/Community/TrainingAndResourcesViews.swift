import SwiftUI

struct TrainingCenterLiveView: View {
    @EnvironmentObject private var appState: AppState
    let session: AuthSession
    @State private var library: TrainingLibrary?
    @State private var backendMessage: String?
    @State private var loading = true

    var body: some View {
        CommandDetailScaffold(title: "Training Center", eyebrow: "MEMBER CENTER", subtitle: "\(session.factionName) • guides, expectations and progression help", accent: TornTheme.purple) {
            if loading { LoadingCommandCard(text: "Loading training resources and your faction library…", accent: TornTheme.green) }

            CommandPanel(title: "Your Faction Expectations", subtitle: "Faction-local training rules") {
                if let rules = library?.rules {
                    Text("Stat gain target: \(rules.statGainTarget.isEmpty ? "Not set" : rules.statGainTarget)")
                        .font(.system(size: 13, weight: .bold)).foregroundStyle(TornTheme.text)
                    Text("Xanax target: \(rules.xanaxTarget.isEmpty ? "Not set" : rules.xanaxTarget)")
                        .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                    if !rules.notes.isEmpty { Text(rules.notes).font(.system(size: 12)).foregroundStyle(TornTheme.muted) }
                    if !rules.updatedByName.isEmpty { Text("Updated by \(rules.updatedByName)").font(.system(size: 10.5)).foregroundStyle(TornTheme.gold2) }
                } else {
                    Text(backendMessage ?? "Your faction has not published training targets yet.")
                        .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                }
            }

            CommandPanel(title: "Faction Guide Library", subtitle: "Only the currently verified faction's guides are shown") {
                if let guides = library?.guides, !guides.isEmpty {
                    ForEach(guides) { guide in GuideCard(guide: guide) }
                } else {
                    Text("No custom faction guides are available right now.")
                        .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                }
            }

            CommandPanel(title: "TornFCA Starter Guides", subtitle: "Universal member guidance") {
                StarterGuide(eyebrow: "HAPPY JUMP", title: "Happy Jump — starter checklist", text: "A happy jump combines stored energy with temporarily elevated happiness, then spends that energy in the gym before the next happiness reset. Xanax currently adds 250 energy and 75 happiness; an Erotic DVD adds 2,500 happiness. Check the in-game happy timer before boosting above your normal cap, and remember that a drug overdose can wipe energy, nerve and happiness. Your faction's own timing, budget and stat targets should take priority over any generic recipe.", accent: TornTheme.purple)
                StarterGuide(eyebrow: "DAILY TRAINING", title: "Xanax & energy discipline", text: "Xanax currently provides 250 energy with a 360–480 minute drug cooldown. Natural energy also refills over time, so capped energy is usually wasted regeneration unless you are deliberately saving it for a faction event. Use your faction's published Xanax target as the expectation rather than assuming every faction wants the same daily count.", accent: TornTheme.green)
                StarterGuide(eyebrow: "PROGRESSION", title: "Build consistency before complexity", text: "Regular training, avoiding wasted energy, following your faction's war/chain priorities and tracking progress over time usually matter more than chasing a complicated routine you cannot sustain.", accent: TornTheme.blue)
            }
        }
        .task { await load() }
    }

    private func load() async {
        guard let key = appState.storedAPIKey() else { backendMessage = "Reconnect your Torn API key to load faction training resources."; loading = false; return }
        do { library = try await TornCommunityClient.shared.trainingLibrary(apiKey: key); backendMessage = nil }
        catch { backendMessage = error.localizedDescription }
        loading = false
    }
}

struct FactionResourcesLiveView: View {
    @EnvironmentObject private var appState: AppState
    let session: AuthSession
    @State private var library: TrainingLibrary?
    @State private var loading = true
    @State private var backendMessage: String?
    @State private var completed: Set<String> = []

    private let checklist: [(String, String, String)] = [
        ("profile", "1. Know your faction", "Review your current faction, position and member-safe roster so you know where you fit."),
        ("training", "2. Read training expectations", "Open Training Center and review the stat-gain/Xanax expectations and any exceptions your faction has published."),
        ("oc", "3. Check your organized crime", "Confirm your current OC assignment, slot, readiness time and required item status."),
        ("war", "4. Know war & chain expectations", "Review My Day, Ranked War and Chain Status before a faction event so you know what needs your attention."),
        ("guides", "5. Read faction guides", "Use the library below for faction-specific onboarding, training, trading, war-prep or community instructions.")
    ]

    var body: some View {
        CommandDetailScaffold(title: "Faction Resources", eyebrow: "MEMBER CENTER", subtitle: "\(session.factionName) • onboarding, local guides and quick links", accent: TornTheme.blue) {
            if loading { LoadingCommandCard(text: "Loading your current faction's resource library…", accent: TornTheme.blue) }

            CommandPanel(title: "New Member Checklist", subtitle: "Stored only on this device for this player + faction") {
                ForEach(checklist, id: \.0) { item in
                    Button { toggle(item.0) } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: completed.contains(item.0) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(completed.contains(item.0) ? TornTheme.green : TornTheme.steel)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.1).font(.system(size: 12.5, weight: .bold)).foregroundStyle(TornTheme.text)
                                Text(item.2).font(.system(size: 10.5)).foregroundStyle(TornTheme.muted)
                            }
                            Spacer()
                        }.padding(.vertical, 5)
                    }.buttonStyle(.plain)
                }
                Text("\(completed.count) / 5 complete")
                    .font(.system(size: 11, weight: .bold)).foregroundStyle(completed.count == 5 ? TornTheme.green : TornTheme.gold2)
            }

            CommandPanel(title: "Quick Links", subtitle: "Jump to the essentials") {
                CommandActionRow(title: "Open My Day", subtitle: "Personal readiness", value: "Open", icon: "calendar", accent: TornTheme.green, route: .myDay)
                CommandActionRow(title: "Open Training Center", subtitle: "Guides & expectations", value: "Open", icon: "chart.line.uptrend.xyaxis", accent: TornTheme.purple, route: .training)
                CommandActionRow(title: "Open Faction Directory", subtitle: "Current roster", value: "Open", icon: "person.3.fill", accent: TornTheme.blue, route: .directory)
                CommandActionRow(title: "Open Ranked War", subtitle: "War status", value: "Open", icon: "shield.fill", accent: TornTheme.red, route: .rankedWar)
            }

            CommandPanel(title: "Faction Guide Library", subtitle: "Verified-faction scope") {
                if let guides = library?.guides, !guides.isEmpty {
                    ForEach(guides) { guide in GuideCard(guide: guide) }
                } else {
                    Text(backendMessage ?? "Your faction has not published any custom guides yet.")
                        .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                }
            }

            CommandPanel(title: "Tenant Scope", subtitle: "Resources belong to the faction") {
                Text("If Torn verifies that you changed factions, the old faction library is not returned. The local onboarding checklist is separately scoped by player and faction.")
                    .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
            }
        }
        .task { loadChecklist(); await load() }
    }

    private func load() async {
        guard let key = appState.storedAPIKey() else { backendMessage = "Reconnect your Torn API key."; loading = false; return }
        do { library = try await TornCommunityClient.shared.trainingLibrary(apiKey: key); backendMessage = nil }
        catch { backendMessage = error.localizedDescription }
        loading = false
    }

    private func storageKey() -> String { "tornfca.onboarding.p\(session.playerID).f\(session.factionID)" }
    private func loadChecklist() {
        completed = Set(UserDefaults.standard.stringArray(forKey: storageKey()) ?? [])
    }
    private func toggle(_ id: String) {
        if completed.contains(id) { completed.remove(id) } else { completed.insert(id) }
        UserDefaults.standard.set(Array(completed), forKey: storageKey())
    }
}

struct GuideCard: View {
    let guide: TrainingGuide
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(guide.category.uppercased()).font(.system(size: 8.5, weight: .bold)).tracking(0.7).foregroundStyle(TornTheme.blue)
            Text(guide.title).font(.system(size: 13, weight: .bold)).foregroundStyle(TornTheme.text)
            if !guide.body.isEmpty { Text(guide.body).font(.system(size: 11)).foregroundStyle(TornTheme.muted) }
            if !guide.authorName.isEmpty { Text("Published by \(guide.authorName)").font(.system(size: 9.5)).foregroundStyle(TornTheme.gold2) }
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TornTheme.panel3.opacity(0.4), in: RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(TornTheme.lineSoft))
    }
}

private struct StarterGuide: View {
    let eyebrow: String
    let title: String
    let text: String
    let accent: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(eyebrow).font(.system(size: 8.5, weight: .bold)).tracking(0.7).foregroundStyle(accent)
            Text(title).font(.system(size: 13, weight: .bold)).foregroundStyle(TornTheme.text)
            Text(text).font(.system(size: 11)).foregroundStyle(TornTheme.muted)
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TornTheme.panel3.opacity(0.35), in: RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(accent.opacity(0.3)))
    }
}
