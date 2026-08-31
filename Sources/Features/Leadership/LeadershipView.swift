import SwiftUI

struct LeadershipView: View {
    private let destinations = [
        FeatureDestination(title: "Needs Attention", subtitle: "Leadership items that need action first.", systemImage: "exclamationmark.triangle.fill"),
        FeatureDestination(title: "People & Activity", subtitle: "Activity tracker, faction pulse and member dossiers.", systemImage: "person.2.fill"),
        FeatureDestination(title: "War & Intel", subtitle: "Spy intel, strength intel and war payouts.", systemImage: "binoculars.fill"),
        FeatureDestination(title: "Finance & Assets", subtitle: "Banking, cache market advisor and armory auditing.", systemImage: "banknote.fill"),
        FeatureDestination(title: "Faction Admin", subtitle: "Announcements, training, reports and moderation.", systemImage: "gearshape.2.fill")
    ]

    var body: some View {
        FeatureListView(title: "Leadership", eyebrow: "Verified authority required", destinations: destinations)
    }
}
