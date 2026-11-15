import SwiftUI

struct RouteOptionsView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model = RouteSelectionTransition()
    @Namespace private var routeMorph

    var body: some View {
        GeometryReader { proxy in
            let layout = RouteSheetLayout(
                containerWidth: proxy.size.width,
                containerHeight: proxy.size.height,
                safeTop: proxy.safeAreaInsets.top,
                safeBottom: proxy.safeAreaInsets.bottom
            )

            ZStack(alignment: .bottom) {
                InteractiveMapContainer(
                    model: model,
                    originTitle: router.journeyFrom,
                    destinationTitle: router.journeyTo
                )
                .ignoresSafeArea()

                RouteDrawDriver(model: model)

                RouteSelectionSheet(
                    model: model,
                    layout: layout,
                    namespace: routeMorph,
                    origin: router.journeyFrom,
                    destination: router.journeyTo,
                    reduceMotion: reduceMotion,
                    onConfirm: { router.push(.routeDetail(model.selectedKind)) }
                )
            }
            .onAppear { model.prepare(layout: layout) }
            .onChange(of: proxy.size.height) { _, _ in
                model.prepare(layout: layout)
            }
            .onDisappear { model.cancelPendingWork() }
        }
        .ignoresSafeArea()
        .pushedChrome(title: "Chennai Route Options")
        .sensoryFeedback(.selection, trigger: model.selectionTick)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.65), trigger: model.detent)
    }
}

#Preview {
    RouteOptionsView()
        .environment(AppRouter())
}
