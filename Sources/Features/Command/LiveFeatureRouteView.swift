import SwiftUI

struct LiveFeatureRouteView: View {
    let route: FeatureRoute
    let session: AuthSession

    var body: some View {
        switch route {
        case .factionChat:
            FactionChatLiveView(session: session)
        case .training:
            TrainingCenterLiveView(session: session)
        case .resources:
            FactionResourcesLiveView(session: session)
        case .warPrep:
            WarPrepLiveView(session: session)
        default:
            FeatureRouteView(route: route, session: session)
        }
    }
}
