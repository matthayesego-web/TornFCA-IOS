import SwiftUI

enum CommandSection: String, CaseIterable, Identifiable {
    case home = "Home"
    case faction = "Faction"
    case war = "War"
    case leadership = "Leadership"
    case more = "More"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .faction: return "person.3.fill"
        case .war: return "shield.fill"
        case .leadership: return "star.fill"
        case .more: return "ellipsis.circle.fill"
        }
    }
}

struct CommandShellView: View {
    let session: AuthSession
    @State private var selected: CommandSection = .home

    private var sections: [CommandSection] {
        session.hasLeadershipWorkspace
            ? [.home, .faction, .war, .leadership, .more]
            : [.home, .faction, .war, .more]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        brandBar
                        identityHero
                        page
                    }
                    .padding(.horizontal, 13)
                    .padding(.top, 7)
                    .padding(.bottom, 22)
                }
                .scrollIndicators(.hidden)
                .background(TornTheme.background)

                bottomNavigation
            }
            .background(TornTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: FeatureRoute.self) { route in
                LiveFeatureRouteView(route: route, session: session)
            }
        }
        .tint(TornTheme.gold2)
        .preferredColorScheme(.dark)
    }

    private var brandBar: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [TornTheme.panel3, Color.rgb(20, 14, 43)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(TornTheme.gold.opacity(0.7)))
                Text("T").font(.system(size: 20, weight: .black)).foregroundStyle(TornTheme.gold2)
            }
            .frame(width: 38, height: 38)

            Text("TORNFCA")
                .font(.system(size: 13.5, weight: .bold))
                .tracking(2.4)
                .foregroundStyle(TornTheme.gold2)
            Spacer()
            NavigationLink(value: FeatureRoute.alerts) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(TornTheme.gold2)
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 7)
    }

    private var identityHero: some View {
        HStack(spacing: 13) {
            ZStack {
                Circle().fill(TornTheme.panel3)
                Circle().stroke(TornTheme.gold, lineWidth: 2)
                Text(String(session.playerName.prefix(1)).uppercased())
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(TornTheme.gold2)
            }
            .frame(width: 92, height: 92)

            VStack(alignment: .leading, spacing: 5) {
                Text("iOS DEVELOPMENT • v0.2.0")
                    .font(.system(size: 9.5, weight: .bold))
                    .tracking(1.1)
                    .foregroundStyle(TornTheme.purple2)
                Text(session.playerName)
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(TornTheme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("\(session.factionName)  •  \(session.position)")
                    .font(.system(size: 12.5))
                    .foregroundStyle(TornTheme.muted)
                    .lineLimit(2)
                Text(session.hasLeadershipWorkspace ? "LEADERSHIP VERIFIED" : "TORN VERIFIED")
                    .font(.system(size: 10.5, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(session.hasLeadershipWorkspace ? TornTheme.gold2 : TornTheme.blue)
                    .padding(.top, 2)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.down")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(TornTheme.purple2)
                .frame(width: 30)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color.rgb(15, 21, 31), Color.rgb(8, 12, 22), Color.rgb(20, 14, 43)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(TornTheme.gold.opacity(0.75)))
        .shadow(color: .black.opacity(0.28), radius: 8, y: 5)
        .padding(.bottom, 18)
    }

    @ViewBuilder private var page: some View {
        switch selected {
        case .home: HomeCommandPage()
        case .faction: FactionCommandPage()
        case .war: WarCommandPage()
        case .leadership: LeadershipCommandPage(session: session)
        case .more: MoreCommandPage()
        }
    }

    private var bottomNavigation: some View {
        HStack(spacing: 5) {
            ForEach(sections) { section in
                Button {
                    withAnimation(.easeOut(duration: 0.14)) { selected = section }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: section.icon)
                            .font(.system(size: 23, weight: .semibold))
                        Text(section.rawValue)
                            .font(.system(size: 9.2, weight: selected == section ? .bold : .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(selected == section ? TornTheme.gold2 : TornTheme.muted)
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .background(
                        selected == section
                            ? AnyShapeStyle(LinearGradient(colors: [Color.rgb(62, 44, 23), Color.rgb(31, 24, 21)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.clear),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(selected == section ? TornTheme.gold : .clear))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(section.rawValue)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 7)
        .padding(.bottom, 7)
        .background(
            LinearGradient(colors: [Color.rgb(12, 14, 28), Color.rgb(5, 9, 15)], startPoint: .top, endPoint: .bottom)
        )
        .overlay(Rectangle().fill(TornTheme.line).frame(height: 1), alignment: .top)
    }
}
