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
                    if content.showsMissedAlert {
                        MissedAlertBanner { router.push(.missedTrain) }
                    }
                    NextTransferCard(next: content.next) {
                        router.push(isLastStep ? .arrived : .live(kind, step + 1))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 2)
            }
        }
        .pushedChrome(title: "Live Chennai Journey")
    }

    @ViewBuilder
    private var timeline: some View {
        switch content.timeline {
        case .walk(let info):
            WalkTimelineCard(info: info)
        case .stops(let stops):
            StopsTimelineCard(stops: stops)
        case .pickupDrop(let info):
            PickupDropCard(info: info)
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

// MARK: - Cards

private struct CurrentlyOnCard: View {
    let content: LiveContent

    private static let walkFraction: CGFloat = 0.35
    private static let illustrationInset: CGFloat = 122

    var body: some View {
        if content.mode == .walk {
            walkCard
        } else {
            standardCard
        }
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
                    .minimumScaleFactor(0.85)
            }
            .padding(.top, 10)

            walkProgress
                .padding(.top, 14)
        }
        .padding(.leading, Self.illustrationInset)
        .padding(16)
        .background(alignment: .bottomLeading) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.transportWalk.opacity(0.18), Color.transportWalk.opacity(0)],
                            center: .center,
                            startRadius: 4,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .offset(y: 8)
                Image("walk_illustration")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 132)
            }
            .offset(x: -8, y: -6)
            .accessibilityHidden(true)
        }
        .premiumGlass(tint: .transportWalk)
        .accessibilityElement(children: .combine)
    }

    private var walkProgress: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(spacing: 8) {
                GeometryReader { geo in
                    let filled = geo.size.width * Self.walkFraction
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.deepSpace.opacity(0.08))
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.8), lineWidth: 0.5))
                            .frame(height: 6)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.transportWalk.opacity(0.7), Color.transportWalk],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: filled, height: 6)
                            .shadow(color: Color.transportWalk.opacity(0.35), radius: 4, x: 0, y: 1)
                        Circle()
                            .fill(Color.white)
                            .overlay(Circle().strokeBorder(Color.transportWalk, lineWidth: 3))
                            .frame(width: 14, height: 14)
                            .shadow(color: Color.transportWalk.opacity(0.45), radius: 4, x: 0, y: 1)
                            .offset(x: filled - 7)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(height: 14)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.deepSpace)
                    .background(Circle().fill(Color.white).padding(2))
                    .shadow(color: Color.deepSpace.opacity(0.22), radius: 3, x: 0, y: 1)
            }

            Text("300 m")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color.deepSpace)
        }
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
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.transportWalk.opacity(0.14), Color.transportWalk.opacity(0.04)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.transportWalk.opacity(0.18), lineWidth: 0.8)
                )
        }
    }
}

private struct StopsTimelineCard: View {
    let stops: [StopItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(stops) { stop in
                StopRow(stop: stop)
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
                    Image(systemName: "tram.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.transportMetro)
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

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    HStack(spacing: 7) {
                        Image(systemName: next.icon.symbolName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(next.icon.color)
                            .frame(width: 26, height: 26)
                            .background(Circle().fill(next.icon.tintedBackground))
                            .overlay(Circle().strokeBorder(next.icon.strokeColor, lineWidth: 0.8))

                        Text("Next Transfer")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.deepSpace)
                    }
                    .padding(.leading, 3)
                    .padding(.trailing, 11)
                    .padding(.vertical, 3)
                    .glassPill()

                    Spacer()

                    GlassChip(text: next.chip, systemImage: "clock.fill")
                }

                HStack(spacing: 6) {
                    Text(next.headline)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.deepSpace)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.deepSpace.opacity(0.35))
                }
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
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: 0xE2F5FD).opacity(0), location: 0.35),
                            .init(color: Color(hex: 0xE2F5FD).opacity(0.7), location: 0.65),
                            .init(color: Color(hex: 0xB6E6F8).opacity(0.9), location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )

                    Image("train_illustration")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
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
                        .offset(x: 10, y: 10)
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
