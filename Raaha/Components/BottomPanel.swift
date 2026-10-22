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
struct BottomPanel<Content: View>: View {
    @ViewBuilder var content: Content

    @State private var expanded = false
    @GestureState private var drag: CGFloat = 0

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
                                    if value.translation.height < -30 { expanded = true }
                                    else if value.translation.height > 30 { expanded = false }
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
                UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32, style: .continuous)
                    .fill(Color.honeydew)
                    .shadow(color: Color.deepSpace.opacity(0.2), radius: 16, x: 0, y: -4)
            )
            .offset(y: offset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var grabber: some View {
        Capsule()
            .fill(Color.deepSpace.opacity(0.85))
            .frame(width: 64, height: 5)
            .frame(maxWidth: .infinity, minHeight: 28)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.snappy(duration: 0.3)) { expanded.toggle() }
            }
            .accessibilityElement()
            .accessibilityLabel(expanded ? "Collapse panel" : "Expand panel")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { expanded.toggle() }
    }
}
