import SwiftUI

struct LiveJourneyView: View {
    let kind: RouteKind
    let step: Int
    @Environment(AppRouter.self) private var router

    private var screens: [LiveScreen] { MockData.route(kind).liveScreens }
    private var content: LiveContent {
        let index = min(max(step, 0), screens.count - 1)
        return MockData.live(screens[index])
    }
    private var isLastStep: Bool { step >= screens.count - 1 }

    var body: some View {
        ZStack {
            JourneyMapView()

            BottomPanel(fitsContent: true) {
                VStack(spacing: 14) {
                    CurrentlyOnCard(content: content)
                        .bottomPanelPeek()
                    timeline
                        .bottomPanelCollapsible(order: 0)
                    if content.showsMissedAlert {
                        MissedAlertBanner { router.push(.missedTrain) }
                            .bottomPanelCollapsible(order: 1)
                    }
                    NextTransferCard(next: content.next) {
                        router.push(isLastStep ? .arrived : .live(kind, step + 1))
                    }
                    .bottomPanelCollapsible(order: 2)
                }
                .padding(.horizontal, 16)
                .padding(.top, 2)
            }
        }
        .pushedChrome {
            if content.mode == .walk, let direction = content.direction {
                WalkDirectionBanner(direction: direction)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                Text("Live Chennai Journey")
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.midnightBlue)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private var timeline: some View {
        switch content.timeline {
        case .walk(let info):
            WalkTimelineCard(info: info)
        case .stops(let stops):
            StopsTimelineCard(stops: stops, mode: content.mode)
        case .pickupDrop(let info):
            PickupDropCard(info: info)
        case .rideStops(let info):
            RideStopsTimelineCard(info: info, mode: content.mode) {
                router.push(.routeDetail(kind))
            }
        }
    }
}

// MARK: - Glass Surfaces

/// Layered frosted glass: material blur, white body, optional mode-tinted glow,
/// top specular sheen, dual rim and a soft two-layer shadow (contact + ambient).
private struct PremiumGlass: ViewModifier {
    var radius: CGFloat
    var tint: Color?

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        content
            .background {
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    shape.fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.84), Color.white.opacity(0.62)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    if let tint {
                        shape.fill(
                            RadialGradient(
                                colors: [tint.opacity(0.13), tint.opacity(0)],
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: 280
                            )
                        )
                    }
                    shape.fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(0.55), location: 0),
                                .init(color: Color.white.opacity(0), location: 0.38)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .shadow(color: Color.oceanic001D39.opacity(0.06), radius: 1.5, x: 0, y: 1)
                .shadow(color: Color.oceanic49769F.opacity(0.18), radius: 18, x: 0, y: 10)
            }
            .overlay {
                shape.strokeBorder(LinearGradient.glassRim, lineWidth: 1)
                shape.inset(by: 1.5)
                    .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
            }
    }
}

private struct GlassPill: ViewModifier {
    var tint: Color?

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    Capsule().fill(.ultraThinMaterial)
                    Capsule().fill(Color.white.opacity(tint == nil ? 0.80 : 0.55))
                    if let tint {
                        Capsule().fill(tint.opacity(0.12))
                    }
                }
                .shadow(color: Color.oceanic49769F.opacity(0.14), radius: 6, x: 0, y: 3)
            }
            .overlay(
                Capsule().strokeBorder(tint?.opacity(0.28) ?? Color.white.opacity(0.95), lineWidth: 0.8)
            )
    }
}

private extension View {
    func premiumGlass(radius: CGFloat = 24, tint: Color? = nil) -> some View {
        modifier(PremiumGlass(radius: radius, tint: tint))
    }

    func glassPill(tint: Color? = nil) -> some View {
        modifier(GlassPill(tint: tint))
    }

    /// Soft tinted highlight for the timeline row the rider is currently on.
    func activeRowBackground(tint: Color = .transportWalk) -> some View {
        background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.14), tint.opacity(0.04)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(tint.opacity(0.18), lineWidth: 0.8)
                )
        }
    }
}

/// Edge-to-clear colour wash shared by the illustrated cards. Every wash uses the same falloff
/// (edge → mid at 45% → clear), and per-colour opacities are tuned so each tint lightens the
/// card by the same amount as the Train sky-blue reference.
private struct CardWash {
    let edge: Color
    let mid: Color

    static let sky = CardWash(edge: Color(hex: 0x8CCBF0).opacity(0.55), mid: Color(hex: 0xCDE9F9).opacity(0.45))
    static let natureGreen = CardWash(edge: Color.transportWalk.opacity(0.25), mid: Color.transportWalk.opacity(0.09))
    static let autoYellow = CardWash(edge: Color(hex: 0xFFD54F).opacity(0.82), mid: Color(hex: 0xFFD54F).opacity(0.28))

    func gradient(from start: UnitPoint, to end: UnitPoint) -> LinearGradient {
        LinearGradient(
            stops: [
                .init(color: edge, location: 0),
                .init(color: mid, location: 0.45),
                .init(color: mid.opacity(0), location: 1)
            ],
            startPoint: start,
            endPoint: end
        )
    }
}

private struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .brightness(configuration.isPressed ? -0.02 : 0)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Shared Pieces

private struct LiveStatusPill: View {
    let color: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.6), lineWidth: 1)
                    .scaleEffect(isPulsing ? 2.4 : 1)
                    .opacity(isPulsing ? 0 : 0.9)
                Circle()
                    .fill(color)
                    .shadow(color: color.opacity(0.6), radius: 3)
            }
            .frame(width: 7, height: 7)

            Text("Currently On")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 5)
        .glassPill(tint: color)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }
}

private struct GlassChip: View {
    let text: String
    var systemImage: String? = nil
    var tint: Color = .deepSpace

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(tint)
            }
            Text(text)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color.deepSpace)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .glassPill()
    }
}

private struct VerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

// MARK: - Walk Direction Banner

private struct WalkDirectionBanner: View {
    let direction: WalkDirection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isNudging = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: direction.turn.symbolName)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(Color.white)
                .offset(y: isNudging ? -2 : 1)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.transportWalk.opacity(0.8), Color.transportWalk],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.8)
                )
                .shadow(color: Color.transportWalk.opacity(0.4), radius: 6, x: 0, y: 3)

            Text("\(direction.turn.phrase) \(Text(direction.distance).foregroundStyle(Color.transportWalk).fontWeight(.heavy))")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.deepSpace)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.leading, 5)
        .padding(.trailing, 16)
        .padding(.vertical, 5)
        .premiumGlass(radius: 16, tint: .transportWalk)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(direction.turn.phrase) \(direction.distance)")
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isNudging = true
            }
        }
    }
}

// MARK: - Cards

private struct CurrentlyOnCard: View {
    let content: LiveContent

    private static let walkFraction: CGFloat = 0.35
    private static let illustrationInset: CGFloat = 122
    private static let rideIllustrationInset: CGFloat = 122

    var body: some View {
        if content.mode == .walk {
            walkCard
        } else if let ride = content.ride {
            rideCard(ride)
        } else {
            standardCard
        }
    }

    // MARK: Ride Card — illustrated vehicle with stop-by-stop progress
    private func rideCard(_ ride: RideProgress) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                LiveStatusPill(color: content.mode.color)
                Spacer(minLength: 8)
                if let chip = content.chips.first {
                    GlassChip(text: chip, systemImage: "clock.fill")
                }
            }

            Text(content.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.deepSpace)
                .padding(.top, 10)

            VStack(alignment: .leading, spacing: 2) {
                ForEach(ride.lines, id: \.self) { line in
                    Text(line)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.deepSpace.opacity(0.68))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
            .padding(.top, 3)

            RideStopsTrack(mode: content.mode, totalStops: ride.totalStops, currentIndex: ride.currentStopIndex)
                .padding(.top, 12)
        }
        .padding(.leading, Self.rideIllustrationInset)
        .padding(16)
        .background(alignment: .leading) {
            Image(content.mode == .train ? "local_train_illustration" : "train_illustration")
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 112, alignment: .trailing)
                .clipped()
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.1),
                            .init(color: .black, location: 0.6),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.6),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(x: -26)
                .accessibilityHidden(true)
        }
        .background(CardWash.sky.gradient(from: .leading, to: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .premiumGlass()
        .accessibilityElement(children: .combine)
    }

    // MARK: Walk Card — illustration sits behind, content is inset past it
    private var walkCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                LiveStatusPill(color: .transportWalk)
                Spacer(minLength: 8)
                if let chip = content.chips.first {
                    GlassChip(text: chip, systemImage: "clock.fill", tint: .transportWalk)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Walking")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.deepSpace)
                Text(content.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.deepSpace.opacity(0.68))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.top, 10)

            walkProgress
                .padding(.top, 14)
        }
        .padding(.leading, Self.illustrationInset)
        .padding(16)
        .background(alignment: .bottomLeading) {
            Image("walk_illustration")
                .resizable()
                .scaledToFit()
                .frame(height: 132)
                .offset(x: -15, y: -6)
                .accessibilityHidden(true)
        }
        .background(CardWash.natureGreen.gradient(from: .leading, to: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .premiumGlass()
        .accessibilityElement(children: .combine)
    }

    private var walkProgress: some View {
        WalkStepTrail(progress: Self.walkFraction, remaining: "300 m")
    }

    // MARK: Standard Card (all other modes)
    private var standardCard: some View {
        HStack(alignment: .center, spacing: 14) {
            ModeBadge(mode: content.mode, size: 54)

            VStack(alignment: .leading, spacing: 5) {
                LiveStatusPill(color: content.mode.color)
                Text(content.title)
                    .font(.raahaTitle3)
                    .foregroundStyle(Color.deepSpace)
                Text(content.subtitle)
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.steelBlue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 8) {
                ForEach(content.chips, id: \.self) { chip in
                    GlassChip(text: chip)
                }
            }
        }
        .padding(16)
        .premiumGlass(tint: content.mode.color)
        .accessibilityElement(children: .combine)
    }
}

/// Walking progress as a trail of alternating footprints: walked steps fill in green and fade
/// behind the walker puck, while the next few steps light up in sequence to lead the way.
private struct WalkStepTrail: View {
    let progress: CGFloat
    let remaining: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown: CGFloat = 0
    @State private var isPulsing = false

    private let stepPitch: CGFloat = 11
    private let puckSize: CGFloat = 24
    private let guideLength = 3

    var body: some View {
        VStack(spacing: 7) {
            HStack(spacing: 6) {
                GeometryReader { geo in
                    let width = geo.size.width
                    let count = max(Int(width / stepPitch), 2)
                    let puckX = min(max(width * shown - puckSize / 2, 0), width - puckSize)

                    ZStack(alignment: .leading) {
                        TimelineView(.animation(minimumInterval: 0.22, paused: reduceMotion)) { context in
                            let wave = Int(context.date.timeIntervalSinceReferenceDate / 0.22) % guideLength
                            HStack(spacing: 0) {
                                ForEach(0..<count, id: \.self) { index in
                                    footstep(index: index, count: count, wave: wave)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }

                        puck
                            .offset(x: puckX)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(height: puckSize)

                destination
            }

            HStack {
                Text("\(Int((progress * 100).rounded()))% walked")
                    .foregroundStyle(Color.transportWalk)
                Spacer(minLength: 4)
                Text("\(Text(remaining).font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(Color.deepSpace)) to go")
                    .foregroundStyle(Color.deepSpace.opacity(0.6))
            }
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int((progress * 100).rounded())) percent walked, \(remaining) to go")
        .onAppear {
            guard !reduceMotion else {
                shown = progress
                return
            }
            withAnimation(.spring(duration: 1.1, bounce: 0.2).delay(0.2)) {
                shown = progress
            }
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }

    private func footstep(index: Int, count: Int, wave: Int) -> some View {
        let position = (CGFloat(index) + 0.5) / CGFloat(count)
        let isWalked = position <= shown
        let puckIndex = Int(shown * CGFloat(count))
        let isGuiding = !isWalked && !reduceMotion && index == puckIndex + 1 + wave
        let isLeftFoot = index.isMultiple(of: 2)
        let trailOpacity = 0.35 + 0.65 * Double(position / max(shown, 0.01))

        return Capsule()
            .fill(
                isWalked
                    ? Color.transportWalk.opacity(trailOpacity)
                    : Color.transportWalk.opacity(isGuiding ? 0.55 : 0)
            )
            .background(Capsule().fill(Color.deepSpace.opacity(isWalked ? 0 : 0.13)))
            .frame(width: 4.5, height: 7.5)
            .scaleEffect(isGuiding ? 1.2 : 1)
            .rotationEffect(.degrees(90 + (isLeftFoot ? -14 : 14)))
            .offset(y: isLeftFoot ? -2.5 : 2.5)
            .animation(.easeInOut(duration: 0.2), value: isGuiding)
    }

    private var puck: some View {
        ZStack {
            Circle()
                .fill(Color.transportWalk.opacity(0.25))
                .scaleEffect(isPulsing ? 1.7 : 1)
                .opacity(isPulsing ? 0 : 1)
            Circle()
                .fill(Color.white)
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.transportWalk.opacity(0.75), Color.transportWalk],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2.5
                )
            Image(systemName: "figure.walk")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.transportWalk)
        }
        .frame(width: puckSize, height: puckSize)
        .shadow(color: Color.transportWalk.opacity(0.35), radius: 5, x: 0, y: 2)
    }

    private var destination: some View {
        FinishFlagBadge(size: puckSize)
    }
}

private struct FinishFlagBadge: View {
    var size: CGFloat = 24

    var body: some View {
        Image(systemName: "flag.checkered")
            .font(.system(size: size * 0.46, weight: .bold))
            .foregroundStyle(Color.deepSpace)
            .frame(width: size, height: size)
            .background(Circle().fill(Color.white))
            .overlay(Circle().strokeBorder(Color.deepSpace.opacity(0.12), lineWidth: 1))
            .shadow(color: Color.deepSpace.opacity(0.15), radius: 3, x: 0, y: 1)
    }
}

/// Railway track: two rails on sleepers, solid where the train has travelled and faded ahead.
/// Every stop on the leg sits on the track, the train puck rides to the current stop, and the finish flag ends the line.
private struct RideStopsTrack: View {
    let mode: TransportMode
    let totalStops: Int
    let currentIndex: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown: CGFloat = 0
    @State private var isPulsing = false

    private let nodeSize: CGFloat = 24
    private let dotSize: CGFloat = 8

    private var tint: Color { mode.color }
    private var stopsRemaining: Int { max(totalStops - currentIndex - 1, 0) }
    private var progress: CGFloat { position(of: currentIndex) }

    private func position(of index: Int) -> CGFloat {
        CGFloat(index + 1) / CGFloat(totalStops + 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                GeometryReader { geo in
                    let width = geo.size.width
                    let puckX = min(max(width * shown - nodeSize / 2, 0), width - nodeSize)

                    ZStack(alignment: .leading) {
                        RailTrack(progress: shown, tint: tint)

                        ForEach(0..<max(totalStops, 0), id: \.self) { index in
                            stationDot(isPassed: position(of: index) <= shown + 0.001)
                                .offset(x: width * position(of: index) - dotSize / 2)
                        }

                        puck
                            .offset(x: puckX)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(height: nodeSize)

                FinishFlagBadge(size: nodeSize)
            }

            Text("\(stopsRemaining) \(stopsRemaining == 1 ? "stop" : "stops") remaining")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(tint)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Stop \(currentIndex + 1) of \(totalStops), \(stopsRemaining) \(stopsRemaining == 1 ? "stop" : "stops") remaining")
        .onAppear {
            guard !reduceMotion else {
                shown = progress
                return
            }
            withAnimation(.spring(duration: 1.1, bounce: 0.2).delay(0.2)) {
                shown = progress
            }
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }

    private func stationDot(isPassed: Bool) -> some View {
        Circle()
            .fill(isPassed ? tint : Color.white)
            .frame(width: dotSize, height: dotSize)
            .overlay(Circle().strokeBorder(tint.opacity(isPassed ? 1 : 0.6), lineWidth: 1.6))
            .shadow(color: Color.deepSpace.opacity(0.15), radius: 2, x: 0, y: 1)
    }

    private var puck: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.25))
                .scaleEffect(isPulsing ? 1.7 : 1)
                .opacity(isPulsing ? 0 : 1)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.8), tint],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Circle()
                .strokeBorder(Color.white.opacity(0.9), lineWidth: 1.5)
            ModeGlyph(mode: mode)
                .foregroundStyle(Color.white)
                .frame(width: 12, height: 12)
        }
        .frame(width: nodeSize, height: nodeSize)
        .shadow(color: tint.opacity(0.4), radius: 5, x: 0, y: 2)
    }
}

/// Two rails on evenly spaced sleepers; the travelled stretch is solid, the rest faded.
private struct RailTrack: View, Animatable {
    var progress: CGFloat
    let tint: Color

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Canvas { context, size in
            let midY = size.height / 2
            let railOffset: CGFloat = 3.5
            let travelledX = size.width * progress
            let ahead = tint.opacity(0.3)

            var x: CGFloat = 3
            while x < size.width - 1 {
                let sleeper = CGRect(x: x - 1, y: midY - 6, width: 2.2, height: 12)
                context.fill(
                    Path(roundedRect: sleeper, cornerRadius: 1),
                    with: .color(x <= travelledX ? tint.opacity(0.75) : ahead)
                )
                x += 6
            }

            for y in [midY - railOffset, midY + railOffset] {
                var travelled = Path()
                travelled.move(to: CGPoint(x: 0, y: y))
                travelled.addLine(to: CGPoint(x: travelledX, y: y))
                context.stroke(travelled, with: .color(tint), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

                var remaining = Path()
                remaining.move(to: CGPoint(x: travelledX, y: y))
                remaining.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(remaining, with: .color(ahead), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
            }
        }
    }
}

private struct WalkTimelineCard: View {
    let info: WalkTimeline

    private let railWidth: CGFloat = 30

    var body: some View {
        VStack(spacing: 0) {
            endpointRow(title: info.startTitle, caption: info.startCaption, isDestination: false)
            connector
            walkRow
            connector
            endpointRow(title: info.endTitle, caption: info.endCaption, isDestination: true)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .premiumGlass(tint: .transportWalk)
        .accessibilityElement(children: .combine)
    }

    private func endpointRow(title: String, caption: String, isDestination: Bool) -> some View {
        HStack(spacing: 12) {
            node(isDestination: isDestination)
                .frame(width: railWidth)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.deepSpace)
                Text(caption)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.deepSpace.opacity(0.65))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
    }

    @ViewBuilder
    private func node(isDestination: Bool) -> some View {
        if isDestination {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.transportWalk)
                .background(Circle().fill(Color.white).padding(2))
                .shadow(color: Color.transportWalk.opacity(0.3), radius: 4, x: 0, y: 2)
        } else {
            Circle()
                .fill(Color.white)
                .overlay(Circle().strokeBorder(Color.transportWalk, lineWidth: 4))
                .frame(width: 18, height: 18)
                .shadow(color: Color.transportWalk.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }

    private var connector: some View {
        HStack(spacing: 0) {
            VerticalLine()
                .stroke(
                    Color.transportWalk.opacity(0.55),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 4])
                )
                .frame(width: railWidth, height: 16)
            Spacer()
        }
        .padding(.horizontal, 8)
    }

    private var walkRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.walk")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 30, height: 30)
                .background(
                    Circle().fill(
                        LinearGradient(
                            colors: [Color.transportWalk.opacity(0.8), Color.transportWalk],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                )
                .shadow(color: Color.transportWalk.opacity(0.35), radius: 5, x: 0, y: 3)
                .frame(width: railWidth)

            VStack(alignment: .leading, spacing: 2) {
                Text(info.walkTitle)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.deepSpace)
                Text(info.walkCaption)
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(Color.deepSpace.opacity(0.65))
            }

            Spacer(minLength: 8)

            Text("Now")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.transportWalk)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .glassPill(tint: .transportWalk)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .activeRowBackground()
    }
}

/// Previous → current → next stop, drawn as a steel line: solid where the ride has been,
/// marching dashes toward the next stop, with the current stop lifted into a highlighted row.
private struct RideStopsTimelineCard: View {
    let info: RideStopsTimeline
    let mode: TransportMode
    let onViewDetails: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dashPhase: CGFloat = 0
    @State private var isPulsing = false

    private let railWidth: CGFloat = 34
    private var tint: Color { mode.color }

    var body: some View {
        VStack(spacing: 0) {
            stopRow(label: "Previous Stop", stop: info.previous, isPassed: true)
            connector(isTravelled: true)
            currentRow
            connector(isTravelled: false)
            stopRow(label: "Next Stop", stop: info.next, isPassed: false)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .premiumGlass(tint: tint)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                dashPhase = -8
            }
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }

    private func stopRow(label: String, stop: RideStopsTimeline.Stop, isPassed: Bool) -> some View {
        HStack(spacing: 12) {
            node(isPassed: isPassed)
                .frame(width: railWidth)

            VStack(alignment: .leading, spacing: 1) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(tint.opacity(isPassed ? 0.7 : 1))
                Text(stop.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.deepSpace.opacity(isPassed ? 0.6 : 1))
            }

            Spacer(minLength: 8)

            HStack(spacing: 4) {
                Image(systemName: isPassed ? "checkmark.circle.fill" : "clock.fill")
                    .font(.system(size: 10, weight: .semibold))
                Text(stop.caption)
                    .monospacedDigit()
            }
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(isPassed ? Color.deepSpace.opacity(0.5) : tint)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .glassPill(tint: isPassed ? nil : tint)
        }
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func node(isPassed: Bool) -> some View {
        if isPassed {
            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .heavy))
                .foregroundStyle(Color.white)
                .frame(width: 18, height: 18)
                .background(Circle().fill(tint.opacity(0.75)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.9), lineWidth: 1.5))
                .shadow(color: tint.opacity(0.3), radius: 3, x: 0, y: 1)
        } else {
            Circle()
                .fill(Color.white)
                .overlay(Circle().strokeBorder(tint, lineWidth: 3.5))
                .frame(width: 18, height: 18)
                .shadow(color: tint.opacity(0.3), radius: 3, x: 0, y: 1)
        }
    }

    private func connector(isTravelled: Bool) -> some View {
        HStack(spacing: 0) {
            Group {
                if isTravelled {
                    Capsule()
                        .fill(tint.opacity(0.75))
                        .frame(width: 3)
                } else {
                    VerticalLine()
                        .stroke(
                            tint.opacity(0.7),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [3, 5], dashPhase: dashPhase)
                        )
                        .frame(width: 3)
                }
            }
            .frame(width: railWidth, height: 14)
            Spacer()
        }
        .padding(.horizontal, 8)
    }

    private var currentRow: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.25))
                    .scaleEffect(isPulsing ? 1.6 : 1)
                    .opacity(isPulsing ? 0 : 1)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.8), tint],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Circle()
                    .strokeBorder(Color.white.opacity(0.9), lineWidth: 1.5)
                ModeGlyph(mode: mode)
                    .foregroundStyle(Color.white)
                    .frame(width: 15, height: 15)
            }
            .frame(width: 34, height: 34)
            .shadow(color: tint.opacity(0.4), radius: 6, x: 0, y: 3)
            .frame(width: railWidth)

            VStack(alignment: .leading, spacing: 3) {
                Text(info.current.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.deepSpace)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                HStack(spacing: 5) {
                    Circle()
                        .fill(tint)
                        .frame(width: 6, height: 6)
                    Text(info.current.caption)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(tint)
                }
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: 8)

            Button(action: onViewDetails) {
                HStack(spacing: 3) {
                    Text("View Details")
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                }
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(tint)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .glassPill(tint: tint)
            }
            .buttonStyle(PressableCardStyle())
            .accessibilityHint("Shows the full route details")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .activeRowBackground(tint: tint)
    }
}

private struct StopsTimelineCard: View {
    let stops: [StopItem]
    let mode: TransportMode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(stops) { stop in
                StopRow(stop: stop, mode: mode)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .leading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.transportMetro.opacity(0.45), Color.steelBlue.opacity(0.20)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2)
                .padding(.leading, 14 + 15)
                .padding(.vertical, 30)
        }
        .premiumGlass(tint: .transportMetro)
    }
}

private struct StopRow: View {
    let stop: StopItem
    let mode: TransportMode

    var body: some View {
        HStack(spacing: 14) {
            dot
                .frame(width: 32)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(stop.name)
                        .font(.raahaSubheadlineMedium)
                        .foregroundStyle(Color.deepSpace)
                    Text(stop.caption)
                        .font(.raahaFootnote)
                        .foregroundStyle(
                            stop.state == .next
                                ? Color.transportMetro
                                : Color.steelBlue
                        )
                }
                Spacer()
                if stop.state == .next {
                    ModeGlyph(mode: mode)
                        .foregroundStyle(Color.transportMetro)
                        .frame(width: 14, height: 14)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(Color.transportMetro.opacity(0.14))
                                .background(.regularMaterial, in: Circle())
                        )
                        .overlay(Circle().stroke(Color.transportMetro.opacity(0.35), lineWidth: 1))
                        .shadow(color: Color.transportMetro.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, stop.state == .next ? 14 : 0)
            .padding(.vertical, stop.state == .next ? 10 : 0)
            .background {
                if stop.state == .next {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.transportMetro.opacity(0.12), Color.transportMetro.opacity(0.04)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(Color.transportMetro.opacity(0.22), lineWidth: 0.8)
                        )
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var dot: some View {
        switch stop.state {
        case .boarded:
            Circle()
                .fill(Color.steelBlue)
                .frame(width: 16, height: 16)
                .overlay(Circle().strokeBorder(Color.white.opacity(0.9), lineWidth: 2))
                .shadow(color: Color.steelBlue.opacity(0.3), radius: 3, x: 0, y: 1)
        case .next:
            ZStack {
                Circle()
                    .fill(Color.transportMetro.opacity(0.18))
                    .frame(width: 24, height: 24)
                Circle()
                    .fill(Color.transportMetro)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                    .shadow(color: Color.transportMetro.opacity(0.5), radius: 4, x: 0, y: 1)
            }
        case .upcoming, .arriving:
            Circle()
                .fill(Color.white.opacity(0.80))
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(Color.steelBlue.opacity(0.60), lineWidth: 1.5))
        }
    }
}

private struct PickupDropCard: View {
    let info: PickupDrop

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Pickup & Drop")
                .font(.raahaTitle3)
                .foregroundStyle(Color.midnightBlue)

            HStack(alignment: .top, spacing: 14) {
                VStack(spacing: 4) {
                    Image("icon_pin")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(Color.royalBlue)
                        .frame(height: 34)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.royalBlue.opacity(0.50), Color(hex: 0x18866B).opacity(0.50)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                    Image("icon_pin")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(Color(hex: 0x18866B))
                        .frame(height: 34)
                }
                .frame(width: 34)

                VStack(spacing: 18) {
                    place(label: "Pickup", name: info.pickup, time: info.pickupTime)
                    place(label: "Drop", name: info.drop, time: info.dropTime)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumGlass(tint: .royalBlue)
    }

    private func place(label: String, name: String, time: String) -> some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.steelBlue)
                Text(name)
                    .font(.raahaTitle3)
                    .foregroundStyle(Color.midnightBlue)
            }
            Spacer()
            Text(time)
                .font(.raahaSubheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(Color.royalBlue)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct MissedAlertBanner: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "exclamationmark")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle().fill(
                            LinearGradient(
                                colors: [Color.strawberry.opacity(0.85), Color.strawberry],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    )
                    .shadow(color: Color.strawberry.opacity(0.35), radius: 6, x: 0, y: 3)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Missed my train!")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.midnightBlue)
                    Text("Find the next available train, get real-time updates and alternatives.")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.steelBlue)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.steelBlue)
            }
            .padding(14)
            .premiumGlass(radius: 22, tint: .strawberry)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.strawberry.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Shows the next available trains")
    }
}

private struct NextTransferCard: View {
    let next: NextTransfer
    let action: () -> Void

    private let radius: CGFloat = 24

    private var illustration: (name: String, height: CGFloat, offset: CGSize) {
        switch next.icon {
        case .train: return ("local_train_illustration", 100, CGSize(width: 10, height: 10))
        case .auto: return ("auto_illustration", 138, CGSize(width: 10, height: 12))
        default: return ("train_illustration", 100, CGSize(width: 10, height: 10))
        }
    }

    private var wash: CardWash {
        next.icon == .auto ? .autoYellow : .sky
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.deepSpace)

                        Text("Next Transfer")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.deepSpace)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .glassPill()

                    Spacer()

                    GlassChip(text: next.chip, systemImage: "clock.fill")
                }

                Text(next.headline)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.deepSpace)
                    .padding(.top, 10)

                VStack(alignment: .leading, spacing: 3) {
                    ForEach(next.lines) { line in
                        HStack(spacing: 4) {
                            Text(line.text)
                            if let trailing = line.trailing {
                                Text("· \(trailing)")
                                    .fontWeight(.semibold)
                                    .monospacedDigit()
                            }
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.deepSpace.opacity(0.72))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                    }
                }
                .padding(.top, 3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(alignment: .bottomTrailing) {
                ZStack(alignment: .bottomTrailing) {
                    wash.gradient(from: .trailing, to: .leading)

                    Image(illustration.name)
                        .resizable()
                        .scaledToFit()
                        .frame(height: illustration.height)
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .clear, location: 0.18),
                                    .init(color: .black.opacity(0.35), location: 0.42),
                                    .init(color: .black.opacity(0.85), location: 0.70),
                                    .init(color: .black, location: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(illustration.offset)
                        .accessibilityHidden(true)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .premiumGlass(radius: radius)
        }
        .buttonStyle(PressableCardStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: next.headline)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Continues to the next leg of the journey")
    }
}

#Preview {
    LiveJourneyView(kind: .fastest, step: 0)
        .environment(AppRouter())
}
