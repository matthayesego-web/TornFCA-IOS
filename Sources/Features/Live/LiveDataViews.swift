import SwiftUI

struct MyDayLiveView: View {
    @EnvironmentObject private var appState: AppState
    let session: AuthSession
    @State private var snapshot: MyDaySnapshot?
    @State private var error: String?
    @State private var loading = true

    var body: some View {
        CommandDetailScaffold(title: "My Day", eyebrow: "FACTION COMPANION • MEMBER", subtitle: "\(session.factionName) • \(session.playerName)", accent: TornTheme.green) {
            if loading { LoadingCommandCard(text: "Building your personal readiness snapshot…", accent: TornTheme.blue) }
            else if let error { ErrorCommandCard(message: error) { Task { await load() } } }
            else if let snapshot {
                CommandPanel(title: "What Should I Do Next?", subtitle: "Generated from the Torn data currently available") {
                    Text(snapshot.priority).font(.system(size: 16, weight: .bold)).foregroundStyle(TornTheme.text)
                }

                if !snapshot.bars.isEmpty {
                    CommandPanel(title: "Personal Readiness", subtitle: "Bars refreshed when My Day opens") {
                        ForEach(snapshot.bars) { bar in BarCommandRow(bar: bar) }
                    }
                }

                if let cooldowns = snapshot.cooldowns {
                    CommandPanel(title: "Cooldowns", subtitle: "Current Torn cooldown timers") {
                        Text("Drug: \(WarSummary.duration(cooldowns.drug))  •  Medical: \(WarSummary.duration(cooldowns.medical))  •  Booster: \(WarSummary.duration(cooldowns.booster))")
                            .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                    }
                }

                if let travel = snapshot.travel {
                    CommandPanel(title: "Traveling to \(travel.destination)", subtitle: "Current travel status") {
                        Text("\(travel.method) • ETA in \(WarSummary.duration(travel.timeLeft))")
                            .font(.system(size: 12)).foregroundStyle(TornTheme.gold2)
                    }
                }

                CommandPanel(title: snapshot.organizedCrime.assigned ? "My OC — \(snapshot.organizedCrime.name)" : "My OC", subtitle: "Your assignment only") {
                    Text(snapshot.organizedCrime.summary).font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                }

                if let balance = snapshot.factionBalance {
                    CommandPanel(title: "My Faction Balance", subtitle: "Only your own faction balance is shown here") {
                        Text("Money: \(money(balance.money))")
                            .font(.system(size: 15, weight: .bold)).foregroundStyle(TornTheme.green)
                        Text("Points: \(balance.points.formatted())")
                            .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                    }
                }

                WarStatusCommandCard(war: snapshot.war)
                ChainStatusCommandCard(chain: snapshot.chain)
            }
        }
        .task { await load() }
    }

    private func load() async {
        loading = true; error = nil
        guard let key = appState.storedAPIKey(), !key.isEmpty else { error = "Reconnect your Torn API key to use My Day."; loading = false; return }
        do { snapshot = try await TornLiveDataService.shared.loadMyDay(apiKey: key, session: session) }
        catch { self.error = error.localizedDescription }
        loading = false
    }

    private func money(_ value: Int64) -> String {
        value.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }
}

struct FactionOverviewLiveView: View {
    @EnvironmentObject private var appState: AppState
    let session: AuthSession
    @State private var snapshot: FactionOverviewSnapshot?
    @State private var error: String?
    @State private var loading = true

    var body: some View {
        CommandDetailScaffold(title: "Faction Overview", eyebrow: "TORNFCA • MEMBER VIEW", subtitle: "\(session.factionName) • signed-in member scope", accent: TornTheme.gold) {
            if loading { LoadingCommandCard(text: "Loading current faction status…", accent: TornTheme.blue) }
            else if let error { ErrorCommandCard(message: error) { Task { await load() } } }
            else if let snapshot {
                CommandPanel(title: "Today", subtitle: "Current member-safe faction readiness") {
                    let attention = (!snapshot.organizedCrime.assigned ? 1 : 0) + (snapshot.war.isLive() ? 1 : 0)
                    Text(attention == 0 ? "✓ You're clear right now" : "! \(attention) item\(attention == 1 ? "" : "s") may need attention")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(attention == 0 ? TornTheme.green : TornTheme.gold2)
                }
                CommandPanel(title: "My OC", subtitle: "Your current assignment") {
                    Text(snapshot.organizedCrime.summary).font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                }
                WarStatusCommandCard(war: snapshot.war)
                ChainStatusCommandCard(chain: snapshot.chain)
                CommandPanel(title: "While You Were Away", subtitle: "Current-state digest") {
                    Text("Live status is generated from current Torn data. Persistent cross-device history will come from the shared backend rather than being guessed locally.")
                        .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        loading = true; error = nil
        guard let key = appState.storedAPIKey(), !key.isEmpty else { error = "Reconnect your Torn API key to continue."; loading = false; return }
        do { snapshot = try await TornLiveDataService.shared.loadFactionOverview(apiKey: key, session: session) }
        catch { self.error = error.localizedDescription }
        loading = false
    }
}

struct FactionDirectoryLiveView: View {
    @EnvironmentObject private var appState: AppState
    let session: AuthSession
    @State private var members: [FactionMemberRow] = []
    @State private var query = ""
    @State private var error: String?
    @State private var loading = true

    private var filtered: [FactionMemberRow] {
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return members }
        return members.filter { $0.name.localizedCaseInsensitiveContains(clean) || $0.position.localizedCaseInsensitiveContains(clean) || String($0.id).contains(clean) }
    }

    var body: some View {
        CommandDetailScaffold(title: "Faction Directory", eyebrow: "TORNFCA • ROSTER", subtitle: "\(session.factionName) • current Torn roster", accent: TornTheme.purple) {
            TextField("Search name, ID or position", text: $query)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 14).frame(height: 46)
                .background(TornTheme.panel2, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(TornTheme.line))
                .foregroundStyle(TornTheme.text)
            if loading { LoadingCommandCard(text: "Loading faction roster…", accent: TornTheme.purple) }
            else if let error { ErrorCommandCard(message: error) { Task { await load() } } }
            else {
                CommandPanel(title: "Members", subtitle: "\(filtered.count) of \(members.count) shown") {
                    ForEach(filtered) { member in
                        HStack(spacing: 10) {
                            ZStack {
                                Circle().fill(TornTheme.panel3)
                                Text(String(member.name.prefix(1)).uppercased()).font(.system(size: 13, weight: .bold)).foregroundStyle(TornTheme.purple2)
                            }.frame(width: 36, height: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(member.name) [\(member.id)]").font(.system(size: 12.5, weight: .bold)).foregroundStyle(TornTheme.text)
                                Text("\(member.position) • \(member.status)").font(.system(size: 10.5)).foregroundStyle(TornTheme.muted)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 7)
                        if member.id != filtered.last?.id { Divider().overlay(TornTheme.lineSoft) }
                    }
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        loading = true; error = nil
        guard let key = appState.storedAPIKey(), !key.isEmpty else { error = "Reconnect your Torn API key to continue."; loading = false; return }
        do { members = try await TornLiveDataService.shared.loadFactionDirectory(apiKey: key) }
        catch { self.error = error.localizedDescription }
        loading = false
    }
}

struct RankedWarLiveView: View {
    @EnvironmentObject private var appState: AppState
    let session: AuthSession
    @State private var snapshot: RankedWarSnapshot?
    @State private var error: String?
    @State private var loading = true

    var body: some View {
        CommandDetailScaffold(title: "Ranked War", eyebrow: "TORNFCA • RANKED WAR", subtitle: "\(session.factionName) • readiness, live command, opponent intelligence, participation and history.", accent: TornTheme.red) {
            if loading { LoadingCommandCard(text: "Building your ranked-war workspace…", accent: TornTheme.red) }
            else if let error { ErrorCommandCard(message: error) { Task { await load() } } }
            else if let snapshot {
                WarStatusCommandCard(war: snapshot.current)
                if snapshot.current.present && (snapshot.current.isLive() || snapshot.current.isUpcoming()) {
                    CommandPanel(title: "WAR//OS", subtitle: "Tactical Forecast integration boundary") {
                        Text("The iOS command surface is reserved and follows Android's placement. WAR//OS will only unlock after Personal/Faction Premium entitlement parity and protected leadership authorization are wired.")
                            .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                    }
                }
                CommandPanel(title: "War Workspace", subtitle: "Prepare, coordinate and review") {
                    CommandActionRow(title: "War Prep", subtitle: "Personal readiness checklist", value: "Prep", icon: "checklist", accent: TornTheme.green, route: .warPrep)
                    CommandActionRow(title: "Chain Status", subtitle: "Current faction chain", value: "Chain", icon: "link", accent: TornTheme.gold, route: .chain)
                    if snapshot.current.present {
                        CommandActionRow(title: "Opponent Intel", subtitle: snapshot.current.opponent, value: "Intel", icon: "scope", accent: TornTheme.blue, route: .strengthIntel)
                    }
                    if session.canWarPayout {
                        CommandActionRow(title: "Ranked War Payout", subtitle: "Participation-based payout workflow", value: "WarPay", icon: "banknote.fill", accent: TornTheme.gold, route: .warPayout)
                    }
                }
                CommandPanel(title: "Recent Ranked Wars", subtitle: "Latest completed wars returned by Torn") {
                    if snapshot.history.isEmpty {
                        Text("No completed ranked-war history returned.").font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                    } else {
                        ForEach(snapshot.history) { war in WarHistoryRow(war: war, factionID: session.factionID) }
                    }
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        loading = true; error = nil
        guard let key = appState.storedAPIKey(), !key.isEmpty else { error = "Reconnect your Torn API key to use Ranked War."; loading = false; return }
        do { snapshot = try await TornLiveDataService.shared.loadRankedWar(apiKey: key, session: session) }
        catch { self.error = error.localizedDescription }
        loading = false
    }
}

struct OrganizedCrimeLiveView: View {
    @EnvironmentObject private var appState: AppState
    let session: AuthSession
    @State private var summary: OrganizedCrimeSummary?
    @State private var error: String?

    var body: some View {
        CommandDetailScaffold(title: "My Organized Crime", eyebrow: "TORNFCA • OC", subtitle: "Your current Torn OC assignment only.", accent: TornTheme.green) {
            if let error { ErrorCommandCard(message: error) { Task { await load() } } }
            else if let summary {
                CommandPanel(title: summary.assigned ? summary.name : "No Current OC", subtitle: summary.assigned ? "Current assignment" : "Member status") {
                    Text(summary.summary).font(.system(size: 13)).foregroundStyle(TornTheme.muted)
                    if summary.readyAt > 0 { Text("Ready: \(Date(timeIntervalSince1970: TimeInterval(summary.readyAt)).formatted(date: .abbreviated, time: .shortened))").font(.system(size: 11.5)).foregroundStyle(TornTheme.gold2) }
                }
            } else { LoadingCommandCard(text: "Checking your OC assignment…", accent: TornTheme.green) }
        }
        .task { await load() }
    }

    private func load() async {
        guard let key = appState.storedAPIKey() else { error = "Reconnect your Torn API key."; return }
        do { summary = try await TornLiveDataService.shared.loadOrganizedCrime(apiKey: key, playerID: session.playerID) }
        catch { self.error = error.localizedDescription }
    }
}

struct ChainLiveView: View {
    @EnvironmentObject private var appState: AppState
    let session: AuthSession
    @State private var chain: ChainSummary?
    @State private var loaded = false
    @State private var error: String?

    var body: some View {
        CommandDetailScaffold(title: "Chain Status", eyebrow: "TORNFCA • CHAIN", subtitle: "\(session.factionName) • current faction chain", accent: TornTheme.gold) {
            if let error { ErrorCommandCard(message: error) { Task { await load() } } }
            else if loaded { ChainStatusCommandCard(chain: chain) }
            else { LoadingCommandCard(text: "Checking current chain…", accent: TornTheme.gold) }
        }
        .task { await load() }
    }

    private func load() async {
        guard let key = appState.storedAPIKey() else { error = "Reconnect your Torn API key."; loaded = true; return }
        do { chain = try await TornLiveDataService.shared.loadChain(apiKey: key) }
        catch { self.error = error.localizedDescription }
        loaded = true
    }
}

private struct BarCommandRow: View {
    let bar: BarSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(bar.label).font(.system(size: 11.5, weight: .bold)).foregroundStyle(TornTheme.text)
                Spacer()
                Text("\(bar.current) / \(bar.maximum)").font(.system(size: 10.5, weight: .semibold)).foregroundStyle(TornTheme.muted)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(TornTheme.lineSoft)
                    Capsule().fill(TornTheme.blue).frame(width: max(0, proxy.size.width * bar.fraction))
                }
            }.frame(height: 7)
        }
        .padding(.vertical, 4)
    }
}

struct WarStatusCommandCard: View {
    let war: WarSummary
    private var accent: Color {
        if !war.present { return TornTheme.green }
        if war.isLive() { return TornTheme.red }
        if war.isUpcoming() { return TornTheme.gold }
        return TornTheme.muted
    }
    var body: some View {
        CommandPanel(title: war.headline(), subtitle: "Ranked War status") {
            Text(war.detail()).font(.system(size: 13)).foregroundStyle(TornTheme.muted)
            if war.present && war.isLive() {
                Text("\(war.ourScore)  –  \(war.opponentScore)")
                    .font(.system(size: 28, weight: .black)).foregroundStyle(accent)
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(accent.opacity(0.55)))
    }
}

struct ChainStatusCommandCard: View {
    let chain: ChainSummary?
    var body: some View {
        CommandPanel(title: "Chain Status", subtitle: "Current Torn faction chain") {
            if let chain {
                Text(chain.active ? "ACTIVE CHAIN" : "No active chain")
                    .font(.system(size: 11, weight: .bold)).tracking(0.7)
                    .foregroundStyle(chain.active ? TornTheme.green : TornTheme.muted)
                Text("Current: \(chain.current) / \(chain.maximum)  •  Timeout: \(chain.timeout)s")
                    .font(.system(size: 12.5)).foregroundStyle(TornTheme.muted)
            } else {
                Text("No active chain returned by Torn.").font(.system(size: 12)).foregroundStyle(TornTheme.muted)
            }
        }
    }
}

private struct WarHistoryRow: View {
    let war: WarHistoryItem
    let factionID: Int
    var body: some View {
        let result = war.result(for: factionID)
        let accent: Color = result == "WIN" ? TornTheme.green : result == "LOSS" ? TornTheme.red : TornTheme.muted
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(war.opponent).font(.system(size: 13, weight: .bold)).foregroundStyle(TornTheme.text)
                Spacer()
                Text(result).font(.system(size: 10.5, weight: .bold)).foregroundStyle(accent)
            }
            Text("Final \(war.ourScore) – \(war.opponentScore)" + (war.end > 0 ? " • \(Date(timeIntervalSince1970: TimeInterval(war.end)).formatted(date: .abbreviated, time: .omitted))" : ""))
                .font(.system(size: 10.5)).foregroundStyle(TornTheme.muted)
        }
        .padding(.vertical, 7)
    }
}

struct LoadingCommandCard: View {
    let text: String
    let accent: Color
    var body: some View {
        HStack(spacing: 12) {
            ProgressView().tint(accent)
            Text(text).font(.system(size: 13, weight: .semibold)).foregroundStyle(TornTheme.text)
            Spacer()
        }
        .padding(16)
        .background(TornTheme.panel, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(accent.opacity(0.45)))
    }
}

struct ErrorCommandCard: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DATA UNAVAILABLE").font(.system(size: 9.5, weight: .bold)).tracking(1).foregroundStyle(TornTheme.red)
            Text(message).font(.system(size: 12.5)).foregroundStyle(TornTheme.text)
            Button("Retry", action: retry).buttonStyle(.borderedProminent).tint(TornTheme.gold)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TornTheme.panel, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(TornTheme.red.opacity(0.55)))
    }
}
