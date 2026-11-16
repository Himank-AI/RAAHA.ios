import SwiftUI

/// Shared “Not sure where to go?” card. Both Home and Trips open the existing Explore tab.
struct SmartRoutePlannerCard: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var taps = 0

    var body: some View {
        Button {
            taps += 1
            router.explorePath = []
            router.tab = .explore
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Not sure where to go?")
                        .font(.system(size: 18.5, weight: .bold))
                        .foregroundStyle(Color.white)

                    Text("Try our Smart Route Planner")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.86))
                }

                Spacer(minLength: 8)

                SmartRoutePlannerArrow()
            }
            .padding(.leading, 22)
            .padding(.trailing, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 88)
            .background { SmartRoutePlannerBackground(animated: !reduceMotion) }
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.42), Color(hex: 0xA9E2ED).opacity(0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.midnightBlue.opacity(0.28), radius: 16, y: 8)
        }
        .buttonStyle(SmartRoutePlannerStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: taps)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Not sure where to go? Try our Smart Route Planner")
        .accessibilityHint("Opens Explore")
    }
}

private struct SmartRoutePressedKey: EnvironmentKey {
    static let defaultValue = false
}

private extension EnvironmentValues {
    var smartRoutePressed: Bool {
        get { self[SmartRoutePressedKey.self] }
        set { self[SmartRoutePressedKey.self] = newValue }
    }
}

private struct SmartRoutePlannerStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .environment(\.smartRoutePressed, configuration.isPressed)
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.985 : 1)
            .animation(
                reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.72),
                value: configuration.isPressed
            )
    }
}

private struct SmartRoutePlannerArrow: View {
    @Environment(\.smartRoutePressed) private var pressed
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var highlighted: Bool { pressed && !reduceMotion }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0x278EAA).opacity(highlighted ? 0.48 : 0.28))
                .frame(width: 62, height: 62)
                .blur(radius: 8)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x278EAA), Color(hex: 0x176987)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0xA9E2ED).opacity(highlighted ? 0.78 : 0.42),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            if #available(iOS 26, *) {
                Circle()
                    .fill(Color.clear)
                    .glassEffect(.clear.tint(Color(hex: 0xA9E2ED).opacity(highlighted ? 0.38 : 0.22)), in: Circle())
            }
            Circle()
                .stroke(Color(hex: 0xA9E2ED).opacity(0.85), lineWidth: 1.5)
            Circle()
                .stroke(Color.white.opacity(0.78), lineWidth: 1)
                .padding(1.5)

            Image(systemName: "arrow.right")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white)
                .offset(x: highlighted ? 3.5 : 0)
        }
        .frame(width: 50, height: 50)
        .scaleEffect(highlighted ? 0.93 : 1)
        .shadow(color: Color(hex: 0x176987).opacity(0.38), radius: 10, y: 5)
        .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.68), value: pressed)
        .accessibilityHidden(true)
    }
}

private struct SmartRoutePlannerBackground: View {
    var animated: Bool

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: 0x2A4E72), location: 0.0),
                        .init(color: Color.midnightBlue, location: 0.42),
                        .init(color: Color(hex: 0x12283F), location: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(Color(hex: 0x278EAA).opacity(0.28))
                    .frame(width: 150, height: 150)
                    .blur(radius: 28)
                    .offset(x: w * 0.32, y: -h * 0.15)

                Path { path in
                    path.move(to: CGPoint(x: w * 0.60, y: 0))
                    path.addCurve(
                        to: CGPoint(x: w, y: h * 0.70),
                        control1: CGPoint(x: w * 0.72, y: h * 0.25),
                        control2: CGPoint(x: w * 0.85, y: h * 0.45)
                    )
                    path.addLine(to: CGPoint(x: w, y: 0))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.brightBlue.opacity(0.35), Color.electricBlue.opacity(0.10)],
                        startPoint: .top,
                        endPoint: .bottomTrailing
                    )
                )

                Path { path in
                    path.move(to: CGPoint(x: w * 0.50, y: 0))
                    path.addCurve(
                        to: CGPoint(x: w * 0.38, y: h),
                        control1: CGPoint(x: w * 0.52, y: h * 0.40),
                        control2: CGPoint(x: w * 0.45, y: h * 0.75)
                    )
                    path.addLine(to: CGPoint(x: w * 0.46, y: h))
                    path.addCurve(
                        to: CGPoint(x: w * 0.58, y: 0),
                        control1: CGPoint(x: w * 0.53, y: h * 0.75),
                        control2: CGPoint(x: w * 0.60, y: h * 0.40)
                    )
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.lightSkyBlue.opacity(0.25), Color.brightBlue.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                if animated {
                    TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { context in
                        let cycle = context.date.timeIntervalSinceReferenceDate
                            .truncatingRemainder(dividingBy: 8) / 8
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.14), Color.clear],
                            startPoint: UnitPoint(x: cycle * 1.5 - 0.4, y: 0),
                            endPoint: UnitPoint(x: cycle * 1.5 - 0.05, y: 1)
                        )
                    }
                    .allowsHitTesting(false)
                }
            }
        }
    }
}
