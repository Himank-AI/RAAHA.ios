import SwiftUI

struct RouteOptionsView: View {
    @Environment(AppRouter.self) private var router
    @State private var selectedRoute: RouteKind = .fastest
    @State private var isPanelExpanded: Bool = true

    private var selectedOption: RouteOption {
        MockData.routes.first { $0.kind == selectedRoute } ?? MockData.routes[0]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            JourneyMapView()

            BottomPanel(isExpanded: $isPanelExpanded) {
                VStack(spacing: 12) {
                    // Route options cards
                    ForEach(MockData.routes) { option in
                        RouteOptionRow(
                            option: option,
                            isSelected: selectedRoute == option.kind
                        ) {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                                selectedRoute = option.kind
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, isPanelExpanded ? 20 : 266)
                .animation(.snappy(duration: 0.3), value: isPanelExpanded)
            }

            // Floating confirm button — always pinned to bottom, independent of panel state
            confirmButton
                .padding(.horizontal, 20)
                .padding(.bottom, -10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .pushedChrome(title: "Chennai Route Options")
    }

    // MARK: - Confirm Selection Button
    private var confirmButton: some View {
        Button {
            router.push(.routeDetail(selectedRoute))
        } label: {
            Text("Confirm \(selectedOption.kind.title) Route")
                .font(.raahaHeadline)
        }
        .buttonStyle(.pillLight)
        .animation(.spring(response: 0.30, dampingFraction: 0.75), value: selectedRoute)
        .accessibilityLabel("Confirm \(selectedOption.kind.title) Route")
        .accessibilityHint("Navigates to the step-by-step route details")
    }
}

// MARK: - Route Option Row
private struct RouteOptionRow: View {
    let option: RouteOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Top Row: Badge on left, Selection Indicator on right
                HStack(alignment: .center) {
                    badgeView
                    Spacer()
                    selectionIndicator
                }

                // Bottom Row: Duration & Modes on left, Price on right
                HStack(alignment: .bottom, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("Est.")
                                .font(.raahaFootnote)
                                .foregroundStyle(Color.steelBlue.opacity(0.8))

                            Text("\(option.minutes) min")
                                .font(.raahaTitle3)
                                .foregroundStyle(Color.midnightBlue)
                        }
                        .lineLimit(1)

                        modeChain
                    }

                    Spacer(minLength: 8)

                    // Right Column: Est. Cost & Price
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Est. Cost")
                            .font(.raahaCaption)
                            .foregroundStyle(Color.steelBlue.opacity(0.8))

                        Text(option.fareText)
                            .font(.raahaTitle3.weight(.bold))
                            .foregroundStyle(Color.royalBlue)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(isSelected ? 0.72 : 0.55))
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        isSelected
                            ? LinearGradient(
                                colors: [Color(hex: 0x4E8EA2), Color(hex: 0x7BBDE8).opacity(0.60)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.white.opacity(0.80), Color(hex: 0xBDD8E9).opacity(0.50)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        lineWidth: isSelected ? 2.0 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: 0x4E8EA2).opacity(0.30) : Color(hex: 0x49769F).opacity(0.14),
                radius: isSelected ? 10 : 6,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.015 : 1.0)
            .opacity(isSelected ? 1.0 : 0.88)
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(option.kind.title), \(option.minutes) minutes, \(option.fareText)\(isSelected ? ", Selected" : "")")
        .accessibilityHint("Selects this route option")
    }

    // MARK: - Selection Indicator
    private var selectionIndicator: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color(hex: 0x4E8EA2))
                    .frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Color.white)
            } else {
                Circle()
                    .stroke(Color(hex: 0x49769F).opacity(0.40), lineWidth: 1.5)
                    .frame(width: 24, height: 24)
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }

    // MARK: - Badge View
    private var badgeView: some View {
        HStack(spacing: 5) {
            badgeIcon
            Text(option.kind.title)
                .font(.raahaFootnoteSemibold)
        }
        .foregroundStyle(badgeTextColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(badgeBackground))
        .fixedSize()
    }

    @ViewBuilder
    private var badgeIcon: some View {
        switch option.kind {
        case .fastest:
            Image(systemName: "bolt.fill")
                .font(.raahaCaption2)
        case .cheapest:
            Image(systemName: "indianrupeesign")
                .font(.system(size: 12, weight: .bold))
        case .comfortable:
            Image(systemName: "sparkles")
                .font(.raahaCaption2)
        case .safest:
            Image(systemName: "shield.fill")
                .font(.raahaCaption2)
        }
    }

    private var badgeBackground: Color {
        switch option.kind {
        case .fastest:     return Color(hex: 0x457B9D)
        case .cheapest:    return Color(hex: 0x299D8F)
        case .comfortable: return Color(hex: 0xA8DADC)
        case .safest:      return Color(hex: 0x18866B)
        }
    }

    private var badgeTextColor: Color {
        switch option.kind {
        case .comfortable:
            return Color(hex: 0x1D3557)
        default:
            return Color.white
        }
    }

    // MARK: - Mode Chain
    private var modeChain: some View {
        HStack(spacing: 0) {
            ForEach(Array(option.chain.enumerated()), id: \.offset) { index, mode in
                if index > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color(hex: 0x49769F).opacity(0.45))
                                .frame(width: 2.5, height: 2.5)
                        }
                    }
                    .padding(.horizontal, 2.5)
                }

                ZStack {
                    Circle()
                        .fill(Color(hex: 0x7BBDE8).opacity(0.18))
                        .background(.regularMaterial, in: Circle())
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(Color(hex: 0x49769F).opacity(0.25), lineWidth: 0.8))

                    modeGlyph(for: mode)
                        .frame(width: 14, height: 14)
                }
            }
        }
    }

    @ViewBuilder
    private func modeGlyph(for mode: TransportMode) -> some View {
        Group {
            switch mode {
            case .walk:
                Image(systemName: "figure.walk")
            case .bus:
                Image(systemName: "bus.fill")
            case .metro, .train:
                Image(systemName: "tram.fill")
            case .auto, .cab, .car:
                Image(systemName: "car.fill")
            case .bike:
                Image(systemName: "bicycle")
            }
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(Color(hex: 0x4E8EA2))
    }
}
