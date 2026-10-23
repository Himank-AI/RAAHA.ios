import Foundation
import MapKit
import CoreLocation
import Combine

// MARK: - Location Permission States

enum LocationPermission {
    case notDetermined, denied, restricted, authorized
}

// MARK: - Location Manager

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var permission: LocationPermission = .notDetermined
    @Published private(set) var userLocation: CLLocation?
    @Published private(set) var isInsideChennai: Bool = false

    /// True if user is authorized and location has been resolved to outside the Chennai boundary
    var isOutsideChennai: Bool {
        permission == .authorized && userLocation != nil && !isInsideChennai
    }

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100
        updatePermission(from: manager.authorizationStatus)
    }

    func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    private func updatePermission(from status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:         permission = .notDetermined
        case .denied:                permission = .denied
        case .restricted:            permission = .restricted
        case .authorizedWhenInUse,
             .authorizedAlways:
            permission = .authorized
            manager.requestLocation()
        @unknown default:            permission = .denied
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in self.updatePermission(from: status) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.userLocation = loc
            self.isInsideChennai = ChennaiServiceArea.shared.isUserInChennai(location: loc)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silently ignore — UI handles missing location gracefully
    }
}
