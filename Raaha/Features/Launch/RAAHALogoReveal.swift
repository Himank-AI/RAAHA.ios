import SwiftUI

/// The app icon, shown whole, then the wordmark and tagline beneath it.
/// The artwork is the asset catalog mark. It is not redrawn.
struct RAAHALogoReveal: View {
    var sample: LaunchSample

    var body: some View {
        ZStack {
            logo
                .scaleEffect(sample.logoScale)
                .opacity(sample.logoOpacity)
            wordmark
                .offset(y: 116)
            tagline
                .offset(y: 156)
        }
        .accessibilityHidden(true)
    }

    private var logo: some View {
        Image("RAAHALogo")
            .resizable()
            .scaledToFit()
            .frame(width: 86, height: 86)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay { sweep }
            .shadow(color: Color.oceanic001D39.opacity(0.30), radius: 10, y: 6)
    }

    private var sweep: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [Color.clear, Color.white.opacity(0.55), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: geo.size.width * 0.28)
            .rotationEffect(.degrees(16))
            .offset(x: -geo.size.width * 0.55 + geo.size.width * 1.4 * sample.sweep)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
            .blendMode(.screen)
            .opacity(sample.sweepStrength)
        }
        .mask {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
        }
        .allowsHitTesting(false)
    }

    private var wordmark: some View {
        Text("RAAHA")
            .font(.system(size: 36, weight: .black, design: .rounded))
            .tracking(1.8)
            .foregroundStyle(Color.white)
            .shadow(color: Color.oceanic001D39.opacity(0.35), radius: 8, y: 3)
            .opacity(sample.wordmark * (1 - sample.dissolve))
            .offset(y: (1 - sample.wordmark) * 8)
    }

    private var tagline: some View {
        Text("EVERY JOURNEY, CONNECTED.")
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .tracking(2.1)
            .lineLimit(1)
            .foregroundStyle(Color.white.opacity(0.86))
            .opacity(sample.tagline * (1 - sample.dissolve))
            .offset(y: (1 - sample.tagline) * 6)
    }
}
