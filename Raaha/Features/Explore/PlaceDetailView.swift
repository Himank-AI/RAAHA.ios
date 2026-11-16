import SwiftUI
import MapKit

// MARK: - Place Details View

/// Editorial place page. A full-bleed photograph gives way to floating facts,
/// a visit card, and a neighbourhood map, then hands off to RAAHA directions.
struct PlaceDetailView: View {
    let place: ExplorePlace
    @Environment(AppRouter.self) private var router
    @Environment(\.openURL) private var openURL
    @State private var camera: MapCameraPosition

    init(place: ExplorePlace) {
        self.place = place
        _camera = State(initialValue: .region(MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        )))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(spacing: 16) {
                        hero(width: geo.size.width)
                        details
                    }
                    .frame(width: geo.size.width, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .ignoresSafeArea(edges: .top)

                BackButton()
                    .padding(.leading, 16)
                    .padding(.top, 8)
            }
        }
        .raahaScreenBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: - Hero

    private func hero(width: CGFloat) -> some View {
        let height: CGFloat = 360
        return ZStack(alignment: .bottomLeading) {
            PlaceImageView(place: place, style: .hero(height: height))
                .frame(width: width, height: height)
                .clipped()
                .allowsHitTesting(false)

            LinearGradient(
                stops: [
                    .init(color: Color.oceanic001D39.opacity(0.18), location: 0),
                    .init(color: Color.clear, location: 0.34),
                    .init(color: Color.oceanic001D39.opacity(0.78), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: width, height: height)
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 8) {
                Label(place.category.title, systemImage: place.symbolName)
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.white.opacity(0.18)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.45), lineWidth: 1))

                Text(place.name)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: Color.oceanic001D39.opacity(0.35), radius: 8, y: 3)
                    .accessibilityAddTraits(.isHeader)

                if !place.locality.isEmpty {
                    Label(place.locality, systemImage: "mappin.and.ellipse")
                        .font(.raahaSubheadlineMedium)
                        .foregroundStyle(Color.white.opacity(0.92))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .frame(width: width, alignment: .leading)
        }
        .frame(width: width, height: height)
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: 32,
                bottomTrailingRadius: 32,
                style: .continuous
            )
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - Details

    private var details: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !stats.isEmpty {
                HStack(spacing: 10) {
                    ForEach(stats) { stat in
                        StatTile(stat: stat)
                    }
                }
            }

            if !displayTags.isEmpty {
                ChipFlow(spacing: 8) {
                    ForEach(displayTags, id: \.self) { tag in
                        Text(tag)
                            .font(.raahaFootnoteSemibold)
                            .foregroundStyle(Color.oceanic0A4174)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(Color.white.opacity(0.72)))
                            .overlay(Capsule().stroke(Color.white.opacity(0.9), lineWidth: 1))
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Tags: \(displayTags.joined(separator: ", "))")
            }

            visitCard

            mapCard

            Button {
                router.planJourney(from: "Current Location", to: place.name)
            } label: {
                Label("Get Directions via RAAHA", systemImage: "arrow.triangle.turn.up.right.circle.fill")
            }
            .buttonStyle(PillButtonStyle(kind: .light))
            .accessibilityHint("Plans a journey to this place inside RAAHA")
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var visitCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Plan a visit")
                .font(.raahaHeadline)
                .foregroundStyle(Color.deepSpace)

            if let opening = place.openingStatus, !opening.isEmpty {
                detailRow(
                    symbol: "clock.fill",
                    title: hoursHeadline,
                    value: opening,
                    tint: place.isOpenNow == false ? Color.strawberry : Color(hex: 0x1F8A5B)
                )
            }

            if !place.displayAddress.isEmpty {
                detailRow(
                    symbol: "mappin.and.ellipse",
                    title: "Address",
                    value: place.displayAddress,
                    tint: Color.oceanic4E8EA2
                )
            }

            if place.shouldDisplayPhoneSection, let phone = place.phoneNumber {
                Button(action: dialPhone) {
                    detailRow(
                        symbol: "phone.fill",
                        title: "Call",
                        value: phone,
                        tint: Color.oceanic0A4174,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens the Phone app to call this number")
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel()
    }

    private var mapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("On the map")
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.deepSpace)
                Spacer(minLength: 8)
                Text(place.locality.isEmpty ? "Chennai" : place.locality)
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                    .lineLimit(1)
            }

            Map(position: $camera, interactionModes: []) {
                Annotation(place.name, coordinate: place.coordinate) {
                    PlaceMapPin()
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .frame(height: 196)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            )
            .disabled(true)
            .accessibilityLabel("Map preview of \(place.name)")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel()
    }

    // MARK: - Facts

    private var stats: [PlaceStat] {
        var items: [PlaceStat] = []
        if let rating = place.ratingText {
            let reviews = reviewText.map { "\($0) reviews" } ?? "Rating"
            items.append(PlaceStat(id: "rating", symbol: "star.fill", value: rating, caption: reviews, tint: Color(hex: 0xC6A15B)))
        }
        if let distance = distanceValue {
            items.append(PlaceStat(id: "distance", symbol: "location.fill", value: distance, caption: "from you", tint: Color.oceanic4E8EA2))
        }
        if let opening = place.openingStatus, !opening.isEmpty {
            items.append(PlaceStat(
                id: "hours",
                symbol: "clock.fill",
                value: hoursHeadline,
                caption: hoursCaption,
                tint: place.isOpenNow == false ? Color.strawberry : Color(hex: 0x1F8A5B)
            ))
        }
        return items
    }

    private var hoursHeadline: String {
        guard let status = place.openingStatus?.lowercased() else { return "Hours" }
        if status.contains("24") { return "All day" }
        if place.isOpenNow == false { return "Closed" }
        return "Open"
    }

    private var hoursCaption: String {
        guard let status = place.openingStatus else { return "Hours" }
        if status.lowercased().contains("24") { return "Open 24 hours" }
        return place.isOpenNow == false ? "Check hours" : "Welcoming now"
    }

    private var distanceValue: String? {
        place.distanceText?.replacingOccurrences(of: " away", with: "")
    }

    private var reviewText: String? {
        guard let count = place.reviewCount, count > 0 else { return nil }
        if count >= 1000 {
            let compact = String(format: "%.1f", Double(count) / 1000)
            let trimmed = compact.hasSuffix(".0") ? String(compact.dropLast(2)) : compact
            return "\(trimmed)k"
        }
        return "\(count)"
    }

    private var displayTags: [String] {
        var seen = Set<String>()
        return place.tags.compactMap { raw in
            let cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleaned.isEmpty else { return nil }
            let titled = cleaned.capitalized
            let key = titled.lowercased()
            guard seen.insert(key).inserted else { return nil }
            return titled
        }
        .prefix(6)
        .map { $0 }
    }

    private func detailRow(
        symbol: String,
        title: String,
        value: String,
        tint: Color,
        showsChevron: Bool = false
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(Circle().fill(tint.opacity(0.14)))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                    .lineLimit(1)
                Text(value)
                    .font(.raahaBody)
                    .foregroundStyle(Color.deepSpace)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 8)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.steelBlue.opacity(0.7))
                    .padding(.top, 10)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func dialPhone() {
        guard let dialable = place.dialablePhoneNumber,
              let url = URL(string: "tel:\(dialable)") else { return }
        openURL(url)
    }
}

// MARK: - Stat tile

private struct PlaceStat: Identifiable {
    let id: String
    let symbol: String
    let value: String
    let caption: String
    let tint: Color
}

private struct StatTile: View {
    let stat: PlaceStat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: stat.symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(stat.tint)
                .accessibilityHidden(true)
            Text(stat.value)
                .font(.raahaHeadline)
                .foregroundStyle(Color.deepSpace)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(stat.caption)
                .font(.raahaCaption2)
                .foregroundStyle(Color.steelBlue)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .glassPanel(radius: 18)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Glass

private extension View {
    func glassPanel(radius: CGFloat = 24) -> some View {
        background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: radius, style: .continuous)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color(hex: 0x0A4174).opacity(0.08), radius: 14, y: 8)
    }
}

// MARK: - Wrapping chips

private struct ChipFlow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        guard width > 0 else {
            let height = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            return CGSize(width: 0, height: height)
        }
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: size.width, height: size.height))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}

// MARK: - Place Map Pin

private struct PlaceMapPin: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 42, height: 42)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x7BBDE8), Color(hex: 0x0A4174)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 32, height: 32)
            Image("icon_pin")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundStyle(Color.white)
        }
        .shadow(color: Color.oceanic001D39.opacity(0.28), radius: 8, y: 4)
    }
}

#Preview("Restaurant") {
    NavigationStack {
        PlaceDetailView(place: ExploreMockData.muruganIdliShop)
    }
    .environment(AppRouter())
}

#Preview("Beach") {
    NavigationStack {
        PlaceDetailView(place: ExploreMockData.marinaBeach)
    }
    .environment(AppRouter())
}

#Preview("Shopping") {
    NavigationStack {
        PlaceDetailView(place: ExploreMockData.ranganathanStreet)
    }
    .environment(AppRouter())
}
