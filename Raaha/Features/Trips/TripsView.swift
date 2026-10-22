import SwiftUI

struct TripsView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "Saved journeys", action: "See all", showsChevron: true)

                    HStack(spacing: 12) {
                        ForEach(MockData.savedJourneys) { journey in
                            SavedJourneyCard(journey: journey) {
                                router.planJourney(from: "Current Location", to: journey.name)
                            }
                        }
                    }

                    SectionHeader(title: "Recent trips", action: "See all", showsChevron: true)
                        .padding(.top, 4)

                    VStack(spacing: 8) {
                        ForEach(MockData.recentTrips) { trip in
                            RecentTripRow(trip: trip) {
                                // parse "A → B" routes into from/to
                                let parts = trip.route.components(separatedBy: " → ")
                                let from = parts.first ?? "Current Location"
                                let to   = parts.last  ?? trip.route
                                router.planJourney(from: from, to: to)
                            }
                        }
                    }

                    SmartRouteBanner {
                        router.planJourney(from: "Current Location", to: router.journeyTo)
                    }
                        .padding(.top, 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 22)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
        }
        .background(LinearGradient.raahaScreen.ignoresSafeArea())
        .navyHeaderChrome()
    }

    private var header: some View {
        NavyHeader {
            VStack(alignment: .leading, spacing: 8) {
                Text("Trips")
                    .font(.raahaTitle)
                    .foregroundStyle(Color.honeydew)
                    .accessibilityAddTraits(.isHeader)
                Text("Your saved journeys, recent trips and quick access to get you moving.")
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.frostedBlue)

                quickAccess
                    .padding(.top, 4)
            }
        }
    }

    private var quickAccess: some View {
        Button {
            router.planJourney(from: "Chennai", to: "T. Nagar")
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "house.fill")
                    .font(.raahaTitle2)
                    .foregroundStyle(Color.deepSpace)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Color.frostedBlue))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Home → Work")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.deepSpace)
                    Text("Chennai → T. Nagar")
                        .font(.raahaSubheadline)
                        .foregroundStyle(Color.steelBlue)
                    Text("via Metro + Walk")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.steelBlue)
                }

                Spacer(minLength: 4)

                VStack(alignment: .trailing, spacing: 14) {
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill")
                        Text("Quick access")
                    }
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.strawberry)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.strawberry.opacity(0.14)))

                    Image(systemName: "chevron.right")
                        .font(.raahaBody)
                        .foregroundStyle(Color.steelBlue)
                }
            }
            .padding(12)
            .lightCard(radius: 24)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

struct SavedJourneyCard: View {
    let journey: SavedJourney
    let action: () -> Void
    @State private var bookmarked: Bool

    init(journey: SavedJourney, action: @escaping () -> Void) {
        self.journey = journey
        self.action = action
        _bookmarked = State(initialValue: journey.isBookmarked)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Image(journey.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                    Spacer()
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        bookmarked.toggle()
                    } label: {
                        Image(systemName: bookmarked ? "bookmark.fill" : "bookmark")
                            .font(.raahaTitle3)
                            .foregroundStyle(Color.steelBlue)
                            .frame(width: 44, height: 44)
                    }
                    .offset(x: 8, y: -8)
                    .accessibilityLabel(bookmarked ? "Remove bookmark" : "Bookmark")
                }

                Spacer(minLength: 10)

                Text(journey.name)
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.deepSpace)
                Text(journey.route)
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                    .padding(.top, 2)

                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.raahaFootnoteSemibold)
                        .foregroundStyle(Color.steelBlue)
                }
            }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
        .lightCard(radius: 24)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture(perform: action)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isButton)
    }
}

struct RecentTripRow: View {
    let trip: RecentTrip
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Group {
                    if let asset = trip.customAsset {
                        Image(asset)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: trip.symbol)
                            .font(.raahaBody)
                    }
                }
                .foregroundStyle(Color.honeydew)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.steelBlue))

                VStack(alignment: .leading, spacing: 3) {
                    Text(trip.route)
                        .font(.raahaFootnoteSemibold)
                        .foregroundStyle(Color.deepSpace)
                    Text(trip.mode)
                        .font(.raahaCaption)
                        .foregroundStyle(Color.steelBlue)
                }

                Spacer(minLength: 4)

                VStack(alignment: .trailing, spacing: 3) {
                    Text(trip.day)
                        .font(.raahaCaption)
                        .foregroundStyle(Color.steelBlue)
                    Text(trip.time)
                        .font(.raahaFootnoteSemibold)
                        .foregroundStyle(Color.deepSpace)
                }

                Image(systemName: "chevron.right")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.steelBlue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .lightCard(radius: 18)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}
