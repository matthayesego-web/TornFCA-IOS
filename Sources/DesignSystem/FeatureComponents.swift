import SwiftUI

struct FeatureDestination: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

struct FeatureListView: View {
    let title: String
    let eyebrow: String?
    let destinations: [FeatureDestination]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                ForEach(destinations) { destination in
                    NavigationLink {
                        FeaturePlaceholderView(destination: destination)
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: destination.systemImage)
                                .font(.title3)
                                .frame(width: 34, height: 34)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(destination.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(destination.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle(title)
    }
}

struct FeaturePlaceholderView: View {
    let destination: FeatureDestination

    var body: some View {
        ContentUnavailableView {
            Label(destination.title, systemImage: destination.systemImage)
        } description: {
            Text("Mapped from Android and reserved in the iOS architecture. Implementation will land feature-by-feature without changing the shared permission model.")
        }
        .navigationTitle(destination.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
