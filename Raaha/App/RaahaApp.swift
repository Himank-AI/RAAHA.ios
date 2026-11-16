import SwiftUI

@main
struct RaahaApp: App {
    init() {
        UIScrollView.appearance().showsVerticalScrollIndicator = false
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                // Light mode by default
                .preferredColorScheme(.light)
                .scrollIndicators(.hidden, axes: .vertical)
        }
    }
}

struct RootView: View {
    @State private var router = AppRouter()
    @State private var launch = LaunchTransitionManager()
    @State private var ads = AdImpressionTracker.shared

    var body: some View {
        @Bindable var router = router
        ZStack {
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
            .accessibilityHidden(launch.isPresenting)

            if launch.isPresenting {
                RAAHACinematicLaunchView(manager: launch)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .environment(router)
        .environment(launch)
        .environment(ads)
    }
}

private struct MainAppView: View {
    @Bindable var router: AppRouter

    var body: some View {
        Group {
            if #available(iOS 18, *) {
                glassTabs
            } else {
                legacyTabs
            }
        }
        .tint(Color(hex: 0x173D5C))
    }

    @available(iOS 18, *)
    private var glassTabs: some View {
        TabView(selection: $router.tab) {
            Tab(AppTab.home.title, systemImage: AppTab.home.symbol(selected: false), value: AppTab.home) {
                tabStack(path: $router.homePath) { HomeView() }
            }
            Tab(AppTab.trips.title, systemImage: AppTab.trips.symbol(selected: false), value: AppTab.trips) {
                tabStack(path: $router.tripsPath) { TripsView() }
            }
            Tab(AppTab.explore.title, systemImage: AppTab.explore.symbol(selected: false), value: AppTab.explore) {
                tabStack(path: $router.explorePath) { ExploreView() }
            }
            Tab(AppTab.profile.title, systemImage: AppTab.profile.symbol(selected: false), value: AppTab.profile) {
                tabStack(path: $router.profilePath) { ProfileView() }
            }
        }
        .modifier(NativeGlassTabBar())
    }

    private var legacyTabs: some View {
        TabView(selection: $router.tab) {
            tabStack(path: $router.homePath) { HomeView() }
                .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.symbol(selected: false)) }
                .tag(AppTab.home)
            tabStack(path: $router.tripsPath) { TripsView() }
                .tabItem { Label(AppTab.trips.title, systemImage: AppTab.trips.symbol(selected: false)) }
                .tag(AppTab.trips)
            tabStack(path: $router.explorePath) { ExploreView() }
                .tabItem { Label(AppTab.explore.title, systemImage: AppTab.explore.symbol(selected: false)) }
                .tag(AppTab.explore)
            tabStack(path: $router.profilePath) { ProfileView() }
                .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.symbol(selected: false)) }
                .tag(AppTab.profile)
        }
    }

    private func tabStack<Root: View>(path: Binding<[Route]>, @ViewBuilder root: () -> Root) -> some View {
        NavigationStack(path: path) {
            root()
                .navigationDestination(for: Route.self) { route in
                    RouteDestination(route: route)
                        .toolbar(.hidden, for: .tabBar)
                }
        }
    }
}

/// The system tab bar adopts Liquid Glass on iOS 26. Older systems keep the standard bar.
private struct NativeGlassTabBar: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.tabBarMinimizeBehavior(.automatic)
        } else {
            content
        }
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

#Preview {
    RootView()
        .environment(AppRouter())
}
