import SwiftUI

struct WarView: View {
    private let destinations = [
        FeatureDestination(title: "Ranked War / WAR//OS", subtitle: "Command HUD, tactical forecast and full war report.", systemImage: "scope"),
        FeatureDestination(title: "Chain Status", subtitle: "Live chain state and protection timing.", systemImage: "link"),
        FeatureDestination(title: "Territories", subtitle: "Faction territory status and context.", systemImage: "map.fill"),
        FeatureDestination(title: "My War Prep", subtitle: "Personal preparation and war-readiness guidance.", systemImage: "shield.checkered")
    ]

    var body: some View {
        FeatureListView(title: "War", eyebrow: "WAR//OS", destinations: destinations)
    }
}
