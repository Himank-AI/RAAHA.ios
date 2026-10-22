import Foundation
import MapKit
import CoreLocation
import Combine

// MARK: - ExploreViewModel

@MainActor
final class ExploreViewModel: ObservableObject {

    // MARK: Published state
    @Published private(set) var nearbyState: PlacesLoadState = .idle
    @Published private(set) var searchState: PlacesLoadState = .idle
    @Published private(set) var featuredPlaces: [ExplorePlace] = []
    @Published private(set) var isFeaturedLoading = true
    @Published var activeFilter: ExploreFilter = .all
    @Published var query: String = ""
    @Published var recentSearches: [String] = []

    var isSearchActive: Bool { !query.isEmpty }

    // MARK: Dependencies
    private let searchService: PlaceSearchService
    private let locationManager: LocationManager

    // MARK: Debounce
    private var searchTask: Task<Void, Never>?
    private var nearbyTask: Task<Void, Never>?
    private var featuredTask: Task<Void, Never>?

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        self.searchService = PlaceSearchService()
    }

    // MARK: - Public actions

    func onAppear() {
        locationManager.requestPermission()
        loadNearby()
        loadFeatured()
    }

    func loadNearby() {
        nearbyTask?.cancel()
        nearbyTask = Task {
            await fetchNearby(filter: activeFilter)
        }
    }

    func refresh() {
        loadNearby()
        featuredPlaces = []
        isFeaturedLoading = true
        loadFeatured()
    }

    func setFilter(_ filter: ExploreFilter) {
        guard activeFilter != filter else { return }
        activeFilter = filter
        loadNearby()
    }

    func onQueryChange(_ newQuery: String) {
        searchTask?.cancel()
        guard !newQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchState = .idle
            return
        }
        searchState = .loading
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000) // 350ms debounce
            guard !Task.isCancelled else { return }
            await performSearch(query: newQuery)
        }
    }

    func submitSearch(_ q: String) {
        let trimmed = q.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        addToRecent(trimmed)
        searchTask?.cancel()
        searchState = .loading
        searchTask = Task { await performSearch(query: trimmed) }
    }

    func clearSearch() {
        searchTask?.cancel()
        query = ""
        searchState = .idle
    }

    func removeRecent(_ search: String) {
        recentSearches.removeAll { $0 == search }
    }

    // MARK: - Private helpers

    private func fetchNearby(filter: ExploreFilter) async {
        nearbyState = .loading
        do {
            let region = searchRegion()
            let q = filter == .all ? "popular places things to do" : filter.naturalLanguageQuery
            let results = try await searchService.searchNearby(
                query: q,
                in: region,
                userLocation: locationManager.userLocation,
                resultLimit: 20
            )
            guard !Task.isCancelled else { return }
            nearbyState = results.isEmpty ? .empty : .loaded(results)
        } catch is CancellationError {
            // Ignore
        } catch {
            guard !Task.isCancelled else { return }
            nearbyState = .error(friendlyError(error))
        }
    }

    private func performSearch(query: String) async {
        do {
            let region = searchRegion()
            let results = try await searchService.searchNearby(
                query: query,
                in: region,
                userLocation: locationManager.userLocation,
                resultLimit: 25
            )
            guard !Task.isCancelled else { return }
            searchState = results.isEmpty ? .empty : .loaded(results)
        } catch is CancellationError {
            // Ignore
        } catch {
            guard !Task.isCancelled else { return }
            searchState = .error(friendlyError(error))
        }
    }

    private func loadFeatured() {
        featuredTask?.cancel()
        featuredTask = Task {
            isFeaturedLoading = true
            do {
                let places = try await searchService.searchFeatured(
                    userLocation: locationManager.userLocation
                )
                guard !Task.isCancelled else { return }
                featuredPlaces = places
            } catch {
                // silently keep empty on failure
            }
            isFeaturedLoading = false
        }
    }

    private func searchRegion() -> MKCoordinateRegion {
        if let loc = locationManager.userLocation {
            return MKCoordinateRegion(
                center: loc.coordinate,
                latitudinalMeters: 10_000,
                longitudinalMeters: 10_000
            )
        }
        return PlaceSearchService.chennaiRegion
    }

    private func addToRecent(_ search: String) {
        recentSearches.removeAll { $0 == search }
        recentSearches.insert(search, at: 0)
        if recentSearches.count > 8 { recentSearches = Array(recentSearches.prefix(8)) }
    }

    private func friendlyError(_ error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == MKErrorDomain {
            switch MKError.Code(rawValue: UInt(nsError.code)) {
            case .serverFailure:    return "Search service is unavailable. Try again."
            case .loadingThrottled: return "Too many requests. Please wait a moment."
            case .placemarkNotFound: return "No places found for that search."
            default: break
            }
        }
        if nsError.domain == NSURLErrorDomain {
            return "No internet connection. Check your network and try again."
        }
        return "Search failed. Please try again."
    }
}
