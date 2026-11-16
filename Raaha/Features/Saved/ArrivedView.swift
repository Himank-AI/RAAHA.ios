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

    @State private var elapsed: TimeInterval = 0
    @State private var startedAt: Date?
    @State private var logoShown = false
    @State private var pinShown = false
    @State private var logoSettled = false
    @State private var badgeShown = false
    @State private var detailsPulse = 0
    @State private var completedAt = Date()

    private var option: RouteOption { MockData.route(completedKind) }

    private var modes: [TransportMode] {
        option.chain.isEmpty ? option.legs.map(\.mode) : option.chain
    }

    private var playhead: TimeInterval {
        reduceMotion ? ArrivalLogoSequence.duration : elapsed
    }

    var body: some View {
        ZStack {
            ArrivalScreenBackground(glow: reduceMotion ? 1 : ArrivalLogoSequence.unit(0, 0.40, playhead))
            ScrollView {
                VStack(spacing: 22) {
                    ArrivalLogoView(
                        circleVisible: reduceMotion || logoShown || playhead > 0,
                        pinVisible: reduceMotion || pinShown || playhead >= 0.85,
                        settled: reduceMotion || logoSettled || playhead >= 1.55,
                        badgeVisible: reduceMotion || badgeShown || playhead >= 0.85,
                        checkDraw: reduceMotion ? 1 : ArrivalLogoSequence.unit(1.20, 1.55, playhead),
                        reduceMotion: reduceMotion
                    )
                    .padding(.top, 12)

                    arrivalCopy
                    JourneyCompletionCard(
                        arrival: arrivalText,
                        duration: "\(option.minutes) min",
                        distance: distanceText,
                        cost: option.fareText,
                        modes: modes,
                        revealed: playhead >= 2.05,
                        timelineRevealed: playhead >= 2.20,
                        reduceMotion: reduceMotion
                    )
                    JourneyCompletionActions(
                        revealed: playhead >= 2.30,
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
        .sensoryFeedback(.success, trigger: badgeShown)
        .background {
            if !reduceMotion, let startedAt, elapsed < ArrivalLogoSequence.duration {
                ArrivalLogoDriver(
                    startedAt: startedAt,
                    elapsed: $elapsed,
                    logoShown: $logoShown,
                    pinShown: $pinShown,
                    logoSettled: $logoSettled,
                    badgeShown: $badgeShown
                )
            }
        }
        .onAppear(perform: beginArrival)
    }

    private func beginArrival() {
        guard startedAt == nil else { return }
        completedAt = Date()
        startedAt = Date()
        if reduceMotion {
            elapsed = ArrivalLogoSequence.duration
            logoShown = true
            pinShown = true
            logoSettled = true
            badgeShown = true
        }
    }

    private var arrivalCopy: some View {
        let visible = playhead >= 1.80 || reduceMotion
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
}

// MARK: - Arrival logo

private enum ArrivalLogoSequence {
    static let duration: TimeInterval = 2.3

    static func unit(_ start: TimeInterval, _ end: TimeInterval, _ elapsed: TimeInterval) -> CGFloat {
        guard end > start else { return elapsed >= end ? 1 : 0 }
        let raw = (elapsed - start) / (end - start)
        let t = min(max(raw, 0), 1)
        return t * t * (3 - 2 * t)
    }
}

private struct ArrivalLogoDriver: View {
    var startedAt: Date
    @Binding var elapsed: TimeInterval
    @Binding var logoShown: Bool
    @Binding var pinShown: Bool
    @Binding var logoSettled: Bool
    @Binding var badgeShown: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            Color.clear
                .onAppear { tick(context.date) }
                .onChange(of: context.date) { _, date in
                    tick(date)
                }
        }
    }

    private func tick(_ date: Date) {
        let time = min(max(date.timeIntervalSince(startedAt), 0), ArrivalLogoSequence.duration)
        guard time > elapsed else { return }
        elapsed = time
        if !logoShown {
            withAnimation(.easeOut(duration: 0.30)) {
                logoShown = true
            }
        }
        if time >= 0.30, !pinShown {
            withAnimation(.spring(response: 0.48, dampingFraction: 0.78)) {
                pinShown = true
            }
        }
        if time >= 0.85, !badgeShown {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                badgeShown = true
            }
        }
        if time >= 1.55, !logoSettled {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                logoSettled = true
            }
        }
    }
}

struct ArrivalLogoView: View {
    var circleVisible: Bool
    var pinVisible: Bool
    var settled: Bool
    var badgeVisible: Bool
    var checkDraw: CGFloat
    var reduceMotion: Bool

    private let pinColor = Color(hex: 0x087797)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.85), Color(hex: 0xD8F3F8).opacity(0)],
                        center: .center,
                        startRadius: 12,
                        endRadius: 110
                    )
                )
                .frame(width: 210, height: 210)
                .opacity(circleVisible ? 1 : 0)

            Circle()
                .fill(Color(hex: 0xE7F6FA).opacity(0.94))
                .overlay {
                    Circle().stroke(Color(hex: 0x75BBD0), lineWidth: 1.25)
                }
                .frame(width: 158, height: 158)
                .shadow(color: pinColor.opacity(0.16), radius: 16, y: 8)
                .opacity(circleVisible ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.30), value: circleVisible)

            IconPin(size: 58)
                .foregroundStyle(pinColor)
                .frame(width: 72, height: 72)
                .scaleEffect(settled ? 1 : (pinVisible ? 1 : 0.65))
                .opacity(pinVisible ? 1 : 0)
                .animation(reduceMotion ? nil : .spring(response: 0.48, dampingFraction: 0.78), value: pinVisible)
                .animation(reduceMotion ? nil : .spring(response: 0.36, dampingFraction: 0.86), value: settled)

            ArrivalCheckBadge(shown: badgeVisible, draw: checkDraw, reduceMotion: reduceMotion)
                .offset(x: 54, y: -54)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 196)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Destination reached")
    }
}

private struct ArrivalCheckBadge: View {
    var shown: Bool
    var draw: CGFloat
    var reduceMotion: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0x087797))
                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                .shadow(color: Color(hex: 0x087797).opacity(0.24), radius: 6, y: 2)
            ArrivalCheckStroke()
                .trim(from: 0, to: draw)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 2.1, lineCap: .round, lineJoin: .round)
                )
                .padding(8)
        }
        .frame(width: 40, height: 40)
        .scaleEffect(shown ? 1 : 0.35)
        .opacity(shown ? 1 : 0)
        .animation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.72), value: shown)
        .accessibilityHidden(true)
    }
}

private struct ArrivalCheckStroke: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.22, y: rect.height * 0.52))
        path.addLine(to: CGPoint(x: rect.width * 0.42, y: rect.height * 0.72))
        path.addLine(to: CGPoint(x: rect.width * 0.78, y: rect.height * 0.30))
        return path
    }
}

private struct ArrivalScreenBackground: View {
    var glow: CGFloat

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
            RadialGradient(
                colors: [Color.white.opacity(0.85), Color(hex: 0xD8F3F8).opacity(0.28), Color.clear],
                center: .center,
                startRadius: 10,
                endRadius: 150
            )
            .frame(width: 300, height: 300)
            .offset(y: -210)
            .opacity(0.25 + 0.75 * glow)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
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
