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
                VStack(spacing: 12) {
                    CurrentlyOnCard(content: content)
                    timeline
                    if content.showsMissedAlert {
                        MissedAlertBanner { router.push(.missedTrain) }
                    }
                    NextTransferCard(next: content.next) {
                        router.push(isLastStep ? .arrived : .live(kind, step + 1))
                    }
                }
                .padding(.horizontal, 16)
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

// MARK: - Cards

private struct CurrentlyOnCard: View {
    let content: LiveContent
    @State private var isPulsing = false

    var body: some View {
        if content.mode == .walk {
            walkCard
        } else {
            standardCard
        }
    }

    // MARK: Walk Card — illustration is the card background, content overlays on top
    private var walkCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Top Row: Status Pill (left-offset) & Clock Chip (right) ──
            HStack(alignment: .center) {
                // Offset to clear the walking illustration in background
                Spacer().frame(width: 122)

                // "• Currently On"
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.transportWalk)
                        .frame(width: 7, height: 7)
                        .scaleEffect(isPulsing ? 1.25 : 0.85)
                        .opacity(isPulsing ? 1.0 : 0.6)
                        .animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: isPulsing)
                        .onAppear { isPulsing = true }

                    Text("Currently On")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.transportWalk)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.transportWalk.opacity(0.14), in: Capsule())

                Spacer()

                // "20 min" Clock Chip
                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.transportWalk)
                    if let chip = content.chips.first {
                        Text(chip)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.deepSpace)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.transportWalk.opacity(0.14), in: Capsule())
            }

            // ── Title & Subtitle ──
            VStack(alignment: .leading, spacing: 3) {
                Text("Walking")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.deepSpace)

                Text(content.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.deepSpace.opacity(0.85))
            }
            .padding(.leading, 122)
            .padding(.top, 8)

            // ── Progress Bar & Caption ──
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.transportWalk)
                        .frame(width: 10, height: 10)

                    GeometryReader { lineGeo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.deepSpace.opacity(0.75))
                                .frame(height: 2)
                            Capsule()
                                .fill(Color.transportWalk)
                                .frame(width: lineGeo.size.width * 0.35, height: 2)
                        }
                    }
                    .frame(height: 2)

                    Image(systemName: "mappin.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.deepSpace)
                }

                Text("0.8 km • 20 min left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.deepSpace)
            }
            .padding(.leading, 122)
            .padding(.top, 14)
        }
        .padding(16)
        .background(alignment: .bottomLeading) {
            Image("walk_illustration")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
                .offset(x: -8, y: 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(LinearGradient.glassRim, lineWidth: 1.2)
        )
        .shadow(color: Color(hex: 0x49769F).opacity(0.18), radius: 14, x: 0, y: 5)
        .accessibilityElement(children: .combine)
    }

    // MARK: Standard Card (all other modes)
    private var standardCard: some View {
        HStack(alignment: .center, spacing: 14) {
            ModeBadge(mode: content.mode, size: 54)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(content.mode.color)
                        .frame(width: 7, height: 7)
                        .scaleEffect(isPulsing ? 1.25 : 0.80)
                        .opacity(isPulsing ? 1.0 : 0.50)
                        .animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: isPulsing)
                        .onAppear { isPulsing = true }

                    Text("CURRENTLY ON")
                        .font(.raahaCaption2)
                        .foregroundStyle(content.mode.color)
                }
                Text(content.title)
                    .font(.raahaHeadline)
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
        VStack(spacing: 0) {
            // Row 1: Start Location (T. Nagar)
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.transportWalk)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(info.startTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.deepSpace)
                    Text(info.startCaption)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.deepSpace.opacity(0.75))
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)

            // Vertical Connector 1
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.transportWalk)
                    .frame(width: 2, height: 16)
                    .frame(width: 28)
                Spacer()
            }
            .padding(.horizontal, 14)

            // Row 2: Walk Segment (Mint Highlighted Pill)
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.transportWalk)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(info.walkTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.deepSpace)
                    Text(info.walkCaption)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.deepSpace.opacity(0.75))
                }

                Spacer()

//                Image(systemName: "chevron.right")
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundStyle(Color.deepSpace.opacity(0.70))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.transportWalk.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 6)

            // Vertical Connector 2
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.transportWalk)
                    .frame(width: 2, height: 16)
                    .frame(width: 28)
                Spacer()
            }
            .padding(.horizontal, 14)

            // Row 3: Destination Location (Marina Beach)
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.transportWalk)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(info.endTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.deepSpace)
                    Text(info.endCaption)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.deepSpace.opacity(0.75))
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .navyCard(radius: 24)
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
                        colors: [Color.transportMetro.opacity(0.45), Color.steelBlue.opacity(0.20)],
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
                }
            }
            .padding(.horizontal, stop.state == .next ? 14 : 0)
            .padding(.vertical, stop.state == .next ? 10 : 0)
            .background {
                if stop.state == .next {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.transportMetro.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.transportMetro.opacity(0.25), lineWidth: 1)
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
        case .next:
            ZStack {
                Circle()
                    .fill(Color.transportMetro.opacity(0.18))
                    .frame(width: 24, height: 24)
                Circle()
                    .fill(Color.transportMetro)
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
            ZStack(alignment: .bottomTrailing) {

                // ── BACKGROUND GRADIENT: white → sky-blue horizontal gradient ──
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .white, location: 0.0),
                                .init(color: .white, location: 0.35),
                                .init(color: Color(hex: 0xE2F5FD), location: 0.60),
                                .init(color: Color(hex: 0xB6E6F8), location: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // ── TRAIN ILLUSTRATION: starting from right to left with decreasing opacity ──
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

                // ── FOREGROUND CONTENT ──
                VStack(alignment: .leading, spacing: 0) {

                    // Top row: [Mode + Next Transfer] badge & [Clock + 12 min] chip
                    HStack(alignment: .center) {
                        // Combined capsule badge
                        HStack(spacing: 7) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: 0x38A8D8).opacity(0.18))
                                    .frame(width: 26, height: 26)
                                Image(systemName: "bus.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color(hex: 0x38A8D8))
                            }

                            Text("Next Transfer")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.deepSpace)
                        }
                        .padding(.leading, 3)
                        .padding(.trailing, 10)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.85), in: Capsule())
                        .overlay(Capsule().stroke(Color.white, lineWidth: 1.2))
                        .shadow(color: Color(hex: 0x49769F).opacity(0.10), radius: 4, x: 0, y: 2)

                        Spacer()

                        // Time chip
                        HStack(spacing: 5) {
                            Image(systemName: "clock")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.deepSpace)
                            Text(next.chip)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.deepSpace)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.85), in: Capsule())
                        .overlay(Capsule().stroke(Color.white, lineWidth: 1.2))
                        .shadow(color: Color(hex: 0x49769F).opacity(0.10), radius: 4, x: 0, y: 2)
                    }

                    // "Train" headline
                    Text(next.headline)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.deepSpace)
                        .padding(.top, 8)

                    // Detail lines
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(next.lines) { line in
                            Text(line.text)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.deepSpace.opacity(0.80))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(LinearGradient.glassRim, lineWidth: 1.2)
            )
            .shadow(color: Color(hex: 0x49769F).opacity(0.18), radius: 14, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: next.headline)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Continues to the next leg of the journey")
    }
}

#Preview {
    LiveJourneyView(kind: .fastest, step: 0)
        .environment(AppRouter())
}

