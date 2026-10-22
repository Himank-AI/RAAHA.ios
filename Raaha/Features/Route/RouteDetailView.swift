import SwiftUI

struct RouteDetailView: View {
    let kind: RouteKind
    @EnvironmentObject private var router: AppRouter

    private var option: RouteOption { MockData.route(kind) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RouteBadge(kind: kind)

                Text("\(option.minutes) min")
                    .font(.raahaLargeTitle)
                    .foregroundStyle(Color.deepSpace)
                    .padding(.top, 6)

                Text("\(option.modeCount) modes  ·  \(option.fareText)")
                    .font(.raahaTitle3)
                    .foregroundStyle(Color.steelBlue)
                    .padding(.top, 2)

                // Use router.journeyFrom / journeyTo
                VStack(alignment: .leading, spacing: 12) {
                    endpoint(symbol: "dot.circle.fill",
                             label: "FROM",
                             value: router.journeyFrom)
                    endpoint(asset: "icon_pin",
                             label: "TO",
                             value: router.journeyTo)
                }
                .padding(.top, 18)

                stepsCard
                    .padding(.top, 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .contentMargins(.bottom, 24, for: .scrollContent)
        .safeAreaInset(edge: .bottom) {
            Button("Start Journey") {
                router.push(.live(kind, 0))
            }
            .buttonStyle(.pillLight)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .padding(.top, 8)
        }
        .background(LinearGradient.raahaScreen.ignoresSafeArea())
        .pushedChrome()
    }

    private func endpoint(symbol: String? = nil, asset: String? = nil, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Group {
                if let asset {
                    Image(asset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                } else if let symbol {
                    Image(systemName: symbol)
                        .font(.raahaBody)
                }
            }
            .foregroundStyle(Color.deepSpace)
            .frame(width: 32, height: 32)
            .background(Circle().fill(Color.honeydew))
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.steelBlue)
                Text(value)
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.deepSpace)
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Steps

    private var stepsCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(Array(option.legs.enumerated()), id: \.element.id) { index, leg in
                    LegRow(leg: leg, isLast: index == option.legs.count - 1)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)

            HairlineDivider(color: Color.frostedBlue.opacity(0.3))
                .padding(.top, 8)

            summary
        }
        .navyCard(radius: 28)
    }

    private var summary: some View {
        HStack(spacing: 0) {
            stat(content: AnyView(Image(systemName: "clock").font(.raahaBody)), label: "Total Time",
                 value: "\(option.minutes) min")
            Rectangle().fill(Color.frostedBlue.opacity(0.3)).frame(width: 1, height: 32)
            stat(content: AnyView(Text("₹").font(.raahaHeadline)), label: "Total Cost",
                 value: "₹ \(option.fare)")
            Rectangle().fill(Color.frostedBlue.opacity(0.3)).frame(width: 1, height: 32)
            stat(content: AnyView(Image(systemName: "arrow.triangle.branch").font(.raahaBody)), label: "Modes",
                 value: "\(option.modeCount)")
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
    }

    private func stat(content: AnyView, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            content
                .foregroundStyle(Color.frostedBlue)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.steelBlue.opacity(0.35)))
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.frostedBlue)
                Text(value)
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.honeydew)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LegRow: View {
    let leg: RouteLeg
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 4) {
                ModeBadge(mode: leg.mode, size: 46, fill: Color.honeydew)
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
                        if let lighting = leg.lighting {
                            LightingTag(lighting: lighting)
                                .padding(.top, 4)
                        }
                    }
                    Spacer(minLength: 8)
                    if let fare = leg.fare {
                        FareChip(mode: leg.mode, text: fare)
                    }
                }
                .padding(.top, 2)
                .padding(.bottom, 14)

                if !isLast {
                    HairlineDivider()
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
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
