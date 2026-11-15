import Foundation
import Observation

// MARK: - ExploreViewModel (Frontend Mock Data Engine)

/// Frontend-only view model for Explore, powered by centralized static Chennai mock data.
/// Fast, responsive, offline-capable, and completely decoupled from network or backend dependencies.
@Observable
@MainActor
final class ExploreViewModel {

    // MARK: - State

    private(set) var nearbyState: PlacesLoadState = .idle
    private(set) var searchState: PlacesLoadState = .idle
    var activeFilter: ExploreFilter = .all
    var query: String = ""

    // Chennai locality selection & overrides
    var selectedLocality: ChennaiLocality? = nil
    private(set) var autocompleteSuggestions: [String] = []
    var outsideBoundaryAlertMessage: String? = nil

    var isSearchActive: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty }

    // MARK: - Lifecycle

    func onAppear() {
        loadData()
    }

    func loadData() {
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
        if isSearchActive {
            performSearch(query: query.trimmingCharacters(in: .whitespaces))
        }
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
        performSearch(query: trimmed)
    }

    func selectSuggestion(_ suggestion: String, onResolved: @escaping (ExplorePlace) -> Void) {
        query = suggestion

        let matches = ExploreMockData.filter(
            query: suggestion,
            filter: activeFilter,
            locality: selectedLocality?.name
        )
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

    // MARK: - Private Search Helper

    private func performSearch(query: String) {
        let results = ExploreMockData.filter(
            query: query,
            filter: activeFilter,
            locality: selectedLocality?.name
        )
        searchState = results.isEmpty ? .empty : .loaded(results)
    }
}
