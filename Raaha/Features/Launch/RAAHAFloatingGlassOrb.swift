import SwiftUI

/// A glass portal, not a glowing ball. Volume comes from a shaded sphere,
/// a clear material, a rim light, and a slow reflection.
struct RAAHAFloatingGlassOrb: View {
    var sample: LaunchSample

    private var portalScale: CGFloat {
        let formed = 0.86 + 0.14 * sample.orb
        return formed * (1 + sample.veil * 2.4)
    }

    private var portalOpacity: CGFloat {
        min(sample.orb * 3, 1) * (1 - min(sample.veil * 1.25, 1))
    }

    var body: some View {
        ZStack {
            ripple
            sphere
        }
        .frame(width: 168, height: 168)
        .scaleEffect(portalScale)
        .opacity(portalOpacity)
        .accessibilityHidden(true)
    }

    private var ripple: some View {
        ZStack {
            Circle()
                .stroke(Color.oceanic7BBDE8.opacity(0.45 * (1 - sample.ripple)), lineWidth: 1.2)
                .scaleEffect(0.7 + sample.ripple * 1.8)
            Circle()
                .stroke(Color.white.opacity(0.35 * (1 - sample.ripple)), lineWidth: 0.8)
                .scaleEffect(0.55 + sample.ripple * 2.3)
        }
        .opacity(sample.ripple > 0.02 ? 1 : 0)
    }

    private var sphere: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color.oceanic001D39.opacity(0.28), Color.clear],
                        center: .center,
                        startRadius: 4,
                        endRadius: 54
                    )
                )
                .frame(width: 112, height: 18)
                .offset(y: 86)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            Color.oceanic7BBDE8.opacity(0.22),
                            Color.oceanic0A4174.opacity(0.45)
                        ],
                        center: UnitPoint(x: 0.38, y: 0.30),
                        startRadius: 4,
                        endRadius: 110
                    )
                )

            glassBody

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.90),
                            Color.white.opacity(0.18),
                            Color.oceanic7BBDE8.opacity(0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.3
                )

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.70), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 26
                    )
                )
                .frame(width: 52, height: 22)
                .rotationEffect(.degrees(-24))
                .offset(x: -26, y: -40)

            Ellipse()
                .fill(Color.white.opacity(0.14))
                .frame(width: 78, height: 14)
                .rotationEffect(.degrees(sin(sample.seconds * 0.55) * 14))
                .offset(y: -8)
                .mask(Circle())
        }
        .rotation3DEffect(
            .degrees(sin(sample.seconds * 0.45) * 6),
            axis: (x: 0.1, y: 1, z: 0),
            perspective: 0.7
        )
        .shadow(color: Color.oceanic001D39.opacity(0.22), radius: 14, y: 12)
    }

    @ViewBuilder
    private var glassBody: some View {
        if #available(iOS 26, *) {
            Circle()
                .fill(Color.clear)
                .glassEffect(.clear.tint(Color.oceanic7BBDE8.opacity(0.18)), in: Circle())
        } else {
            Circle().fill(.ultraThinMaterial)
            Circle().fill(Color.white.opacity(0.06))
        }
    }
}
