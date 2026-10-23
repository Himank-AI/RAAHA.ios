import Foundation
import CoreLocation
import MapKit

final class MockTestRunner {
    var totalTests = 0
    var passedTests = 0
    var failedTests = 0

    func assert(_ condition: Bool, _ testName: String, line: Int = #line) {
        totalTests += 1
        if condition {
            passedTests += 1
            print("  ✅ PASS: \(testName)")
        } else {
            failedTests += 1
            print("  ❌ FAIL: \(testName) (line \(line))")
        }
    }

    func report() {
        print("\n==========================================")
        print("MOCK DATA TEST RESULTS: \(passedTests)/\(totalTests) Passed (\(failedTests) Failed)")
        print("==========================================")
        if failedTests > 0 {
            exit(1)
        }
    }
}

@main
struct ExploreMockDataTestsApp {
    static func main() {
        let runner = MockTestRunner()

        print("\n--- TEST GROUP 1: Static Chennai Mock Data Completeness ---")
        runner.assert(!ExploreMockData.allPlaces.isEmpty, "ExploreMockData contains static places")
        runner.assert(ExploreMockData.allPlaces.count >= 15, "ExploreMockData has rich collection of places (count: \(ExploreMockData.allPlaces.count))")
        runner.assert(ExploreMockData.featuredPlaces.count >= 4, "ExploreMockData contains featured destinations")
        runner.assert(!ExploreMockData.nearbySpots.isEmpty, "ExploreMockData contains nearby spots")
        runner.assert(!ExploreMockData.restaurants.isEmpty, "ExploreMockData contains restaurants and cafes")

        print("\n--- TEST GROUP 2: Strict Chennai Boundary Validation ---")
        for place in ExploreMockData.allPlaces {
            let isValid = ChennaiServiceArea.shared.validate(place: place)
            runner.assert(isValid, "Place '\(place.name)' at (\(place.coordinate.latitude), \(place.coordinate.longitude)) must be inside Chennai boundary")
        }

        print("\n--- TEST GROUP 3: Category Filtering ---")
        let restaurants = ExploreMockData.filter(filter: .restaurants)
        runner.assert(!restaurants.isEmpty, "Restaurant filter returns places")
        runner.assert(restaurants.allSatisfy { $0.category == .restaurant || $0.category == .cafe }, "Restaurant filter returns only restaurants and cafes")

        let beaches = ExploreMockData.filter(filter: .beaches)
        runner.assert(!beaches.isEmpty, "Beach filter returns places")
        runner.assert(beaches.allSatisfy { $0.category == .beach }, "Beach filter returns only beaches")

        let parks = ExploreMockData.filter(filter: .parks)
        runner.assert(!parks.isEmpty, "Park filter returns places")
        runner.assert(parks.allSatisfy { $0.category == .park }, "Park filter returns only parks")

        let landmarks = ExploreMockData.filter(filter: .landmarks)
        runner.assert(!landmarks.isEmpty, "Landmark filter returns places")
        runner.assert(landmarks.allSatisfy { $0.category == .landmark || $0.category == .attraction }, "Landmark filter returns only landmarks and attractions")

        print("\n--- TEST GROUP 4: Locality Filtering ---")
        let mylaporePlaces = ExploreMockData.filter(locality: "Mylapore")
        runner.assert(!mylaporePlaces.isEmpty, "Mylapore filter returns places")
        runner.assert(mylaporePlaces.contains { $0.name.contains("Kapaleeshwarar") }, "Mylapore contains Kapaleeshwarar Temple")

        let tnagarPlaces = ExploreMockData.filter(locality: "T. Nagar")
        runner.assert(!tnagarPlaces.isEmpty, "T. Nagar filter returns places")
        runner.assert(tnagarPlaces.contains { $0.name.contains("Murugan Idli") }, "T. Nagar contains Murugan Idli Shop")

        print("\n--- TEST GROUP 5: Search Query Filtering ---")
        let idliSearch = ExploreMockData.filter(query: "idli")
        runner.assert(idliSearch.contains { $0.name.contains("Murugan Idli") }, "Searching 'idli' returns Murugan Idli Shop")

        let beachSearch = ExploreMockData.filter(query: "beach")
        runner.assert(beachSearch.contains { $0.name == "Marina Beach" }, "Searching 'beach' returns Marina Beach")
        runner.assert(beachSearch.contains { $0.name == "Besant Nagar Beach" }, "Searching 'beach' returns Besant Nagar Beach")

        let coffeeSearch = ExploreMockData.filter(query: "coffee")
        runner.assert(!coffeeSearch.isEmpty, "Searching 'coffee' returns cafes/restaurants")

        print("\n--- TEST GROUP 6: Autocomplete Suggestions ---")
        let suggestions = ExploreMockData.searchSuggestions(for: "mar")
        runner.assert(suggestions.contains("Marina Beach"), "Suggests 'Marina Beach' for 'mar'")

        let idliSuggestions = ExploreMockData.searchSuggestions(for: "idli")
        runner.assert(!idliSuggestions.isEmpty, "Generates suggestions for 'idli'")

        print("\n--- TEST GROUP 7: Place Details, Ratings & Distances ---")
        let marina = ExploreMockData.marinaBeach
        runner.assert(marina.distanceText != nil, "Marina Beach has distance text ('\(marina.distanceText ?? "")')")
        runner.assert(marina.ratingText == "4.6", "Marina Beach has rating 4.6")
        runner.assert(marina.localAssetImageName == "thumb_marina", "Marina Beach has bundled image asset 'thumb_marina'")
        runner.assert(marina.openingStatus != nil, "Marina Beach has opening status")

        runner.report()
    }
}
