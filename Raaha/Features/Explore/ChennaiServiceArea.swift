import Foundation
import CoreLocation
import MapKit

// MARK: - Chennai Locality Model

/// Represents a verified locality within the Chennai service area boundary.
public struct ChennaiLocality: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let coordinate: CLLocationCoordinate2D
    public let tagline: String
    public let symbol: String

    public init(id: String = UUID().uuidString, name: String, latitude: Double, longitude: Double, tagline: String, symbol: String) {
        self.id = id
        self.name = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.tagline = tagline
        self.symbol = symbol
    }

    public static func == (lhs: ChennaiLocality, rhs: ChennaiLocality) -> Bool {
        lhs.name == rhs.name &&
        abs(lhs.coordinate.latitude - rhs.coordinate.latitude) < 0.0001 &&
        abs(lhs.coordinate.longitude - rhs.coordinate.longitude) < 0.0001
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(coordinate.latitude.rounded())
        hasher.combine(coordinate.longitude.rounded())
    }
}

// MARK: - Chennai Service Area Boundary

/// Centralized geographic service boundary and validator for RAAHA.
///
/// CRITICAL PRODUCT RULE: RAAHA serves Chennai, Tamil Nadu, India exclusively.
/// Every place search, autocomplete suggestion, nearby result, restaurant, cafe,
/// featured destination, recommendation, and place detail must refer to a location
/// inside this configured Chennai service boundary.
///
/// Coordinate-based point-in-polygon validation is strictly enforced to prevent outside-city
/// results from leaking in even when queries name other cities (e.g. "San Francisco").
public struct ChennaiServiceArea: Sendable {

    public static let shared = ChennaiServiceArea()

    // Service identification
    public let serviceCity = "Chennai"
    public let serviceState = "Tamil Nadu"
    public let serviceCountry = "India"
    public let serviceCountryCode = "IN"

    /// ARCHITECTURAL DECISION ON MAHABALIPURAM:
    /// Mahabalipuram (Mamallapuram) is situated at (12.6269° N, 80.1927° E) in Chengalpattu
    /// district, ~56 km south of Chennai Central.
    /// Under RAAHA's STRICT CHENNAI-ONLY product rule, service is confined to the Chennai
    /// Metropolitan Area. Because Mahabalipuram is in a separate district well south of
    /// the approved southern boundary (12.83° N), it is EXPLICITLY EXCLUDED from RAAHA's
    /// service area. It must not appear in search results, featured carousels, or fallback data.
    public static let isMahabalipuramIncluded: Bool = false

    /// Chennai metropolitan center (Anna Salai / Central)
    public let defaultCenter = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)

    /// Default search region centered on Chennai with appropriate span for discovery
    public var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: defaultCenter,
            latitudinalMeters: 22_000,
            longitudinalMeters: 22_000
        )
    }

    /// Approved Chennai Metropolitan Area polygon boundary vertices (ordered clockwise).
    /// Encompasses GCC & CMA limits: Ennore (N), Minjur (N), Red Hills (NW), Avadi (W),
    /// Poonamallee (W), Kundrathur (SW), Tambaram (SW), Vandalur / Kelambakkam border (S),
    /// Kovalam / Muttukadu inlet (SE), and the Bay of Bengal coastline (E).
    public let polygon: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 13.2600, longitude: 80.3350), // Ennore Port / North Coast
        CLLocationCoordinate2D(latitude: 13.2800, longitude: 80.2600), // Minjur North
        CLLocationCoordinate2D(latitude: 13.2300, longitude: 80.1500), // Sholavaram / Red Hills North
        CLLocationCoordinate2D(latitude: 13.1800, longitude: 80.1200), // Puzhal / Ambattur North
        CLLocationCoordinate2D(latitude: 13.1200, longitude: 80.0600), // Avadi / Pattabiram
        CLLocationCoordinate2D(latitude: 13.0500, longitude: 80.0200), // Poonamallee West
        CLLocationCoordinate2D(latitude: 12.9800, longitude: 80.0500), // Kundrathur
        CLLocationCoordinate2D(latitude: 12.9200, longitude: 80.0700), // Tambaram West
        CLLocationCoordinate2D(latitude: 12.8700, longitude: 80.0700), // Vandalur South-West
        CLLocationCoordinate2D(latitude: 12.8300, longitude: 80.1000), // Southern Boundary West
        CLLocationCoordinate2D(latitude: 12.8300, longitude: 80.2200), // Kelambakkam / Siruseri border
        CLLocationCoordinate2D(latitude: 12.8300, longitude: 80.2600), // Muttukadu / Kovalam coast border
        CLLocationCoordinate2D(latitude: 12.9000, longitude: 80.2650), // Sholinganallur East Coast
        CLLocationCoordinate2D(latitude: 12.9900, longitude: 80.2750), // Thiruvanmiyur Coast
        CLLocationCoordinate2D(latitude: 13.0600, longitude: 80.2900), // Marina Beach Coast
        CLLocationCoordinate2D(latitude: 13.1200, longitude: 80.3050), // Royapuram / Kasimedu Coast
        CLLocationCoordinate2D(latitude: 13.1800, longitude: 80.3150)  // Tiruvottiyur Coast
    ]

    /// Bounding box for O(1) early rejection before polygon ray-casting.
    public let boundingBox: (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double)

    /// Curated verified Chennai localities inside the boundary.
    public let approvedLocalities: [ChennaiLocality]

    /// Curated Chennai-specific search suggestion queries for empty/prompt states.
    public let emptySearchSuggestions: [String] = [
        "Filter Coffee",
        "Chettinad Cuisine",
        "South Indian Tiffin",
        "Marina Beach",
        "Besant Nagar",
        "Mylapore Temples",
        "T. Nagar Shopping",
        "Anna Nagar Tower Park"
    ]

    public init() {
        // Compute bounding box from polygon
        let poly = [
            CLLocationCoordinate2D(latitude: 13.2600, longitude: 80.3350),
            CLLocationCoordinate2D(latitude: 13.2800, longitude: 80.2600),
            CLLocationCoordinate2D(latitude: 13.2300, longitude: 80.1500),
            CLLocationCoordinate2D(latitude: 13.1800, longitude: 80.1200),
            CLLocationCoordinate2D(latitude: 13.1200, longitude: 80.0600),
            CLLocationCoordinate2D(latitude: 13.0500, longitude: 80.0200),
            CLLocationCoordinate2D(latitude: 12.9800, longitude: 80.0500),
            CLLocationCoordinate2D(latitude: 12.9200, longitude: 80.0700),
            CLLocationCoordinate2D(latitude: 12.8700, longitude: 80.0700),
            CLLocationCoordinate2D(latitude: 12.8300, longitude: 80.1000),
            CLLocationCoordinate2D(latitude: 12.8300, longitude: 80.2200),
            CLLocationCoordinate2D(latitude: 12.8300, longitude: 80.2600),
            CLLocationCoordinate2D(latitude: 12.9000, longitude: 80.2650),
            CLLocationCoordinate2D(latitude: 12.9900, longitude: 80.2750),
            CLLocationCoordinate2D(latitude: 13.0600, longitude: 80.2900),
            CLLocationCoordinate2D(latitude: 13.1200, longitude: 80.3050),
            CLLocationCoordinate2D(latitude: 13.1800, longitude: 80.3150)
        ]

        var minLat = Double.infinity
        var maxLat = -Double.infinity
        var minLon = Double.infinity
        var maxLon = -Double.infinity

        for pt in poly {
            minLat = min(minLat, pt.latitude)
            maxLat = max(maxLat, pt.latitude)
            minLon = min(minLon, pt.longitude)
            maxLon = max(maxLon, pt.longitude)
        }

        self.boundingBox = (minLat, maxLat, minLon, maxLon)

        self.approvedLocalities = [
            ChennaiLocality(name: "T. Nagar", latitude: 13.0418, longitude: 80.2341, tagline: "Shopping & Dining Hub", symbol: "bag.fill"),
            ChennaiLocality(name: "Marina Beach", latitude: 13.0500, longitude: 80.2824, tagline: "World's 2nd Longest Beach", symbol: "water.waves"),
            ChennaiLocality(name: "Besant Nagar", latitude: 13.0001, longitude: 80.2667, tagline: "Elliot's Beach & Cafes", symbol: "cup.and.heat.waves"),
            ChennaiLocality(name: "Mylapore", latitude: 13.0334, longitude: 80.2706, tagline: "Kapaleeshwarar & Heritage", symbol: "building.columns.fill"),
            ChennaiLocality(name: "Adyar", latitude: 13.0012, longitude: 80.2565, tagline: "Theosophical & Bakeries", symbol: "tree.fill"),
            ChennaiLocality(name: "Anna Nagar", latitude: 13.0850, longitude: 80.2100, tagline: "Tower Park & Boutiques", symbol: "sparkles"),
            ChennaiLocality(name: "Velachery", latitude: 12.9759, longitude: 80.2212, tagline: "Phoenix Mall & Transit", symbol: "tram.fill"),
            ChennaiLocality(name: "San Thome", latitude: 13.0336, longitude: 80.2783, tagline: "Historic Basilica & Coast", symbol: "cross.fill"),
            ChennaiLocality(name: "Guindy", latitude: 13.0067, longitude: 80.2026, tagline: "National Park & Tech Hub", symbol: "leaf.fill"),
            ChennaiLocality(name: "Nungambakkam", latitude: 13.0594, longitude: 80.2425, tagline: "Culture & Fine Dining", symbol: "fork.knife")
        ]
    }

    // MARK: - Point-in-Polygon Geographic Validation

    /// Validates whether a given geographic coordinate falls strictly inside the Chennai service boundary.
    /// Uses bounding box pre-screening followed by ray-casting (Jordan curve theorem).
    public func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        // Fast bounding box check
        guard coordinate.latitude >= boundingBox.minLat,
              coordinate.latitude <= boundingBox.maxLat,
              coordinate.longitude >= boundingBox.minLon,
              coordinate.longitude <= boundingBox.maxLon else {
            return false
        }

        // Ray-casting algorithm: count ray intersections from point horizontally to the right (+longitude)
        var inside = false
        let count = polygon.count
        var j = count - 1

        for i in 0..<count {
            let pi = polygon[i]
            let pj = polygon[j]

            // Check if the horizontal ray at coordinate.latitude crosses the edge between pi and pj
            if ((pi.latitude > coordinate.latitude) != (pj.latitude > coordinate.latitude)) {
                let intersectLon = (pj.longitude - pi.longitude) * (coordinate.latitude - pi.latitude) / (pj.latitude - pi.latitude) + pi.longitude
                if coordinate.longitude < intersectLon {
                    inside.toggle()
                }
            }
            j = i
        }

        return inside
    }

    /// Primary validator method: returns true if coordinate is inside approved Chennai service boundary.
    public func validate(coordinate: CLLocationCoordinate2D) -> Bool {
        contains(coordinate: coordinate)
    }

    /// Validates an MKMapItem by its placemark coordinate.
    public func validate(mapItem: MKMapItem) -> Bool {
        validate(coordinate: mapItem.placemark.coordinate)
    }

    /// Checks if a user's current location is inside Chennai.
    public func isUserInChennai(location: CLLocation?) -> Bool {
        guard let location else { return false }
        return contains(coordinate: location.coordinate)
    }

    /// Checks if a coordinate is inside Chennai.
    public func isUserInChennai(coordinate: CLLocationCoordinate2D) -> Bool {
        contains(coordinate: coordinate)
    }

    /// Filters an array of MKMapItems, discarding any whose coordinates lie outside the Chennai polygon.
    public func filterMapItems(_ items: [MKMapItem]) -> [MKMapItem] {
        items.filter { validate(mapItem: $0) }
    }

    /// Validates an ExplorePlace by its coordinate.
    func validate(place: ExplorePlace) -> Bool {
        validate(coordinate: place.coordinate)
    }

    /// Filters an array of ExplorePlaces, discarding any whose coordinates lie outside the Chennai polygon.
    func filterPlaces(_ places: [ExplorePlace]) -> [ExplorePlace] {
        places.filter { validate(place: $0) }
    }

    /// Re-validates cached places on read, ensuring only points inside the current boundary are served.
    func revalidate(cachedPlaces: [ExplorePlace]) -> [ExplorePlace] {
        filterPlaces(cachedPlaces)
    }
}
