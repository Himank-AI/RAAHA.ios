import Foundation
import CoreLocation

// MARK: - Explore Mock Data Repository

/// Centralized offline mock data repository for Chennai places, restaurants, cafes, and landmarks.
/// All locations are strictly inside the Chennai service boundary.
enum ExploreMockData {

    // MARK: - Featured Chennai Places

    static let marinaBeach = ExplorePlace(
        id: "chennai_marina_beach",
        name: "Marina Beach",
        category: .beach,
        address: "Kamarajar Promenade, Triplicane, Chennai 600005",
        locality: "Mylapore Coast",
        phoneNumber: "+91 44 2844 1421",
        website: URL(string: "https://www.chennaitourism.com/marina-beach"),
        distance: 1200,
        rating: 4.6,
        reviewCount: 14850,
        openingStatus: "Open 24 hours",
        coordinate: CLLocationCoordinate2D(latitude: 13.0500, longitude: 80.2824),
        localAssetImageName: "thumb_marina",
        tags: ["beach", "sea", "sunrise", "promenade", "mylapore", "triplicane", "attraction"]
    )

    static let besantNagarBeach = ExplorePlace(
        id: "chennai_besant_beach",
        name: "Besant Nagar Beach",
        category: .beach,
        address: "6th Avenue, Besant Nagar, Chennai 600090",
        locality: "Besant Nagar",
        phoneNumber: "+91 44 2491 0022",
        website: URL(string: "https://www.chennaitourism.com/elliots-beach"),
        distance: 3800,
        rating: 4.7,
        reviewCount: 9640,
        openingStatus: "Open 24 hours · Cafes till 11 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0001, longitude: 80.2667),
        localAssetImageName: "thumb_besant",
        tags: ["beach", "elliots", "promenade", "cafes", "sunset", "besant nagar"]
    )

    static let kapaleeshwararTemple = ExplorePlace(
        id: "chennai_kapaleeshwarar",
        name: "Kapaleeshwarar Temple",
        category: .landmark,
        address: "12 Vadakku Maada Veethi, Mylapore, Chennai 600004",
        locality: "Mylapore",
        phoneNumber: "+91 44 2464 1670",
        website: URL(string: "https://kapaleeshwarartemple.tnhrce.in"),
        distance: 2100,
        rating: 4.9,
        reviewCount: 16200,
        openingStatus: "Open · 6:00 AM – 12:30 PM, 4:00 PM – 9:00 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0334, longitude: 80.2706),
        tags: ["temple", "shiva", "heritage", "mylapore", "dravidian", "landmark"]
    )

    static let guindyNationalPark = ExplorePlace(
        id: "chennai_guindy_park",
        name: "Guindy National Park",
        category: .park,
        address: "Rangeguindy, Guindy, Chennai 600025",
        locality: "Guindy",
        phoneNumber: "+91 44 2235 1461",
        website: URL(string: "https://forests.tn.gov.in"),
        distance: 5400,
        rating: 4.4,
        reviewCount: 6850,
        openingStatus: "Open · 9:00 AM – 5:30 PM (Closed Tue)",
        coordinate: CLLocationCoordinate2D(latitude: 13.0067, longitude: 80.2026),
        tags: ["park", "nature", "wildlife", "deer", "guindy", "trees"]
    )

    // MARK: - Nearby Spots & Cultural Destinations

    static let sanThomeBasilica = ExplorePlace(
        id: "chennai_santhome",
        name: "San Thome Basilica",
        category: .landmark,
        address: "38 Santhome High Road, Mylapore, Chennai 600004",
        locality: "San Thome",
        phoneNumber: "+91 44 2498 5455",
        website: URL(string: "https://santhomechurch.com"),
        distance: 2500,
        rating: 4.8,
        reviewCount: 7420,
        openingStatus: "Open · 6:00 AM – 9:00 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0336, longitude: 80.2783),
        tags: ["church", "cathedral", "apostle", "heritage", "santhome", "mylapore"]
    )

    static let semmozhiPoonga = ExplorePlace(
        id: "chennai_semmozhi_poonga",
        name: "Semmozhi Poonga",
        category: .park,
        address: "Cathedral Road, Teynampet, Chennai 600086",
        locality: "Cathedral Road",
        phoneNumber: "+91 44 2811 0440",
        website: nil,
        distance: 1800,
        rating: 4.3,
        reviewCount: 5120,
        openingStatus: "Open · 10:00 AM – 7:30 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0487, longitude: 80.2520),
        tags: ["park", "botanical garden", "bonsai", "plants", "teynampet"]
    )

    static let valluvarKottam = ExplorePlace(
        id: "chennai_valluvar_kottam",
        name: "Valluvar Kottam",
        category: .landmark,
        address: "Valluvar Kottam High Road, Nungambakkam, Chennai 600034",
        locality: "Nungambakkam",
        phoneNumber: "+91 44 2817 2200",
        website: nil,
        distance: 3100,
        rating: 4.4,
        reviewCount: 4180,
        openingStatus: "Open · 8:30 AM – 5:30 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0560, longitude: 80.2415),
        tags: ["monument", "chariot", "thiruvalluvar", "nungambakkam", "landmark"]
    )

    static let governmentMuseum = ExplorePlace(
        id: "chennai_egmore_museum",
        name: "Government Museum Egmore",
        category: .attraction,
        address: "Pantheon Road, Egmore, Chennai 600008",
        locality: "Egmore",
        phoneNumber: "+91 44 2819 3238",
        website: URL(string: "https://www.govtmuseumchennai.org"),
        distance: 3600,
        rating: 4.6,
        reviewCount: 9810,
        openingStatus: "Open · 9:30 AM – 5:00 PM (Closed Fri)",
        coordinate: CLLocationCoordinate2D(latitude: 13.0732, longitude: 80.2570),
        tags: ["museum", "bronzes", "history", "art", "egmore", "attraction"]
    )

    static let phoenixMarketcity = ExplorePlace(
        id: "chennai_phoenix_marketcity",
        name: "Phoenix Marketcity",
        category: .shopping,
        address: "142 Velachery Main Road, Velachery, Chennai 600042",
        locality: "Velachery",
        phoneNumber: "+91 44 6134 3000",
        website: URL(string: "https://www.phoenixmarketcity.com/chennai"),
        distance: 7200,
        rating: 4.7,
        reviewCount: 22400,
        openingStatus: "Open · 10:00 AM – 10:00 PM",
        coordinate: CLLocationCoordinate2D(latitude: 12.9915, longitude: 80.2170),
        tags: ["mall", "shopping", "cinema", "food court", "velachery", "stores"]
    )

    static let ranganathanStreet = ExplorePlace(
        id: "chennai_ranganathan_street",
        name: "T. Nagar Ranganathan Street",
        category: .shopping,
        address: "Ranganathan Street, T. Nagar, Chennai 600017",
        locality: "T. Nagar",
        phoneNumber: nil,
        website: nil,
        distance: 1500,
        rating: 4.5,
        reviewCount: 19100,
        openingStatus: "Open · 9:30 AM – 9:30 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0405, longitude: 80.2310),
        tags: ["shopping", "textiles", "silk", "jewellery", "t nagar", "market"]
    )

    // MARK: - Iconic Chennai Restaurants & Cafes

    static let muruganIdliShop = ExplorePlace(
        id: "chennai_murugan_idli",
        name: "Murugan Idli Shop",
        category: .restaurant,
        address: "77-1/A GN Chetty Road, T. Nagar, Chennai 600017",
        locality: "T. Nagar",
        phoneNumber: "+91 44 2815 5449",
        website: URL(string: "https://muruganidlishop.com"),
        distance: 1100,
        rating: 4.6,
        reviewCount: 15400,
        openingStatus: "Open now · Closes 11:00 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0418, longitude: 80.2341),
        tags: ["idli", "dosa", "chutney", "breakfast", "t nagar", "south indian", "restaurant"]
    )

    static let saravanaBhavan = ExplorePlace(
        id: "chennai_saravana_bhavan",
        name: "Hotel Saravana Bhavan",
        category: .restaurant,
        address: "70 Radhakrishnan Salai, Mylapore, Chennai 600004",
        locality: "Mylapore",
        phoneNumber: "+91 44 2811 5830",
        website: URL(string: "https://saravanabhavan.com"),
        distance: 2000,
        rating: 4.5,
        reviewCount: 17200,
        openingStatus: "Open now · Closes 10:30 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0441, longitude: 80.2608),
        tags: ["vegetarian", "thali", "filter coffee", "mylapore", "restaurant"]
    )

    static let ratnaCafe = ExplorePlace(
        id: "chennai_ratna_cafe",
        name: "Ratna Cafe",
        category: .restaurant,
        address: "255 Triplicane High Road, Triplicane, Chennai 600005",
        locality: "Triplicane",
        phoneNumber: "+91 44 2844 1957",
        website: nil,
        distance: 1900,
        rating: 4.6,
        reviewCount: 9100,
        openingStatus: "Open now · Closes 10:00 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0565, longitude: 80.2760),
        tags: ["sambar", "idli", "heritage", "triplicane", "breakfast", "restaurant"]
    )

    static let amethystCafe = ExplorePlace(
        id: "chennai_amethyst_cafe",
        name: "Wild Garden Cafe at Amethyst",
        category: .cafe,
        address: "Whites Road, Royapettah, Chennai 600014",
        locality: "Royapettah",
        phoneNumber: "+91 44 4599 1630",
        website: URL(string: "https://amethystchennai.com"),
        distance: 2300,
        rating: 4.7,
        reviewCount: 6800,
        openingStatus: "Open now · Closes 11:00 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0543, longitude: 80.2612),
        tags: ["cafe", "coffee", "garden", "pastry", "royapettah", "brunch"]
    )

    static let writersCafe = ExplorePlace(
        id: "chennai_writers_cafe",
        name: "Writer's Cafe",
        category: .cafe,
        address: "98 Peter's Road, Gopalapuram, Chennai 600086",
        locality: "Gopalapuram",
        phoneNumber: "+91 44 4861 1604",
        website: nil,
        distance: 1700,
        rating: 4.8,
        reviewCount: 6150,
        openingStatus: "Open now · Closes 10:30 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0505, longitude: 80.2555),
        tags: ["cafe", "books", "coffee", "pastas", "gopalapuram", "bakery"]
    )

    static let sangeethaVeg = ExplorePlace(
        id: "chennai_sangeetha_adyar",
        name: "Sangeetha Veg Restaurant",
        category: .restaurant,
        address: "7 Gandhi Nagar 1st Main Road, Adyar, Chennai 600020",
        locality: "Adyar",
        phoneNumber: "+91 44 2442 2252",
        website: URL(string: "https://sangeethaveg.com"),
        distance: 3500,
        rating: 4.4,
        reviewCount: 9400,
        openingStatus: "Open now · Closes 11:00 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0064, longitude: 80.2568),
        tags: ["vegetarian", "adyar", "thali", "dosa", "south indian", "restaurant"]
    )

    static let annalakshmi = ExplorePlace(
        id: "chennai_annalakshmi",
        name: "Annalakshmi Restaurant",
        category: .restaurant,
        address: "Rukmani Lakshmipathi Road, Egmore, Chennai 600008",
        locality: "Egmore",
        phoneNumber: "+91 44 2854 0845",
        website: URL(string: "https://annalakshmichennai.com"),
        distance: 3400,
        rating: 4.8,
        reviewCount: 4620,
        openingStatus: "Open · 12 PM – 3 PM, 7 PM – 10 PM",
        coordinate: CLLocationCoordinate2D(latitude: 13.0690, longitude: 80.2580),
        tags: ["fine dining", "vegetarian", "egmore", "buffet", "culture", "restaurant"]
    )

    // MARK: - Master Lists

    static let allPlaces: [ExplorePlace] = [
        marinaBeach,
        besantNagarBeach,
        kapaleeshwararTemple,
        muruganIdliShop,
        saravanaBhavan,
        guindyNationalPark,
        amethystCafe,
        sanThomeBasilica,
        ratnaCafe,
        writersCafe,
        semmozhiPoonga,
        phoenixMarketcity,
        valluvarKottam,
        sangeethaVeg,
        governmentMuseum,
        annalakshmi,
        ranganathanStreet
    ]

    static let featuredPlaces: [ExplorePlace] = [
        marinaBeach,
        besantNagarBeach,
        kapaleeshwararTemple,
        guindyNationalPark
    ]

    static let nearbySpots: [ExplorePlace] = [
        marinaBeach,
        besantNagarBeach,
        kapaleeshwararTemple,
        sanThomeBasilica,
        semmozhiPoonga,
        valluvarKottam,
        guindyNationalPark
    ]

    static let restaurants: [ExplorePlace] = [
        muruganIdliShop,
        saravanaBhavan,
        ratnaCafe,
        amethystCafe,
        writersCafe,
        sangeethaVeg,
        annalakshmi
    ]

    // MARK: - Query & Filter Engine

    /// Filters local mock data instantly without network calls.
    static func filter(
        query: String = "",
        filter: ExploreFilter = .all,
        locality: String? = nil
    ) -> [ExplorePlace] {
        var results = allPlaces

        // 1. Locality Filter
        if let locality = locality, !locality.isEmpty {
            let lowerLoc = locality.lowercased()
            results = results.filter {
                $0.locality.lowercased().contains(lowerLoc) ||
                $0.address.lowercased().contains(lowerLoc)
            }
        }

        // 2. Category Filter
        if filter != .all {
            results = results.filter { filter.matches($0) }
        }

        // 3. Search Query Filter
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmed.isEmpty {
            results = results.filter { place in
                place.name.lowercased().contains(trimmed) ||
                place.locality.lowercased().contains(trimmed) ||
                place.address.lowercased().contains(trimmed) ||
                place.category.title.lowercased().contains(trimmed) ||
                place.tags.contains { $0.lowercased().contains(trimmed) }
            }
        }

        // Sort by distance
        return results.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
    }

    /// Autocomplete suggestions generated from local mock places.
    static func searchSuggestions(for query: String) -> [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return [] }

        var suggestions: [String] = []

        // Match place names
        for place in allPlaces {
            if place.name.lowercased().contains(trimmed) && !suggestions.contains(place.name) {
                suggestions.append(place.name)
            }
        }

        // Match localities
        let localities = ["T. Nagar", "Mylapore", "Besant Nagar", "Marina Beach", "Adyar", "Guindy", "Egmore", "Velachery", "San Thome", "Royapettah"]
        for loc in localities {
            if loc.lowercased().contains(trimmed) && !suggestions.contains(loc) {
                suggestions.append(loc)
            }
        }

        // Match category keywords
        let keywords = ["Filter Coffee", "South Indian Idli", "Vegetarian Thali", "Beach Promenade", "Dravidian Temple", "Heritage Museum", "Botanical Garden"]
        for kw in keywords {
            if kw.lowercased().contains(trimmed) && !suggestions.contains(kw) {
                suggestions.append(kw)
            }
        }

        return Array(suggestions.prefix(6))
    }
}
