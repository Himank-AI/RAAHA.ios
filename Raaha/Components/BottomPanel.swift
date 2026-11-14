import SwiftUI
import MapKit

/// Chennai map used behind the route and live-journey panels.
struct JourneyMapView: View {
    var routeKind: RouteKind? = nil
    var activeMode: TransportMode? = nil

    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: MockData.mapCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.24, longitudeDelta: 0.24)
        )
    )

    private var indicatorColor: Color {
        activeMode?.color ?? Color.transportMetro
    }

    var body: some View {
        Map(position: $position) {
            MapPolyline(coordinates: MockData.routeCoordinates)
                .stroke(indicatorColor, lineWidth: 5)
            Marker("Current Location", systemImage: "location.fill", coordinate: MockData.origin)
                .tint(Color.steelBlue)
            Marker("Phoenix Mall", image: "icon_pin", coordinate: MockData.destination)
                .tint(indicatorColor)
        }
        .mapStyle(.standard(elevation: .flat))
        .ignoresSafeArea()
    }
}

private var panelSnap: Animation { .spring(response: 0.42, dampingFraction: 0.82) }

/// Honeydew bottom sheet with a grabber. Drag (or tap) the grabber to expand / collapse.
/// Pass `isExpanded` binding to observe expansion state from outside (e.g. for dynamic content padding).
/// Set `fitsContent: true` when the panel height should snugly wrap the content and sit at the bottom.
/// Content can read collapse progress via `bottomPanelCollapsible(order:)`.
struct BottomPanel<Content: View>: View {
    var isExpanded: Binding<Bool>?
    var fitsContent: Bool = false
    let content: Content

    init(isExpanded: Binding<Bool>? = nil, fitsContent: Bool = false, @ViewBuilder content: () -> Content) {
        self.isExpanded = isExpanded
        self.fitsContent = fitsContent
        self.content = content()
    }

    @State private var _expanded = true
    @State private var panelHeight: CGFloat = 0
    @State private var peekHeight: CGFloat?
    @GestureState(resetTransaction: Transaction(animation: panelSnap)) private var drag: CGFloat = 0

    private var expanded: Bool {
        isExpanded?.wrappedValue ?? _expanded
    }

    private func setExpanded(_ value: Bool) {
        if let binding = isExpanded {
            binding.wrappedValue = value
        } else {
            _expanded = value
        }
    }

    var body: some View {
        GeometryReader { safeProxy in
            panel(bottomInset: safeProxy.safeAreaInsets.bottom)
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.7), trigger: expanded)
    }

    private func panel(bottomInset: CGFloat) -> some View {
        GeometryReader { proxy in
            if fitsContent {
                let collapsedVisible = peekHeight.map { $0 + max(bottomInset, 16) } ?? 48
                let hidden = max(panelHeight - collapsedVisible, 0)
                let offset = resolvedOffset(hidden: hidden)

                VStack(spacing: 0) {
                    grabber
                        .gesture(dragGesture(threshold: 25))

                    ScrollView(showsIndicators: false) {
                        content
                            .padding(.bottom, 28)
                            .environment(\.bottomPanelCollapseProgress, progress(offset: offset, hidden: hidden))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: PanelHeightPreferenceKey.self, value: geo.size.height)
                    }
                )
                .onPreferenceChange(PanelHeightPreferenceKey.self) { height in
                    panelHeight = height
                }
                .onPreferenceChange(PanelPeekPreferenceKey.self) { maxY in
                    peekHeight = maxY
                }
                .coordinateSpace(name: PanelPeekPreferenceKey.coordinateSpace)
                .background(panelBackground)
                .frame(width: proxy.size.width)
                .offset(y: offset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            } else {
                let fullHeight = proxy.size.height * 0.88
                let collapsedVisible = proxy.size.height * 0.58
                let hidden = fullHeight - collapsedVisible
                let offset = resolvedOffset(hidden: hidden)

                VStack(spacing: 0) {
                    grabber
                        .gesture(dragGesture(threshold: 30))

                    ScrollView(showsIndicators: false) {
                        content
                            .padding(.bottom, 48)
                            .environment(\.bottomPanelCollapseProgress, progress(offset: offset, hidden: hidden))
                    }
                }
                .frame(width: proxy.size.width, height: fullHeight, alignment: .top)
                .background(panelBackground)
                .offset(y: offset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: Drag physics

    /// Follows the finger between the open and collapsed stops, with rubber-band resistance past either end.
    private func resolvedOffset(hidden: CGFloat) -> CGFloat {
        let raw = (expanded ? 0 : hidden) + drag
        if raw < 0 { return -rubberBand(-raw) }
        if raw > hidden { return hidden + rubberBand(raw - hidden) }
        return raw
    }

    private func rubberBand(_ overshoot: CGFloat) -> CGFloat {
        let limit: CGFloat = 60
        return limit * (1 - 1 / (overshoot / limit * 0.55 + 1))
    }

    private func progress(offset: CGFloat, hidden: CGFloat) -> CGFloat {
        guard hidden > 0 else { return 0 }
        return min(max(offset / hidden, 0), 1)
    }

    private func dragGesture(threshold: CGFloat) -> some Gesture {
        DragGesture()
            .updating($drag) { value, state, _ in state = value.translation.height }
            .onEnded { value in
                let projected = value.predictedEndTranslation.height
                withAnimation(panelSnap) {
                    if projected < -threshold { setExpanded(true) }
                    else if projected > threshold { setExpanded(false) }
                }
            }
    }

    // MARK: Chrome

    private var panelBackground: some View {
        RaahaScreenBackground()
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32, style: .continuous))
            .overlay(
                UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.85), Color.white.opacity(0.25)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color(hex: 0x49769F).opacity(0.35), radius: 18, x: 0, y: -4)
            .padding(.bottom, -80)
    }

    /// Flat bar at rest; bends into a chevron that follows the drag, and hints "pull up" when collapsed.
    private var grabber: some View {
        let isDragging = drag != 0
        let bend = isDragging ? min(max(drag / 10, -4), 4) : (expanded ? 0 : -3)

        return GrabberShape(bend: bend)
            .stroke(
                Color(hex: 0x49769F).opacity(isDragging ? 0.75 : 0.45),
                style: StrokeStyle(lineWidth: 4.5, lineCap: .round, lineJoin: .round)
            )
            .frame(width: isDragging ? 44 : 36, height: 10)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: bend)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(panelSnap) { setExpanded(!expanded) }
            }
            .accessibilityElement()
            .accessibilityLabel(expanded ? "Collapse panel" : "Expand panel")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { setExpanded(!expanded) }
    }
}

private struct GrabberShape: Shape {
    var bend: CGFloat

    var animatableData: CGFloat {
        get { bend }
        set { bend = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + bend))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

// MARK: - Collapse progress

private struct BottomPanelCollapseProgressKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    /// 0 when the enclosing `BottomPanel` is fully open, 1 when fully collapsed. Tracks the drag live.
    var bottomPanelCollapseProgress: CGFloat {
        get { self[BottomPanelCollapseProgressKey.self] }
        set { self[BottomPanelCollapseProgressKey.self] = newValue }
    }
}

private struct BottomPanelCollapseEffect: ViewModifier {
    let order: Int
    @Environment(\.bottomPanelCollapseProgress) private var progress

    func body(content: Content) -> some View {
        let p = min(progress * (1.15 + CGFloat(order) * 0.35), 1)

        content
            .opacity(1 - p)
            .blur(radius: 6 * p)
            .scaleEffect(1 - 0.06 * p, anchor: .top)
            .rotation3DEffect(.degrees(-18 * p), axis: (x: 1, y: 0, z: 0), anchor: .top, perspective: 0.6)
            .offset(y: -10 * p)
    }
}

extension View {
    /// Fades, blurs and folds this view away as the enclosing `BottomPanel` collapses.
    /// Higher `order` values disappear sooner, giving a staggered fold.
    func bottomPanelCollapsible(order: Int = 0) -> some View {
        modifier(BottomPanelCollapseEffect(order: order))
    }

    /// Marks this view as the part of a `fitsContent` `BottomPanel` that stays visible when collapsed.
    /// The panel collapses down to the bottom edge of the marked view instead of just the grabber.
    func bottomPanelPeek() -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: PanelPeekPreferenceKey.self,
                    value: geo.frame(in: .named(PanelPeekPreferenceKey.coordinateSpace)).maxY
                )
            }
        )
    }
}

private struct PanelPeekPreferenceKey: PreferenceKey {
    static let coordinateSpace = "BottomPanelPeek"
    static var defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

private struct PanelHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        if next > 0 {
            value = next
        }
    }
}
