import SwiftUI
import MapKit

// MARK: - Place Details View

struct PlaceDetailView: View {
    let place: ExplorePlace
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image / map preview
                heroSection

                // Details card
                VStack(alignment: .leading, spacing: 20) {
                    // Name + category
                    VStack(alignment: .leading, spacing: 6) {
                        Text(place.name)
                            .font(.raahaTitle2)
                            .foregroundStyle(Color.deepSpace)

                        HStack(spacing: 8) {
                            Label(place.category.title, systemImage: place.symbolName)
                                .font(.raahaFootnoteSemibold)
                                .foregroundStyle(Color.honeydew)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.steelBlue))

                            if place.isValidChennaiLocation {
                                Label("Chennai Verified", systemImage: "checkmark.shield.fill")
                                    .font(.raahaFootnote)
                                    .foregroundStyle(Color.steelBlue)
                            }

                            if let dist = place.distanceText {
                                Label(dist, systemImage: "location.fill")
                                    .font(.raahaFootnote)
                                    .foregroundStyle(Color.steelBlue)
                            }
                        }

                        if !place.isValidChennaiLocation {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(Color.strawberry)
                                Text("Outside RAAHA Chennai Service Boundary")
                                    .font(.raahaCaption2)
                                    .foregroundStyle(Color.strawberry)
                            }
                            .padding(.top, 2)
                        }
                    }

                    HairlineDivider()

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
                            if let url = URL(string: tel) { UIApplication.shared.open(url) }
                        } label: {
                            detailRow(symbol: "phone.fill", title: "Phone", value: phone)
                        }
                        .buttonStyle(.plain)
                    }

                    // Website
                    if let web = place.website {
                        Link(destination: web) {
                            detailRow(symbol: "safari.fill", title: "Website",
                                      value: web.host(percentEncoded: false) ?? web.absoluteString)
                        }
                        .buttonStyle(.plain)
                    }

                    HairlineDivider()

                    // Map
                    Map {
                        Annotation(place.name, coordinate: place.mapItem.placemark.coordinate) {
                            PlaceMapPin()
                        }
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .disabled(true)

                    // Open in Maps button
                    Button {
                        place.mapItem.openInMaps(launchOptions: nil)
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
        .background(LinearGradient.raahaScreen.ignoresSafeArea())
        .pushedChrome(title: place.name)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Category illustration background
            Rectangle()
                .fill(LinearGradient.raahaHero)
                .frame(height: 220)

            // Category icon as hero art
            Image(systemName: place.symbolName)
                .font(.system(size: 72, weight: .thin))
                .foregroundStyle(Color.honeydew.opacity(0.35))
                .frame(maxWidth: .infinity, maxHeight: 220)

            // Bottom gradient scrim
            LinearGradient(
                colors: [Color.clear, Color.deepSpace.opacity(0.5)],
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
                .foregroundStyle(Color.honeydew)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.steelBlue))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                Text(value)
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.deepSpace)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}

// MARK: - Small pin for map annotation

private struct PlaceMapPin: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("icon_pin")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundStyle(Color.strawberry)
        }
    }
}
