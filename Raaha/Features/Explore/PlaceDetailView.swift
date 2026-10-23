import SwiftUI
import MapKit

// MARK: - Place Details View

/// Rich offline place detail view displaying static Chennai place metadata, opening status,
/// rating, address, contact information, mini-map preview, and direct route integration.
struct PlaceDetailView: View {
    let place: ExplorePlace
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image / banner
                heroSection

                // Details card
                VStack(alignment: .leading, spacing: 20) {
                    // Name + category + rating
                    VStack(alignment: .leading, spacing: 8) {
                        Text(place.name)
                            .font(.raahaTitle2)
                            .foregroundStyle(Color.deepSpace)

                        // Badges row
                        FlowBadgesView(place: place)
                    }

                    HairlineDivider()

                    // Opening status
                    if let opening = place.openingStatus {
                        detailRow(
                            symbol: "clock.fill",
                            title: "Hours",
                            value: opening
                        )
                    }

                    // Address
                    if !place.address.isEmpty || place.locality != "Chennai" {
                        detailRow(
                            symbol: "mappin.and.ellipse",
                            title: "Address",
                            value: [place.address, place.locality]
                                .filter { !$0.isEmpty }
                                .joined(separator: ", ")
                        )
                    }

                    // Phone
                    if let phone = place.phoneNumber, !phone.isEmpty {
                        Button {
                            let tel = "tel:\(phone.filter { $0.isNumber || $0 == "+" })"
                            if let url = URL(string: tel) { openURL(url) }
                        } label: {
                            detailRow(symbol: "phone.fill", title: "Phone", value: phone)
                        }
                        .buttonStyle(.plain)
                    }

                    // Website
                    if let web = place.website {
                        Link(destination: web) {
                            detailRow(
                                symbol: "safari.fill",
                                title: "Website",
                                value: web.host(percentEncoded: false) ?? web.absoluteString
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    HairlineDivider()

                    // Mini Map
                    Map {
                        Annotation(place.name, coordinate: place.coordinate) {
                            PlaceMapPin()
                        }
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .disabled(true)

                    // Open in Maps button
                    Button {
                        place.openInMaps()
                    } label: {
                        Label("Open in Maps", systemImage: "map.fill")
                    }
                    .buttonStyle(PillButtonStyle(kind: .dark))

                    // Plan journey button
                    Button {
                        router.planJourney(from: "Current Location", to: place.name)
                    } label: {
                        Label("Get Directions via RAAHA", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                    }
                    .buttonStyle(PillButtonStyle(kind: .light))
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .raahaScreenBackground()
        .pushedChrome(title: place.name)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Place photo hero or design system fallback
            PlaceImageView(place: place, style: .hero(height: 220))
                .frame(maxWidth: .infinity, maxHeight: 220)
                .clipped()

            // Bottom gradient scrim
            LinearGradient(
                colors: [Color.clear, Color.deepSpace.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 220)

            // Category badge bottom-leading
            HStack {
                Label(place.category.title, systemImage: place.symbolName)
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.honeydew)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.deepSpace.opacity(0.75)))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Detail Row

    private func detailRow(symbol: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.steelBlue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                Text(value)
                    .font(.raahaBody)
                    .foregroundStyle(Color.deepSpace)
            }

            Spacer()
        }
    }
}

// MARK: - Flow Badges View

private struct FlowBadgesView: View {
    let place: ExplorePlace

    var body: some View {
        HStack(spacing: 8) {
            Label(place.category.title, systemImage: place.symbolName)
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.honeydew)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.steelBlue))

            if let rating = place.ratingText {
                Label("\(rating) ★", systemImage: "star.fill")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.deepSpace)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.frostedBlue))
            }

            if let dist = place.distanceText {
                Label(dist, systemImage: "location.fill")
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.steelBlue)
            }
        }
    }
}

// MARK: - Place Map Pin

private struct PlaceMapPin: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.deepSpace)
                .frame(width: 34, height: 34)
            Circle()
                .fill(Color.strawberry)
                .frame(width: 28, height: 28)
            Image("icon_pin")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundStyle(Color.honeydew)
        }
        .shadow(radius: 4)
    }
}


