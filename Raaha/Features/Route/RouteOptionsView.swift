import SwiftUI

struct RouteOptionsView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            JourneyMapView()

            BottomPanel {
                VStack(spacing: 14) {
                    // Journey endpoints summary
                    endpointBanner

                    // Route options cards (single tap navigates directly to route detail)
                    VStack(spacing: 12) {
                        ForEach(MockData.routes) { option in
                            RouteOptionRow(option: option) {
                                router.push(.routeDetail(option.kind))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .pushedChrome(title: "Chennai Route Options")
    }

    // MARK: - Endpoint Banner
    private var endpointBanner: some View {
        HStack(alignment: .center, spacing: 0) {
            // Origin & Destination
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "location.north.fill")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.lightSkyBlue)

                    Text(router.journeyFrom.isEmpty ? "Current Location" : router.journeyFrom)
                        .font(.raahaCaption)
                        .foregroundStyle(Color.lightSkyBlue)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    Image(systemName: "mappin.fill")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.neonLime)

                    Text(router.journeyTo.isEmpty ? "Phoenix Mall, Velachery" : router.journeyTo)
                        .font(.raahaCaption.weight(.semibold))
                        .foregroundStyle(Color.honeydew)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 4)
        .padding(.bottom, 2)
    }
}

// MARK: - Route Option Row
private struct RouteOptionRow: View {
    let option: RouteOption
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 0) {
                // Left Column: Badge, Duration, Mode Chain
                VStack(alignment: .leading, spacing: 8) {
                    badgeView

                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("Est.")
                            .font(.raahaFootnote)
                            .foregroundStyle(Color.lightSkyBlue.opacity(0.9))

                        Text("\(option.minutes) min")
                            .font(.raahaTitle3)
                            .foregroundStyle(Color.white)
                    }
                    .lineLimit(1)

                    modeChain
                }

                Spacer(minLength: 6)

                // Subtle vertical divider inside the card
                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 1, height: 52)
                    .padding(.horizontal, 14)

                // Right Column: Est. Cost & Price
                VStack(alignment: .leading, spacing: 4) {
                    Text("Est. Cost")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.lightSkyBlue.opacity(0.9))

                    Text(option.fareText)
                        .font(.raahaTitle3)
                        .foregroundStyle(Color.neonLime)
                        .lineLimit(1)
                }
                .frame(width: 72, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(cardGradient)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.midnightBlue.opacity(0.30), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(option.kind.title), \(option.minutes) minutes, \(option.fareText)")
        .accessibilityHint("Shows the step-by-step route")
    }

    // MARK: - Card Gradient
    private var cardGradient: LinearGradient {
        switch option.kind {
        case .fastest:
            return LinearGradient(
                colors: [Color.royalBlue.opacity(0.85), Color.midnightBlue.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cheapest:
            return LinearGradient(
                colors: [Color.electricBlue.opacity(0.65), Color.midnightBlue.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .comfortable:
            return LinearGradient(
                colors: [Color.brightBlue.opacity(0.55), Color.midnightBlue.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .safest:
            return LinearGradient(
                colors: [Color.royalBlue.opacity(0.70), Color.midnightBlue.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: - Badge View
    private var badgeView: some View {
        HStack(spacing: 5) {
            badgeIcon
                .font(.raahaCaption2)
            Text(option.kind.title)
                .font(.raahaFootnoteSemibold)
        }
        .foregroundStyle(badgeTextColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(badgeBackground))
    }

    @ViewBuilder
    private var badgeIcon: some View {
        switch option.kind {
        case .fastest:
            Image(systemName: "bolt.fill")
        case .cheapest:
            Text("₹")
        case .comfortable:
            Image(systemName: "sparkles")
        case .safest:
            Image(systemName: "shield.fill")
        }
    }

    private var badgeBackground: Color {
        switch option.kind {
        case .fastest:     return Color.brightBlue
        case .cheapest:    return Color.neonLime
        case .comfortable: return Color.lightSkyBlue
        case .safest:      return Color.neonLime
        }
    }

    private var badgeTextColor: Color {
        switch option.kind {
        case .cheapest, .safest, .comfortable:
            return Color.midnightBlue
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
                                .fill(Color.white.opacity(0.65))
                                .frame(width: 2.5, height: 2.5)
                        }
                    }
                    .padding(.horizontal, 2.5)
                }

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .background(.ultraThinMaterial, in: Circle())
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 0.8))
                        .shadow(color: Color.black.opacity(0.12), radius: 2, y: 1)

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
        .foregroundStyle(Color.honeydew)
    }
}
