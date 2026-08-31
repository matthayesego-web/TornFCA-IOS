import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var appState: AppState
    @State private var apiKey = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Torn API key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("Verify & Continue") {
                        Task { await appState.signIn(apiKey: apiKey) }
                    }
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } header: {
                    Text("Connect Torn")
                } footer: {
                    Text("Your API key is verified directly with Torn and stored in the iOS Keychain on this device. TornFCA does not need your Torn password.")
                }

                if let error = appState.lastError {
                    Section("Couldn’t connect") {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("TornFCA")
        }
    }
}
