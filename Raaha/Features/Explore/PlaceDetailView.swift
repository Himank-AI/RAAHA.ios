import SwiftUI
import MapKit

// MARK: - Place Details View

/// Rich offline place detail view displaying static Chennai place metadata, opening status,
/// rating, address, contact information, mini-map preview, and direct route integration.
struct PlaceDetailView: View {
    let place: ExplorePlace
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            navigationHeader

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection

                    detailContent
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 28)
                }
            }
            .scrollIndicators(.hidden)
            .contentMargins(.bottom, 110, for: .scrollContent)
        }
        .raahaScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Navigation Header (safe-area aware)

    private var navigationHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            BackButton()

            Text(place.name)
                .font(.raahaHeadline)
                .foregroundStyle(Color.midnightBlue)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            Rectangle()
                .fill(Color.white.opacity(0.55))
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: 0x49769F).opacity(0.18))
                .frame(height: 1)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            PlaceImageView(place: place, style: .hero(height: 220))
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()

            LinearGradient(
                colors: [Color.clear, Color.deepSpace.opacity(0.62)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 220)
            .allowsHitTesting(false)

            Label(place.category.title, systemImage: place.symbolName)
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.deepSpace.opacity(0.78)))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
    }

    // MARK: - Detail Content

    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            titleBlock

            metaBadges

            HairlineDivider(color: Color(hex: 0x49769F).opacity(0.16))

            if let opening = place.openingStatus, !opening.isEmpty {
                detailRow(symbol: "clock.fill", title: "Hours", value: opening)
            }

            if !place.displayAddress.isEmpty {
                detailRow(symbol: "mappin.and.ellipse", title: "Address", value: place.displayAddress)
            }

            if place.shouldDisplayPhoneSection, let phone = place.phoneNumber {
                Button(action: dialPhone) {
                    detailRow(symbol: "phone.fill", title: "Phone", value: phone)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens the Phone app to call this number")
            }

            HairlineDivider(color: Color(hex: 0x49769F).opacity(0.16))

            mapPreview

            actionButtons
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.62))
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.75), lineWidth: 1)
        )
        .shadow(color: Color(hex: 0x49769F).opacity(0.16), radius: 12, x: 0, y: 5)
    }

    private var titleBlock: some View {
        Text(place.name)
            .font(.raahaTitle2)
            .foregroundStyle(Color.deepSpace)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    private var metaBadges: some View {
        FlowBadgesView(place: place)
    }

    private var mapPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location")
                .font(.raahaCaption)
                .foregroundStyle(Color.steelBlue)

            Map {
                Annotation(place.name, coordinate: place.coordinate) {
                    PlaceMapPin()
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(hex: 0x49769F).opacity(0.18), lineWidth: 1)
            )
            .disabled(true)
            .accessibilityLabel("Map preview of \(place.name)")
        }
    }

    private var actionButtons: some View {
        Button {
            router.planJourney(from: "Current Location", to: place.name)
        } label: {
            Label("Get Directions via RAAHA", systemImage: "arrow.triangle.turn.up.right.circle.fill")
        }
        .buttonStyle(PillButtonStyle(kind: .light))
        .padding(.top, 4)
        .accessibilityHint("Plans a journey to this place inside RAAHA")
    }

    // MARK: - Helpers

    private func detailRow(symbol: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.steelBlue)
                .frame(width: 24, alignment: .center)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                Text(value)
                    .font(.raahaBody)
                    .foregroundStyle(Color.deepSpace)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private func dialPhone() {
        guard let dialable = place.dialablePhoneNumber,
              let url = URL(string: "tel:\(dialable)") else { return }
        openURL(url)
    }
}

// MARK: - Flow Badges View

private struct FlowBadgesView: View {
    let place: ExplorePlace

    var body: some View {
        HStack(spacing: 8) {
            Label(place.category.title, systemImage: place.symbolName)
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.steelBlue))

            if let rating = place.ratingText {
                Label("\(rating) ★", systemImage: "star.fill")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.deepSpace)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color(hex: 0xBDD8E9)))
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
                .foregroundStyle(Color.white)
        }
        .shadow(radius: 4)
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
