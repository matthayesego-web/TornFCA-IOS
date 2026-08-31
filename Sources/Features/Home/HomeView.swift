import SwiftUI

struct HomeView: View {
    let profile: TornProfile

    private let destinations = [
        FeatureDestination(title: "My Day", subtitle: "Your immediate TornFCA command view.", systemImage: "sun.max.fill"),
        FeatureDestination(title: "Training & Progress", subtitle: "Training guidance, progress and faction resources.", systemImage: "chart.line.uptrend.xyaxis"),
        FeatureDestination(title: "Notification Inbox", subtitle: "Faction, war and platform updates in one place.", systemImage: "bell.fill")
    ]

    var body: some View {
        FeatureListView(title: "Home", eyebrow: "Welcome, \(profile.name)", destinations: destinations)
    }
}
