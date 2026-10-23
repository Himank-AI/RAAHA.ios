import Foundation
import MapKit
import CoreLocation

// MARK: - Place Search Service

/// Wraps MKLocalSearch with strict Chennai geographic boundary validation.
///
/// CRITICAL PRODUCT RULE: RAAHA serves Chennai, Tamil Nadu, India exclusively.
/// No results outside the configured Chennai service boundary are ever displayed,
/// cached, or returned.
actor PlaceSearchService {

    private var currentSearch: MKLocalSearch?
    private let cache = NSCache<NSString, CacheEntry>()

    init() {
        cache.countLimit = 60
        cache.totalCostLimit = 4 * 1024 * 1024 // 4 MB approx
    }

    // MARK: - Public Search Interface

    /// Performs search restricted strictly to the Chennai service boundary.
    /// Rejects any results outside the approved polygon even if the query mentions outside locations.
    func searchNearby(
        query: String,
        in region: MKCoordinateRegion? = nil,
        userLocation: CLLocation?,
        resultLimit: Int = 20
    ) async throws -> [ExplorePlace] {

        // Validate the region center: if region is outside Chennai, fall back strictly to Chennai default region
        let searchRegion: MKCoordinateRegion
        if let region = region, ChennaiServiceArea.shared.contains(coordinate: region.center) {
            searchRegion = region
        } else {
            searchRegion = ChennaiServiceArea.shared.defaultRegion
        }

        let roundedLat = (searchRegion.center.latitude * 100).rounded() / 100
        let roundedLon = (searchRegion.center.longitude * 100).rounded() / 100
        let cacheKey = "\(query.lowercased().trimmingCharacters(in: .whitespaces))|\(roundedLat)|\(roundedLon)" as NSString

        // Cache lookup with boundary re-validation
        if let cached = cache.object(forKey: cacheKey), !cached.isStale {
            let revalidated = ChennaiServiceArea.shared.revalidate(cachedPlaces: cached.places)
            return revalidated
        }

        // Cancel any in-flight search
        currentSearch?.cancel()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query.isEmpty ? "places" : query
        request.region = searchRegion
        request.resultTypes = .pointOfInterest
        if #available(iOS 18.0, *) {
            request.regionPriority = .required
        }

        let search = MKLocalSearch(request: request)
        currentSearch = search

        let response = try await search.start()

        // CRITICAL PRODUCT RULE: Filter all items strictly through the Chennai service area boundary
        let validatedItems = ChennaiServiceArea.shared.filterMapItems(response.mapItems)

        let places = validatedItems
            .prefix(resultLimit)
            .map { ExplorePlace(mapItem: $0, userLocation: userLocation) }
            .sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }

        // Cache ONLY results that passed boundary validation
        let entry = CacheEntry(places: places)
        cache.setObject(entry, forKey: cacheKey, cost: places.count * 512)

        return places
    }

    /// Fetches verified Chennai-only featured destinations inside the approved boundary.
    /// Mahabalipuram is explicitly omitted because it lies outside the Chennai service boundary.
    func searchFeatured(userLocation: CLLocation?) async throws -> [ExplorePlace] {
        let queries = [
            "Marina Beach, Chennai",
            "Besant Nagar Beach, Chennai",
            "Kapaleeshwarar Temple, Mylapore, Chennai",
            "San Thome Cathedral Basilica, Chennai"
        ]
        var featured: [ExplorePlace] = []
        for q in queries {
            if let result = try? await searchSingle(query: q, userLocation: userLocation) {
                // Double-check boundary validation
                if ChennaiServiceArea.shared.validate(place: result) {
                    featured.append(result)
                }
            }
        }
        return featured
    }

    /// Searches for a single place query, verifying it is strictly inside Chennai.
    func searchSingle(query: String, userLocation: CLLocation?) async throws -> ExplorePlace? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = ChennaiServiceArea.shared.defaultRegion
        request.resultTypes = .pointOfInterest
        if #available(iOS 18.0, *) {
            request.regionPriority = .required
        }
        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        // Return first item strictly inside Chennai
        for item in response.mapItems {
            if ChennaiServiceArea.shared.validate(mapItem: item) {
                return ExplorePlace(mapItem: item, userLocation: userLocation)
            }
        }
        return nil
    }

    /// Resolves an MKLocalSearchCompletion to an ExplorePlace, strictly validating its coordinates.
    func resolveCompletion(
        _ completion: MKLocalSearchCompletion,
        userLocation: CLLocation?
    ) async throws -> ExplorePlace? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        for item in response.mapItems {
            if ChennaiServiceArea.shared.validate(mapItem: item) {
                return ExplorePlace(mapItem: item, userLocation: userLocation)
            }
        }
        return nil
    }

    func cancelCurrent() {
        currentSearch?.cancel()
        currentSearch = nil
    }

    // MARK: - Cache Entry

    private final class CacheEntry {
        let places: [ExplorePlace]
        let timestamp: Date

        init(places: [ExplorePlace]) {
            self.places = places
            self.timestamp = Date()
        }

        var isStale: Bool {
            Date().timeIntervalSince(timestamp) > 300 // 5 min TTL
        }
    }
}
