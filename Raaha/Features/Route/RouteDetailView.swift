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
                            .foregroundStyle(Color.deepSpace)
                            .padding(.top, 4)

                        Text("\(option.modeCount) modes  ·  \(option.fareText)")
                            .font(.raahaTitle3)
                            .foregroundStyle(Color.steelBlue)
                    }

                    Spacer()
                }
                .padding(.top, 4)

                // Journey Endpoints (Styled cleanly like reference without card container)
                endpointsSection
                    .padding(.top, 16)

                // Steps Card with expandable legs
                stepsCard
                    .padding(.top, 18)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .contentMargins(.bottom, 24, for: .scrollContent)
        .safeAreaInset(edge: .bottom) {
            Button {
                router.push(.live(kind, 0))
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk.motion")
                    Text("Start Live Journey")
                }
            }
            .buttonStyle(.pillLight)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .padding(.top, 8)
            .sensoryFeedback(.impact(weight: .medium), trigger: kind)
        }
        .background(LinearGradient.raahaScreen.ignoresSafeArea())
        .pushedChrome()
        .onAppear {
            expandedLegIds.removeAll()
        }
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
                    .fill(Color.honeydew)
                    .frame(width: 34, height: 34)
                    .shadow(color: Color.deepSpace.opacity(0.08), radius: 4, x: 0, y: 2)

                if isDestination {
                    Image("icon_pin")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(Color.deepSpace)
                } else {
                    Circle()
                        .fill(Color.deepSpace)
                        .frame(width: 10, height: 10)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.steelBlue)

                Text(value)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.deepSpace)
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
                    .foregroundStyle(Color.honeydew)
                Spacer()
                Text("Tap step to expand")
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.frostedBlue.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            HairlineDivider(color: Color.frostedBlue.opacity(0.2))

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
                    ModeBadge(mode: leg.mode, size: 44, fill: Color.honeydew)
                    if !isLast {
                        DashedVLine()
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, 2)
                    }
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(leg.title)
                                .font(.raahaHeadline)
                                .foregroundStyle(Color.honeydew)
                            Text(leg.detail)
                                .font(.raahaSubheadline)
                                .foregroundStyle(Color.honeydew.opacity(0.9))
                            Text(leg.description)
                                .font(.raahaFootnote)
                                .foregroundStyle(Color.frostedBlue)
                                .fixedSize(horizontal: false, vertical: true)

                            // Walk does not show lighting per user instructions
                            if let lighting = leg.lighting, leg.mode != .walk {
                                LightingTag(lighting: lighting)
                                    .padding(.top, 4)
                            }
                        }

                        Spacer(minLength: 8)

                        VStack(alignment: .trailing, spacing: 8) {
                            if let fare = leg.fare {
                                FareChip(mode: leg.mode, text: fare)
                            }

                            // Show chevron only for expandable modes (e.g. Metro, Bus, Train)
                            if isExpandable {
                                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.frostedBlue)
                            }
                        }
                    }
                    .padding(.top, 2)
                    .padding(.bottom, isExpanded && isExpandable ? 8 : 14)

                    // Expanded step details
                    if isExpanded && isExpandable {
                        expandedLegDetails(for: leg)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .padding(.bottom, 12)
                    }

                    if !isLast {
                        HairlineDivider(color: Color.frostedBlue.opacity(0.2))
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
                .fill(Color.deepSpace.opacity(0.6))
        )
    }

    private func guidancePill(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.frostedBlue)
                .frame(width: 16)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.honeydew)
            Spacer()
        }
    }
}

private struct FareChip: View {
    let mode: TransportMode
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "ticket")
            Text(text)
        }
        .font(.raahaCaption)
        .foregroundStyle(Color.frostedBlue)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .overlay(Capsule().stroke(Color.frostedBlue.opacity(0.6), lineWidth: 1))
    }
}
