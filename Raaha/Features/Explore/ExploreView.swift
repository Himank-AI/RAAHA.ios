import SwiftUI
import MapKit

// MARK: - Root Explore View

struct ExploreView: View {
    enum Segment { case places, planAhead }

    @EnvironmentObject private var router: AppRouter
    @StateObject private var locationManager = LocationManager()
    @StateObject private var vm: ExploreViewModel

    @State private var segment: Segment = .places
    @State private var selectedPlace: ExplorePlace?
    @State private var showAllNearby = false

    init() {
        // We can't access locationManager here yet, so build VM with a temp one;
        // VM is rebuilt once the view appears via onAppear.
        let loc = LocationManager()
        _vm = StateObject(wrappedValue: ExploreViewModel(locationManager: loc))
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                Group {
                    switch segment {
                    case .places:
                        PlacesContent(
                            vm: vm,
                            locationManager: locationManager,
                            selectedPlace: $selectedPlace,
                            showAllNearby: $showAllNearby
                        )
                    case .planAhead:
                        PlanAheadCard()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
            .scrollDismissesKeyboard(.interactively)
            .refreshable { vm.refresh() }
        }
        .background(LinearGradient.raahaScreen.ignoresSafeArea())
        .navyHeaderChrome()
        .onAppear { vm.onAppear() }
        .onChange(of: vm.query) { vm.onQueryChange(vm.query) }
        .navigationDestination(isPresented: Binding(
            get: { selectedPlace != nil },
            set: { if !$0 { selectedPlace = nil } }
        )) {
            if let place = selectedPlace {
                PlaceDetailView(place: place)
            }
        }
        .sheet(isPresented: $showAllNearby) {
            AllNearbySheet(vm: vm, selectedPlace: $selectedPlace, showAllNearby: $showAllNearby)
        }
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

    private func segmentButton(
        _ title: String,
        symbol: String? = nil,
        asset: String? = nil,
        value: Segment
    ) -> some View {
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
                text: $vm.query,
                prompt: Text(segment == .places ? "Search places, restaurants…" : "Search trips or places")
                    .foregroundStyle(Color.steelBlue)
            )
            .font(.raahaBody)
            .foregroundStyle(Color.deepSpace)
            .submitLabel(.search)
            .onSubmit { vm.submitSearch(vm.query) }
            .accessibilityLabel("Search")

            if !vm.query.isEmpty {
                Button {
                    withAnimation { vm.clearSearch() }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.steelBlue)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 48)
        .background(Capsule().fill(Color.honeydew))
    }
}

// MARK: - Places Content

private struct PlacesContent: View {
    @ObservedObject var vm: ExploreViewModel
    @ObservedObject var locationManager: LocationManager
    @Binding var selectedPlace: ExplorePlace?
    @Binding var showAllNearby: Bool
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // ── Location permission banner ──
            if locationManager.permission == .denied || locationManager.permission == .restricted {
                LocationDeniedBanner()
            }

            // ── Search results (active search) ──
            if vm.isSearchActive {
                searchResults
            } else {
                // ── Explore options ──
                SectionHeader(title: "Explore options", action: nil)
                HStack(spacing: 12) {
                    ExploreOptionCard(
                        imageName: "explore_spots",
                        asset: "icon_pin",
                        title: "Spots",
                        subtitle: "Landmarks & parks"
                    ) {
                        vm.setFilter(.landmarks)
                    }
                    ExploreOptionCard(
                        imageName: "explore_restaurants",
                        symbol: "fork.knife",
                        title: "Restaurants",
                        subtitle: "Cafes & dining"
                    ) {
                        vm.setFilter(.restaurants)
                    }
                }

                // ── Category filter chips ──
                filterChips

                // ── Nearby spots ──
                SectionHeader(title: "Nearby spots", action: "See all") {
                    showAllNearby = true
                }
                .padding(.top, 4)

                nearbySection

                // ── Featured places ──
                SectionHeader(title: "Featured places", action: nil)
                    .padding(.top, 4)

                featuredSection

                // ── Recent searches ──
                if !vm.recentSearches.isEmpty {
                    recentSearchesSection
                }
            }
        }
    }

    // MARK: Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ExploreFilter.allCases) { filter in
                    FilterChip(filter: filter, isSelected: vm.activeFilter == filter) {
                        vm.setFilter(filter)
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
    }

    // MARK: Nearby section

    @ViewBuilder
    private var nearbySection: some View {
        switch vm.nearbyState {
        case .loading:
            PlacesSkeletonView(count: 3)

        case .loaded(let places):
            VStack(spacing: 8) {
                ForEach(places.prefix(5)) { place in
                    RealNearbySpotRow(place: place) {
                        selectedPlace = place
                    } planAction: {
                        router.planJourney(from: "Current Location", to: place.name)
                    }
                }
            }

        case .empty:
            EmptyResultsView(message: "No nearby spots found.\nTry changing the filter or search area.")

        case .error(let msg):
            ErrorBannerView(message: msg) { vm.loadNearby() }

        case .idle:
            EmptyView()
        }
    }

    // MARK: Featured section

    @ViewBuilder
    private var featuredSection: some View {
        if vm.isFeaturedLoading {
            VStack(spacing: 14) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.frostedBlue.opacity(0.3))
                        .frame(height: 140)
                        .shimmer()
                }
            }
        } else if vm.featuredPlaces.isEmpty {
            // Fall back to static featured entries so the screen is never blank
            VStack(spacing: 14) {
                ForEach(MockData.featuredPlaces) { place in
                    FeaturedPlaceCard(place: place) {
                        router.planJourney(from: "Current Location", to: place.name)
                    }
                }
            }
        } else {
            VStack(spacing: 14) {
                ForEach(vm.featuredPlaces) { place in
                    RealFeaturedPlaceCard(place: place) {
                        selectedPlace = place
                    } planAction: {
                        router.planJourney(from: "Current Location", to: place.name)
                    }
                }
            }
        }
    }

    // MARK: Search results

    @ViewBuilder
    private var searchResults: some View {
        switch vm.searchState {
        case .loading:
            VStack(alignment: .leading, spacing: 8) {
                Text("Searching…")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                    .padding(.top, 4)
                PlacesSkeletonView(count: 5)
            }

        case .loaded(let places):
            VStack(alignment: .leading, spacing: 8) {
                Text("\(places.count) results near Chennai")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                ForEach(places) { place in
                    RealNearbySpotRow(place: place) {
                        selectedPlace = place
                    } planAction: {
                        router.planJourney(from: "Current Location", to: place.name)
                    }
                }
            }

        case .empty:
            EmptyResultsView(message: "No results. Try a different search.")

        case .error(let msg):
            ErrorBannerView(message: msg) { vm.submitSearch(vm.query) }

        case .idle:
            // Show recent searches while query is being typed
            if !vm.recentSearches.isEmpty {
                recentSearchesSection
            }
        }
    }

    // MARK: Recent searches

    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent searches")
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.steelBlue)
                .padding(.top, 4)
            ForEach(vm.recentSearches, id: \.self) { search in
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.steelBlue)
                    Text(search)
                        .font(.raahaSubheadline)
                        .foregroundStyle(Color.deepSpace)
                    Spacer()
                    Button {
                        vm.removeRecent(search)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.raahaCaption2)
                            .foregroundStyle(Color.steelBlue)
                    }
                }
                .onTapGesture {
                    vm.query = search
                    vm.submitSearch(search)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .lightCard(radius: 14)
            }
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let filter: ExploreFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: filter.symbol)
                    .font(.raahaCaption2)
                Text(filter.title)
                    .font(.raahaFootnoteSemibold)
            }
            .foregroundStyle(isSelected ? Color.honeydew : Color.deepSpace)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule().fill(isSelected ? Color.steelBlue : Color.honeydew)
            )
            .shadow(color: Color.deepSpace.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.2), value: isSelected)
    }
}

// MARK: - Real Nearby Spot Row (MapKit-backed)

private struct RealNearbySpotRow: View {
    let place: ExplorePlace
    let action: () -> Void
    let planAction: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Category icon circle
                Image(systemName: place.symbolName)
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.honeydew)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Color.steelBlue))
                    .shadow(color: Color.deepSpace.opacity(0.15), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 3) {
                    Text(place.name)
                        .font(.raahaSubheadlineMedium)
                        .foregroundStyle(Color.honeydew)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(place.category.title)
                            .font(.raahaCaption)
                            .foregroundStyle(Color.frostedBlue.opacity(0.85))
                        if let dist = place.distanceText {
                            Text("·")
                                .foregroundStyle(Color.frostedBlue.opacity(0.5))
                                .font(.raahaCaption)
                            Text(dist)
                                .font(.raahaCaption)
                                .foregroundStyle(Color.frostedBlue.opacity(0.85))
                        }
                    }

                    if !place.address.isEmpty {
                        Text(place.address)
                            .font(.raahaCaption2)
                            .foregroundStyle(Color.frostedBlue.opacity(0.65))
                            .lineLimit(1)
                    }
                }

                Spacer()

                VStack(spacing: 6) {
                    Image(systemName: "chevron.right")
                        .font(.raahaFootnoteSemibold)
                        .foregroundStyle(Color.frostedBlue)

                    // Quick route button
                    Button(action: planAction) {
                        Image(systemName: "arrow.triangle.turn.up.right.circle")
                            .font(.raahaTitle3)
                            .foregroundStyle(Color.frostedBlue)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Plan route to \(place.name)")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .navyCard(radius: 18, gradient: .raahaNavyGlow)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Real Featured Place Card (MapKit-backed)

private struct RealFeaturedPlaceCard: View {
    let place: ExplorePlace
    let action: () -> Void
    let planAction: () -> Void
    @State private var liked = false

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                // Hero: gradient background + large icon
                ZStack {
                    LinearGradient.raahaHero
                    Image(systemName: place.symbolName)
                        .font(.system(size: 60, weight: .thin))
                        .foregroundStyle(Color.honeydew.opacity(0.25))
                }
                .frame(height: 160)

                // Text overlay
                LinearGradient(
                    colors: [Color.deepSpace.opacity(0.55), Color.clear],
                    startPoint: .bottom,
                    endPoint: .center
                )

                // Top text
                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name)
                        .font(.raahaTitle2)
                        .foregroundStyle(Color.honeydew)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(place.category.title)
                            .font(.raahaFootnote)
                            .foregroundStyle(Color.frostedBlue)
                        if let dist = place.distanceText {
                            Text("· \(dist)")
                                .font(.raahaFootnote)
                                .foregroundStyle(Color.frostedBlue.opacity(0.75))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .frame(maxHeight: 160, alignment: .topLeading)

                // Bottom action row
                HStack(spacing: 10) {
                    Button("View details", action: action)
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
                    .buttonStyle(.plain)
                    .accessibilityLabel(liked ? "Remove from favourites" : "Add to favourites")
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.deepSpace.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Legacy FeaturedPlaceCard (static fallback)

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
                    Text(place.name).font(.raahaTitle2).foregroundStyle(Color.honeydew)
                    Text(place.subtitle).font(.raahaFootnote).foregroundStyle(Color.frostedBlue)
                }
                .padding(16)
            }
            .overlay(alignment: .bottom) {
                HStack(spacing: 10) {
                    Button("View route", action: action).buttonStyle(CompactPillStyle())
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

// MARK: - Explore Option Card (with action)

private struct ExploreOptionCard: View {
    let imageName: String
    var symbol: String? = nil
    var asset: String? = nil
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - All Nearby Sheet

private struct AllNearbySheet: View {
    @ObservedObject var vm: ExploreViewModel
    @Binding var selectedPlace: ExplorePlace?
    @Binding var showAllNearby: Bool
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch vm.nearbyState {
                case .loaded(let places):
                    List(places) { place in
                        RealNearbySpotRow(place: place) {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                selectedPlace = place
                            }
                        } planAction: {
                            dismiss()
                            router.planJourney(from: "Current Location", to: place.name)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .background(LinearGradient.raahaScreen.ignoresSafeArea())

                case .loading:
                    ProgressView("Loading nearby places…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(LinearGradient.raahaScreen.ignoresSafeArea())

                default:
                    EmptyResultsView(message: "No nearby places found.")
                }
            }
            .navigationTitle("Nearby Spots")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.steelBlue)
                }
            }
        }
    }
}

// MARK: - Skeleton Loader

private struct PlacesSkeletonView: View {
    let count: Int

    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { _ in
                HStack(spacing: 14) {
                    Circle()
                        .fill(Color.frostedBlue.opacity(0.3))
                        .frame(width: 48, height: 48)
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.frostedBlue.opacity(0.3))
                            .frame(width: 140, height: 14)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.frostedBlue.opacity(0.2))
                            .frame(width: 90, height: 12)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .navyCard(radius: 18, gradient: .raahaNavyGlow)
                .shimmer()
            }
        }
    }
}

// MARK: - Empty State

private struct EmptyResultsView: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(Color.steelBlue.opacity(0.6))
            Text(message)
                .font(.raahaSubheadline)
                .foregroundStyle(Color.steelBlue)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }
}

// MARK: - Error Banner

private struct ErrorBannerView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .foregroundStyle(Color.strawberry)
            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.honeydew)
            }
            Spacer()
            Button("Retry", action: retry)
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.frostedBlue)
        }
        .padding(14)
        .navyCard(radius: 18)
    }
}

// MARK: - Location Denied Banner

private struct LocationDeniedBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "location.slash.fill")
                .foregroundStyle(Color.strawberry)
            VStack(alignment: .leading, spacing: 2) {
                Text("Location access denied")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.honeydew)
                Text("Showing Chennai results. Enable in Settings.")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.frostedBlue)
            }
            Spacer()
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Settings")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.frostedBlue)
            }
        }
        .padding(14)
        .navyCard(radius: 18)
    }
}

// MARK: - Shimmer modifier

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.25),
                        Color.white.opacity(0)
                    ]),
                    startPoint: UnitPoint(x: phase - 0.3, y: 0),
                    endPoint: UnitPoint(x: phase, y: 0)
                )
                .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: phase)
            )
            .onAppear { phase = 1.3 }
            .clipped()
    }
}

private extension View {
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}

// MARK: - CompactPillStyle (preserved)

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

// MARK: - Plan Ahead (unchanged)

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

            PlanFieldRow(asset: "icon_pin", label: "Destination") {
                Menu {
                    ForEach(TripPlan.destinations, id: \.self) { name in
                        Button(name) { router.plan.destination = name }
                    }
                } label: {
                    PlanFieldValue(text: router.plan.destination)
                }
            }

            PlanFieldRow(symbol: "calendar", label: "Date") {
                Button { showDateSheet = true } label: {
                    PlanFieldValue(text: router.plan.dateText)
                }
            }

            PlanFieldRow(symbol: "clock", label: "Time") {
                Button { showTimeSheet = true } label: {
                    PlanFieldValue(text: router.plan.timeText)
                }
            }

            Button("Check") { router.push(.tripPreview) }
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
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.deepSpace.opacity(0.85)))
    }
}

private struct PlanFieldValue: View {
    let text: String
    var body: some View {
        HStack {
            Text(text).font(.raahaSubheadline).foregroundStyle(Color.honeydew)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.raahaSubheadlineMedium).foregroundStyle(Color.frostedBlue)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Color.frostedBlue.opacity(0.7), lineWidth: 1))
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
