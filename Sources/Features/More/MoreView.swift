import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var appState: AppState
    let profile: TornProfile

    private let destinations = [
        FeatureDestination(title: "Settings", subtitle: "App, notification and privacy preferences.", systemImage: "gearshape.fill"),
        FeatureDestination(title: "Notification Inbox", subtitle: "Review recent TornFCA updates.", systemImage: "bell.fill"),
        FeatureDestination(title: "Premium", subtitle: "Entitlements remain tied to verified Torn identity.", systemImage: "crown.fill"),
        FeatureDestination(title: "Feedback & Requests", subtitle: "Send beta feedback and track its status.", systemImage: "text.bubble.fill"),
        FeatureDestination(title: "Legal & Privacy", subtitle: "Privacy, permissions and platform disclosures.", systemImage: "hand.raised.fill"),
        FeatureDestination(title: "About", subtitle: "Version, Beta Founder and Special Thanks information.", systemImage: "info.circle.fill")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.title2.bold())
                    Text("Level \(profile.level) • Torn ID \(profile.id)")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(destinations) { destination in
                    NavigationLink {
                        FeaturePlaceholderView(destination: destination)
                    } label: {
                        HStack {
                            Label(destination.title, systemImage: destination.systemImage)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                Button(role: .destructive) {
                    appState.signOut()
                } label: {
                    Label("Disconnect Torn account", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("More")
    }
}
