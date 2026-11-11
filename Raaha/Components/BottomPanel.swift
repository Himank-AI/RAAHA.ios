import SwiftUI
import MapKit

/// Chennai map used behind the route and live-journey panels.
struct JourneyMapView: View {
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: MockData.mapCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.24, longitudeDelta: 0.24)
        )
    )

    var body: some View {
        Map(position: $position) {
            MapPolyline(coordinates: MockData.routeCoordinates)
                .stroke(Color.strawberry, lineWidth: 5)
            Marker("Current Location", systemImage: "location.fill", coordinate: MockData.origin)
                .tint(Color.steelBlue)
            Marker("Phoenix Mall", image: "icon_pin", coordinate: MockData.destination)
                .tint(Color.strawberry)
        }
        .mapStyle(.standard(elevation: .flat))
        .ignoresSafeArea()
    }
}

/// Honeydew bottom sheet with a grabber. Drag (or tap) the grabber to expand / collapse.
/// Pass `isExpanded` binding to observe expansion state from outside (e.g. for dynamic content padding).
struct BottomPanel<Content: View>: View {
    var isExpanded: Binding<Bool>?
    let content: Content

    init(isExpanded: Binding<Bool>? = nil, @ViewBuilder content: () -> Content) {
        self.isExpanded = isExpanded
        self.content = content()
    }

    @State private var _expanded = true
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
        GeometryReader { proxy in
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
            .background(
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
            )
            .offset(y: offset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var grabber: some View {
        Capsule()
            .fill(Color(hex: 0x49769F).opacity(0.45))
            .frame(width: 36, height: 4)
            .frame(maxWidth: .infinity, minHeight: 14)
            .contentShape(Rectangle())
            .padding(.top, 6)
            .padding(.bottom, 2)
            .onTapGesture {
                withAnimation(.snappy(duration: 0.3)) { setExpanded(!expanded) }
            }
            .accessibilityElement()
            .accessibilityLabel(expanded ? "Collapse panel" : "Expand panel")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { setExpanded(!expanded) }
    }
}
