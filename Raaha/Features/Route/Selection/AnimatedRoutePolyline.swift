import MapKit
import SwiftUI

/// Draws the selected journey along the existing route polyline, one transport
/// segment after another. Colour comes from `TransportMode.color`.
struct AnimatedRoutePolyline: MapContent {
    let segments: [RouteGeometry.Segment]
    let progress: CGFloat

    var body: some MapContent {
        ForEach(segments) { segment in
            SegmentStroke(segment: segment, progress: progress)
        }
    }
}

private struct SegmentStroke: MapContent {
    let segment: RouteGeometry.Segment
    let progress: CGFloat

    var body: some MapContent {
        let local = min(max(progress - CGFloat(segment.id), 0), 1)
        let coordinates = RouteGeometry.trimmed(segment.coordinates, progress: local)
        if coordinates.count >= 2 {
            MapPolyline(coordinates: coordinates)
                .stroke(
                    Color.white.opacity(0.92),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                )
            MapPolyline(coordinates: coordinates)
                .stroke(
                    segment.mode.color,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                )
        }
    }
}
