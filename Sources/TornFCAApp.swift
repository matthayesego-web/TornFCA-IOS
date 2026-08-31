import SwiftUI

@main
struct TornFCAApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
                .task {
                    await appState.restoreSessionIfNeeded()
                }
        }
    }
}
