import SwiftUI

// MARK: - Root Explore View

struct ExploreView: View {
    enum Segment { case places, planAhead }

    @Environment(AppRouter.self) private var router
    @State private var vm = ExploreViewModel()

    @State private var segment: Segment = .places
    @State private var selectedPlace: ExplorePlace?
    @State private var selectedEvent: EventModel?
    @State private var showAllNearby = false

    var body: some View {
        @Bindable var vm = vm
        VStack(spacing: 0) {
            header

            ScrollView(.vertical, showsIndicators: false) {
                Group {
                    switch segment {
                    case .places:
                        PlacesContent(
                            vm: vm,
                            selectedPlace: $selectedPlace,
                            selectedEvent: $selectedEvent,
                            showAllNearby: $showAllNearby
                        )
                    case .planAhead:
                        PlanAheadCard()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 150)
            }
            .scrollDismissesKeyboard(.interactively)
            .refreshable { vm.refresh() }
        }
        .raahaScreenBackground()
        .navyHeaderChrome()
        .onAppear { vm.onAppear() }
        .onChange(of: vm.query) { _, newValue in vm.onQueryChange(newValue) }
        .onChange(of: vm.activeFilter) { _, filter in
            router.lastExploreFilter = filter == .all ? nil : filter
        }
        .task(id: router.exploreRequest?.token) {
            guard router.exploreRequest != nil else { return }
            try? await Task.sleep(nanoseconds: 80_000_000)
            openPendingExplorePlace()
        }
        .navigationDestination(item: $selectedPlace) { place in
            PlaceDetailView(place: place)
        }
        .navigationDestination(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
        .sheet(isPresented: $showAllNearby) {
            AllNearbySheet(vm: vm, selectedPlace: $selectedPlace, showAllNearby: $showAllNearby)
        }
        .alert(
            "Outside Service Area",
            isPresented: Binding(
                get: { vm.outsideBoundaryAlertMessage != nil },
                set: { if !$0 { vm.outsideBoundaryAlertMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { vm.outsideBoundaryAlertMessage = nil }
        } message: {
            if let msg = vm.outsideBoundaryAlertMessage {
                Text(msg)
            }
        }
    }

    private func openPendingExplorePlace() {
        guard let request = router.exploreRequest else { return }
        router.exploreRequest = nil
        segment = .places
        if vm.activeFilter != request.filter {
            vm.setFilter(request.filter)
        }
        guard let placeID = request.placeID,
              let place = ExploreMockData.allPlaces.first(where: { $0.id == placeID })
        else { return }
        selectedPlace = place
    }

    // MARK: Header

    private var header: some View {
        NavyHeader {
            VStack(alignment: .leading, spacing: 14) {
                Text("Explore")
                    .font(.raahaTitle)
                    .foregroundStyle(Color.white)
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
            .foregroundStyle(selected ? Color.white : Color.royalBlue)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                Capsule()
                    .fill(
                        selected
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.brightBlue, Color.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Color.white.opacity(0.65))
                    )
                    .background(
                        .regularMaterial,
                        in: Capsule()
                    )
            )
            .overlay(
                Capsule()
                    .stroke(selected ? Color.white.opacity(0.5) : Color.white.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: selected ? Color.electricBlue.opacity(0.45) : Color.clear, radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.royalBlue)
            TextField(
                "",
                text: $vm.query,
                prompt: Text(segment == .places ? "Search places, restaurants…" : "Search trips or places")
                    .foregroundStyle(Color.royalBlue.opacity(0.65))
            )
            .font(.raahaBody)
            .foregroundStyle(Color.midnightBlue)
            .submitLabel(.search)
            .onSubmit { vm.submitSearch(vm.query) }
            .accessibilityLabel("Search")

            if !vm.query.isEmpty {
                Button {
                    withAnimation { vm.clearSearch() }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.royalBlue)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 48)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.65))
                .background(.regularMaterial, in: Capsule())
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.80), lineWidth: 1))
    }
}

// MARK: - Places Content

private struct PlacesContent: View {
    let vm: ExploreViewModel
    @Binding var selectedPlace: ExplorePlace?
    @Binding var selectedEvent: EventModel?
    @Binding var showAllNearby: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // ── Category filters ──
            categoryFilterChips

            // ── Search results (active search) ──
            if vm.isSearchActive {
                searchResults
            } else {
                // ── Nearby spots ──
                SectionHeader(title: vm.activeFilter.nearbySectionTitle, action: "See all") {
                    showAllNearby = true
                }
                .padding(.top, 2)

                nearbySection
            }

            EventDiscoverySection(selectedEvent: $selectedEvent)
                .padding(.top, 8)
        }
    }

    // MARK: Category filter chips

    private var categoryFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ExploreFilter.allCases) { filter in
                    CategoryFilterChip(
                        filter: filter,
                        isSelected: vm.activeFilter == filter
                    ) {
                        withAnimation(.snappy(duration: 0.22)) {
                            vm.setFilter(filter)
                        }
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
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
                        if place.isValidChennaiLocation {
                            selectedPlace = place
                        } else {
                            vm.outsideBoundaryAlertMessage = "\(place.name) is outside the Chennai service area."
                        }
                    }
                }
            }

        case .empty:
            CategoryEmptyState(categoryTitle: vm.activeFilter.title)

        case .error(let msg):
            ErrorBannerView(message: msg) { vm.loadNearby() }

        case .idle:
            EmptyView()
        }
    }

    // MARK: Search results

    @ViewBuilder
    private var searchResults: some View {
        // Autocomplete suggestions
        if !vm.autocompleteSuggestions.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("Chennai Suggestions")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)

                ForEach(vm.autocompleteSuggestions.prefix(4), id: \.self) { suggestion in
                    Button {
                        vm.selectSuggestion(suggestion) { place in
                            selectedPlace = place
                        }
                    } label: {
                        HStack(spacing: 10) {
                            IconPin(size: 18)
                                .foregroundStyle(Color.steelBlue)
                            Text(suggestion)
                                .font(.raahaSubheadlineMedium)
                                .foregroundStyle(Color.deepSpace)
                            Spacer()
                            Image(systemName: "arrow.up.left")
                                .font(.raahaCaption2)
                                .foregroundStyle(Color.steelBlue.opacity(0.6))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.honeydew))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 6)
        }

        switch vm.searchState {
        case .loading:
            VStack(alignment: .leading, spacing: 8) {
                Text("Searching Chennai…")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                    .padding(.top, 4)
                PlacesSkeletonView(count: 5)
            }

        case .loaded(let places):
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(places.count) results in Chennai")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.steelBlue)
                    Spacer()
                    Label("Chennai Only", systemImage: "checkmark.shield.fill")
                        .font(.raahaCaption2)
                        .foregroundStyle(Color.steelBlue)
                }
                ForEach(places) { place in
                    RealNearbySpotRow(place: place) {
                        if place.isValidChennaiLocation {
                            selectedPlace = place
                        } else {
                            vm.outsideBoundaryAlertMessage = "\(place.name) is outside the Chennai service area."
                        }
                    }
                }
            }

        case .empty:
            ChennaiEmptyResultsView(
                query: vm.query,
                suggestions: ChennaiServiceArea.shared.emptySearchSuggestions
            ) { suggestion in
                vm.query = suggestion
                vm.submitSearch(suggestion)
            }

        case .error(let msg):
            ErrorBannerView(message: msg) { vm.submitSearch(vm.query) }

        case .idle:
            EmptyView()
        }
    }
}

// MARK: - Real Nearby Spot Row (MapKit-backed)

private struct RealNearbySpotRow: View {
    let place: ExplorePlace
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Real Place Image Thumbnail with fallback
                PlaceImageView(place: place, style: .thumbnail(size: 54))
                    .shadow(color: Color.deepSpace.opacity(0.18), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 3) {
                    Text(place.name)
                        .font(.system(.subheadline).weight(.semibold))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(place.category.title)
                            .font(.system(.caption).weight(.medium))
                            .foregroundStyle(Color.black)
                        if let rating = place.ratingText {
                            Text("·")
                                .foregroundStyle(Color.black)
                                .font(.system(.caption).weight(.medium))
                            Text("★ \(rating)")
                                .font(.system(.caption).weight(.medium))
                                .foregroundStyle(Color.black)
                        }
                        if let dist = place.distanceText {
                            Text("·")
                                .foregroundStyle(Color.black)
                                .font(.system(.caption).weight(.medium))
                            Text(dist)
                                .font(.system(.caption).weight(.medium))
                                .foregroundStyle(Color.black)
                        }
                    }

                    if !place.address.isEmpty {
                        Text(place.address)
                            .font(.system(.caption2).weight(.regular))
                            .foregroundStyle(Color.black)
                            .lineLimit(1)
                    }
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
        .buttonStyle(TactileButtonStyle())
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Category Filter Chip

private struct CategoryFilterChip: View {
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
            .foregroundStyle(isSelected ? Color.white : Color.midnightBlue)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.brightBlue, Color.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Color.white.opacity(0.72))
                    )
                    .background(.regularMaterial, in: Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.white.opacity(0.55) : Color.white.opacity(0.85),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color.electricBlue.opacity(0.35) : Color.clear,
                radius: 6, x: 0, y: 2
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(filter.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Category Empty State

private struct CategoryEmptyState: View {
    let categoryTitle: String

    var body: some View {
        VStack(spacing: 8) {
            IconPin(size: 22)
                .foregroundStyle(Color.royalBlue.opacity(0.75))
            Text("No places found in this category.")
                .font(.system(.subheadline).weight(.semibold))
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.center)
            Text(categoryTitle == "All" ? "Try refreshing nearby spots." : "Nothing nearby for \(categoryTitle) yet.")
                .font(.system(.caption).weight(.medium))
                .foregroundStyle(Color.black.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .navyCard(radius: 18)
    }
}

// MARK: - All Nearby Sheet

private struct AllNearbySheet: View {
    let vm: ExploreViewModel
    @Binding var selectedPlace: ExplorePlace?
    @Binding var showAllNearby: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch vm.nearbyState {
                case .loaded(let places):
                    List(places) { place in
                        RealNearbySpotRow(place: place) {
                            dismiss()
                            Task { @MainActor in
                                try? await Task.sleep(for: .milliseconds(300))
                                selectedPlace = place
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .raahaScreenBackground()

                case .loading:
                    ProgressView("Loading nearby places…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .raahaScreenBackground()

                default:
                    ChennaiEmptyResultsView(
                        query: "Nearby",
                        suggestions: ChennaiServiceArea.shared.emptySearchSuggestions
                    ) { suggestion in
                        dismiss()
                        vm.query = suggestion
                        vm.submitSearch(suggestion)
                    }
                }
            }
            .navigationTitle(vm.activeFilter.nearbySectionTitle)
            .toolbarTitleDisplayMode(.inline)
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

// MARK: - Outside Chennai Banner

private struct OutsideChennaiBanner: View {
    let exploreAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "location.slash.fill")
                    .font(.raahaTitle2)
                    .foregroundStyle(Color.strawberry)

                VStack(alignment: .leading, spacing: 4) {
                    Text("RAAHA is currently available only in Chennai.")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.honeydew)

                    Text("We detected you are outside our service area. Nearby results for your current location are not available.")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.frostedBlue)
                }
            }

            Button {
                exploreAction()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "safari.fill")
                    Text("Explore Chennai Instead")
                }
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.deepSpace)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Capsule().fill(Color.honeydew))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(16)
        .navyCard(radius: 20, gradient: .raahaNavyGlow)
    }
}

// MARK: - Chennai Locality Selector

private struct ChennaiLocalitySelector: View {
    let selected: ChennaiLocality?
    let onSelect: (ChennaiLocality?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Chennai Localities")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.midnightBlue)
                Spacer()
                if selected != nil {
                    Button("All Chennai") {
                        onSelect(nil)
                    }
                    .font(.raahaCaption)
                    .foregroundStyle(Color.royalBlue)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        onSelect(nil)
                    } label: {
                        HStack(spacing: 4) {
                            IconPin(size: 12)
                            Text("All Chennai")
                                .font(.raahaFootnoteSemibold)
                        }
                        .foregroundStyle(selected == nil ? Color.white : Color.royalBlue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    selected == nil
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color.brightBlue, Color.electricBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    : AnyShapeStyle(Color.white.opacity(0.65))
                                )
                                .background(.regularMaterial, in: Capsule())
                        )
                        .overlay(
                            Capsule()
                                .stroke(selected == nil ? Color.white.opacity(0.5) : Color.white.opacity(0.8), lineWidth: 1)
                        )
                        .shadow(color: selected == nil ? Color.electricBlue.opacity(0.35) : Color.clear, radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)

                    ForEach(ChennaiServiceArea.shared.approvedLocalities) { locality in
                        let isCurSelected = selected?.name == locality.name
                        Button {
                            onSelect(locality)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: locality.symbol)
                                    .font(.raahaCaption2)
                                Text(locality.name)
                                    .font(.raahaFootnoteSemibold)
                            }
                            .foregroundStyle(isCurSelected ? Color.white : Color.royalBlue)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        isCurSelected
                                        ? AnyShapeStyle(
                                            LinearGradient(
                                                colors: [Color.brightBlue, Color.electricBlue],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        : AnyShapeStyle(Color.white.opacity(0.65))
                                    )
                                    .background(.regularMaterial, in: Capsule())
                            )
                            .overlay(
                                Capsule()
                                    .stroke(isCurSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.8), lineWidth: 1)
                            )
                            .shadow(color: isCurSelected ? Color.electricBlue.opacity(0.35) : Color.clear, radius: 6, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - Chennai Empty Results View

private struct ChennaiEmptyResultsView: View {
    let query: String
    let suggestions: [String]
    let onSelectSuggestion: (String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                IconPin(size: 44)
                    .foregroundStyle(Color.strawberry)

                Text("No places found in Chennai")
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.deepSpace)

                if !query.isEmpty {
                    Text("No results for \"\(query)\" inside the approved Chennai service boundary.")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.steelBlue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                Text("RAAHA is currently available only in Chennai, Tamil Nadu.")
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.steelBlue.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Popular Chennai categories:")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.steelBlue)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button {
                                onSelectSuggestion(suggestion)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkle")
                                        .font(.raahaCaption2)
                                    Text(suggestion)
                                        .font(.raahaFootnoteSemibold)
                                }
                                .foregroundStyle(Color.deepSpace)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Capsule().fill(Color.frostedBlue.opacity(0.35)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .lightCard(radius: 20)
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
    @Environment(\.openURL) private var openURL

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
                if let url = URL(string: "app-settings:") {
                    openURL(url)
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

struct ShimmerModifier: ViewModifier {
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

extension View {
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}

// MARK: - CompactPillStyle (preserved)

private struct CompactPillStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.raahaHeadline)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.brightBlue, Color.electricBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
            .shadow(color: Color.electricBlue.opacity(0.35), radius: 6, x: 0, y: 2)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

// MARK: - Plan Ahead

private enum PlanAheadPalette {
    static let navy = Color(red: 0.08, green: 0.18, blue: 0.30)
    static let label = Color(red: 0.08, green: 0.18, blue: 0.30)
    static let value = Color.black
    static let supporting = Color(red: 0.27, green: 0.42, blue: 0.55) // steel-blue grey
    static let placeholder = Color(red: 0.45, green: 0.50, blue: 0.55)
    static let icon = Color(red: 0.08, green: 0.18, blue: 0.30)
    static let border = Color(red: 0.45, green: 0.55, blue: 0.65)
}

private struct PlanAheadCard: View {
    @Environment(AppRouter.self) private var router
    @State private var showDateSheet = false
    @State private var showTimeSheet = false

    var body: some View {
        @Bindable var router = router
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Plan Ahead")
                    .font(.raahaTitle2)
                    .foregroundStyle(PlanAheadPalette.navy)
                Text("Check travel conditions for your future trip.")
                    .font(.raahaSubheadline)
                    .foregroundStyle(PlanAheadPalette.supporting)
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
                    .tint(PlanAheadPalette.navy)
                    .foregroundStyle(PlanAheadPalette.navy)
            }
        }
        .sheet(isPresented: $showTimeSheet) {
            PickerSheet(title: "Time") {
                DatePicker("Time", selection: $router.plan.date, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(PlanAheadPalette.navy)
                    .foregroundStyle(PlanAheadPalette.navy)
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
            .foregroundStyle(PlanAheadPalette.icon)
            .frame(width: 34, height: 34)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.72))
                    .background(.ultraThinMaterial, in: Circle())
            )
            .overlay(Circle().stroke(PlanAheadPalette.border.opacity(0.45), lineWidth: 1))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(PlanAheadPalette.label)
                field
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.55))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(PlanAheadPalette.border.opacity(0.40), lineWidth: 1)
        )
    }
}

private struct PlanFieldValue: View {
    let text: String
    var body: some View {
        HStack {
            Text(text)
                .font(.raahaSubheadline)
                .foregroundStyle(PlanAheadPalette.value)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(PlanAheadPalette.icon)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PlanAheadPalette.border.opacity(0.55), lineWidth: 1)
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
            .raahaScreenBackground()
            .navigationTitle(title)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(PlanAheadPalette.navy)
                }
            }
            .tint(PlanAheadPalette.navy)
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ExploreView()
        .environment(AppRouter())
}
