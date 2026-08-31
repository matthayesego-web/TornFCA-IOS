import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState
    let profile: TornProfile

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(profile: profile)
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                FactionView()
            }
            .tabItem { Label("Faction", systemImage: "person.3.fill") }

            NavigationStack {
                WarView()
            }
            .tabItem { Label("War", systemImage: "shield.lefthalf.filled") }

            if appState.canOpenLeadershipWorkspace {
                NavigationStack {
                    LeadershipView()
                }
                .tabItem { Label("Leadership", systemImage: "star.circle.fill") }
            }

            NavigationStack {
                MoreView(profile: profile)
            }
            .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
        }
    }
}
