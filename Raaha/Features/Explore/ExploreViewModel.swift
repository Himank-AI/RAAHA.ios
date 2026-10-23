import Foundation
import MapKit
import CoreLocation
import Combine

// MARK: - Autocomplete Delegate Helper

private final class CompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var onUpdate: (([MKLocalSearchCompletion]) -> Void)?
    var onError: ((Error) -> Void)?

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate?(completer.results)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        onError?(error)
    }
}

// MARK: - ExploreViewModel

@MainActor
final class ExploreViewModel: ObservableObject {

    // MARK: Published State
    @Published private(set) var nearbyState: PlacesLoadState = .idle
    @Published private(set) var searchState: PlacesLoadState = .idle
    @Published private(set) var featuredPlaces: [ExplorePlace] = []
    @Published private(set) var isFeaturedLoading = true
    @Published var activeFilter: ExploreFilter = .all
    @Published var query: String = ""
    @Published var recentSearches: [String] = []

    // Chennai-specific exploration & locality overrides
    @Published var selectedLocality: ChennaiLocality? = nil
    @Published var forcedExploreChennai: Bool = false
    @Published private(set) var autocompleteSuggestions: [MKLocalSearchCompletion] = []
    @Published var outsideBoundaryAlertMessage: String? = nil

    var isSearchActive: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty }

    /// Indicates if user is confirmed outside Chennai and hasn't yet opted to "Explore Chennai"
    var isUserOutsideChennai: Bool {
        locationManager.isOutsideChennai && !forcedExploreChennai
    }

    // MARK: Dependencies
    private let searchService: PlaceSearchService
    let locationManager: LocationManager

    // Autocomplete
    private let completer = MKLocalSearchCompleter()
    private let completerDelegate = CompleterDelegate()

    // MARK: Debounce & Tasks
    private var searchTask: Task<Void, Never>?
    private var nearbyTask: Task<Void, Never>?
    private var featuredTask: Task<Void, Never>?

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        self.searchService = PlaceSearchService()

        setupCompleter()
    }

    private func setupCompleter() {
        completer.delegate = completerDelegate
        completer.region = ChennaiServiceArea.shared.defaultRegion
        completer.resultTypes = [.pointOfInterest, .address]

        completerDelegate.onUpdate = { [weak self] results in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.autocompleteSuggestions = results
            }
        }

        completerDelegate.onError = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.autocompleteSuggestions = []
            }
        }
    }

    // MARK: - Public Actions

    func onAppear() {
        locationManager.requestPermission()
        loadNearby()
        loadFeatured()
    }

    func loadNearby() {
        // If user is outside Chennai and has not chosen to explore Chennai, do not fetch places near their position
        if isUserOutsideChennai {
            nearbyState = .idle
            return
        }

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

    func selectLocality(_ locality: ChennaiLocality?) {
        guard selectedLocality != locality else { return }
        selectedLocality = locality
        loadNearby()
    }

    func exploreChennaiAnyway() {
        forcedExploreChennai = true
        loadNearby()
    }

    func onQueryChange(_ newQuery: String) {
        searchTask?.cancel()
        let trimmed = newQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchState = .idle
            autocompleteSuggestions = []
            completer.queryFragment = ""
            return
        }

        // Bias autocomplete strictly toward Chennai
        completer.region = ChennaiServiceArea.shared.defaultRegion
        completer.queryFragment = trimmed

        searchState = .loading
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000) // 350ms debounce
            guard !Task.isCancelled else { return }
            await performSearch(query: trimmed)
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

    func selectSuggestion(_ completion: MKLocalSearchCompletion, onResolved: @escaping (ExplorePlace) -> Void) {
        searchTask?.cancel()
        searchState = .loading

        Task {
            let userLoc = locationManager.isInsideChennai ? locationManager.userLocation : nil
            if let resolved = try? await searchService.resolveCompletion(completion, userLocation: userLoc) {
                // Must pass strict Chennai boundary validation
                if ChennaiServiceArea.shared.validate(place: resolved) {
                    addToRecent(resolved.name)
                    searchState = .loaded([resolved])
                    onResolved(resolved)
                    return
                }
            }

            // If resolution failed or resolved coordinate is outside Chennai:
            outsideBoundaryAlertMessage = "\"\(completion.title)\" is located outside Chennai. RAAHA is available only in Chennai."
            searchState = .empty
        }
    }

    func clearSearch() {
        searchTask?.cancel()
        query = ""
        searchState = .idle
        autocompleteSuggestions = []
        completer.queryFragment = ""
    }

    func removeRecent(_ search: String) {
        recentSearches.removeAll { $0 == search }
    }

    // MARK: - Private Helpers

    private func fetchNearby(filter: ExploreFilter) async {
        nearbyState = .loading
        do {
            let region = searchRegion()
            let q = filter == .all ? "popular places attractions" : filter.naturalLanguageQuery
            let effectiveUserLocation = locationManager.isInsideChennai ? locationManager.userLocation : nil

            let results = try await searchService.searchNearby(
                query: q,
                in: region,
                userLocation: effectiveUserLocation,
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
            let effectiveUserLocation = locationManager.isInsideChennai ? locationManager.userLocation : nil

            let results = try await searchService.searchNearby(
                query: query,
                in: region,
                userLocation: effectiveUserLocation,
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
                let effectiveUserLocation = locationManager.isInsideChennai ? locationManager.userLocation : nil
                let places = try await searchService.searchFeatured(
                    userLocation: effectiveUserLocation
                )
                guard !Task.isCancelled else { return }
                // Extra safety: re-verify every featured place
                featuredPlaces = ChennaiServiceArea.shared.filterPlaces(places)
            } catch {
                featuredPlaces = []
            }
            isFeaturedLoading = false
        }
    }

    /// Determines the search region:
    /// - If manual locality selected, centers on that Chennai locality
    /// - If user is in Chennai, centers on user's location
    /// - Otherwise, defaults to Chennai central metropolitan region
    private func searchRegion() -> MKCoordinateRegion {
        if let locality = selectedLocality {
            return MKCoordinateRegion(
                center: locality.coordinate,
                latitudinalMeters: 6_000,
                longitudinalMeters: 6_000
            )
        }
        if let loc = locationManager.userLocation, locationManager.isInsideChennai {
            return MKCoordinateRegion(
                center: loc.coordinate,
                latitudinalMeters: 10_000,
                longitudinalMeters: 10_000
            )
        }
        return ChennaiServiceArea.shared.defaultRegion
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
            case .serverFailure:    return "Search service is temporarily unavailable. Please try again."
            case .loadingThrottled: return "Too many requests. Please wait a moment."
            case .placemarkNotFound: return "No places found in Chennai for that search."
            default: break
            }
        }
        if nsError.domain == NSURLErrorDomain {
            return "No internet connection. Please check your network."
        }
        return "Search failed. Please try again."
    }
}
