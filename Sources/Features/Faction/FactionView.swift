import SwiftUI

struct FactionView: View {
    private let destinations = [
        FeatureDestination(title: "Faction Chat", subtitle: "TornFCA native faction community chat.", systemImage: "bubble.left.and.bubble.right.fill"),
        FeatureDestination(title: "Announcements", subtitle: "Faction notices and important updates.", systemImage: "megaphone.fill"),
        FeatureDestination(title: "Overview & Directory", subtitle: "Faction overview, member directory and shared resources.", systemImage: "person.3.sequence.fill"),
        FeatureDestination(title: "Resources", subtitle: "Faction guides and useful references.", systemImage: "books.vertical.fill"),
        FeatureDestination(title: "Faction Tools", subtitle: "OC, chain and strength-intel tools.", systemImage: "wrench.and.screwdriver.fill"),
        FeatureDestination(title: "Voting", subtitle: "Faction polls and verified ballots.", systemImage: "checkmark.circle.fill")
    ]

    var body: some View {
        FeatureListView(title: "Faction", eyebrow: nil, destinations: destinations)
    }
}
