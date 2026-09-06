import SwiftUI

enum TornTheme {
    static let background = Color.rgb(3, 6, 10)
    static let background2 = Color.rgb(6, 10, 16)
    static let panel = Color.rgb(10, 16, 24)
    static let panel2 = Color.rgb(13, 20, 31)
    static let panel3 = Color.rgb(18, 26, 39)
    static let line = Color.rgb(43, 55, 74)
    static let lineSoft = Color.rgb(26, 35, 49)
    static let text = Color.rgb(246, 247, 250)
    static let muted = Color.rgb(149, 160, 179)
    static let steel = Color.rgb(112, 128, 151)
    static let gold = Color.rgb(238, 185, 83)
    static let gold2 = Color.rgb(255, 214, 132)
    static let purple = Color.rgb(147, 89, 246)
    static let purple2 = Color.rgb(180, 120, 255)
    static let green = Color.rgb(78, 190, 129)
    static let red = Color.rgb(226, 91, 100)
    static let blue = Color.rgb(84, 151, 222)
}

extension Color {
    static func rgb(_ red: Double, _ green: Double, _ blue: Double, alpha: Double = 1) -> Color {
        Color(.sRGB, red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha)
    }
}

struct CommandSectionHeading: View {
    let title: String
    let subtitle: String
    let accent: Color

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accent)
                .frame(width: 4, height: 38)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(TornTheme.text)
                Text(subtitle)
                    .font(.system(size: 12.5))
                    .foregroundStyle(TornTheme.muted)
            }
            Spacer(minLength: 0)
        }
    }
}

struct CommandQuickTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let route: FeatureRoute

    var body: some View {
        NavigationLink(value: route) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 28, height: 28)
                Text(title)
                    .font(.system(size: 13.2, weight: .bold))
                    .foregroundStyle(TornTheme.text)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 10.2))
                    .foregroundStyle(TornTheme.muted)
                    .lineLimit(1)
                Text("→")
                    .font(.system(size: 17))
                    .foregroundStyle(accent)
            }
            .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
            .padding(13)
            .background(
                LinearGradient(colors: [TornTheme.panel2, TornTheme.panel], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 17, style: .continuous)
            )
            .overlay(RoundedRectangle(cornerRadius: 17).stroke(TornTheme.line.opacity(0.75), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct CommandDuoTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let route: FeatureRoute

    var body: some View {
        NavigationLink(value: route) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.system(size: 13.3, weight: .bold)).foregroundStyle(TornTheme.text).lineLimit(1)
                    Text(subtitle).font(.system(size: 10.2)).foregroundStyle(TornTheme.muted).lineLimit(1)
                }
                Spacer(minLength: 4)
                Text("›").font(.system(size: 23)).foregroundStyle(accent)
            }
            .padding(.horizontal, 13)
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(
                LinearGradient(colors: [TornTheme.panel2, TornTheme.panel], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 17, style: .continuous)
            )
            .overlay(RoundedRectangle(cornerRadius: 17).stroke(accent.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct CommandFeaturedPanel: View {
    let badge: String
    let title: String
    let bodyText: String
    let button: String
    let accent: Color
    let route: FeatureRoute

    var body: some View {
        NavigationLink(value: route) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [Color.rgb(20, 16, 43), TornTheme.panel2, TornTheme.panel],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadarArt(accent: accent)
                    .opacity(0.65)
                VStack(alignment: .leading, spacing: 0) {
                    Text(badge)
                        .font(.system(size: 9.5, weight: .bold))
                        .tracking(1.3)
                        .foregroundStyle(TornTheme.purple2)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.rgb(70, 35, 126, alpha: 0.48), in: RoundedRectangle(cornerRadius: 7))
                        .overlay(RoundedRectangle(cornerRadius: 7).stroke(TornTheme.purple2.opacity(0.5)))
                    Text(title)
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(TornTheme.text)
                        .padding(.top, 11)
                    Text(bodyText)
                        .font(.system(size: 12))
                        .foregroundStyle(TornTheme.muted)
                        .lineLimit(3)
                        .frame(maxWidth: 245, alignment: .leading)
                        .padding(.top, 6)
                    HStack {
                        Text(button)
                        Text("→")
                    }
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(TornTheme.text)
                    .frame(maxWidth: 220, minHeight: 44)
                    .background(
                        LinearGradient(colors: [Color.rgb(76, 40, 145), Color.rgb(52, 29, 109)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(accent.opacity(0.8)))
                    .padding(.top, 14)
                }
                .padding(17)
            }
            .frame(maxWidth: .infinity, minHeight: 210, alignment: .topLeading)
            .background(TornTheme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(accent.opacity(0.55)))
        }
        .buttonStyle(.plain)
    }
}

private struct RadarArt: View {
    let accent: Color
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach([70.0, 120.0, 176.0], id: \.self) { diameter in
                    Circle().stroke(accent.opacity(0.18), lineWidth: 1).frame(width: diameter, height: diameter)
                }
                Rectangle().fill(accent.opacity(0.12)).frame(width: 1, height: 185)
                Rectangle().fill(accent.opacity(0.12)).frame(width: 185, height: 1)
            }
            .position(x: proxy.size.width * 0.79, y: proxy.size.height * 0.52)
        }
        .allowsHitTesting(false)
    }
}

struct CommandPanel<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(TornTheme.text)
            Text(subtitle).font(.system(size: 11)).foregroundStyle(TornTheme.muted)
            content
        }
        .padding(14)
        .background(
            LinearGradient(colors: [TornTheme.panel2, TornTheme.panel], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(TornTheme.line, lineWidth: 1))
    }
}

struct CommandActionRow: View {
    let title: String
    let subtitle: String
    let value: String
    let icon: String
    let accent: Color
    let route: FeatureRoute

    var body: some View {
        NavigationLink(value: route) {
            HStack(spacing: 11) {
                Image(systemName: icon).font(.system(size: 22)).foregroundStyle(accent).frame(width: 26)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 13.5, weight: .bold)).foregroundStyle(TornTheme.text).lineLimit(1)
                    Text(subtitle).font(.system(size: 10.5)).foregroundStyle(TornTheme.muted).lineLimit(2)
                }
                Spacer(minLength: 6)
                Text(value).font(.system(size: 11.5, weight: .bold)).foregroundStyle(accent).lineLimit(1)
                Text("›").font(.system(size: 24)).foregroundStyle(TornTheme.steel)
            }
            .padding(.horizontal, 13)
            .frame(maxWidth: .infinity, minHeight: 68)
            .background(TornTheme.panel3.opacity(0.35), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(TornTheme.lineSoft))
        }
        .buttonStyle(.plain)
    }
}

struct CommandMetricTile: View {
    let eyebrow: String
    let center: String
    let title: String
    let detail: String
    let accent: Color
    let route: FeatureRoute

    var body: some View {
        NavigationLink(value: route) {
            VStack(spacing: 5) {
                Text(eyebrow).font(.system(size: 8.2, weight: .bold)).tracking(0.7).foregroundStyle(accent).lineLimit(1)
                ZStack {
                    Circle().stroke(TornTheme.line, lineWidth: 4)
                    Circle().trim(from: 0, to: 0.72).stroke(accent, style: StrokeStyle(lineWidth: 4, lineCap: .round)).rotationEffect(.degrees(-90))
                    Text(center).font(.system(size: 10, weight: .bold)).foregroundStyle(TornTheme.text).lineLimit(1).minimumScaleFactor(0.65)
                }
                .frame(width: 56, height: 56)
                Text(title).font(.system(size: 10.7, weight: .bold)).foregroundStyle(TornTheme.text).lineLimit(1)
                Text(detail).font(.system(size: 8.8)).foregroundStyle(TornTheme.muted).lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 112)
            .padding(.vertical, 8)
            .background(
                LinearGradient(colors: [TornTheme.panel2, TornTheme.panel], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(accent.opacity(0.45)))
        }
        .buttonStyle(.plain)
    }
}

struct CommandFooter: View {
    var body: some View {
        Text("TornFCA iOS • Development • Android-parity build")
            .font(.system(size: 10.5))
            .foregroundStyle(TornTheme.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}
