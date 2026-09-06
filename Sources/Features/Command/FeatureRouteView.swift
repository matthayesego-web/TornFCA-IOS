import SwiftUI

struct FeatureRouteView: View {
    let route: FeatureRoute
    let session: AuthSession

    var body: some View {
        switch route {
        case .leadershipPeople:
            LeadershipGroupView(title: "People & Activity", subtitle: "Member review and faction participation tools.", accent: TornTheme.purple, rows: [
                ("Activity Tracker", "Faction-wide participation and activity scan", "Open", "person.3.fill", TornTheme.purple, .activityTracker),
                ("Faction Pulse", "Member health, inactivity and availability at a glance", "Pulse", "waveform.path.ecg", TornTheme.gold, .factionPulse),
                ("Member Dossier", "Leadership member lookup and research", "Lookup", "person.text.rectangle", TornTheme.blue, .memberDossier)
            ])
        case .leadershipWarIntel:
            LeadershipGroupView(title: "War & Intel", subtitle: "Official spies, strength estimates and Ranked War payout analysis.", accent: TornTheme.red, rows: [
                ("Spy Intel", "Official Torn faction stat reports with full/partial spy labels", "Spies", "scope", TornTheme.purple, .spyIntel),
                ("Faction Strength Intel", "Optional FFScouter estimates and strength comparison", "Intel", "chart.bar.fill", TornTheme.blue, .strengthIntel),
                ("War Payout Calculator", "Completed Ranked War participation and payout calculation", "Payout", "banknote.fill", TornTheme.red, .warPayout)
            ])
        case .leadershipFinance:
            LeadershipGroupView(title: "Finance & Assets", subtitle: "Banking, Ranked War cache valuation and armory control.", accent: TornTheme.green, rows: [
                ("Banking", "Faction payout requests and leadership queue", "Banking", "building.columns.fill", TornTheme.blue, .banking),
                ("RW Cache Market Advisor", "Compare war reward caches with current market and trader leads", "Advisor", "shippingbox.fill", TornTheme.gold, .cacheAdvisor),
                ("Armory Auditor", "Audit armory items, member totals, deposits and restocks", "Audit", "archivebox.fill", TornTheme.green, .armory)
            ])
        case .factionAdmin:
            LeadershipGroupView(title: "Faction Admin", subtitle: "Publishing, training administration and community moderation.", accent: TornTheme.blue, rows: [
                ("Faction Announcements", "Publish or manage current faction notices", "Manage", "megaphone.fill", TornTheme.gold, .announcements),
                ("Guide & Training Management", "Publish faction-scoped guides and training expectations", "Manage", "book.closed.fill", TornTheme.purple, .trainingAdmin),
                ("Reports & Moderation", "Review faction chat reports and moderation queue", "Review", "exclamationmark.shield.fill", TornTheme.red, .moderation)
            ])
        case .settings:
            SettingsCommandView(session: session)
        case .about:
            AboutCommandView()
        case .legal:
            LegalCommandView()
        default:
            CommandFeatureStatusView(route: route)
        }
    }
}

private struct LeadershipGroupView: View {
    let title: String
    let subtitle: String
    let accent: Color
    let rows: [(String, String, String, String, Color, FeatureRoute)]

    var body: some View {
        CommandDetailScaffold(title: title, eyebrow: "LEADERSHIP", subtitle: subtitle, accent: accent) {
            CommandPanel(title: title, subtitle: "Focused leadership workspace") {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    CommandActionRow(title: row.0, subtitle: row.1, value: row.2, icon: row.3, accent: row.4, route: row.5)
                }
            }
        }
    }
}

struct CommandDetailScaffold<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let eyebrow: String
    let subtitle: String
    let accent: Color
    @ViewBuilder let content: Content

    init(title: String, eyebrow: String, subtitle: String, accent: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.eyebrow = eyebrow
        self.subtitle = subtitle
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Button { dismiss() } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundStyle(TornTheme.text)
                        .padding(.horizontal, 14)
                        .frame(height: 42)
                        .background(TornTheme.panel2, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(TornTheme.line))
                }
                .buttonStyle(.plain)
                Text(eyebrow)
                    .font(.system(size: 9.5, weight: .bold))
                    .tracking(1.3)
                    .foregroundStyle(accent)
                Text(title)
                    .font(.system(size: 31, weight: .bold))
                    .foregroundStyle(TornTheme.text)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(TornTheme.muted)
                content
                CommandFooter()
            }
            .padding(16)
        }
        .background(TornTheme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct CommandFeatureStatusView: View {
    let route: FeatureRoute

    var descriptor: (String, String, Color, String) {
        switch route {
        case .myDay: return ("My Day", "Personal readiness and daily Torn status.", TornTheme.green, "LIVE DATA PORT IN PROGRESS")
        case .training: return ("Training & Progress", "Battle-stat and Xanax baseline tracking plus faction guides.", TornTheme.purple, "ANDROID PARITY MAPPED")
        case .warPrep: return ("My War Prep", "Personal readiness checklist for Ranked War.", TornTheme.gold, "ANDROID PARITY MAPPED")
        case .alerts: return ("Notification Inbox", "Faction notices and TornFCA alerts.", TornTheme.blue, "PUSH BACKEND NOT WIRED")
        case .factionChat: return ("Faction Chat", "TornFCA native General / War / OC / Leadership channels.", TornTheme.blue, "COMMUNITY BACKEND NOT WIRED")
        case .factionOverview: return ("Faction Overview", "Member-safe faction status, OC, chain and war readiness.", TornTheme.gold, "LIVE DATA PORT IN PROGRESS")
        case .directory: return ("Faction Directory", "Search the current faction roster.", TornTheme.purple, "LIVE DATA PORT IN PROGRESS")
        case .voting: return ("Faction Voting", "Whole faction, leadership, member and split-chamber polls.", TornTheme.green, "VOTING BACKEND NOT WIRED")
        case .resources: return ("Faction Resources", "Faction rules, guides and reference material.", TornTheme.blue, "CONTENT BACKEND NOT WIRED")
        case .announcements: return ("Faction Announcements", "Current faction notices and authorized publishing.", TornTheme.gold, "COMMUNITY BACKEND NOT WIRED")
        case .organizedCrime: return ("My Organized Crime", "Your current OC assignment and readiness.", TornTheme.green, "LIVE DATA PORT IN PROGRESS")
        case .chain: return ("Chain Status", "Current chain context and participation.", TornTheme.gold, "LIVE DATA PORT IN PROGRESS")
        case .strengthIntel: return ("Faction Strength Intel", "Optional FFScouter estimates and comparison.", TornTheme.purple, "PROVIDER INTEGRATION NOT WIRED")
        case .rankedWar: return ("Ranked War", "Current matchup, score, timing and completed-war history.", TornTheme.red, "LIVE DATA PORT IN PROGRESS")
        case .territories: return ("Territories", "Walls, assaults and territory status.", TornTheme.gold, "ANDROID PARITY MAPPED")
        case .needsAttention: return ("Needs Attention", "Inactivity, war gaps, OC gaps and availability exceptions.", TornTheme.gold, "LEADERSHIP DATA PORT PENDING")
        case .activityTracker: return ("Activity Tracker", "Faction-wide participation and activity scan.", TornTheme.purple, "LEADERSHIP DATA PORT PENDING")
        case .factionPulse: return ("Faction Pulse", "Member health, inactivity and availability.", TornTheme.gold, "LEADERSHIP DATA PORT PENDING")
        case .memberDossier: return ("Member Dossier", "Leadership member lookup and research.", TornTheme.blue, "LEADERSHIP DATA PORT PENDING")
        case .spyIntel: return ("Spy Intel", "Official Torn faction stat reports with completeness labels.", TornTheme.purple, "LEADERSHIP DATA PORT PENDING")
        case .warPayout: return ("War Payout Calculator", "Completed Ranked War participation and payout calculation.", TornTheme.red, "WRITE FLOW NOT WIRED")
        case .banking: return ("Banking", "Faction payout requests and leadership queue.", TornTheme.blue, "SHARED BANKING BACKEND NOT WIRED")
        case .cacheAdvisor: return ("RW Cache Market Advisor", "Reward cache valuation and trader context.", TornTheme.gold, "MARKET PROVIDERS NOT WIRED")
        case .armory: return ("Armory Auditor", "Audit armory items, member totals, deposits and restocks.", TornTheme.green, "LEADERSHIP DATA PORT PENDING")
        case .trainingAdmin: return ("Guide & Training Management", "Faction-scoped guides and training expectations.", TornTheme.purple, "CONTENT BACKEND NOT WIRED")
        case .moderation: return ("Reports & Moderation", "Faction chat reports and moderation queue.", TornTheme.red, "COMMUNITY BACKEND NOT WIRED")
        case .premium: return ("Premium", "Personal Premium and Faction Premium remain separate products.", TornTheme.gold, "ENTITLEMENT BACKEND NOT WIRED")
        case .feedback: return ("Feedback & Requests", "Bug reports, feature requests and usability notes.", TornTheme.purple, "FEEDBACK BACKEND NOT WIRED")
        case .leadershipPeople, .leadershipWarIntel, .leadershipFinance, .factionAdmin, .settings, .legal, .about:
            return ("TornFCA", "Command workspace", TornTheme.blue, "")
        }
    }

    var body: some View {
        let item = descriptor
        CommandDetailScaffold(title: item.0, eyebrow: "TORNFCA • iOS", subtitle: item.1, accent: item.2) {
            CommandPanel(title: "Implementation Status", subtitle: "This destination is preserved so iOS stays structurally aligned with Android while backend behavior is ported safely.") {
                Text(item.3)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(item.2)
                Text("A visible destination is not treated as proof that its protected backend action is available. Torn/backend authorization remains authoritative.")
                    .font(.system(size: 11.5))
                    .foregroundStyle(TornTheme.muted)
            }
        }
    }
}

private struct SettingsCommandView: View {
    @EnvironmentObject private var appState: AppState
    let session: AuthSession

    var body: some View {
        CommandDetailScaffold(title: "Settings", eyebrow: "TORNFCA • iOS", subtitle: "Account, privacy and local app controls.", accent: TornTheme.gold) {
            CommandPanel(title: "Signed-in Torn Account", subtitle: "Identity is verified directly with Torn") {
                Text("\(session.playerName) [\(session.playerID)]")
                    .font(.system(size: 15, weight: .bold)).foregroundStyle(TornTheme.text)
                Text("\(session.factionName) • \(session.position)")
                    .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                Text(session.accessLabel)
                    .font(.system(size: 11, weight: .semibold)).foregroundStyle(TornTheme.gold2)
            }
            Button(role: .destructive) { appState.signOut() } label: {
                Text("Sign Out & Remove Local API Key")
                    .font(.system(size: 13, weight: .bold))
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(TornTheme.red)
        }
    }
}

private struct LegalCommandView: View {
    var body: some View {
        CommandDetailScaffold(title: "Legal & Privacy", eyebrow: "TORNFCA • PRIVACY", subtitle: "Local-first credentials and explicit backend boundaries.", accent: TornTheme.blue) {
            CommandPanel(title: "API Key Privacy", subtitle: "Current iOS architecture") {
                Text("Your Torn API key is stored in the iOS Keychain on this device. It is sent to Torn for authenticated Torn API requests and is not committed to source control.")
                    .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
            }
            CommandPanel(title: "Authority", subtitle: "Premium never grants faction authority") {
                Text("Leadership visibility is derived from Torn faction position abilities. Protected endpoints and shared backends remain the final authority for privileged actions.")
                    .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
            }
        }
    }
}

private struct AboutCommandView: View {
    var body: some View {
        CommandDetailScaffold(title: "About Torn FCA", eyebrow: "TORNFCA • iOS", subtitle: "Native iOS companion for the TornFCA platform.", accent: TornTheme.blue) {
            CommandPanel(title: "Development Build", subtitle: "v0.2.0-dev") {
                Text("Android is the canonical mobile product reference. This iOS build is being brought to behavioral and visual parity with the same information architecture and permission rules.")
                    .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
            }
        }
    }
}
