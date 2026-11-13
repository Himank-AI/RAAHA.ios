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

/// Honeydew bottom sheet with a grabber. Drag (or tap) the grabber to expand / collapse.
/// Pass `isExpanded` binding to observe expansion state from outside (e.g. for dynamic content padding).
/// Set `fitsContent: true` when the panel height should snugly wrap the content and sit at the bottom.
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
    @GestureState private var drag: CGFloat = 0

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
    }

    private func panel(bottomInset: CGFloat) -> some View {
        GeometryReader { proxy in
            if fitsContent {
                let collapsedVisible = peekHeight.map { $0 + max(bottomInset, 16) } ?? 48
                let hidden = max(panelHeight - collapsedVisible, 0)
                let base = expanded ? 0 : hidden
                let offset = min(max(base + drag, 0), hidden)

                VStack(spacing: 0) {
                    grabber
                        .gesture(
                            DragGesture()
                                .updating($drag) { value, state, _ in state = value.translation.height }
                                .onEnded { value in
                                    withAnimation(.snappy(duration: 0.3)) {
                                        if value.translation.height < -25 { setExpanded(true) }
                                        else if value.translation.height > 25 { setExpanded(false) }
                                    }
                                }
                        )

                    ScrollView(showsIndicators: false) {
                        content
                            .padding(.bottom, 28)
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
                let base = expanded ? 0 : hidden
                let offset = min(max(base + drag, 0), hidden)

                VStack(spacing: 0) {
                    grabber
                        .gesture(
                            DragGesture()
                                .updating($drag) { value, state, _ in state = value.translation.height }
                                .onEnded { value in
                                    withAnimation(.snappy(duration: 0.3)) {
                                        if value.translation.height < -30 { setExpanded(true) }
                                        else if value.translation.height > 30 { setExpanded(false) }
                                    }
                                }
                        )

                    ScrollView(showsIndicators: false) {
                        content
                            .padding(.bottom, 48)
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
    }

    private var grabber: some View {
        Capsule()
            .fill(Color(hex: 0x49769F).opacity(0.45))
            .frame(width: 36, height: 4)
            .frame(maxWidth: .infinity, minHeight: 14)
            .contentShape(Rectangle())
            .padding(.top, 10)
            .padding(.bottom, 6)
            .onTapGesture {
                withAnimation(.snappy(duration: 0.3)) { setExpanded(!expanded) }
            }
            .accessibilityElement()
            .accessibilityLabel(expanded ? "Collapse panel" : "Expand panel")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { setExpanded(!expanded) }
    }
}

extension View {
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
