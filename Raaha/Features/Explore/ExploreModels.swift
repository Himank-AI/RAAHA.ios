import Foundation
import MapKit

// MARK: - Domain Model

/// Unified place model wrapping an MKMapItem with derived helpers.
struct ExplorePlace: Identifiable {
    let id: String                       // stable: MKMapItem.identifier or UUID
    let mapItem: MKMapItem

    var name: String          { mapItem.name ?? "Unknown" }
    var category: PlaceCategory
    var address: String       { mapItem.placemark.thoroughfare ?? mapItem.placemark.locality ?? "" }
    var locality: String      { mapItem.placemark.locality ?? mapItem.placemark.administrativeArea ?? "Chennai" }
    var phoneNumber: String?  { mapItem.phoneNumber }
    var website: URL?         { mapItem.url }
    var distance: CLLocationDistance?   // metres, set by search service when user location available

    // Opening status — only set if the MapKit item provides it
    var isOpenNow: Bool?      { nil } // MapKit MKMapItem does not reliably expose this; we do not fabricate it

    var distanceText: String? {
        guard let d = distance else { return nil }
        if d < 1000 { return "\(Int(d)) m away" }
        let km = d / 1000
        return String(format: "%.1f km away", km)
    }

    /// SF Symbol name that best matches the category.
    var symbolName: String { category.symbol }

    var coordinate: CLLocationCoordinate2D { mapItem.placemark.coordinate }
    var isValidChennaiLocation: Bool { ChennaiServiceArea.shared.validate(coordinate: coordinate) }

    init(mapItem: MKMapItem, userLocation: CLLocation? = nil) {
        self.mapItem = mapItem
        if #available(iOS 18.0, *) {
            self.id = mapItem.identifier?.rawValue ?? UUID().uuidString
        } else {
            self.id = UUID().uuidString
        }
        self.category = PlaceCategory.from(mapItem: mapItem)
        if let userLocation, let coord = mapItem.placemark.location {
            self.distance = userLocation.distance(from: coord)
        }
    }
}

// MARK: - Place Categories

enum PlaceCategory: String, CaseIterable {
    case restaurant, cafe, beach, park, landmark, shopping, attraction, other

    static func from(mapItem: MKMapItem) -> PlaceCategory {
        guard let types = mapItem.pointOfInterestCategory else { return .other }
        switch types {
        case .restaurant, .foodMarket, .bakery:    return .restaurant
        case .cafe:                                 return .cafe
        case .beach:                                return .beach
        case .park, .nationalPark:                  return .park
        case .museum, .theater, .amusementPark,
             .aquarium, .zoo:                       return .attraction
        case .store:                                return .shopping
        default:                                    return .landmark
        }
    }

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

enum ExploreFilter: String, CaseIterable, Identifiable {
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

    /// Maps to MKPointOfInterestCategory for MapKit queries
    var mkCategory: String {
        switch self {
        case .all:         return ""
        case .restaurants: return "restaurant"
        case .beaches:     return "beach"
        case .parks:       return "park"
        case .landmarks:   return "landmark"
        case .shopping:    return "store"
        }
    }

    var naturalLanguageQuery: String {
        switch self {
        case .all:         return "places"
        case .restaurants: return "restaurants cafes"
        case .beaches:     return "beach"
        case .parks:       return "park"
        case .landmarks:   return "landmarks monuments tourist"
        case .shopping:    return "shopping mall market"
        }
    }
}
