import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home, trips, explore, profile

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .trips: return "Trips"
        case .explore: return "Explore"
        case .profile: return "Profile"
        }
    }

    func symbol(selected: Bool) -> String {
        switch self {
        case .home: return selected ? "house.fill" : "house"
        case .trips: return selected ? "map.fill" : "map"
        case .explore: return selected ? "safari.fill" : "safari"
        case .profile: return selected ? "person.fill" : "person"
        }
    }
}

enum Route: Hashable {
    case routeOptions
    case routeDetail(RouteKind)
    case live(RouteKind, Int)
    case missedTrain
    case arrived
    case tripPreview
    case tripSaved
}

final class AppRouter: ObservableObject {
    @Published var tab: AppTab = .home
    @Published var homePath: [Route] = []
    @Published var tripsPath: [Route] = []
    @Published var explorePath: [Route] = []
    @Published var profilePath: [Route] = []

    /// Active journey origin & destination shared across the planning flow.
    @Published var journeyFrom: String = "Current Location"
    @Published var journeyTo: String = "Phoenix Mall, Velachery"

    /// Shared state for the Plan Ahead → Trip Preview → Trip Saved flow.
    @Published var plan = TripPlan()

    /// The floating tab bar is only shown on a tab's root screen.
    var isTabBarVisible: Bool {
        switch tab {
        case .home: return homePath.isEmpty
        case .trips: return tripsPath.isEmpty
        case .explore: return explorePath.isEmpty
        case .profile: return profilePath.isEmpty
        }
    }

    func push(_ route: Route) {
        switch tab {
        case .home: homePath.append(route)
        case .trips: tripsPath.append(route)
        case .explore: explorePath.append(route)
        case .profile: profilePath.append(route)
        }
    }

    func popToRoot() {
        switch tab {
        case .home: homePath = []
        case .trips: tripsPath = []
        case .explore: explorePath = []
        case .profile: profilePath = []
        }
    }

    func showTrips() {
        homePath = []
        explorePath = []
        tab = .trips
    }

    func showHome() {
        popToRoot()
        tab = .home
    }

    /// Set endpoints then push routeOptions in one call.
    func planJourney(from: String, to: String) {
        journeyFrom = from
        journeyTo = to
        push(.routeOptions)
    }
}
