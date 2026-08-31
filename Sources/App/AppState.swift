import Foundation

@MainActor
final class AppState: ObservableObject {
    enum SessionState: Equatable {
        case loading
        case signedOut
        case signedIn(TornProfile)
    }

    @Published private(set) var session: SessionState = .loading
    @Published private(set) var lastError: String?

    // This must eventually be resolved from real Torn/backend authority.
    // It is deliberately false in the bootstrap so UI visibility never becomes a security boundary.
    @Published private(set) var canOpenLeadershipWorkspace = false

    private let keychain = KeychainStore()
    private let api = TornAPIClient()
    private var didAttemptRestore = false

    func restoreSessionIfNeeded() async {
        guard !didAttemptRestore else { return }
        didAttemptRestore = true

        guard let apiKey = try? keychain.readAPIKey(), !apiKey.isEmpty else {
            session = .signedOut
            return
        }

        await authenticate(apiKey: apiKey, persistOnSuccess: false)
    }

    func signIn(apiKey: String) async {
        await authenticate(apiKey: apiKey, persistOnSuccess: true)
    }

    func signOut() {
        try? keychain.deleteAPIKey()
        canOpenLeadershipWorkspace = false
        lastError = nil
        session = .signedOut
    }

    private func authenticate(apiKey: String, persistOnSuccess: Bool) async {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            lastError = "Enter a Torn API key."
            session = .signedOut
            return
        }

        session = .loading
        lastError = nil

        do {
            let profile = try await api.verifyAPIKey(trimmed)
            if persistOnSuccess {
                try keychain.saveAPIKey(trimmed)
            }
            session = .signedIn(profile)
        } catch {
            lastError = error.localizedDescription
            session = .signedOut
        }
    }
}
