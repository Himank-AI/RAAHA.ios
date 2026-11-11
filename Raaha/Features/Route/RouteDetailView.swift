import SwiftUI

struct RouteDetailView: View {
    let kind: RouteKind
    @EnvironmentObject private var router: AppRouter
    @State private var expandedLegIds: Set<String> = []

    private var option: RouteOption { MockData.route(kind) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header info
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        RouteBadge(kind: kind)

                        Text("\(option.minutes) min")
                            .font(.raahaLargeTitle)
                            .foregroundStyle(Color.midnightBlue)
                            .padding(.top, 4)

                        HStack(spacing: 6) {
                            Text("\(option.modeCount) modes  ·")
                                .font(.raahaTitle3)
                                .foregroundStyle(Color.steelBlue)

                            Text(option.fareText)
                                .font(.raahaTitle3.weight(.bold))
                                .foregroundStyle(Color.royalBlue)
                        }
                    }

                    Spacer()
                }
                .padding(.top, 4)

                // Journey Endpoints
                endpointsSection
                    .padding(.top, 16)

                // Steps Card with expandable legs
                stepsCard
                    .padding(.top, 18)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .contentMargins(.bottom, 28, for: .scrollContent)
        .safeAreaInset(edge: .bottom) {
            SlideToStartJourneyButton(title: "Start Live Journey") {
                router.push(.live(kind, 0))
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: 0x4E8EA2).opacity(0.0),
                        Color(hex: 0x4E8EA2).opacity(0.20),
                        Color(hex: 0x49769F).opacity(0.55)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .bottom)
            )
        }
        // Fixed background illustration — pinned to top-right, does NOT scroll
        .background(alignment: .topTrailing) {
            transitIllustration
                .ignoresSafeArea(edges: .top)
        }
        .raahaScreenBackground()
        .pushedChrome()
        .onAppear {
            expandedLegIds.removeAll()
        }
    }

    // MARK: - Transit Illustration Background
    /// Fixed non-scrolling background illustration pinned to top-right corner.
    private var transitIllustration: some View {
        Image("transit_illustration")
            .resizable()
            .scaledToFill()
            .opacity(0.70)
            .frame(
                width: UIScreen.main.bounds.width * 0.65,
                height: UIScreen.main.bounds.height * 0.42
            )
            .clipped()
            // Left-edge fade + bottom-edge fade combined via nested mask
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black.opacity(0.40), location: 0.14),
                        .init(color: .black.opacity(0.80), location: 0.32),
                        .init(color: .black, location: 0.52)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0.0),
                            .init(color: .black, location: 0.62),
                            .init(color: .black.opacity(0.60), location: 0.82),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            )
            .allowsHitTesting(false)
    }

    // MARK: - Endpoints Section (Matches 2nd Attached Image)
    private var endpointsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            endpointRow(
                isDestination: false,
                label: "FROM",
                value: router.journeyFrom
            )
            endpointRow(
                isDestination: true,
                label: "TO",
                value: router.journeyTo
            )
        }
        .padding(.horizontal, 4)
    }

    private func endpointRow(isDestination: Bool, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.70))
                    .background(.regularMaterial, in: Circle())
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(Color.white.opacity(0.75), lineWidth: 1))
                    .shadow(color: Color(hex: 0x49769F).opacity(0.18), radius: 4, x: 0, y: 2)

                if isDestination {
                    Image("icon_pin")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(Color(hex: 0x0A4174))
                } else {
                    Circle()
                        .fill(Color(hex: 0x4E8EA2))
                        .frame(width: 10, height: 10)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.steelBlue)

                Text(value)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.midnightBlue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Steps Card
    private var stepsCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Step-by-Step Directions")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.midnightBlue)
                Spacer()
                Text("Tap step to expand")
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.steelBlue.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            HairlineDivider(color: Color(hex: 0x49769F).opacity(0.15))

            VStack(spacing: 0) {
                ForEach(Array(option.legs.enumerated()), id: \.element.id) { index, leg in
                    let isExpanded = expandedLegIds.contains(leg.id)
                    InteractiveLegRow(
                        leg: leg,
                        isLast: index == option.legs.count - 1,
                        isExpanded: isExpanded,
                        onToggleExpand: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                if isExpanded {
                                    expandedLegIds.remove(leg.id)
                                } else {
                                    expandedLegIds.insert(leg.id)
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 14)
        }
        .navyCard(radius: 24)
    }
}

// MARK: - Interactive Leg Row
private struct InteractiveLegRow: View {
    let leg: RouteLeg
    let isLast: Bool
    let isExpanded: Bool
    let onToggleExpand: () -> Void

    // Walk and Auto do not have dropdowns per user instructions
    private var isExpandable: Bool {
        leg.mode == .metro || leg.mode == .bus || leg.mode == .train
    }

    var body: some View {
        Button {
            if isExpandable {
                onToggleExpand()
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                VStack(spacing: 4) {
                    ModeBadge(mode: leg.mode, size: 44, fill: Color.white.opacity(0.75), tint: Color(hex: 0x0A4174))
                    if !isLast {
                        DashedVLine(color: Color(hex: 0x4E8EA2).opacity(0.40))
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, 2)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    // Top header line: Title (+ expand indicator) & Fare Chip uniformly right-aligned
                    HStack(alignment: .center, spacing: 8) {
                        HStack(spacing: 6) {
                            legTitleView(for: leg.title)

                            // Show chevron indicator directly beside expandable mode titles (e.g. Metro)
                            if isExpandable {
                                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color(hex: 0x4E8EA2))
                            }
                        }

                        Spacer(minLength: 8)

                        if let fare = leg.fare {
                            FareChip(mode: leg.mode, text: fare)
                        }
                    }
                    .padding(.top, 2)

                    Text(leg.detail)
                        .font(.raahaSubheadline)
                        .foregroundStyle(Color.midnightBlue.opacity(0.85))

                    Text(leg.description)
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.steelBlue)
                        .fixedSize(horizontal: false, vertical: true)

                    // Walk does not show lighting per user instructions
                    if let lighting = leg.lighting, leg.mode != .walk {
                        LightingTag(lighting: lighting)
                            .padding(.top, 4)
                    }

                    // Expanded step details
                    if isExpanded && isExpandable {
                        expandedLegDetails(for: leg)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .padding(.top, 4)
                            .padding(.bottom, 6)
                    }

                    if !isLast {
                        HairlineDivider(color: Color(hex: 0x49769F).opacity(0.12))
                            .padding(.top, 8)
                            .padding(.bottom, 6)
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .sensoryFeedback(.selection, trigger: isExpanded)
    }

    @ViewBuilder
    private func legTitleView(for title: String) -> some View {
        if title.contains("(Green Line)") {
            HStack(spacing: 4) {
                Text(title.replacingOccurrences(of: "(Green Line)", with: "").trimmingCharacters(in: .whitespaces))
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.midnightBlue)

                Text("(Green Line)")
                    .font(.raahaHeadline)
                    .foregroundStyle(Color(hex: 0x18866B))
            }
        } else {
            Text(title)
                .font(.raahaHeadline)
                .foregroundStyle(Color.midnightBlue)
        }
    }

    @ViewBuilder
    private func expandedLegDetails(for leg: RouteLeg) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            switch leg.mode {
            case .metro:
                guidancePill(icon: "tram.fill", text: "Platform 2 • Washermanpet to Airport Corridor")
            case .bus:
                guidancePill(icon: "bus.fill", text: "MTC Bus Bay 4 • Frequency every 5–10 mins")
                guidancePill(icon: "ticket.fill", text: "Singara Chennai Card & Cash Accepted")
            case .train:
                guidancePill(icon: "train.side.front.car", text: "Suburban Platform 1 • Beach–Tambaram Fast")
            default:
                EmptyView()
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.60))
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(hex: 0xBDD8E9).opacity(0.60), lineWidth: 1)
        )
    }

    private func guidancePill(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: 0x0A4174))
                .frame(width: 16)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.midnightBlue)
            Spacer()
        }
    }
}

private struct FareChip: View {
    let mode: TransportMode
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "ticket")
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(Color.royalBlue)
        .padding(.horizontal, 9)
        .padding(.vertical, 4.5)
        .background(
            Capsule()
                .fill(Color(hex: 0x7BBDE8).opacity(0.20))
                .background(.regularMaterial, in: Capsule())
        )
        .overlay(
            Capsule()
                .stroke(Color(hex: 0x49769F).opacity(0.25), lineWidth: 1)
        )
    }
}
