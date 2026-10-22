import Foundation
import MapKit
import CoreLocation

// MARK: - Place Search Service

/// Wraps MKLocalSearch to provide async/await place discovery.
/// All searches are performed in Chennai, India as the fallback region.
actor PlaceSearchService {

    // Chennai city centre — used when user location is unavailable
    static let chennaiCenter = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2785)
    static let chennaiRegion = MKCoordinateRegion(
        center: chennaiCenter,
        latitudinalMeters: 25_000,
        longitudinalMeters: 25_000
    )

    private var currentSearch: MKLocalSearch?
    private let cache = NSCache<NSString, CacheEntry>()

    init() {
        cache.countLimit = 60
        cache.totalCostLimit = 4 * 1024 * 1024 // 4 MB approx
    }

    // MARK: - Public interface

    func searchNearby(
        query: String,
        in region: MKCoordinateRegion,
        userLocation: CLLocation?,
        resultLimit: Int = 20
    ) async throws -> [ExplorePlace] {

        let cacheKey = "\(query)|\(region.center.latitude.rounded())|\(region.center.longitude.rounded())" as NSString

        if let cached = cache.object(forKey: cacheKey), !cached.isStale {
            return cached.places
        }

        // Cancel any in-flight search before issuing a new one
        currentSearch?.cancel()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query.isEmpty ? "places" : query
        request.region = region
        request.resultTypes = .pointOfInterest
        if #available(iOS 18.0, *) {
            request.regionPriority = .required
        }

        let search = MKLocalSearch(request: request)
        currentSearch = search

        let response = try await search.start()
        let places = response.mapItems
            .prefix(resultLimit)
            .map { ExplorePlace(mapItem: $0, userLocation: userLocation) }
            .sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }

        let entry = CacheEntry(places: places)
        cache.setObject(entry, forKey: cacheKey, cost: places.count * 512)

        return places
    }

    func searchFeatured(userLocation: CLLocation?) async throws -> [ExplorePlace] {
        // These are real landmarks curated for Chennai – names are resolved via MapKit
        let queries = ["Marina Beach Chennai", "Besant Nagar Beach Chennai", "Mahabalipuram", "Kapaleeshwarar Temple"]
        var featured: [ExplorePlace] = []
        for q in queries {
            if let result = try? await searchSingle(query: q, userLocation: userLocation) {
                featured.append(result)
            }
        }
        return featured
    }

    func searchSingle(query: String, userLocation: CLLocation?) async throws -> ExplorePlace? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = PlaceSearchService.chennaiRegion
        request.resultTypes = .pointOfInterest
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        return response.mapItems.first.map { ExplorePlace(mapItem: $0, userLocation: userLocation) }
    }

    func cancelCurrent() {
        currentSearch?.cancel()
        currentSearch = nil
    }

    // MARK: - Cache entry

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
