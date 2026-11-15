import SwiftUI

/// Elevated metro plus the ground routes that later meet at the glass portal.
struct RAAHATransportAnimation: View {
    var sample: LaunchSample

    var body: some View {
        ZStack {
            RAAHAMetroViaduct(sample: sample)
            RAAHAAnimatedRouteNetwork(sample: sample)
        }
        .scaleEffect(1 + sample.camera * 0.10, anchor: UnitPoint(x: 0.50, y: 0.42))
        .opacity(sample.networkOpacity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// A quiet elevated line. The train crosses once; a purple trail follows it.
private struct RAAHAMetroViaduct: View {
    var sample: LaunchSample

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let route = LaunchRoute.metro
            let drawn = route.drawAmount(sample.metro)
            ZStack {
                LaunchCurve(start: route.start, control: route.control, end: route.end)
                    .trim(from: 0, to: drawn)
                    .stroke(route.color.opacity(0.85), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                if drawn > 0.06 {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .shadow(color: route.color.opacity(0.9), radius: 6)
                        .position(route.point(at: max(drawn - 0.04, 0.02), in: size))
                        .opacity(1 - sample.logo)
                }
            }
        }
    }
}

/// Ground routes for bus, auto, walk, local train, bike, and cab.
struct RAAHAAnimatedRouteNetwork: View {
    var sample: LaunchSample

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                ForEach(LaunchRoute.ground) { route in
                    let drawn = route.drawAmount(sample.routeDraw)
                    if drawn > 0.01 {
                        routeStroke(route, amount: drawn)
                        Circle()
                            .fill(route.darkCore ? Color.white : route.color)
                            .frame(width: 6, height: 6)
                            .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 0.8))
                            .scaleEffect(min(drawn * 4, 1))
                            .position(route.point(at: 0, in: size))
                    }
                }
                RouteLightTrail(sample: sample)
                ForEach(LaunchRoute.ground) { route in
                    let drawn = route.drawAmount(sample.routeDraw)
                    let traveled = min(route.drawAmount(sample.travel), drawn)
                    MovingTransportIcon(
                        route: route,
                        progress: traveled,
                        opacity: traveled > 0.04 ? (1 - sample.logo) : 0,
                        size: size
                    )
                }
            }
        }
    }

    private func routeStroke(_ route: LaunchRoute, amount: CGFloat) -> some View {
        let curve = LaunchCurve(start: route.start, control: route.control, end: route.end)
            .trim(from: 0, to: amount)
        return ZStack {
            if route.darkCore {
                curve.stroke(Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 3.6, lineCap: .round))
            } else {
                curve.stroke(route.color.opacity(0.28), style: StrokeStyle(lineWidth: 6, lineCap: .round))
            }
            curve.stroke(route.color, style: StrokeStyle(lineWidth: 2.1, lineCap: .round))
        }
    }
}

/// Two lights trailing each moving icon. Kept few on purpose.
private struct RouteLightTrail: View {
    var sample: LaunchSample

    var body: some View {
        Canvas { context, size in
            let fade = 1 - sample.logo
            guard fade > 0.04 else { return }
            for route in LaunchRoute.ground {
                let head = min(route.drawAmount(sample.travel), route.drawAmount(sample.routeDraw))
                guard head > 0.06 else { continue }
                for index in 0..<2 {
                    let at = head - CGFloat(index) * 0.05
                    guard at > 0 else { continue }
                    let point = route.point(at: at, in: size)
                    let radius = 2.6 - CGFloat(index) * 0.7
                    let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
                    let tint = route.darkCore ? Color.white : route.color
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(tint.opacity((0.75 - CGFloat(index) * 0.25) * fade))
                    )
                }
            }
        }
    }
}

struct MovingTransportIcon: View {
    let route: LaunchRoute
    let progress: CGFloat
    let opacity: CGFloat
    let size: CGSize

    var body: some View {
        Group {
            if opacity > 0.03 && progress > 0.03 {
                ZStack {
                    Circle()
                        .fill(route.color)
                        .frame(width: 26, height: 26)
                        .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1))
                    ModeGlyph(mode: route.mode)
                        .foregroundStyle(route.mode == .auto ? Color.midnightBlue : Color.white)
                        .frame(width: 13, height: 13)
                }
                .position(route.point(at: progress, in: size))
                .opacity(opacity)
            }
        }
        .accessibilityHidden(true)
    }
}

struct LaunchRoute: Identifiable {
    let id: Int
    let mode: TransportMode
    let color: Color
    let darkCore: Bool
    let start: CGPoint
    let control: CGPoint
    let end: CGPoint
    let stagger: CGFloat

    static let metro = LaunchRoute(
        id: 0, mode: .metro, color: Color(hex: 0x8B64E8), darkCore: false,
        start: CGPoint(x: -0.02, y: 0.57), control: CGPoint(x: 0.50, y: 0.53),
        end: CGPoint(x: 1.02, y: 0.58), stagger: 0
    )

    /// Opening palette: auto yellow, walk blue, metro purple, bus orange,
    /// local train teal, bike green, cab black.
    static let ground: [LaunchRoute] = [
        LaunchRoute(id: 1, mode: .bus, color: Color(hex: 0xF08A24), darkCore: false,
                    start: CGPoint(x: 0.06, y: 0.70), control: CGPoint(x: 0.16, y: 0.50),
                    end: CGPoint(x: 0.40, y: 0.44), stagger: 0.00),
        LaunchRoute(id: 2, mode: .auto, color: Color(hex: 0xE6B325), darkCore: false,
                    start: CGPoint(x: 0.20, y: 0.86), control: CGPoint(x: 0.14, y: 0.62),
                    end: CGPoint(x: 0.44, y: 0.47), stagger: 0.06),
        LaunchRoute(id: 3, mode: .walk, color: Color(hex: 0x3E7BFF), darkCore: false,
                    start: CGPoint(x: 0.50, y: 0.92), control: CGPoint(x: 0.66, y: 0.68),
                    end: CGPoint(x: 0.52, y: 0.49), stagger: 0.10),
        LaunchRoute(id: 4, mode: .train, color: Color(hex: 0x2BB5A0), darkCore: false,
                    start: CGPoint(x: 0.80, y: 0.84), control: CGPoint(x: 0.90, y: 0.60),
                    end: CGPoint(x: 0.60, y: 0.47), stagger: 0.05),
        LaunchRoute(id: 5, mode: .bike, color: Color(hex: 0x2FAE62), darkCore: false,
                    start: CGPoint(x: 0.96, y: 0.62), control: CGPoint(x: 0.78, y: 0.48),
                    end: CGPoint(x: 0.62, y: 0.44), stagger: 0.08),
        LaunchRoute(id: 6, mode: .cab, color: Color(hex: 0x16181D), darkCore: true,
                    start: CGPoint(x: 0.90, y: 0.34), control: CGPoint(x: 0.76, y: 0.30),
                    end: CGPoint(x: 0.58, y: 0.40), stagger: 0.03)
    ]

    func drawAmount(_ global: CGFloat) -> CGFloat {
        min(max((global - stagger) / 0.82, 0), 1)
    }

    func point(at t: CGFloat, in size: CGSize) -> CGPoint {
        let clamped = min(max(t, 0), 1)
        let a = CGPoint(x: start.x * size.width, y: start.y * size.height)
        let b = CGPoint(x: control.x * size.width, y: control.y * size.height)
        let c = CGPoint(x: end.x * size.width, y: end.y * size.height)
        let u = 1 - clamped
        return CGPoint(
            x: u * u * a.x + 2 * u * clamped * b.x + clamped * clamped * c.x,
            y: u * u * a.y + 2 * u * clamped * b.y + clamped * clamped * c.y
        )
    }
}

struct LaunchCurve: Shape {
    var start: CGPoint
    var control: CGPoint
    var end: CGPoint

    func path(in rect: CGRect) -> Path {
        func point(_ unit: CGPoint) -> CGPoint {
            CGPoint(x: unit.x * rect.width, y: unit.y * rect.height)
        }
        var path = Path()
        path.move(to: point(start))
        path.addQuadCurve(to: point(end), control: point(control))
        return path
    }
}
