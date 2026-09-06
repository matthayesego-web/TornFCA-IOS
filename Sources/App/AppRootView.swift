import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        switch appState.session {
        case .loading:
            ZStack {
                Color(red: 3/255, green: 6/255, blue: 10/255).ignoresSafeArea()
                ProgressView("Connecting to Torn…")
                    .tint(.white)
                    .foregroundStyle(.white)
            }
        case .signedOut:
            SignInView()
        case .signedIn(let session):
            RootTabView(profile: session.profile)
        }
    }
}
