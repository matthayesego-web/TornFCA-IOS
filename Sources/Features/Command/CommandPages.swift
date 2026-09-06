import SwiftUI

enum FeatureRoute: String, Hashable {
    case myDay, training, warPrep, alerts
    case factionChat, factionOverview, directory, voting, resources, announcements, organizedCrime, chain, strengthIntel
    case rankedWar, territories
    case needsAttention, leadershipPeople, leadershipWarIntel, leadershipFinance, factionAdmin
    case activityTracker, factionPulse, memberDossier, spyIntel, warPayout, banking, cacheAdvisor, armory, trainingAdmin, moderation
    case settings, premium, feedback, legal, about
}

struct HomeCommandPage: View {
    var body: some View {
        VStack(spacing: 14) {
            CommandSectionHeading(title: "Command Center", subtitle: "Your personal starting point. Faction, warfare and leadership now have dedicated homes.", accent: TornTheme.gold)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                CommandQuickTile(title: "My Day", subtitle: "Daily snapshot", icon: "calendar", accent: TornTheme.green, route: .myDay)
                CommandQuickTile(title: "Training", subtitle: "Progress & guides", icon: "chart.line.uptrend.xyaxis", accent: TornTheme.purple, route: .training)
                CommandQuickTile(title: "War Prep", subtitle: "Get ready", icon: "shield.fill", accent: TornTheme.gold, route: .warPrep)
                CommandQuickTile(title: "Alerts", subtitle: "Inbox", icon: "bell.fill", accent: TornTheme.blue, route: .alerts)
            }
            CommandFeaturedPanel(
                badge: "FEATURED",
                title: "My Day",
                bodyText: "Bars, cooldowns, organized crime, chain and warfare readiness in one personal command view.",
                button: "Open My Day",
                accent: TornTheme.purple,
                route: .myDay
            )
            CommandPanel(title: "Personal Shortcuts", subtitle: "Every tile opens a focused personal tool") {
                HStack(spacing: 8) {
                    CommandMetricTile(eyebrow: "TODAY", center: "OPEN", title: "My Day", detail: "Daily view", accent: TornTheme.green, route: .myDay)
                    CommandMetricTile(eyebrow: "TRAIN", center: "GO", title: "Training", detail: "Progress", accent: TornTheme.purple, route: .training)
                    CommandMetricTile(eyebrow: "ALERTS", center: "INBOX", title: "Notifications", detail: "Review", accent: TornTheme.blue, route: .alerts)
                }
            }
            CommandFooter()
        }
    }
}

struct FactionCommandPage: View {
    var body: some View {
        VStack(spacing: 14) {
            CommandSectionHeading(title: "Faction", subtitle: "Communication, roster information and shared faction tools.", accent: TornTheme.purple)
            CommandFeaturedPanel(
                badge: "FACTION CHAT",
                title: "Faction Chat",
                bodyText: "Your single normal chat entry point. Torn Chat remains available from inside the chat screen.",
                button: "Open Faction Chat",
                accent: TornTheme.blue,
                route: .factionChat
            )
            VStack(spacing: 9) {
                CommandDuoTile(title: "Overview", subtitle: "Faction status", icon: "person.3.fill", accent: TornTheme.gold, route: .factionOverview)
                CommandDuoTile(title: "Directory", subtitle: "Search roster", icon: "magnifyingglass", accent: TornTheme.purple, route: .directory)
                CommandDuoTile(title: "Voting", subtitle: "Faction decisions", icon: "checkmark.seal.fill", accent: TornTheme.green, route: .voting)
                CommandDuoTile(title: "Resources", subtitle: "Rules & guides", icon: "book.closed.fill", accent: TornTheme.blue, route: .resources)
                CommandDuoTile(title: "Announcements", subtitle: "Faction notices", icon: "megaphone.fill", accent: TornTheme.gold, route: .announcements)
            }
            CommandPanel(title: "Faction Tools", subtitle: "Shared status and intelligence without duplicating chat") {
                CommandActionRow(title: "My Organized Crime", subtitle: "Your OC assignment and readiness", value: "OC", icon: "person.2.badge.gearshape.fill", accent: TornTheme.green, route: .organizedCrime)
                CommandActionRow(title: "Chain Status", subtitle: "Current chain context and participation", value: "Chain", icon: "link", accent: TornTheme.gold, route: .chain)
                CommandActionRow(title: "Faction Strength Intel", subtitle: "Optional FFScouter strength estimates", value: "Intel", icon: "scope", accent: TornTheme.purple, route: .strengthIntel)
            }
            CommandFooter()
        }
    }
}

struct WarCommandPage: View {
    var body: some View {
        VStack(spacing: 14) {
            CommandSectionHeading(title: "War", subtitle: "Ranked War, chain, territories and personal readiness stay together.", accent: TornTheme.red)
            CommandFeaturedPanel(
                badge: "RANKED WAR",
                title: "Ranked War Command",
                bodyText: "Current matchup, score, timing, participation, opponent intel and completed-war history.",
                button: "Open Ranked War",
                accent: TornTheme.red,
                route: .rankedWar
            )
            VStack(spacing: 9) {
                CommandDuoTile(title: "Ranked War", subtitle: "Matchup & score", icon: "shield.fill", accent: TornTheme.red, route: .rankedWar)
                CommandDuoTile(title: "Chain Status", subtitle: "Current chain", icon: "link", accent: TornTheme.gold, route: .chain)
                CommandDuoTile(title: "Territories", subtitle: "Walls & assaults", icon: "map.fill", accent: TornTheme.gold, route: .territories)
                CommandDuoTile(title: "War Prep", subtitle: "Personal readiness", icon: "checklist", accent: TornTheme.green, route: .warPrep)
            }
            CommandFooter()
        }
    }
}

struct LeadershipCommandPage: View {
    let session: AuthSession

    var body: some View {
        VStack(spacing: 14) {
            CommandSectionHeading(title: "Leadership", subtitle: "Leadership-only work is grouped by job instead of mixed into member pages.", accent: TornTheme.gold)
            if session.canAttention {
                CommandFeaturedPanel(
                    badge: "PRIORITY",
                    title: "Needs Attention",
                    bodyText: "Review inactivity, war gaps, OC gaps and availability exceptions that may need leadership action.",
                    button: "Review Attention",
                    accent: TornTheme.gold,
                    route: .needsAttention
                )
            }
            VStack(spacing: 9) {
                if session.canPeopleActivity {
                    CommandDuoTile(title: "People & Activity", subtitle: "Members & participation", icon: "person.3.fill", accent: TornTheme.purple, route: .leadershipPeople)
                }
                if session.canWarIntel || session.canWarPayout {
                    CommandDuoTile(title: "War & Intel", subtitle: "Opponent research & payouts", icon: "scope", accent: TornTheme.red, route: .leadershipWarIntel)
                }
                if session.canBanking || session.canCacheAdvisor || session.canArmory {
                    CommandDuoTile(title: "Finance & Assets", subtitle: "Banking, caches, armory", icon: "banknote.fill", accent: TornTheme.green, route: .leadershipFinance)
                }
                if session.canFactionAdmin {
                    CommandDuoTile(title: "Faction Admin", subtitle: "Publishing & moderation", icon: "gearshape.2.fill", accent: TornTheme.blue, route: .factionAdmin)
                }
            }
            CommandPanel(title: "Verified Access", subtitle: "UI visibility mirrors Torn abilities; protected endpoints remain authoritative") {
                Text(session.accessLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TornTheme.gold2)
                if !session.abilities.isEmpty {
                    Text(session.abilities.joined(separator: " • "))
                        .font(.system(size: 10.5))
                        .foregroundStyle(TornTheme.muted)
                }
            }
            CommandFooter()
        }
    }
}

struct MoreCommandPage: View {
    var body: some View {
        VStack(spacing: 14) {
            CommandSectionHeading(title: "More", subtitle: "Settings, alerts, feedback, privacy and optional app services.", accent: TornTheme.blue)
            VStack(spacing: 9) {
                CommandDuoTile(title: "Settings", subtitle: "Preferences", icon: "gearshape.fill", accent: TornTheme.gold, route: .settings)
                CommandDuoTile(title: "Alerts", subtitle: "Notification inbox", icon: "bell.fill", accent: TornTheme.blue, route: .alerts)
                CommandDuoTile(title: "Premium", subtitle: "Optional extras", icon: "sparkles", accent: TornTheme.gold, route: .premium)
                CommandDuoTile(title: "Feedback", subtitle: "Bugs & requests", icon: "bubble.left.and.exclamationmark.bubble.right.fill", accent: TornTheme.purple, route: .feedback)
            }
            CommandPanel(title: "App & Privacy", subtitle: "Less-frequent app controls and information") {
                CommandActionRow(title: "Feedback & Requests", subtitle: "Send a bug report, feature request or usability note", value: "Send", icon: "bubble.left.fill", accent: TornTheme.purple, route: .feedback)
                CommandActionRow(title: "Legal & Privacy", subtitle: "Privacy Policy, Terms, EULA and acknowledgement", value: "Review", icon: "lock.shield.fill", accent: TornTheme.blue, route: .legal)
                CommandActionRow(title: "About Torn FCA", subtitle: "Version, privacy approach and third-party services", value: "About", icon: "info.circle.fill", accent: TornTheme.blue, route: .about)
            }
            CommandFooter()
        }
    }
}
