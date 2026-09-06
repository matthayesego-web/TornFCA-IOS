import Foundation

@MainActor
final class AppState: ObservableObject {
    enum SessionState: Equatable {
        case loading
        case signedOut
        case signedIn(AuthSession)
    }

    @Published private(set) var session: SessionState = .loading
    @Published private(set) var lastError: String?

    var canOpenLeadershipWorkspace: Bool {
        guard case .signedIn(let session) = session else { return false }
        return session.hasLeadershipWorkspace
    }

    private let keychain = KeychainStore()
    private let api = TornAPIClient.shared
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
        Task { await api.clearMemoryCache() }
        lastError = nil
        session = .signedOut
    }

    func storedAPIKey() -> String? {
        try? keychain.readAPIKey()
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
            let verified = try await api.authenticate(trimmed)
            if persistOnSuccess { try keychain.saveAPIKey(trimmed) }
            session = .signedIn(verified)
        } catch {
            lastError = error.localizedDescription
            session = .signedOut
        }
    }
}
