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

    private var liveProgressTracker: some View {
        VStack(spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.statusGreen)
                        .frame(width: 8, height: 8)
                    Text("LIVE TRANSIT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.statusGreen)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.statusGreen.opacity(0.15)))

                Spacer()

                Text("Step \(step + 1) of \(screens.count)")
                    .font(.raahaCaption.weight(.semibold))
                    .foregroundStyle(Color.deepSpace)
            }

            // Progress segments
            HStack(spacing: 5) {
                ForEach(0..<screens.count, id: \.self) { idx in
                    Capsule()
                        .fill(
                            idx < step
                                ? Color.statusGreen
                                : (idx == step ? Color.strawberry : Color.steelBlue.opacity(0.3))
                        )
                        .frame(height: 5)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .lightCard(radius: 16)
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

// MARK: - Cards

private struct CurrentlyOnCard: View {
    let content: LiveContent
    @State private var isPulsing = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ModeBadge(mode: content.mode, size: 54, fill: Color.honeydew)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.strawberry)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isPulsing ? 1.25 : 0.8)
                        .opacity(isPulsing ? 1.0 : 0.55)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
                        .onAppear { isPulsing = true }

                    Text("CURRENTLY ON")
                        .font(.raahaCaption2)
                        .foregroundStyle(Color.frostedBlue.opacity(0.85))
                }
                Text(content.title)
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.honeydew)
                Text(content.subtitle)
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.frostedBlue)
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
            VStack(spacing: 0) {
                Circle().fill(Color.frostedBlue).frame(width: 14, height: 14)
                Rectangle().fill(Color.frostedBlue.opacity(0.8)).frame(width: 2)
                Circle().stroke(Color.frostedBlue, lineWidth: 2.5).frame(width: 14, height: 14)
            }
            .padding(.vertical, 18)

            VStack(spacing: 0) {
                row(asset: "icon_pin", tint: Color.frostedBlue, title: info.startTitle,
                    caption: info.startCaption, chip: nil, chevron: true)
                HairlineDivider()
                row(symbol: "figure.walk", tint: Color.frostedBlue, title: info.walkTitle,
                    caption: info.walkCaption, chip: info.walkChip, chevron: false)
                HairlineDivider()
                row(asset: "icon_pin", tint: Color.strawberry, title: info.endTitle,
                    caption: info.endCaption, chip: nil, chevron: true)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .navyCard(radius: 24)
    }

    private func row(symbol: String? = nil, asset: String? = nil, tint: Color, title: String, caption: String,
                     chip: String?, chevron: Bool) -> some View {
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
                    .foregroundStyle(Color.honeydew)
                Text(caption)
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.frostedBlue)
            }
            Spacer(minLength: 4)
            if let chip {
                TimeChip(text: chip)
            }
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.frostedBlue)
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
                .fill(Color.steelBlue.opacity(0.9))
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
                        .foregroundStyle(stop.state == .next ? Color.deepSpace : Color.honeydew)
                    Text(stop.caption)
                        .font(.raahaFootnote)
                        .foregroundStyle(stop.state == .next ? Color.steelBlue : Color.frostedBlue)
                }
                Spacer()
                if stop.state == .next {
                    Image("icon_metro")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(Color.deepSpace)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.honeydew))
                }
            }
            .padding(.horizontal, stop.state == .next ? 14 : 0)
            .padding(.vertical, stop.state == .next ? 10 : 0)
            .background {
                if stop.state == .next {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.frostedBlue, Color.frostedBlue.opacity(0.55)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
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
            Circle().fill(Color.steelBlue).frame(width: 16, height: 16)
        case .next:
            Circle()
                .fill(Color.strawberry)
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(Color.honeydew, lineWidth: 3))
                .frame(width: 24, height: 24)
        case .upcoming, .arriving:
            Circle()
                .fill(Color.honeydew)
                .frame(width: 12, height: 12)
                .overlay(Circle().stroke(Color.steelBlue, lineWidth: 2))
        }
    }
}

private struct PickupDropCard: View {
    let info: PickupDrop

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Pickup & Drop")
                .font(.raahaTitle3)
                .foregroundStyle(Color.honeydew)

            HStack(alignment: .top, spacing: 14) {
                VStack(spacing: 4) {
                    Image("icon_pin")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(Color.frostedBlue)
                        .frame(height: 34)
                    Rectangle()
                        .fill(Color.frostedBlue.opacity(0.7))
                        .frame(width: 2)
                    Image("icon_pin")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(Color.strawberry)
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
                    .foregroundStyle(Color.frostedBlue)
                Text(name)
                    .font(.raahaTitle3)
                    .foregroundStyle(Color.honeydew)
            }
            Spacer()
            Text(time)
                .font(.raahaSubheadline)
                .foregroundStyle(Color.frostedBlue)
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
                    .foregroundStyle(Color.honeydew)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.strawberry))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Missed my train!")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.strawberry)
                    Text("Find the next available train, get real-time updates and alternatives.")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.steelBlue)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.strawberry)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.strawberry.opacity(0.14))
            )
            .shadow(color: Color.deepSpace.opacity(0.08), radius: 8, x: 0, y: 4)
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
                Image(systemName: next.icon.symbolName)
                    .font(.raahaTitle3)
                    .foregroundStyle(Color.frostedBlue)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(Color.steelBlue.opacity(0.6)))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Next Transfer")
                            .font(.raahaBody)
                            .foregroundStyle(Color.honeydew)
                        Spacer()
                        TimeChip(text: next.chip)
                    }
                    Text(next.headline)
                        .font(.raahaSubheadlineMedium)
                        .foregroundStyle(Color.honeydew)
                    ForEach(next.lines) { line in
                        HStack {
                            Text(line.text)
                                .font(.raahaCaption)
                                .foregroundStyle(Color.frostedBlue)
                                .multilineTextAlignment(.leading)
                            if let trailing = line.trailing {
                                Spacer()
                                Text(trailing)
                                    .font(.raahaCaption)
                                    .foregroundStyle(Color.frostedBlue)
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
