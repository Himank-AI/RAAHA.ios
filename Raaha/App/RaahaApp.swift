import SwiftUI

@main
struct RaahaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                // The RAAHA palette is a light design; keep system chrome consistent with it.
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @StateObject private var router = AppRouter()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.honeydew.ignoresSafeArea()

            Group {
                switch router.tab {
                case .home:
                    NavigationStack(path: $router.homePath) {
                        HomeView()
                            .navigationDestination(for: Route.self) { RouteDestination(route: $0) }
                    }
                case .trips:
                    NavigationStack(path: $router.tripsPath) {
                        TripsView()
                            .navigationDestination(for: Route.self) { RouteDestination(route: $0) }
                    }
                case .explore:
                    NavigationStack(path: $router.explorePath) {
                        ExploreView()
                            .navigationDestination(for: Route.self) { RouteDestination(route: $0) }
                    }
                case .profile:
                    NavigationStack(path: $router.profilePath) {
                        ProfileView()
                            .navigationDestination(for: Route.self) { RouteDestination(route: $0) }
                    }
                }
            }

            if router.isTabBarVisible {
                RaahaTabBar(selection: $router.tab)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: router.isTabBarVisible)
        .environmentObject(router)
    }
}

struct RouteDestination: View {
    let route: Route

    var body: some View {
        switch route {
        case .routeOptions:
            RouteOptionsView()
        case .routeDetail(let kind):
            RouteDetailView(kind: kind)
        case .live(let kind, let step):
            LiveJourneyView(kind: kind, step: step)
        case .missedTrain:
            MissedTrainView()
        case .arrived:
            ArrivedView()
        case .tripPreview:
            TripPreviewView()
        case .tripSaved:
            TripSavedView()
        }
    }
}

// Keeps the interactive swipe-back gesture working when the system back button is replaced.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
