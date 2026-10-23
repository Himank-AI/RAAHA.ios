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
        self.address = mapItem.placemark.thoroughfare ?? mapItem.placemark.locality ?? ""
        self.locality = mapItem.placemark.locality ?? mapItem.placemark.administrativeArea ?? "Chennai"
        self.phoneNumber = mapItem.phoneNumber
        self.website = mapItem.url
        if let userLocation, let coord = mapItem.placemark.location {
            self.distance = userLocation.distance(from: coord)
        } else {
            self.distance = nil
        }
        self.rating = nil
        self.reviewCount = nil
        self.openingStatus = "Open now"
        self.coordinate = mapItem.placemark.coordinate
        self.localAssetImageName = nil
        self.tags = []
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
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = name
        item.openInMaps(launchOptions: nil)
    }
}

// MARK: - Place Categories

enum PlaceCategory: String, CaseIterable, Hashable {
    case restaurant, cafe, beach, park, landmark, shopping, attraction, other

    var title: String {
        switch self {
        case .restaurant:  return "Restaurant"
        case .cafe:        return "Cafe"
        case .beach:       return "Beach"
        case .park:        return "Park"
        case .landmark:    return "Landmark"
        case .shopping:    return "Shopping"
        case .attraction:  return "Attraction"
        case .other:       return "Place"
        }
    }

    var symbol: String {
        switch self {
        case .restaurant:  return "fork.knife"
        case .cafe:        return "cup.and.heat.waves"
        case .beach:       return "umbrella.fill"
        case .park:        return "tree.fill"
        case .landmark:    return "building.columns.fill"
        case .shopping:    return "bag.fill"
        case .attraction:  return "star.fill"
        case .other:       return "mappin.and.ellipse"
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
    case all, restaurants, beaches, parks, landmarks, shopping

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:         return "All"
        case .restaurants: return "Restaurants"
        case .beaches:     return "Beaches"
        case .parks:       return "Parks"
        case .landmarks:   return "Landmarks"
        case .shopping:    return "Shopping"
        }
    }

    var symbol: String {
        switch self {
        case .all:         return "square.grid.2x2"
        case .restaurants: return "fork.knife"
        case .beaches:     return "umbrella.fill"
        case .parks:       return "tree.fill"
        case .landmarks:   return "building.columns.fill"
        case .shopping:    return "bag.fill"
        }
    }

    func matches(_ place: ExplorePlace) -> Bool {
        switch self {
        case .all:
            return true
        case .restaurants:
            return place.category == .restaurant || place.category == .cafe
        case .beaches:
            return place.category == .beach
        case .parks:
            return place.category == .park
        case .landmarks:
            return place.category == .landmark || place.category == .attraction
        case .shopping:
            return place.category == .shopping
        }
    }
}
