import SwiftUI

/// Miniature coastal city. Distant silhouettes, the existing Chennai illustration
/// as a tilted diorama, and a foreground shore, all under one slow camera push.
struct RAAHACityEnvironment: View {
    var sample: LaunchSample

    var body: some View {
        ZStack {
            RAAHACityLayer(role: .sky, sample: sample)
            RAAHACityLayer(role: .light, sample: sample)
            RAAHACityLayer(role: .clouds, sample: sample)
            RAAHACityLayer(role: .skyline, sample: sample)
            RAAHACityLayer(role: .diorama, sample: sample)
            RAAHACityLayer(role: .coast, sample: sample)
            RAAHACityLayer(role: .fog, sample: sample)
        }
        .scaleEffect(1 + sample.camera * 0.10, anchor: UnitPoint(x: 0.50, y: 0.42))
        .opacity(1 - sample.veil)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// One depth plane of the opening city.
struct RAAHACityLayer: View {
    enum Role {
        case sky, light, clouds, skyline, diorama, coast, fog
    }

    var role: Role
    var sample: LaunchSample

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            switch role {
            case .sky:
                sky(size)
            case .light:
                light(size)
            case .clouds:
                clouds(size)
            case .skyline:
                skyline(size)
            case .diorama:
                diorama(size)
            case .coast:
                coast(size)
            case .fog:
                fog(size)
            }
        }
        .allowsHitTesting(false)
    }

    private func sky(_ size: CGSize) -> some View {
        LinearGradient(
            stops: [
                .init(color: Color.oceanic001D39, location: 0.00),
                .init(color: Color.oceanic0A4174, location: 0.34),
                .init(color: Color.oceanic4E8EA2, location: 0.62),
                .init(color: Color.oceanic7BBDE8, location: 0.84),
                .init(color: Color(hex: 0xD5EFE6), location: 1.00)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: size.width, height: size.height)
        .opacity(sample.awaken)
    }

    private func light(_ size: CGSize) -> some View {
        ZStack {
            RadialGradient(
                colors: [Color.white.opacity(0.75), Color.oceanic7BBDE8.opacity(0.28), Color.clear],
                center: UnitPoint(x: 0.50, y: 0.36),
                startRadius: 6,
                endRadius: min(size.width, size.height) * 0.46
            )
            RadialGradient(
                colors: [Color(hex: 0xF4E4C8).opacity(0.32), Color.clear],
                center: UnitPoint(x: 0.74, y: 0.58),
                startRadius: 8,
                endRadius: size.width * 0.42
            )
            .opacity(sample.city)
        }
        .frame(width: size.width, height: size.height)
        .opacity(sample.awaken)
        .scaleEffect(0.72 + sample.awaken * 0.28, anchor: UnitPoint(x: 0.5, y: 0.38))
    }

    private func clouds(_ size: CGSize) -> some View {
        let drift = CGFloat(sample.seconds) * 4
        return ZStack {
            cloudBank
                .position(x: size.width * 0.24 + drift, y: size.height * 0.13)
            cloudBank
                .scaleEffect(1.25)
                .position(x: size.width * 0.72 - drift * 0.5, y: size.height * 0.09)
        }
        .frame(width: size.width, height: size.height)
        .opacity(sample.awaken * 0.55)
    }

    private var cloudBank: some View {
        ZStack {
            Ellipse().frame(width: 78, height: 26)
            Ellipse().frame(width: 58, height: 30).offset(x: 28, y: 2)
            Ellipse().frame(width: 46, height: 22).offset(x: -26, y: 4)
        }
        .foregroundStyle(Color.white.opacity(0.14))
    }

    private func skyline(_ size: CGSize) -> some View {
        Canvas { context, canvasSize in
            let reveal = sample.city
            let base = canvasSize.height * 0.56
            let towers: [(CGFloat, CGFloat, CGFloat)] = [
                (0.04, 16, 64), (0.10, 22, 108), (0.17, 14, 78),
                (0.24, 28, 146), (0.33, 18, 96), (0.40, 12, 70),
                (0.62, 20, 120), (0.70, 30, 168), (0.80, 16, 88),
                (0.87, 24, 132), (0.95, 14, 72)
            ]
            for tower in towers {
                let height = tower.2 * reveal
                let rect = CGRect(
                    x: tower.0 * canvasSize.width,
                    y: base - height + sample.camera * 18,
                    width: tower.1,
                    height: height
                )
                let path = Path(roundedRect: rect, cornerRadius: 2)
                context.fill(path, with: .color(Color.oceanic6EA2B3.opacity(0.30)))
                if tower.2 > 100 {
                    let crown = CGRect(
                        x: rect.midX - rect.width * 0.28,
                        y: rect.minY - tower.2 * 0.16 * reveal,
                        width: rect.width * 0.56,
                        height: tower.2 * 0.18 * reveal
                    )
                    context.fill(Path(roundedRect: crown, cornerRadius: 1.5), with: .color(Color.oceanic7BBDE8.opacity(0.28)))
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .opacity(sample.city)
    }

    private func diorama(_ size: CGSize) -> some View {
        CityDiorama(camera: sample.camera, reveal: sample.city)
            .frame(width: size.width, height: size.height)
    }

    private func coast(_ size: CGSize) -> some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.oceanic7BBDE8.opacity(0.05),
                            Color.oceanic7BBDE8.opacity(0.34),
                            Color(hex: 0xE7F6F1).opacity(0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size.width * 1.4, height: size.height * 0.22)
                .position(x: size.width * 0.5, y: size.height * 0.96)
        }
        .frame(width: size.width, height: size.height)
        .offset(y: sample.camera * -16)
        .opacity(sample.city * 0.95)
    }

    private func fog(_ size: CGSize) -> some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.00),
                .init(color: Color.oceanicBDD8E9.opacity(0.05), location: 0.30),
                .init(color: Color.white.opacity(0.28), location: 0.52),
                .init(color: Color.oceanicBDD8E9.opacity(0.10), location: 0.74),
                .init(color: .clear, location: 1.00)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: size.width, height: size.height)
        .opacity(sample.awaken * (0.90 - sample.city * 0.62))
    }
}

/// The existing Chennai illustration, set into the scene as a small tilted model.
private struct CityDiorama: View {
    var camera: CGFloat
    var reveal: CGFloat

    var body: some View {
        GeometryReader { geo in
            plate(width: geo.size.width, height: geo.size.height)
                .rotation3DEffect(
                    .degrees(16 - Double(camera) * 5),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .bottom,
                    perspective: 0.55
                )
                .scaleEffect(1 + camera * 0.06, anchor: .bottom)
                .position(x: geo.size.width * 0.50, y: geo.size.height * 0.66)
                .opacity(reveal)
        }
    }

    private func plate(width: CGFloat, height: CGFloat) -> some View {
        Image("transit_illustration")
            .resizable()
            .scaledToFill()
            .frame(width: width * 1.08, height: height * 0.46)
            .clipped()
            .mask(fade)
            .mask(sideFade)
            .shadow(color: Color.oceanic001D39.opacity(0.20), radius: 18, y: 10)
    }

    private var sideFade: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.00),
                .init(color: .black, location: 0.16),
                .init(color: .black, location: 0.84),
                .init(color: .clear, location: 1.00)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var fade: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.00),
                .init(color: .black.opacity(0.35), location: 0.10),
                .init(color: .black, location: 0.28),
                .init(color: .black, location: 0.78),
                .init(color: .black.opacity(0.4), location: 0.90),
                .init(color: .clear, location: 1.00)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
