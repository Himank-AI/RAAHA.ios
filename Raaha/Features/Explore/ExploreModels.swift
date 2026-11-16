import Foundation
import CoreLocation
import MapKit

// MARK: - Domain Model

/// Unified place model representing a Chennai destination, restaurant, or landmark.
/// Designed for fast, offline frontend rendering with rich static mock data.
struct ExplorePlace: Identifiable, Hashable {
    let id: String
    let name: String
    let category: PlaceCategory
    let address: String
    let locality: String
    let phoneNumber: String?
    let website: URL?
    let distance: CLLocationDistance?
    let rating: Double?
    let reviewCount: Int?
    let openingStatus: String?
    let coordinate: CLLocationCoordinate2D
    let localAssetImageName: String?
    let tags: [String]

    init(
        id: String = UUID().uuidString,
        name: String,
        category: PlaceCategory,
        address: String,
        locality: String,
        phoneNumber: String? = nil,
        website: URL? = nil,
        distance: CLLocationDistance? = nil,
        rating: Double? = nil,
        reviewCount: Int? = nil,
        openingStatus: String? = "Open now",
        coordinate: CLLocationCoordinate2D,
        localAssetImageName: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.address = address
        self.locality = locality
        self.phoneNumber = phoneNumber
        self.website = website
        self.distance = distance
        self.rating = rating
        self.reviewCount = reviewCount
        self.openingStatus = openingStatus
        self.coordinate = coordinate
        self.localAssetImageName = localAssetImageName
        self.tags = tags
    }

    /// Convenience initializer from an MKMapItem for backwards compatibility and MapItem testing.
    init(mapItem: MKMapItem, userLocation: CLLocation? = nil) {
        if #available(iOS 18.0, *) {
            self.id = mapItem.identifier?.rawValue ?? UUID().uuidString
        } else {
            self.id = UUID().uuidString
        }
        self.name = mapItem.name ?? "Unknown"
        self.category = .landmark
        self.phoneNumber = mapItem.phoneNumber
        self.website = mapItem.url
        self.rating = nil
        self.reviewCount = nil
        self.openingStatus = "Open now"
        self.localAssetImageName = nil
        self.tags = []

        if #available(iOS 26.0, *) {
            let location = mapItem.location
            self.coordinate = location.coordinate
            self.address = mapItem.addressRepresentations?.fullAddress(includingRegion: false, singleLine: true)
                ?? mapItem.address?.fullAddress
                ?? mapItem.name
                ?? ""
            self.locality = mapItem.addressRepresentations?.cityWithContext(.short)
                ?? "Chennai"
            if let userLocation {
                self.distance = userLocation.distance(from: location)
            } else {
                self.distance = nil
            }
        } else {
            self.address = mapItem.placemark.thoroughfare ?? mapItem.placemark.locality ?? ""
            self.locality = mapItem.placemark.locality ?? mapItem.placemark.administrativeArea ?? "Chennai"
            if let userLocation, let coord = mapItem.placemark.location {
                self.distance = userLocation.distance(from: coord)
            } else {
                self.distance = nil
            }
            self.coordinate = mapItem.placemark.coordinate
        }
    }

    var distanceText: String? {
        guard let d = distance else { return nil }
        if d < 1000 { return "\(Int(d)) m away" }
        let km = d / 1000
        return String(format: "%.1f km away", km)
    }

    var ratingText: String? {
        guard let r = rating else { return nil }
        return String(format: "%.1f", r)
    }

    var isOpenNow: Bool? {
        guard let status = openingStatus?.lowercased() else { return nil }
        return status.contains("open")
    }

    /// SF Symbol name that best matches the category.
    var symbolName: String { category.symbol }

    /// Normalized phone digits suitable for `tel:` URLs, if a usable number exists.
    var dialablePhoneNumber: String? {
        guard let phoneNumber else { return nil }
        let trimmed = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let dialable = trimmed.filter { $0.isNumber || $0 == "+" }
        guard dialable.filter(\.isNumber).count >= 6 else { return nil }
        return dialable
    }

    /// Whether the Place Detail phone section should appear for this location.
    /// Beaches never show phone; restaurants/cafes and other places show it only when a valid number exists.
    var shouldDisplayPhoneSection: Bool {
        guard dialablePhoneNumber != nil else { return false }
        switch category {
        case .beach:
            return false
        case .restaurant, .cafe, .landmark, .shopping, .attraction, .park, .entertainment, .other:
            return true
        }
    }

    /// Combined address line for detail screens.
    var displayAddress: String {
        [address, locality]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    /// Verified Chennai location.
    var isValidChennaiLocation: Bool {
        ChennaiServiceArea.shared.validate(coordinate: coordinate)
    }

    // MARK: Hashable & Equatable

    static func == (lhs: ExplorePlace, rhs: ExplorePlace) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Opens location in native Apple Maps.
    func openInMaps() {
        let item: MKMapItem
        if #available(iOS 26.0, *) {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            item = MKMapItem(location: location, address: nil)
        } else {
            item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        }
        item.name = name
        item.openInMaps(launchOptions: nil)
    }
}

// MARK: - MapKit Compatibility

extension MKMapItem {
    /// Coordinate using the modern `location` API on iOS 26+, with placemark fallback for earlier OS versions.
    var raahaCoordinate: CLLocationCoordinate2D {
        if #available(iOS 26.0, *) {
            location.coordinate
        } else {
            placemark.coordinate
        }
    }

    /// Creates an `MKMapItem` without relying on deprecated placemark APIs when running on iOS 26+.
    static func raahaItem(coordinate: CLLocationCoordinate2D, name: String? = nil) -> MKMapItem {
        let item: MKMapItem
        if #available(iOS 26.0, *) {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            item = MKMapItem(location: location, address: nil)
        } else {
            item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        }
        item.name = name
        return item
    }
}

// MARK: - Place Categories

enum PlaceCategory: String, CaseIterable, Hashable {
    case restaurant, cafe, beach, park, landmark, shopping, attraction, entertainment, other

    var title: String {
        switch self {
        case .restaurant:     return "Restaurant"
        case .cafe:           return "Cafe"
        case .beach:          return "Beach"
        case .park:           return "Park"
        case .landmark:       return "Landmark"
        case .shopping:       return "Shopping"
        case .attraction:     return "Attraction"
        case .entertainment:  return "Entertainment"
        case .other:          return "Place"
        }
    }

    var symbol: String {
        switch self {
        case .restaurant:     return "fork.knife"
        case .cafe:           return "cup.and.heat.waves"
        case .beach:          return "umbrella.fill"
        case .park:           return "tree.fill"
        case .landmark:       return "building.columns.fill"
        case .shopping:       return "bag.fill"
        case .attraction:     return "star.fill"
        case .entertainment:  return "theatermasks.fill"
        case .other:          return "icon_pin"
        }
    }
}

// MARK: - Search Result State

enum PlacesLoadState: Equatable {
    case idle
    case loading
    case loaded([ExplorePlace])
    case empty
    case error(String)

    static func == (lhs: PlacesLoadState, rhs: PlacesLoadState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.empty, .empty): return true
        case let (.error(a), .error(b)): return a == b
        case let (.loaded(a), .loaded(b)): return a.map(\.id) == b.map(\.id)
        default: return false
        }
    }

    var places: [ExplorePlace] {
        if case .loaded(let p) = self { return p }
        return []
    }
}

// MARK: - Filter

enum ExploreFilter: String, CaseIterable, Identifiable, Hashable {
    case all
    case restaurants
    case cafes
    case parks
    case beaches
    case touristSpots
    case shopping
    case entertainment

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:            return "All"
        case .restaurants:    return "Restaurants"
        case .cafes:          return "Cafes"
        case .parks:          return "Parks"
        case .beaches:        return "Beaches"
        case .touristSpots:   return "Tourist Spots"
        case .shopping:       return "Shopping"
        case .entertainment:  return "Entertainment"
        }
    }

    /// Section heading for the nearby list. All stays "Nearby spots"; every other filter uses its category name.
    var nearbySectionTitle: String {
        switch self {
        case .all:            return "Nearby spots"
        case .restaurants:    return "Nearby restaurants"
        case .cafes:          return "Nearby cafes"
        case .parks:          return "Nearby parks"
        case .beaches:        return "Nearby beaches"
        case .touristSpots:   return "Nearby tourist spots"
        case .shopping:       return "Nearby shopping"
        case .entertainment:  return "Nearby entertainment"
        }
    }

    var symbol: String {
        switch self {
        case .all:            return "square.grid.2x2"
        case .restaurants:    return "fork.knife"
        case .cafes:          return "cup.and.heat.waves"
        case .parks:          return "tree.fill"
        case .beaches:        return "umbrella.fill"
        case .touristSpots:   return "binoculars.fill"
        case .shopping:       return "bag.fill"
        case .entertainment:  return "theatermasks.fill"
        }
    }

    func matches(_ place: ExplorePlace) -> Bool {
        switch self {
        case .all:
            return true
        case .restaurants:
            return place.category == .restaurant
        case .cafes:
            return place.category == .cafe
        case .parks:
            return place.category == .park
        case .beaches:
            return place.category == .beach
        case .touristSpots:
            return place.category == .landmark || place.category == .attraction
        case .shopping:
            return place.category == .shopping
        case .entertainment:
            return place.category == .entertainment
                || place.tags.contains { $0.lowercased().contains("cinema") || $0.lowercased().contains("entertainment") }
        }
    }
}
