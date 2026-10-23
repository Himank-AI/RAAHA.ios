import SwiftUI

enum RouteListFilter: String, CaseIterable, Identifiable {
    case all = "All Routes"
    case fastest = "Fastest"
    case cheapest = "Cheapest"
    case safest = "Safest"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .all: return "line.3.horizontal.decrease.circle"
        case .fastest: return "bolt.fill"
        case .cheapest: return "indianrupeesign.circle.fill"
        case .safest: return "shield.checkered"
        }
    }
}

struct RouteOptionsView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var activeFilter: RouteListFilter = .all
    @State private var selectedKind: RouteKind = .fastest

    private var filteredRoutes: [RouteOption] {
        let all = MockData.routes
        switch activeFilter {
        case .all:
            return all
        case .fastest:
            return all.sorted { $0.minutes < $1.minutes }
        case .cheapest:
            return all.sorted { $0.fare < $1.fare }
        case .safest:
            return all.filter { $0.kind == .safest || $0.kind == .fastest }
        }
    }

    var body: some View {
        ZStack {
            JourneyMapView()

            BottomPanel {
                VStack(spacing: 12) {
                    // Journey endpoints summary
                    endpointBanner
                        .padding(.horizontal, 4)

                    // Filter selector chips
                    filterPills
                        .padding(.horizontal, 4)

                    // Route options cards
                    VStack(spacing: 8) {
                        ForEach(filteredRoutes) { option in
                            RouteOptionRow(
                                option: option,
                                isSelected: selectedKind == option.kind,
                                onSelect: {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                        selectedKind = option.kind
                                    }
                                },
                                onInspect: {
                                    router.push(.routeDetail(option.kind))
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)

                    // Quick action to start or view details of selected route
                    Button {
                        router.push(.routeDetail(selectedKind))
                    } label: {
                        HStack(spacing: 8) {
                            Text("View \(selectedKind.title) Route Details")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(.pillLight)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    .sensoryFeedback(.selection, trigger: selectedKind)
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

    // MARK: - Filter Pills
    private var filterPills: some View {
        HStack(spacing: 8) {
            ForEach(RouteListFilter.allCases) { filter in
                let isSelected = activeFilter == filter
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        activeFilter = filter
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: filter.symbol)
                            .font(.system(size: 11))
                        Text(filter.rawValue)
                            .font(.raahaCaption)
                            .fontWeight(isSelected ? .semibold : .regular)
                    }
                    .foregroundStyle(isSelected ? Color.honeydew : Color.deepSpace)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.deepSpace : Color.honeydew)
                    )
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color.clear : Color.frostedBlue.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: activeFilter)
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Route Option Row
private struct RouteOptionRow: View {
    let option: RouteOption
    let isSelected: Bool
    let onSelect: () -> Void
    let onInspect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: 0) {
                // Colored left accent bar keyed to route kind
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(option.kind.badgeFill)
                    .frame(width: isSelected ? 6 : 4)
                    .padding(.vertical, 12)

                HStack(alignment: .center, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            RouteBadge(kind: option.kind)

                            if isSelected {
                                HStack(spacing: 3) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 11))
                                    Text("Selected")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundStyle(Color.statusGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.honeydew))
                            }
                        }

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

                        // Arrow action trigger
                        Button(action: onInspect) {
                            HStack(spacing: 2) {
                                Text("Steps")
                                    .font(.system(size: 11, weight: .semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(Color.frostedBlue)
                            .padding(.top, 4)
                        }
                        .buttonStyle(.plain)
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
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? Color.frostedBlue : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: isSelected ? Color.deepSpace.opacity(0.25) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(option.kind.title), \(option.minutes) minutes, \(option.fareText), \(option.modesText)")
        .accessibilityHint("Tap to select, double tap to see step-by-step route")
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
