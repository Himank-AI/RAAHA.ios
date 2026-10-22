import SwiftUI

struct ExploreView: View {
    enum Segment { case places, planAhead }

    @EnvironmentObject private var router: AppRouter
    @State private var segment: Segment = .places
    @State private var query = ""

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                Group {
                    switch segment {
                    case .places: PlacesContent()
                    case .planAhead: PlanAheadCard()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(LinearGradient.raahaScreen.ignoresSafeArea())
        .navyHeaderChrome()
    }

    // MARK: Header

    private var header: some View {
        NavyHeader {
            VStack(alignment: .leading, spacing: 14) {
                Text("Explore")
                    .font(.raahaTitle)
                    .foregroundStyle(Color.honeydew)
                    .accessibilityAddTraits(.isHeader)

                HStack(spacing: 12) {
                    segmentButton("Places", asset: "icon_pin", value: .places)
                    segmentButton("Plan Ahead", symbol: "calendar", value: .planAhead)
                }

                searchField
            }
        }
    }

    private func segmentButton(_ title: String, symbol: String? = nil, asset: String? = nil, value: Segment) -> some View {
        let selected = segment == value
        return Button {
            withAnimation(.snappy(duration: 0.25)) { segment = value }
        } label: {
            HStack(spacing: 8) {
                if let asset {
                    Image(asset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                } else if let symbol {
                    Image(systemName: symbol)
                }
                Text(title)
            }
            .font(.raahaSubheadlineMedium)
            .foregroundStyle(selected ? Color.honeydew : Color.deepSpace)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(selected ? Color.strawberry : Color.honeydew)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.steelBlue)
            TextField(
                "",
                text: $query,
                prompt: Text(segment == .places ? "Search places, restaurants" : "Search trips or places")
                    .foregroundStyle(Color.steelBlue)
            )
            .font(.raahaBody)
            .foregroundStyle(Color.deepSpace)
            .submitLabel(.search)
            .accessibilityLabel("Search")
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 48)
        .background(Capsule().fill(Color.honeydew))
    }
}

// MARK: - Places

private struct PlacesContent: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Explore options")

            HStack(spacing: 12) {
                ExploreOptionCard(imageName: "explore_spots", asset: "icon_pin",
                                  title: "Spots", subtitle: "Landmarks & parks")
                ExploreOptionCard(imageName: "explore_restaurants", symbol: "fork.knife",
                                  title: "Restaurants", subtitle: "Cafes & dining")
            }

            SectionHeader(title: "Nearby spots")
                .padding(.top, 4)

            VStack(spacing: 8) {
                ForEach(MockData.nearbySpots) { spot in
                    NearbySpotRow(place: spot) {
                        router.planJourney(from: "Current Location", to: spot.name)
                    }
                }
            }

            SectionHeader(title: "Featured places")
                .padding(.top, 4)

            VStack(spacing: 14) {
                ForEach(MockData.featuredPlaces) { place in
                    FeaturedPlaceCard(place: place) {
                        router.planJourney(from: "Current Location", to: place.name)
                    }
                }
            }
        }
    }
}

private struct ExploreOptionCard: View {
    let imageName: String
    var symbol: String? = nil
    var asset: String? = nil
    let title: String
    let subtitle: String

    var body: some View {
        FillImage(name: imageName, height: 118)
            .overlay(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        if let asset {
                            Image(asset)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                        } else if let symbol {
                            Image(systemName: symbol)
                        }
                        Text(title)
                    }
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.honeydew)

                    Text(subtitle)
                        .font(.raahaCaption)
                        .foregroundStyle(Color.frostedBlue)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.steelBlue.opacity(0.85), Color.deepSpace.opacity(0.92)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.deepSpace.opacity(0.15), radius: 8, x: 0, y: 4)
            .accessibilityElement(children: .combine)
    }
}

private struct NearbySpotRow: View {
    let place: Place
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                FillImage(name: place.imageName, height: 48)
                    .frame(width: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(place.name)
                        .font(.raahaSubheadlineMedium)
                        .foregroundStyle(Color.honeydew)
                    Text(place.subtitle)
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.frostedBlue.opacity(0.85))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.frostedBlue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .navyCard(radius: 18, gradient: .raahaNavyGlow)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

private struct FeaturedPlaceCard: View {
    let place: Place
    let action: () -> Void
    @State private var liked = false

    var body: some View {
        FillImage(name: place.imageName, height: 140)
            .overlay {
                LinearGradient(
                    colors: [Color.deepSpace.opacity(0.55), Color.clear],
                    startPoint: .top,
                    endPoint: .center
                )
            }
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name)
                        .font(.raahaTitle2)
                        .foregroundStyle(Color.honeydew)
                    Text(place.subtitle)
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.frostedBlue)
                }
                .padding(16)
            }
            .overlay(alignment: .bottom) {
                HStack(spacing: 10) {
                    Button("View route", action: action)
                        .buttonStyle(CompactPillStyle())

                    Button {
                        liked.toggle()
                    } label: {
                        Image(systemName: liked ? "heart.fill" : "heart")
                            .font(.raahaTitle3)
                            .foregroundStyle(liked ? Color.strawberry : Color.deepSpace)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.honeydew))
                    }
                    .accessibilityLabel(liked ? "Remove from favourites" : "Add to favourites")
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.deepSpace.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

private struct CompactPillStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.raahaHeadline)
            .foregroundStyle(Color.deepSpace)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Capsule().fill(Color.honeydew))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

// MARK: - Plan Ahead

private struct PlanAheadCard: View {
    @EnvironmentObject private var router: AppRouter
    @State private var showDateSheet = false
    @State private var showTimeSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Plan Ahead")
                    .font(.raahaTitle2)
                    .foregroundStyle(Color.honeydew)
                Text("Check travel conditions for your future trip.")
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.frostedBlue)
            }

            // Destination
            PlanFieldRow(asset: "icon_pin", label: "Destination") {
                Menu {
                    ForEach(TripPlan.destinations, id: \.self) { name in
                        Button(name) { router.plan.destination = name }
                    }
                } label: {
                    PlanFieldValue(text: router.plan.destination)
                }
            }

            // Date
            PlanFieldRow(symbol: "calendar", label: "Date") {
                Button { showDateSheet = true } label: {
                    PlanFieldValue(text: router.plan.dateText)
                }
            }

            // Time
            PlanFieldRow(symbol: "clock", label: "Time") {
                Button { showTimeSheet = true } label: {
                    PlanFieldValue(text: router.plan.timeText)
                }
            }

            Button("Check") {
                router.push(.tripPreview)
            }
            .buttonStyle(.pillLight)
            .padding(.top, 14)
        }
        .padding(18)
        .navyCard(radius: 30, gradient: .raahaHero)
        .sheet(isPresented: $showDateSheet) {
            PickerSheet(title: "Date") {
                DatePicker("Date", selection: $router.plan.date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
            }
        }
        .sheet(isPresented: $showTimeSheet) {
            PickerSheet(title: "Time") {
                DatePicker("Time", selection: $router.plan.date, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
        }
    }
}

private struct PlanFieldRow<Field: View>: View {
    var symbol: String? = nil
    var asset: String? = nil
    let label: String
    @ViewBuilder var field: Field

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Group {
                if let asset {
                    Image(asset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                } else if let symbol {
                    Image(systemName: symbol)
                        .font(.raahaSubheadlineMedium)
                }
            }
            .foregroundStyle(Color.honeydew)
            .frame(width: 34, height: 34)
            .background(Circle().fill(Color.steelBlue))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.honeydew)
                field
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.deepSpace.opacity(0.85))
        )
    }
}

private struct PlanFieldValue: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .font(.raahaSubheadline)
                .foregroundStyle(Color.honeydew)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.frostedBlue)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.frostedBlue.opacity(0.7), lineWidth: 1)
        )
        .contentShape(Rectangle())
    }
}

private struct PickerSheet<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                content
                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .tint(Color.steelBlue)
        }
        .presentationDetents([.medium])
    }
}
