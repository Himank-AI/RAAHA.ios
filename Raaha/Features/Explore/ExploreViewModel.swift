import Foundation
import Combine

// MARK: - ExploreViewModel (Frontend Mock Data Engine)

/// Frontend-only view model for Explore, powered by centralized static Chennai mock data.
/// Fast, responsive, offline-capable, and completely decoupled from network or backend dependencies.
@MainActor
final class ExploreViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var nearbyState: PlacesLoadState = .idle
    @Published private(set) var searchState: PlacesLoadState = .idle
    @Published private(set) var featuredPlaces: [ExplorePlace] = []
    @Published private(set) var isFeaturedLoading = false
    @Published var activeFilter: ExploreFilter = .all
    @Published var query: String = ""
    @Published var recentSearches: [String] = [
        "Marina Beach",
        "Murugan Idli Shop",
        "Besant Nagar",
        "Kapaleeshwarar Temple"
    ]

    // Chennai locality selection & overrides
    @Published var selectedLocality: ChennaiLocality? = nil
    @Published private(set) var autocompleteSuggestions: [String] = []
    @Published var outsideBoundaryAlertMessage: String? = nil

    var isSearchActive: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty }

    // MARK: - Lifecycle

    func onAppear() {
        loadData()
    }

    func loadData() {
        loadFeatured()
        loadNearby()
    }

    func refresh() {
        loadData()
    }

    // MARK: - Filter & Locality Actions

    func setFilter(_ filter: ExploreFilter) {
        guard activeFilter != filter else { return }
        activeFilter = filter
        loadNearby()
    }

    func selectLocality(_ locality: ChennaiLocality?) {
        guard selectedLocality != locality else { return }
        selectedLocality = locality
        loadNearby()
    }

    // MARK: - Nearby Places (Mock)

    func loadNearby() {
        let results = ExploreMockData.filter(
            query: "",
            filter: activeFilter,
            locality: selectedLocality?.name
        )
        nearbyState = results.isEmpty ? .empty : .loaded(results)
    }

    private func loadFeatured() {
        featuredPlaces = ExploreMockData.featuredPlaces
        isFeaturedLoading = false
    }

    // MARK: - Search Actions

    func onQueryChange(_ newQuery: String) {
        let trimmed = newQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchState = .idle
            autocompleteSuggestions = []
            return
        }

        // Generate instant search suggestions from mock data
        autocompleteSuggestions = ExploreMockData.searchSuggestions(for: trimmed)

        // Perform instant local search filtering
        performSearch(query: trimmed)
    }

    func submitSearch(_ q: String) {
        let trimmed = q.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        addToRecent(trimmed)
        performSearch(query: trimmed)
    }

    func selectSuggestion(_ suggestion: String, onResolved: @escaping (ExplorePlace) -> Void) {
        addToRecent(suggestion)
        query = suggestion

        let matches = ExploreMockData.filter(query: suggestion)
        if let first = matches.first {
            searchState = .loaded(matches)
            onResolved(first)
        } else {
            performSearch(query: suggestion)
        }
    }

    func clearSearch() {
        query = ""
        searchState = .idle
        autocompleteSuggestions = []
    }

    func removeRecent(_ search: String) {
        recentSearches.removeAll { $0 == search }
    }

    // MARK: - Private Search Helper

    private func performSearch(query: String) {
        let results = ExploreMockData.filter(
            query: query,
            filter: activeFilter,
            locality: selectedLocality?.name
        )
        searchState = results.isEmpty ? .empty : .loaded(results)
    }

    private func addToRecent(_ search: String) {
        recentSearches.removeAll { $0 == search }
        recentSearches.insert(search, at: 0)
        if recentSearches.count > 8 { recentSearches = Array(recentSearches.prefix(8)) }
    }
}
