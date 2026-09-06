import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState
    let profile: TornProfile

    var body: some View {
        if case .signedIn(let session) = appState.session {
            CommandShellView(session: session)
        } else {
            Color.clear
        }
    }
}
