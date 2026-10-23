import SwiftUI

struct RouteOptionsView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            JourneyMapView()

            BottomPanel {
                VStack(spacing: 12) {
                    // Journey endpoints summary
                    endpointBanner
                        .padding(.horizontal, 4)

                    // Route options cards (single tap navigates directly to route detail)
                    VStack(spacing: 10) {
                        ForEach(MockData.routes) { option in
                            RouteOptionRow(option: option) {
                                router.push(.routeDetail(option.kind))
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .pushedChrome(title: "Chennai Route Options")
    }

    // MARK: - Endpoint Banner
    private var endpointBanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Label(router.journeyFrom, systemImage: "location.fill")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image("icon_pin")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                    Text(router.journeyTo)
                }
                .font(.raahaCaption.weight(.semibold))
                .foregroundStyle(Color.deepSpace)
                .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(MockData.routes.count) Multimodal")
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.steelBlue)
                Text("Options Available")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.deepSpace)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .lightCard(radius: 18)
    }
}

// MARK: - Route Option Row
private struct RouteOptionRow: View {
    let option: RouteOption
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 0) {
                // Colored left accent bar keyed to route kind
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(option.kind.badgeFill)
                    .frame(width: 4)
                    .padding(.vertical, 12)

                HStack(alignment: .center, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        RouteBadge(kind: option.kind)

                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("Est.")
                                .font(.raahaFootnote)
                                .foregroundStyle(Color.steelBlue)
                            Text("\(option.minutes) min")
                                .font(.raahaTitle3)
                                .foregroundStyle(Color.honeydew)
                        }

                        modeChain
                    }

                    Spacer(minLength: 0)

                    Rectangle()
                        .fill(Color.frostedBlue.opacity(0.3))
                        .frame(width: 1)
                        .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Est. Cost")
                            .font(.raahaCaption)
                            .foregroundStyle(Color.frostedBlue.opacity(0.8))
                        Text(option.fareText)
                            .font(.raahaTitle3)
                            .foregroundStyle(Color.honeydew)
                        Text(option.modesText)
                            .font(.raahaCaption2)
                            .foregroundStyle(Color.steelBlue)

                        HStack(spacing: 3) {
                            Text("Steps")
                                .font(.system(size: 11, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(Color.frostedBlue)
                        .padding(.top, 2)
                    }
                    .frame(width: 84, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, minHeight: 88)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient.raahaNavy)
            )
            .shadow(color: Color.deepSpace.opacity(0.12), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(option.kind.title), \(option.minutes) minutes, \(option.fareText), \(option.modesText)")
        .accessibilityHint("Shows the step-by-step route")
    }

    private var modeChain: some View {
        HStack(spacing: 0) {
            ForEach(Array(option.chain.enumerated()), id: \.offset) { index, mode in
                if index > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color.frostedBlue.opacity(0.7))
                                .frame(width: 2.5, height: 2.5)
                        }
                    }
                    .padding(.horizontal, 3)
                }
                ModeBadge(mode: mode, size: 28)
            }
        }
    }
}
