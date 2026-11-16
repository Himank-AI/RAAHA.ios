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
                if router.showLogin && !launch.isPresenting {
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
        .onChange(of: launch.handoffStarted) { _, started in
            guard started, router.showLogin else { return }
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                router.showLogin = false
            }
        }
    }
}

private struct MainAppView: View {
    @Bindable var router: AppRouter
    @Environment(LaunchTransitionManager.self) private var launch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                    .opacity(launch.chromeReveal)
                    .offset(y: (1 - launch.chromeReveal) * 18)
                    .animation(reduceMotion ? nil : .interactiveSpring(response: 0.52, dampingFraction: 0.86, blendDuration: 0.12).delay(0.10), value: launch.chromeReveal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear { launch.revealContent() }
                    .onChange(of: launch.handoffStarted) { _, _ in
                        launch.revealContent()
                    }
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

#Preview {
    RootView()
        .environment(AppRouter())
}
