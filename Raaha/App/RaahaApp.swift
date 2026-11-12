import SwiftUI

@main
struct RaahaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                // Light mode by default
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @State private var router = AppRouter()

    var body: some View {
        @Bindable var router = router
        Group {
            if router.showLogin {
                LoginView()
                    .transition(.opacity)
            } else {
                MainAppView(router: router)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: router.showLogin)
        .environment(router)
    }
}

private struct MainAppView: View {
    @Bindable var router: AppRouter

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: 0xBDD8E9).ignoresSafeArea()

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
        case .login:
            LoginView()
        }
    }
}
