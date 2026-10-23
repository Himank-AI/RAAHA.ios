import Foundation
import CoreLocation
import MapKit

final class TestRunner {
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
        print("TEST SUITE RESULTS: \(passedTests)/\(totalTests) Passed (\(failedTests) Failed)")
        print("==========================================")
        if failedTests > 0 {
            exit(1)
        }
    }
}

@main
struct ChennaiBoundaryTestsApp {
    static func main() {
        let runner = TestRunner()
        let serviceArea = ChennaiServiceArea.shared

        print("\n--- TEST GROUP 1: Approved Chennai Localities ---")
        let chennaiLocalities: [(String, CLLocationCoordinate2D)] = [
            ("Marina Beach", CLLocationCoordinate2D(latitude: 13.0500, longitude: 80.2824)),
            ("Besant Nagar Beach", CLLocationCoordinate2D(latitude: 13.0001, longitude: 80.2667)),
            ("Kapaleeshwarar Temple (Mylapore)", CLLocationCoordinate2D(latitude: 13.0334, longitude: 80.2706)),
            ("San Thome Basilica", CLLocationCoordinate2D(latitude: 13.0336, longitude: 80.2783)),
            ("T. Nagar", CLLocationCoordinate2D(latitude: 13.0418, longitude: 80.2341)),
            ("Adyar", CLLocationCoordinate2D(latitude: 13.0012, longitude: 80.2565)),
            ("Anna Nagar", CLLocationCoordinate2D(latitude: 13.0850, longitude: 80.2100)),
            ("Velachery", CLLocationCoordinate2D(latitude: 12.9759, longitude: 80.2212)),
            ("Guindy", CLLocationCoordinate2D(latitude: 13.0067, longitude: 80.2026)),
            ("Chennai Central", CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2785)),
            ("Chennai Airport (Meenambakkam)", CLLocationCoordinate2D(latitude: 12.9941, longitude: 80.1709)),
            ("Tambaram", CLLocationCoordinate2D(latitude: 12.9249, longitude: 80.1000)),
            ("Sholinganallur", CLLocationCoordinate2D(latitude: 12.9010, longitude: 80.2279)),
            ("Nungambakkam", CLLocationCoordinate2D(latitude: 13.0594, longitude: 80.2425)),
            ("Alwarpet", CLLocationCoordinate2D(latitude: 13.0339, longitude: 80.2530))
        ]

        for (name, coord) in chennaiLocalities {
            runner.assert(serviceArea.validate(coordinate: coord), "Chennai locality '\(name)' must be accepted")
        }

        print("\n--- TEST GROUP 2: Curated Approved Localities in ServiceArea ---")
        for locality in serviceArea.approvedLocalities {
            runner.assert(serviceArea.validate(coordinate: locality.coordinate), "Curated locality '\(locality.name)' must be within boundary")
        }

        print("\n--- TEST GROUP 3: Outside Service Boundary Rejection ---")
        let outsideCoordinates: [(String, CLLocationCoordinate2D)] = [
            // CRITICAL REQUIREMENT: San Francisco must be rejected
            ("San Francisco, CA, USA", CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)),
            // CRITICAL REQUIREMENT: Mahabalipuram is explicitly excluded from Chennai service boundary
            ("Mahabalipuram / Mamallapuram", CLLocationCoordinate2D(latitude: 12.6269, longitude: 80.1927)),
            // Major Indian cities outside Chennai
            ("Bangalore, Karnataka", CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)),
            ("New Delhi", CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090)),
            ("Mumbai, Maharashtra", CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777)),
            ("Hyderabad, Telangana", CLLocationCoordinate2D(latitude: 17.3850, longitude: 78.4867)),
            ("Kolkata, West Bengal", CLLocationCoordinate2D(latitude: 22.5726, longitude: 88.3639)),
            // Nearby Tamil Nadu towns outside Chennai
            ("Pondicherry / Puducherry", CLLocationCoordinate2D(latitude: 11.9416, longitude: 79.8083)),
            ("Chengalpattu", CLLocationCoordinate2D(latitude: 12.6819, longitude: 79.9888)),
            ("Kanchipuram", CLLocationCoordinate2D(latitude: 12.8342, longitude: 79.7036)),
            // International cities
            ("London, UK", CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)),
            ("New York, USA", CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)),
            ("Tokyo, Japan", CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)),
            ("Sydney, Australia", CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093))
        ]

        for (name, coord) in outsideCoordinates {
            runner.assert(!serviceArea.validate(coordinate: coord), "Outside location '\(name)' MUST be rejected")
        }

        print("\n--- TEST GROUP 4: Architectural Decision & Config Verification ---")
        runner.assert(ChennaiServiceArea.isMahabalipuramIncluded == false, "Mahabalipuram must be explicitly excluded (isMahabalipuramIncluded == false)")
        runner.assert(serviceArea.serviceCity == "Chennai", "Service city must be Chennai")
        runner.assert(serviceArea.serviceState == "Tamil Nadu", "Service state must be Tamil Nadu")
        runner.assert(serviceArea.serviceCountry == "India", "Service country must be India")
        runner.assert(serviceArea.serviceCountryCode == "IN", "Service country code must be IN")

        print("\n--- TEST GROUP 5: User Location Awareness ---")
        let userInSF = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let userInMahabalipuram = CLLocation(latitude: 12.6269, longitude: 80.1927)
        let userInMarina = CLLocation(latitude: 13.0500, longitude: 80.2824)
        let userInTNagar = CLLocation(latitude: 13.0418, longitude: 80.2341)

        runner.assert(!serviceArea.isUserInChennai(location: userInSF), "User in SF is detected outside Chennai")
        runner.assert(!serviceArea.isUserInChennai(location: userInMahabalipuram), "User in Mahabalipuram is detected outside Chennai")
        runner.assert(serviceArea.isUserInChennai(location: userInMarina), "User in Marina Beach is detected inside Chennai")
        runner.assert(serviceArea.isUserInChennai(location: userInTNagar), "User in T. Nagar is detected inside Chennai")
        runner.assert(!serviceArea.isUserInChennai(location: nil), "Nil location is safely handled as false")

        print("\n--- TEST GROUP 6: MapItem Filtering ---")
        let sfPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
        let sfMapItem = MKMapItem(placemark: sfPlacemark)
        sfMapItem.name = "Golden Gate Grill, San Francisco"

        let chennaiPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 13.0418, longitude: 80.2341))
        let chennaiMapItem = MKMapItem(placemark: chennaiPlacemark)
        chennaiMapItem.name = "Murugan Idli Shop, T. Nagar, Chennai"

        runner.assert(!serviceArea.validate(mapItem: sfMapItem), "San Francisco MapItem is rejected by mapItem validator")
        runner.assert(serviceArea.validate(mapItem: chennaiMapItem), "Chennai MapItem is accepted by mapItem validator")

        let filteredItems = serviceArea.filterMapItems([sfMapItem, chennaiMapItem])
        runner.assert(filteredItems.count == 1, "filterMapItems must filter out SF item")
        runner.assert(filteredItems.first?.name == "Murugan Idli Shop, T. Nagar, Chennai", "filterMapItems retains Chennai item")

        print("\n--- TEST GROUP 7: ExplorePlace Domain Model & Cache Revalidation ---")
        let chennaiPlace = ExplorePlace(mapItem: chennaiMapItem)
        let sfPlace = ExplorePlace(mapItem: sfMapItem)

        runner.assert(chennaiPlace.isValidChennaiLocation, "Chennai ExplorePlace isValidChennaiLocation must be true")
        runner.assert(!sfPlace.isValidChennaiLocation, "San Francisco ExplorePlace isValidChennaiLocation must be false")

        let validatedPlaces = serviceArea.filterPlaces([chennaiPlace, sfPlace])
        runner.assert(validatedPlaces.count == 1, "filterPlaces must discard SF place")
        runner.assert(validatedPlaces.first?.name == "Murugan Idli Shop, T. Nagar, Chennai", "filterPlaces retains Chennai place")

        let revalidatedCache = serviceArea.revalidate(cachedPlaces: [chennaiPlace, sfPlace])
        runner.assert(revalidatedCache.count == 1, "revalidate(cachedPlaces:) must purge outside-area items from cache")

        print("\n--- TEST GROUP 8: Bounding Box Efficiency ---")
        runner.assert(!serviceArea.contains(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)), "Null island rejected")
        runner.assert(!serviceArea.contains(coordinate: CLLocationCoordinate2D(latitude: -80, longitude: 80)), "Antarctica rejected")
        runner.assert(!serviceArea.contains(coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)), "Paris, France rejected")

        runner.report()
    }
}
