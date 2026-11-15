import SwiftUI

struct RouteSelectionSheet: View {
    let model: RouteSelectionTransition
    let layout: RouteSheetLayout
    let namespace: Namespace.ID
    let origin: String
    let destination: String
    let reduceMotion: Bool
    let onConfirm: () -> Void

    @State private var dragOrigin: CGFloat?

    private var expansion: CGFloat { layout.expansion(for: model.sheetHeight) }
    private var minimizedAmount: CGFloat { layout.minimizedAmount(for: model.sheetHeight) }

    private var summaryOpacity: CGFloat {
        let appear = min(max((0.62 - expansion) / 0.62, 0), 1)
        return appear * (1 - minimizedAmount)
    }

    private var summaryOwnsGeometry: Bool {
        !model.isDragging && summaryOpacity > 0.58 && minimizedAmount < 0.3
    }

    private var sideInset: CGFloat {
        12 * (1 - expansion) + 20 * minimizedAmount
    }

    private var bottomInset: CGFloat {
        (1 - expansion) * (layout.safeBottom + 8)
    }

    private var shape: UnevenRoundedRectangle {
        let radius: CGFloat = 30
        return UnevenRoundedRectangle(
            topLeadingRadius: radius,
            bottomLeadingRadius: radius * (1 - expansion),
            bottomTrailingRadius: radius * (1 - expansion),
            topTrailingRadius: radius,
            style: .continuous
        )
    }

    private var orderedRoutes: [RouteOption] {
        let routes = MockData.routes
        let promoteSelected = model.isPresentingSelection || model.detent != .expanded
        guard promoteSelected else { return routes }
        return routes.sorted { lhs, rhs in
            (lhs.kind == model.selectedKind) && rhs.kind != model.selectedKind
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber
            ZStack(alignment: .top) {
                routeList
                    .allowsHitTesting(summaryOpacity < 0.4 && minimizedAmount < 0.35 && !model.isDragging)

                GlassJourneySummary(
                    option: model.option,
                    origin: origin,
                    destination: destination,
                    namespace: namespace,
                    ownsGeometry: summaryOwnsGeometry,
                    onExpand: expandRoutes,
                    onConfirm: onConfirm,
                    drag: sheetDrag
                )
                .opacity(Double(summaryOpacity))
                .allowsHitTesting(summaryOpacity > 0.45 && minimizedAmount < 0.45)

                MinimizedJourneyBar(option: model.option, onExpand: showCompact, drag: sheetDrag)
                    .opacity(Double(minimizedAmount))
                    .allowsHitTesting(minimizedAmount > 0.55)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(sheetDrag)
            }
        }
        .padding(.bottom, expansion * layout.safeBottom)
        .frame(maxWidth: .infinity)
        .frame(height: max(model.sheetHeight, layout.minimizedHeight), alignment: .top)
        .background { sheetBackground }
        .clipShape(shape)
        .overlay {
            shape.stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.95),
                        Color(hex: 0x7BBDE8).opacity(0.28 + 0.45 * (1 - expansion)),
                        Color.white.opacity(0.30)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.15
            )
        }
        .shadow(
            color: Color(hex: 0x1D3557).opacity(0.10 + 0.12 * (1 - expansion)),
            radius: 10 + 14 * (1 - expansion),
            x: 0,
            y: 6 + 6 * (1 - expansion)
        )
        .padding(.horizontal, sideInset)
        .padding(.bottom, bottomInset)
        .accessibilityAction(named: Text("Show all routes")) { expandRoutes() }
        .accessibilityAction(named: Text("Show journey summary")) { showCompact() }
        .accessibilityAction(named: Text("Minimize")) { showMinimized() }
    }

    private var routeList: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(orderedRoutes) { option in
                        let isSelected = option.kind == model.selectedKind
                        let dim = isSelected ? 0 : max(1 - model.listReveal, 1 - expansion)
                        AnimatedRouteCard(
                            option: option,
                            isSelected: isSelected,
                            dim: dim,
                            lift: isSelected ? (1 - model.listReveal) : 0,
                            fadeIntoSummary: isSelected ? summaryOpacity : 0,
                            reduceMotion: reduceMotion,
                            blurUnselected: !model.isDragging,
                            namespace: namespace,
                            ownsGeometry: isSelected && !summaryOwnsGeometry,
                            action: { model.select(option.kind, layout: layout, reduceMotion: reduceMotion) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 8)
            }
            .scrollDisabled(model.isDragging || expansion < 0.95)

            Button(action: onConfirm) {
                Text("Confirm \(model.option.kind.title) Route")
            }
            .buttonStyle(.pillLight)
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 10)
            .opacity(Double(model.listReveal * expansion))
            .allowsHitTesting(model.listReveal > 0.8 && expansion > 0.85 && !model.isDragging)
            .accessibilityHint("Navigates to the step-by-step route details")
        }
    }

    private var grabber: some View {
        Capsule()
            .fill(Color.steelBlue.opacity(model.isDragging ? 0.62 : 0.34))
            .frame(width: model.isDragging ? 46 : 36, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .frame(height: 28)
            .contentShape(Rectangle())
            .gesture(sheetDrag)
            .accessibilityElement()
            .accessibilityLabel(grabberLabel)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default, toggleFromGrabber)
            .animation(RouteSelectionTransition.dragSpring(reduceMotion: reduceMotion), value: model.isDragging)
    }

    private var grabberLabel: String {
        switch model.detent {
        case .expanded: return "Collapse route options"
        case .compact: return "Show all routes"
        case .minimized: return "Show journey summary"
        }
    }

    @ViewBuilder
    private var sheetBackground: some View {
        ZStack {
            RaahaScreenBackground()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .opacity(Double(expansion))
            FloatingSheetGlass(shape: shape)
                .opacity(Double(1 - expansion))
        }
        .allowsHitTesting(false)
    }

    private var sheetDrag: AnyGesture<DragGesture.Value> {
        AnyGesture(
            DragGesture(minimumDistance: 12, coordinateSpace: .global)
                .onChanged { value in
                    if dragOrigin == nil {
                        dragOrigin = model.sheetHeight
                        model.cancelPendingCollapse()
                        model.isDragging = true
                    }
                    let origin = dragOrigin ?? model.sheetHeight
                    model.sheetHeight = layout.rubberClamp(origin - value.translation.height)
                }
                .onEnded { value in
                    let origin = dragOrigin ?? model.sheetHeight
                    dragOrigin = nil
                    let predicted = origin - value.predictedEndTranslation.height
                    model.finishDrag(predictedHeight: predicted, layout: layout, reduceMotion: reduceMotion)
                }
        )
    }

    private func toggleFromGrabber() {
        switch model.detent {
        case .expanded:
            model.animate(to: .compact, layout: layout, reduceMotion: reduceMotion, replayDraw: false)
        case .compact:
            expandRoutes()
        case .minimized:
            showCompact()
        }
    }

    private func expandRoutes() {
        model.animate(to: .expanded, layout: layout, reduceMotion: reduceMotion, replayDraw: false)
    }

    private func showCompact() {
        model.animate(to: .compact, layout: layout, reduceMotion: reduceMotion, replayDraw: false)
    }

    private func showMinimized() {
        model.animate(to: .minimized, layout: layout, reduceMotion: reduceMotion, replayDraw: false)
    }
}

private struct FloatingSheetGlass: View {
    var shape: UnevenRoundedRectangle

    var body: some View {
        ZStack {
            if #available(iOS 26.0, *) {
                shape.fill(Color.clear)
                    .glassEffect(.regular.tint(Color(hex: 0xEAF4FB).opacity(0.42)), in: shape)
                shape.fill(Color.white.opacity(0.18))
            } else {
                shape.fill(.ultraThinMaterial)
                shape.fill(Color.white.opacity(0.42))
            }
            shape.fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.48), Color.white.opacity(0)],
                    startPoint: .top,
                    endPoint: .center
                )
            )
        }
    }
}
