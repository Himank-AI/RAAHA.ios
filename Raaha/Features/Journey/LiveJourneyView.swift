import SwiftUI

struct LiveJourneyView: View {
    let kind: RouteKind
    let step: Int
    @EnvironmentObject private var router: AppRouter

    private var screens: [LiveScreen] { MockData.route(kind).liveScreens }
    private var content: LiveContent {
        let index = min(max(step, 0), screens.count - 1)
        return MockData.live(screens[index])
    }
    private var isLastStep: Bool { step >= screens.count - 1 }

    var body: some View {
        ZStack {
            JourneyMapView()

            BottomPanel {
                VStack(spacing: 12) {
                    // Step Progress Tracker
                    liveProgressTracker

                    CurrentlyOnCard(content: content)
                    timeline
                    if content.showsMissedAlert {
                        MissedAlertBanner { router.push(.missedTrain) }
                    }
                    NextTransferCard(next: content.next) {
                        router.push(isLastStep ? .arrived : .live(kind, step + 1))
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .pushedChrome(title: "Live Chennai Journey")
    }

    // MARK: - Dynamic Step-Chain Progress Tracker

    private var liveProgressTracker: some View {
        VStack(spacing: 10) {
            // Top row: LIVE badge + step counter
            HStack {
                LiveBadge()
                Spacer()
                Text("Step \(step + 1) of \(screens.count)")
                    .font(.raahaCaption.weight(.semibold))
                    .foregroundStyle(Color.royalBlue)
            }

            // Animated icon-chain progress bar
            StepChainProgressView(screens: screens, currentStep: step)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .navyCard(radius: 20)
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

// MARK: - Live Badge (pulsing emerald dot)

private struct LiveBadge: View {
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: 0x18866B))
                .frame(width: 8, height: 8)
                .scaleEffect(isPulsing ? 1.3 : 0.75)
                .opacity(isPulsing ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isPulsing)
                .onAppear { isPulsing = true }

            Text("LIVE TRANSIT")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: 0x18866B))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color(hex: 0x18866B).opacity(0.12))
                .overlay(Capsule().stroke(Color(hex: 0x18866B).opacity(0.30), lineWidth: 1))
        )
    }
}

// MARK: - Step-Chain Progress View

private struct StepChainProgressView: View {
    let screens: [LiveScreen]
    let currentStep: Int

    private func iconName(for screen: LiveScreen) -> String {
        switch screen {
        case .walk, .walkEnd:  return "figure.walk"
        case .metro:           return "tram.fill"
        case .bus:             return "bus.fill"
        case .auto:            return "car.fill"
        case .train:           return "train.side.front.car"
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(screens.enumerated()), id: \.offset) { idx, screen in
                // Icon node
                stepNode(index: idx, screen: screen)

                // Connector line (not after last)
                if idx < screens.count - 1 {
                    connectorLine(upTo: idx)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func stepNode(index: Int, screen: LiveScreen) -> some View {
        let isDone    = index < currentStep
        let isCurrent = index == currentStep

        ZStack {
            // Background circle
            Circle()
                .fill(
                    isDone    ? Color(hex: 0x18866B).opacity(0.15) :
                    isCurrent ? Color.royalBlue.opacity(0.12) :
                                Color.white.opacity(0.0)
                )
                .overlay(
                    Circle()
                        .stroke(
                            isDone    ? Color(hex: 0x18866B).opacity(0.50) :
                            isCurrent ? Color.royalBlue.opacity(0.70) :
                                        Color(hex: 0x4E8EA2).opacity(0.25),
                            lineWidth: isCurrent ? 2 : 1.5
                        )
                )
                .frame(width: isCurrent ? 36 : 28, height: isCurrent ? 36 : 28)
                .shadow(
                    color: isCurrent ? Color.royalBlue.opacity(0.25) : .clear,
                    radius: 6, x: 0, y: 2
                )

            if isDone {
                // Completed: checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(hex: 0x18866B))
            } else {
                // Icon
                Image(systemName: iconName(for: screen))
                    .font(.system(size: isCurrent ? 16 : 12, weight: .semibold))
                    .foregroundStyle(
                        isCurrent ? Color.royalBlue :
                                    Color(hex: 0x4E8EA2).opacity(0.60)
                    )
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentStep)
    }

    private func connectorLine(upTo idx: Int) -> some View {
        let isDone = idx < currentStep

        return Rectangle()
            .fill(
                isDone
                    ? LinearGradient(
                        colors: [Color(hex: 0x18866B).opacity(0.60), Color(hex: 0x4E8EA2).opacity(0.40)],
                        startPoint: .leading,
                        endPoint: .trailing
                      )
                    : LinearGradient(
                        colors: [Color(hex: 0x4E8EA2).opacity(0.25), Color(hex: 0x4E8EA2).opacity(0.15)],
                        startPoint: .leading,
                        endPoint: .trailing
                      )
            )
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 4) // vertically align with circle centres
    }
}

// MARK: - Cards

private struct CurrentlyOnCard: View {
    let content: LiveContent
    @State private var isPulsing = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ModeBadge(mode: content.mode, size: 54, fill: Color.white.opacity(0.75), tint: Color.royalBlue)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: 0x18866B))
                        .frame(width: 7, height: 7)
                        .scaleEffect(isPulsing ? 1.25 : 0.80)
                        .opacity(isPulsing ? 1.0 : 0.50)
                        .animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: isPulsing)
                        .onAppear { isPulsing = true }

                    Text("CURRENTLY ON")
                        .font(.raahaCaption2)
                        .foregroundStyle(Color.steelBlue)
                }
                Text(content.title)
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.midnightBlue)
                Text(content.subtitle)
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.steelBlue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 8) {
                ForEach(content.chips, id: \.self) { chip in
                    TimeChip(text: chip)
                }
            }
        }
        .padding(14)
        .navyCard(radius: 24)
        .accessibilityElement(children: .combine)
    }
}

private struct WalkTimelineCard: View {
    let info: WalkTimeline

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Vertical connector
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.royalBlue)
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.royalBlue.opacity(0.60), Color.steelBlue.opacity(0.30)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2)
                Circle()
                    .stroke(Color.steelBlue, lineWidth: 2)
                    .frame(width: 12, height: 12)
            }
            .padding(.vertical, 20)

            VStack(spacing: 0) {
                row(asset: "icon_pin", tint: Color.royalBlue,
                    title: info.startTitle, caption: info.startCaption,
                    chip: nil, chevron: true)
                HairlineDivider(color: Color(hex: 0x4E8EA2).opacity(0.25))
                row(symbol: "figure.walk", tint: Color.steelBlue,
                    title: info.walkTitle, caption: info.walkCaption,
                    chip: info.walkChip, chevron: false)
                HairlineDivider(color: Color(hex: 0x4E8EA2).opacity(0.25))
                row(asset: "icon_pin", tint: Color(hex: 0x18866B),
                    title: info.endTitle, caption: info.endCaption,
                    chip: nil, chevron: true)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .navyCard(radius: 24)
    }

    private func row(symbol: String? = nil, asset: String? = nil, tint: Color,
                     title: String, caption: String, chip: String?, chevron: Bool) -> some View {
        HStack(spacing: 12) {
            Group {
                if let asset {
                    Image(asset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                } else if let symbol {
                    Image(systemName: symbol)
                        .font(.raahaTitle3)
                }
            }
            .foregroundStyle(tint)
            .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.midnightBlue)
                Text(caption)
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.steelBlue)
            }
            Spacer(minLength: 4)
            if let chip {
                TimeChip(text: chip)
            }
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.steelBlue)
            }
        }
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
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
                        colors: [Color.royalBlue.opacity(0.35), Color.steelBlue.opacity(0.20)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2)
                .padding(.leading, 14 + 15)
                .padding(.vertical, 30)
        }
        .navyCard(radius: 24)
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
                        .foregroundStyle(Color.midnightBlue)
                    Text(stop.caption)
                        .font(.raahaFootnote)
                        .foregroundStyle(
                            stop.state == .next
                                ? Color(hex: 0x18866B)
                                : Color.steelBlue
                        )
                }
                Spacer()
                if stop.state == .next {
                    Image(systemName: "tram.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.royalBlue)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.80))
                                .background(.regularMaterial, in: Circle())
                        )
                        .overlay(Circle().stroke(Color(hex: 0x4E8EA2).opacity(0.35), lineWidth: 1))
                }
            }
            .padding(.horizontal, stop.state == .next ? 14 : 0)
            .padding(.vertical, stop.state == .next ? 10 : 0)
            .background {
                if stop.state == .next {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(hex: 0x18866B).opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color(hex: 0x18866B).opacity(0.25), lineWidth: 1)
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
                .fill(Color.royalBlue)
                .frame(width: 16, height: 16)
        case .next:
            ZStack {
                Circle()
                    .fill(Color(hex: 0x18866B).opacity(0.15))
                    .frame(width: 24, height: 24)
                Circle()
                    .fill(Color(hex: 0x18866B))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
            }
        case .upcoming, .arriving:
            Circle()
                .fill(Color.white.opacity(0.60))
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
        .navyCard(radius: 24)
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
                    .font(.raahaTitle2)
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.strawberry))

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
            .navyCard(radius: 22)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.strawberry.opacity(0.30), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Shows the next available trains")
    }
}

private struct NextTransferCard: View {
    let next: NextTransfer
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                // Mode icon — navy on frosted white
                Image(systemName: next.icon.symbolName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.royalBlue)
                    .frame(width: 54, height: 54)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.80))
                            .background(.regularMaterial, in: Circle())
                    )
                    .overlay(Circle().stroke(LinearGradient.glassRim, lineWidth: 1))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Next Transfer")
                            .font(.raahaBody.weight(.semibold))
                            .foregroundStyle(Color.midnightBlue)
                        Spacer()
                        TimeChip(text: next.chip)
                    }
                    Text(next.headline)
                        .font(.raahaSubheadlineMedium)
                        .foregroundStyle(Color.royalBlue)
                    ForEach(next.lines) { line in
                        HStack {
                            Text(line.text)
                                .font(.raahaCaption)
                                .foregroundStyle(Color.steelBlue)
                                .multilineTextAlignment(.leading)
                            if let trailing = line.trailing {
                                Spacer()
                                Text(trailing)
                                    .font(.raahaCaption)
                                    .foregroundStyle(Color.steelBlue)
                            }
                        }
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .navyCard(radius: 24, gradient: .raahaNavyGlow)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: next.headline)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Continues to the next leg of the journey")
    }
}
