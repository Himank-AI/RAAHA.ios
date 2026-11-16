import MapKit
import SwiftUI

struct InteractiveMapContainer: View {
    let model: RouteSelectionTransition
    let originTitle: String
    let destinationTitle: String

    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: MockData.mapCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.24, longitudeDelta: 0.24)
        )
    )

    var body: some View {
        let option = model.mappedOption
        let progress = model.displayProgress
        let frameToken = model.frameRequest.token
        let segments = RouteGeometry.segments(for: option)

        Map(position: $camera) {
            AnimatedRoutePolyline(segments: segments, progress: progress)

            ForEach(segments) { segment in
                Annotation(segment.mode.title, coordinate: segment.midpoint, anchor: .center) {
                    RouteModeMarker(
                        mode: segment.mode,
                        isVisible: progress > CGFloat(segment.id) + 0.58
                    )
                }
            }

            Annotation(originTitle, coordinate: MockData.origin, anchor: .center) {
                CurrentLocationMarker()
            }

            Marker(destinationTitle, systemImage: "mappin", coordinate: MockData.destination)
                .tint(segments.last?.mode.color ?? Color.steelBlue)
        }
        .mapStyle(.standard(elevation: .flat))
        .onChange(of: frameToken) { _, token in
            guard token > 0 else { return }
            let request = model.frameRequest
            let region = RouteGeometry.framedRegion(
                bottomCoverage: request.bottomCoverage,
                topCoverage: request.topCoverage,
                viewport: request.viewport
            )
            if request.animated {
                withAnimation(RouteSelectionTransition.cameraSpring(reduceMotion: false)) {
                    camera = .region(region)
                }
            } else {
                camera = .region(region)
            }
        }
    }
}

/// Advances route-draw progress without rebuilding the map's camera every frame.
struct RouteDrawDriver: View {
    let model: RouteSelectionTransition

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !model.isDrawing)) { context in
            Color.clear
                .onAppear { publish(at: context.date) }
                .onChange(of: context.date) { _, date in
                    publish(at: date)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(0)
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private func publish(at date: Date) {
        let next = model.renderedProgress(at: date)
        if abs(next - model.displayProgress) > 0.004 {
            model.displayProgress = next
        }
    }
}

struct RouteModeMarker: View {
    let mode: TransportMode
    var isVisible: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ModeGlyph(mode: mode)
            .foregroundStyle(mode.color)
            .frame(width: 13, height: 13)
            .padding(6)
            .background {
                Circle().fill(.ultraThinMaterial)
                Circle().fill(Color.white.opacity(0.88))
            }
            .overlay(Circle().stroke(mode.color, lineWidth: 1.5))
            .shadow(color: mode.color.opacity(0.28), radius: 4, x: 0, y: 2)
            .scaleEffect(reduceMotion || isVisible ? 1 : 0.35)
            .opacity(isVisible ? 1 : 0)
            .animation(reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.36, dampingFraction: 0.68), value: isVisible)
            .accessibilityHidden(true)
    }
}

struct CurrentLocationMarker: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false
    @State private var bob = false

    var body: some View {
        ZStack {
            if !reduceMotion {
                Circle()
                    .fill(Color.steelBlue.opacity(0.20))
                    .frame(width: 34, height: 34)
                    .scaleEffect(pulse ? 1.65 : 0.72)
                    .opacity(pulse ? 0 : 0.85)
            }

            Circle()
                .fill(Color.white)
                .frame(width: 18, height: 18)
                .shadow(color: Color.steelBlue.opacity(0.35), radius: 3, x: 0, y: 1)
            Circle()
                .fill(Color.steelBlue)
                .frame(width: 11, height: 11)
        }
        .offset(y: reduceMotion ? 0 : (bob ? -1.1 : 1.1))
        .frame(width: 44, height: 44)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 1.55).repeatForever(autoreverses: false)) {
                pulse = true
            }
            withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                bob = true
            }
        }
        .accessibilityHidden(true)
    }
}
