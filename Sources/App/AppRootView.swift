import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        switch appState.session {
        case .loading:
            ProgressView("Connecting to Torn…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .signedOut:
            SignInView()
        case .signedIn(let profile):
            RootTabView(profile: profile)
        }
    }
}
