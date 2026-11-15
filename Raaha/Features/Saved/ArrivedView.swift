import SwiftUI

// MARK: - Coastal arrival palette

private enum ArrivalInk {
    static let ice = Color(hex: 0xDCEFF5)
    static let soft = Color(hex: 0x75BBD0)
    static let deep = Color(hex: 0x176487)
    static let navy = Color(hex: 0x173D5C)
    static let muted = Color(hex: 0x326F89)
    static let white = Color(hex: 0xF5FAFC)
}

enum ArrivalCue: Int {
    case idle, marker, ripple, check, route, particles, heading, card, timeline, ready
}

/// Destination reached. Stats, cost, and the transport sequence come from the
/// route that was just completed, not from fixed sample numbers.
struct ArrivedView: View {
    var body: some View {
        JourneyArrivalView()
    }
}

struct JourneyArrivalView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var cue: ArrivalCue = .idle
    @State private var detailsPulse = 0
    @State private var completedAt = Date()

    private var option: RouteOption { MockData.route(completedKind) }

    private var modes: [TransportMode] {
        option.chain.isEmpty ? option.legs.map(\.mode) : option.chain
    }

    var body: some View {
        ZStack {
            ArrivalBackdrop(animated: !reduceMotion)
            ScrollView {
                VStack(spacing: 22) {
                    ArrivalDestinationAnimation(cue: cue, reduceMotion: reduceMotion)
                        .padding(.top, 8)

                    arrivalCopy
                    JourneyCompletionCard(
                        arrival: arrivalText,
                        duration: "\(option.minutes) min",
                        distance: distanceText,
                        cost: option.fareText,
                        modes: modes,
                        revealed: cue.rawValue >= ArrivalCue.card.rawValue,
                        timelineRevealed: cue.rawValue >= ArrivalCue.timeline.rawValue,
                        reduceMotion: reduceMotion
                    )
                    JourneyCompletionActions(
                        revealed: cue.rawValue >= ArrivalCue.ready.rawValue,
                        reduceMotion: reduceMotion,
                        onDetails: openJourneyDetails,
                        onHome: { router.showHome() },
                        detailsPulse: $detailsPulse
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sensoryFeedback(.success, trigger: cue.rawValue >= ArrivalCue.check.rawValue)
        .task {
            completedAt = Date()
            await play()
        }
    }

    private var arrivalCopy: some View {
        let visible = cue.rawValue >= ArrivalCue.heading.rawValue || reduceMotion
        return VStack(spacing: 8) {
            Text("JOURNEY COMPLETED")
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.6)
                .foregroundStyle(ArrivalInk.muted)
            Text("You've arrived!")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(ArrivalInk.navy)
                .minimumScaleFactor(0.8)
            Text(router.journeyTo)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(ArrivalInk.navy)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            Text("Every connection brought you closer.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ArrivalInk.muted)
                .multilineTextAlignment(.center)
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text("Completed")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(ArrivalInk.deep)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(ArrivalInk.ice))
            .padding(.top, 2)
        }
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 12)
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.86), value: visible)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Journey completed. You've arrived at \(router.journeyTo).")
    }

    private var completedKind: RouteKind {
        let path: [Route]
        switch router.tab {
        case .home: path = router.homePath
        case .trips: path = router.tripsPath
        case .explore: path = router.explorePath
        case .profile: path = router.profilePath
        }
        for route in path.reversed() {
            if case .live(let kind, _) = route { return kind }
            if case .routeDetail(let kind) = route { return kind }
        }
        return .fastest
    }

    private var arrivalText: String {
        guard let screen = option.liveScreens.last else { return Self.clock.string(from: completedAt) }
        let content = MockData.live(screen)
        if let arrival = content.arrival, !arrival.isEmpty { return arrival }
        for line in content.next.lines where line.text.localizedCaseInsensitiveContains("by ") {
            if let range = line.text.range(of: "by ", options: .caseInsensitive) {
                let time = line.text[range.upperBound...].trimmingCharacters(in: .whitespaces)
                if time.contains(":") { return time }
            }
        }
        return Self.clock.string(from: completedAt)
    }

    private var distanceText: String {
        let meters = option.legs.reduce(0.0) { $0 + ArrivalMetrics.meters(in: $1.detail) }
        return ArrivalMetrics.format(meters: meters)
    }

    private static let clock: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private func openJourneyDetails() {
        detailsPulse += 1
        router.push(.routeDetail(completedKind))
    }

    private func play() async {
        guard !reduceMotion else {
            cue = .ready
            return
        }
        let beats: [(ArrivalCue, UInt64)] = [
            (.marker, 70_000_000),
            (.ripple, 260_000_000),
            (.check, 560_000_000),
            (.route, 780_000_000),
            (.particles, 980_000_000),
            (.heading, 1_180_000_000),
            (.card, 1_500_000_000),
            (.timeline, 1_820_000_000),
            (.ready, 2_080_000_000)
        ]
        var elapsed: UInt64 = 0
        for (step, at) in beats {
            try? await Task.sleep(nanoseconds: at - elapsed)
            elapsed = at
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                cue = step
            }
        }
    }
}

// MARK: - Destination animation

struct ArrivalDestinationAnimation: View {
    var cue: ArrivalCue
    var reduceMotion: Bool

    private var shown: Bool { reduceMotion || cue.rawValue >= ArrivalCue.marker.rawValue }
    private var rippled: Bool { reduceMotion || cue.rawValue >= ArrivalCue.ripple.rawValue }
    private var checked: Bool { reduceMotion || cue.rawValue >= ArrivalCue.check.rawValue }
    private var routed: Bool { reduceMotion || cue.rawValue >= ArrivalCue.route.rawValue }
    private var burst: Bool { reduceMotion || cue.rawValue >= ArrivalCue.particles.rawValue }

    var body: some View {
        ZStack {
            ArrivalRippleEffect(expanded: rippled)
            ArrivalParticles(burst: burst, reduceMotion: reduceMotion)
            ArrivalRouteLine(progress: routed ? 1 : 0)
                .offset(x: -78, y: 18)
            marker
            check
        }
        .frame(height: 168)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Destination reached")
    }

    private var marker: some View {
        ZStack {
            Circle()
                .fill(ArrivalInk.white)
                .frame(width: 76, height: 76)
                .shadow(color: ArrivalInk.deep.opacity(0.16), radius: 14, y: 8)
            Circle()
                .stroke(ArrivalInk.soft.opacity(0.9), lineWidth: 1.2)
                .frame(width: 76, height: 76)
            Image(systemName: "mappin")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(ArrivalInk.deep)
                .offset(y: -2)
        }
        .scaleEffect(shown ? 1 : 0.72)
        .opacity(shown ? 1 : 0)
        .animation(reduceMotion ? nil : .spring(response: 0.48, dampingFraction: 0.72), value: shown)
    }

    private var check: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(ArrivalInk.white)
            .frame(width: 28, height: 28)
            .background(Circle().fill(ArrivalInk.deep))
            .overlay(Circle().stroke(ArrivalInk.white, lineWidth: 2))
            .shadow(color: ArrivalInk.deep.opacity(0.25), radius: 6, y: 3)
            .offset(x: 30, y: 26)
            .scaleEffect(checked ? 1 : 0.2)
            .opacity(checked ? 1 : 0)
            .animation(reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.62), value: checked)
    }
}

struct ArrivalRippleEffect: View {
    var expanded: Bool

    var body: some View {
        ZStack {
            ripple(scale: 1.85, opacity: 0.55, delay: 0)
            ripple(scale: 1.45, opacity: 0.35, delay: 0.16)
        }
    }

    private func ripple(scale: CGFloat, opacity: Double, delay: Double) -> some View {
        Circle()
            .stroke(ArrivalInk.soft.opacity(opacity), lineWidth: 1.4)
            .frame(width: 92, height: 92)
            .scaleEffect(expanded ? scale : 0.55)
            .opacity(expanded ? 0 : 1)
            .animation(.easeOut(duration: 1.05).delay(delay), value: expanded)
    }
}

struct ArrivalRouteLine: View {
    var progress: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 26))
            path.addQuadCurve(to: CGPoint(x: 74, y: 4), control: CGPoint(x: 36, y: 30))
        }
        .trim(from: 0, to: progress)
        .stroke(
            ArrivalInk.deep.opacity(0.75),
            style: StrokeStyle(lineWidth: 2.2, lineCap: .round)
        )
        .frame(width: 76, height: 32)
        .animation(.easeOut(duration: 0.55), value: progress)
    }
}

struct ArrivalParticles: View {
    var burst: Bool
    var reduceMotion: Bool

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                let angle = (Double(index) / 6) * .pi * 2 - .pi / 2
                Circle()
                    .fill(index.isMultiple(of: 2) ? ArrivalInk.soft : ArrivalInk.deep.opacity(0.7))
                    .frame(width: 5, height: 5)
                    .offset(
                        x: burst ? CGFloat(cos(angle)) * 58 : 0,
                        y: burst ? CGFloat(sin(angle)) * 46 : 0
                    )
                    .opacity(burst ? 0 : 0.95)
            }
        }
        .opacity(burst && !reduceMotion ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.95), value: burst)
        .accessibilityHidden(true)
    }
}

// MARK: - Summary

struct JourneyCompletionCard: View {
    let arrival: String
    let duration: String
    let distance: String
    let cost: String
    let modes: [TransportMode]
    var revealed: Bool
    var timelineRevealed: Bool
    var reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Journey at a Glance")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(ArrivalInk.navy)

            HStack(alignment: .top, spacing: 8) {
                glanceStat(symbol: "clock", value: arrival, label: "Arrival")
                glanceStat(symbol: "timer", value: duration, label: "Duration")
                glanceStat(symbol: "map", value: distance, label: "Distance")
            }

            if timelineRevealed || reduceMotion {
                VStack(alignment: .leading, spacing: 14) {
                    HairlineDivider(color: ArrivalInk.soft.opacity(0.45))
                    TransportJourneyTimeline(modes: modes)
                    HStack {
                        Text("Total journey cost")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(ArrivalInk.muted)
                        Spacer(minLength: 8)
                        Text(cost)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(ArrivalInk.navy)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { arrivalGlass(radius: 24) }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.85), lineWidth: 1)
        }
        .shadow(color: ArrivalInk.navy.opacity(0.08), radius: 16, y: 8)
        .opacity(revealed || reduceMotion ? 1 : 0)
        .offset(y: revealed || reduceMotion ? 0 : 18)
        .animation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.86), value: revealed)
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.86), value: timelineRevealed)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Journey summary. Arrived \(arrival). \(duration). \(distance). Cost \(cost).")
    }

    private func glanceStat(symbol: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ArrivalInk.deep)
                .frame(height: 18)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(ArrivalInk.navy)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ArrivalInk.muted)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TransportJourneyTimeline: View {
    let modes: [TransportMode]

    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(modes.enumerated()), id: \.offset) { index, mode in
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(mode.tintedBackground)
                                ModeGlyph(mode: mode)
                                    .foregroundStyle(mode.color)
                                    .frame(width: 16, height: 16)
                            }
                            .frame(width: 36, height: 36)
                            .overlay(Circle().stroke(mode.color.opacity(0.35), lineWidth: 1))
                            Text(ArrivalMetrics.label(for: mode))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(ArrivalInk.navy)
                                .lineLimit(1)
                                .frame(width: 68)
                        }
                        if index < modes.count - 1 {
                            Capsule()
                                .fill(ArrivalInk.soft)
                                .frame(width: 18, height: 2)
                                .padding(.top, 17)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .frame(minWidth: geo.size.width, alignment: .center)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .frame(height: 64)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Transport used: \(modes.map(ArrivalMetrics.label).joined(separator: ", "))")
    }
}

struct JourneyCompletionActions: View {
    var revealed: Bool
    var reduceMotion: Bool
    let onDetails: () -> Void
    let onHome: () -> Void
    @Binding var detailsPulse: Int

    var body: some View {
        VStack(spacing: 10) {
            Button(action: onDetails) {
                HStack(spacing: 8) {
                    Text("View Journey Details")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(ArrivalInk.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [ArrivalInk.soft, ArrivalInk.deep],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                )
                .shadow(color: ArrivalInk.deep.opacity(0.22), radius: 10, y: 5)
            }
            .buttonStyle(ArrivalPressStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: detailsPulse)

            Button(action: onHome) {
                Text("Back to Home")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ArrivalInk.navy)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Capsule().fill(Color.white.opacity(0.55)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.9), lineWidth: 1))
            }
            .buttonStyle(ArrivalPressStyle())
        }
        .opacity(revealed || reduceMotion ? 1 : 0)
        .offset(y: revealed || reduceMotion ? 0 : 12)
        .animation(reduceMotion ? nil : .interactiveSpring(response: 0.45, dampingFraction: 0.86), value: revealed)
    }
}

// MARK: - Backdrop

private struct ArrivalBackdrop: View {
    var animated: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    ArrivalInk.white,
                    ArrivalInk.ice,
                    Color(hex: 0xB7DCE8),
                    Color(hex: 0x7BBDE8).opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            if animated {
                TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { context in
                    let time = context.date.timeIntervalSinceReferenceDate
                    Canvas { canvas, size in
                        for index in 0..<6 {
                            let seed = Double(index)
                            let x = size.width * (0.12 + 0.14 * seed + 0.03 * sin(time * 0.18 + seed))
                            let y = size.height * (0.08 + 0.12 * seed + 0.02 * cos(time * 0.15 + seed * 1.3))
                            let rect = CGRect(x: x, y: y, width: 6, height: 6)
                            canvas.fill(
                                Path(ellipseIn: rect),
                                with: .color(Color.white.opacity(0.55))
                            )
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct ArrivalPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.interactiveSpring(response: 0.24, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

@ViewBuilder
private func arrivalGlass(radius: CGFloat) -> some View {
    let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
    ZStack {
        shape.fill(ArrivalInk.white.opacity(0.78))
        if #available(iOS 26, *) {
            shape.fill(Color.clear)
                .glassEffect(.regular.tint(Color.white.opacity(0.48)), in: shape)
        } else {
            shape.fill(.ultraThinMaterial)
        }
    }
}

private enum ArrivalMetrics {
    static func meters(in text: String) -> Double {
        let tokens = text
            .replacingOccurrences(of: "·", with: " ")
            .split(separator: " ")
            .map(String.init)
        var total = 0.0
        for index in tokens.indices where index > 0 {
            let unit = tokens[index].lowercased()
            guard unit == "km" || unit == "m", let value = Double(tokens[index - 1]) else { continue }
            total += unit == "km" ? value * 1000 : value
        }
        return total
    }

    static func format(meters: Double) -> String {
        guard meters > 0 else { return "—" }
        if meters >= 1000 {
            let kilometres = meters / 1000
            if kilometres >= 10 {
                return String(format: "%.0f km", kilometres)
            }
            return String(format: "%.1f km", kilometres)
        }
        return "\(Int(meters.rounded())) m"
    }

    static func label(for mode: TransportMode) -> String {
        switch mode {
        case .walk: return "Walking"
        case .metro: return "Metro"
        case .bus: return "Bus"
        case .auto: return "Auto"
        case .bike: return "Bike"
        case .train: return "Train"
        case .cab, .car: return "Cab"
        }
    }
}

#Preview {
    ArrivedView()
        .environment(AppRouter())
}
