import MapKit
import SwiftUI

/// Event page laid out like the place page: full-bleed photograph, floating
/// facts, a visit card, and a neighbourhood map, then RAAHA directions.
struct EventDetailView: View {
    let event: EventModel

    @Environment(AppRouter.self) private var router
    @Environment(AdImpressionTracker.self) private var tracker
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var camera: MapCameraPosition
    @State private var ticketPulse = 0
    @State private var planPulse = 0

    init(event: EventModel) {
        self.event = event
        _camera = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: event.venue.latitude, longitude: event.venue.longitude),
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
            EventPhoto(event: event, height: height, pressed: false, reduceMotion: reduceMotion)
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
                Label(event.category.title, systemImage: event.category.symbol)
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.white.opacity(0.18)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.45), lineWidth: 1))

                Text(event.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: Color.oceanic001D39.opacity(0.35), radius: 8, y: 3)
                    .accessibilityAddTraits(.isHeader)

                if !event.venue.locality.isEmpty {
                    Label {
                        Text(event.venue.locality)
                    } icon: {
                        IconPin(size: 14)
                    }
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
                planPulse += 1
                EventNavigationManager.planJourney(
                    to: event,
                    placementID: "explore.events.detail",
                    router: router,
                    tracker: tracker
                )
            } label: {
                Label("Get Directions via RAAHA", systemImage: "arrow.triangle.turn.up.right.circle.fill")
            }
            .buttonStyle(PillButtonStyle(kind: .light))
            .sensoryFeedback(.impact(weight: .medium), trigger: planPulse)
            .accessibilityHint("Plans a journey to this event inside RAAHA")
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

            if showsDescription {
                Text(event.detail)
                    .font(.raahaBody)
                    .foregroundStyle(Color.steelBlue)
                    .fixedSize(horizontal: false, vertical: true)
            }

            DetailFactRow(
                symbol: "calendar",
                title: "Date and time",
                value: event.scheduleText,
                tint: Color.oceanic4E8EA2
            )

            DetailFactRow(
                symbol: "tag.fill",
                title: "Category",
                value: event.category.title,
                tint: Color.oceanic0A4174
            )

            DetailFactRow(
                symbol: "icon_pin",
                title: "Venue",
                value: event.venue.name,
                tint: Color(hex: 0x1F8A5B),
                usesAsset: true
            )

            DetailFactRow(
                symbol: "location.fill",
                title: "Address",
                value: addressText,
                tint: Color.oceanic4E8EA2
            )

            if let organiser = event.organiser, !organiser.isEmpty, !event.isSample {
                DetailFactRow(
                    symbol: "person.fill",
                    title: "Organiser",
                    value: organiser,
                    tint: Color(hex: 0xC6A15B)
                )
            }

            if let ticketURL = EventNavigationManager.ticketURL(for: event) {
                Button {
                    ticketPulse += 1
                    openURL(ticketURL)
                } label: {
                    DetailFactRow(
                        symbol: "ticket.fill",
                        title: "Tickets",
                        value: ticketValue,
                        tint: Color.oceanic0A4174,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.impact(weight: .light), trigger: ticketPulse)
                .accessibilityHint("Opens ticket details")
            } else if let price = event.ticketPriceText, !price.isEmpty, !event.isSample {
                DetailFactRow(
                    symbol: "ticket.fill",
                    title: "Tickets",
                    value: price,
                    tint: Color.oceanic0A4174
                )
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
                Text(event.venue.locality.isEmpty ? "Chennai" : event.venue.locality)
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                    .lineLimit(1)
            }

            Map(position: $camera, interactionModes: []) {
                Annotation(event.title, coordinate: coordinate) {
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
            .accessibilityLabel("Map preview of \(event.venue.name)")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel()
    }

    // MARK: - Facts

    private var stats: [PlaceStat] {
        var items = [
            PlaceStat(
                id: "date",
                symbol: "calendar",
                value: EventDetailFormat.day.string(from: event.startDate),
                caption: EventDetailFormat.weekday.string(from: event.startDate),
                tint: Color.oceanic4E8EA2
            ),
            PlaceStat(
                id: "time",
                symbol: "clock.fill",
                value: EventDetailFormat.time.string(from: event.startDate),
                caption: "Starts",
                tint: Color(hex: 0x1F8A5B)
            )
        ]
        if let price = event.ticketPriceText, !price.isEmpty, !event.isSample {
            items.append(PlaceStat(
                id: "tickets",
                symbol: "ticket.fill",
                value: price,
                caption: "Tickets",
                tint: Color(hex: 0xC6A15B)
            ))
        } else {
            items.append(PlaceStat(
                id: "ends",
                symbol: "hourglass",
                value: EventDetailFormat.time.string(from: event.endDate),
                caption: "Ends",
                tint: Color.oceanic0A4174
            ))
        }
        return items
    }

    private var displayTags: [String] {
        var tags = [event.category.title]
        if showsVerifiedSponsoredBadge {
            tags.append("Sponsored")
        }
        return tags
    }

    private var showsVerifiedSponsoredBadge: Bool {
        event.isSponsored && !event.isSample && event.campaignID != nil
    }

    private var showsDescription: Bool {
        !event.isSample && !event.detail.isEmpty
    }

    private var ticketValue: String {
        if let price = event.ticketPriceText, !price.isEmpty {
            return price
        }
        return "View tickets"
    }

    private var addressText: String {
        let address = event.venue.address.trimmingCharacters(in: .whitespacesAndNewlines)
        let locality = event.venue.locality.trimmingCharacters(in: .whitespacesAndNewlines)
        if address.isEmpty { return locality }
        if locality.isEmpty || address.localizedCaseInsensitiveContains(locality) {
            return address
        }
        return "\(address), \(locality)"
    }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: event.venue.latitude, longitude: event.venue.longitude)
    }
}

private enum EventDetailFormat {
    static let day: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    static let weekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter
    }()

    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}
