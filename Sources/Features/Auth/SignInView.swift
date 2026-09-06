import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var appState: AppState
    @State private var apiKey = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Spacer(minLength: 40)
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(LinearGradient(colors: [TornTheme.panel3, Color.rgb(20, 14, 43)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(RoundedRectangle(cornerRadius: 22).stroke(TornTheme.gold, lineWidth: 1.5))
                    Text("T").font(.system(size: 44, weight: .black)).foregroundStyle(TornTheme.gold2)
                }
                .frame(width: 96, height: 96)
                Text("TORNFCA")
                    .font(.system(size: 25, weight: .black))
                    .tracking(4)
                    .foregroundStyle(TornTheme.text)
                Text("FACTION COMMAND • iOS DEVELOPMENT")
                    .font(.system(size: 9.5, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(TornTheme.purple2)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Connect Torn")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(TornTheme.text)
                    Text("Use the same Torn API-key model as Android. TornFCA does not need your Torn password.")
                        .font(.system(size: 12.5))
                        .foregroundStyle(TornTheme.muted)

                    SecureField("16-character Torn API key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(TornTheme.text)
                        .padding(.horizontal, 14)
                        .frame(height: 50)
                        .background(TornTheme.background2, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(TornTheme.line))

                    Button {
                        Task { await appState.signIn(apiKey: apiKey) }
                    } label: {
                        Text("Verify & Continue  →")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(TornTheme.text)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                LinearGradient(colors: [Color.rgb(76, 40, 145), Color.rgb(52, 29, 109)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(TornTheme.purple2.opacity(0.75)))
                    }
                    .buttonStyle(.plain)
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)

                    Text("Your API key is verified directly with Torn and stored in the iOS Keychain on this device.")
                        .font(.system(size: 10.5))
                        .foregroundStyle(TornTheme.muted)

                    if let error = appState.lastError {
                        Text(error)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(TornTheme.red)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(TornTheme.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(TornTheme.red.opacity(0.45)))
                    }
                }
                .padding(18)
                .background(
                    LinearGradient(colors: [TornTheme.panel2, TornTheme.panel], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(TornTheme.line))
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 18)
        }
        .background(TornTheme.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}
