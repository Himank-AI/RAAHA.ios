import CoreLocation
import MapKit
import Observation
import SwiftUI

// MARK: - Detents

enum RouteSheetDetent: Int, Equatable {
    case minimized
    case compact
    case expanded
}

struct RouteSheetLayout {
    var containerWidth: CGFloat
    var containerHeight: CGFloat
    var safeTop: CGFloat
    var safeBottom: CGFloat

    var minimizedHeight: CGFloat { 76 }
    var compactHeight: CGFloat { 236 }

    var expandedHeight: CGFloat {
        let ceiling = max(containerHeight - safeTop - 12, compactHeight + 80)
        let proposed = max(containerHeight * 0.72, compactHeight + 120)
        return min(proposed, ceiling)
    }

    func height(for detent: RouteSheetDetent) -> CGFloat {
        switch detent {
        case .minimized: return minimizedHeight
        case .compact: return compactHeight
        case .expanded: return expandedHeight
        }
    }

    func expansion(for height: CGFloat) -> CGFloat {
        let span = max(expandedHeight - compactHeight, 1)
        return min(max((height - compactHeight) / span, 0), 1)
    }

    func minimizedAmount(for height: CGFloat) -> CGFloat {
        let span = max(compactHeight - minimizedHeight, 1)
        return min(max((compactHeight - height) / span, 0), 1)
    }

    /// Distance from the bottom of the screen to the top of the sheet, including the floating margin.
    func footprint(for detent: RouteSheetDetent) -> CGFloat {
        let height = height(for: detent)
        let expansion = expansion(for: height)
        return height + (1 - expansion) * (safeBottom + 8)
    }

    func rubberClamp(_ height: CGFloat) -> CGFloat {
        let lower = minimizedHeight
        let upper = expandedHeight
        if height < lower { return lower - rubberBand(lower - height) }
        if height > upper { return upper + rubberBand(height - upper) }
        return height
    }

    func snappedDetent(predictedHeight: CGFloat, from current: RouteSheetDetent) -> RouteSheetDetent {
        let currentHeight = height(for: current)
        let delta = predictedHeight - currentHeight
        let threshold: CGFloat = 56

        if delta > threshold {
            switch current {
            case .minimized:
                return predictedHeight > (compactHeight + expandedHeight) / 2 ? .expanded : .compact
            case .compact:
                return .expanded
            case .expanded:
                return .expanded
            }
        }

        if delta < -threshold {
            switch current {
            case .expanded:
                return predictedHeight < (minimizedHeight + compactHeight) / 2 ? .minimized : .compact
            case .compact:
                return .minimized
            case .minimized:
                return .minimized
            }
        }

        return current
    }

    private func rubberBand(_ overshoot: CGFloat) -> CGFloat {
        let limit: CGFloat = 52
        return limit * (1 - 1 / (overshoot / limit * 0.55 + 1))
    }
}

struct MapFrameRequest: Equatable {
    var token: Int = 0
    var bottomCoverage: CGFloat = 280
    var topCoverage: CGFloat = 120
    var viewport: CGSize = CGSize(width: 390, height: 844)
    var animated: Bool = true
}

// MARK: - Transition state

/// Selected route, sheet position, and map-draw progress for route options.
/// The selected kind is the source of truth for the card, the sheet, and the map.
@MainActor
@Observable
final class RouteSelectionTransition {
    var selectedKind: RouteKind = .fastest
    /// Route currently stroked on the map. Updates when a draw begins so the
    /// line does not swap underneath the card-lift animation.
    var mappedKind: RouteKind = .fastest
    var detent: RouteSheetDetent = .expanded
    var sheetHeight: CGFloat = 620
    var listReveal: CGFloat = 1
    var isPresentingSelection = false
    var isDragging = false
    var selectionTick = 0
    var displayProgress: CGFloat = 3
    var isDrawing = false
    var frameRequest = MapFrameRequest()

    @ObservationIgnored private var didPrepare = false
    @ObservationIgnored private var selectionGeneration = 0
    @ObservationIgnored private var drawGeneration = 0
    @ObservationIgnored private var drawnKind: RouteKind?
    @ObservationIgnored private var drawStart: Date?
    @ObservationIgnored private var drawDuration: TimeInterval = 1
    @ObservationIgnored private var collapseTask: Task<Void, Never>?
    @ObservationIgnored private var drawTask: Task<Void, Never>?

    var option: RouteOption { MockData.route(selectedKind) }
    var mappedOption: RouteOption { MockData.route(mappedKind) }

    static func cardSpring(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.38, dampingFraction: 0.72)
    }

    static func sheetSpring(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.25) : .spring(response: 0.54, dampingFraction: 0.88)
    }

    static func dragSpring(reduceMotion: Bool) -> Animation {
        reduceMotion
            ? .easeInOut(duration: 0.25)
            : .interactiveSpring(response: 0.34, dampingFraction: 0.86, blendDuration: 0.12)
    }

    static func cameraSpring(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.72, dampingFraction: 0.9)
    }

    static func checkSpring(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.32, dampingFraction: 0.56)
    }

    func prepare(layout: RouteSheetLayout) {
        guard layout.containerHeight > 100 else { return }
        if !didPrepare {
            didPrepare = true
            sheetHeight = layout.expandedHeight
            return
        }
        guard !isDragging, detent == .expanded else { return }
        sheetHeight = layout.expandedHeight
    }

    func select(_ kind: RouteKind, layout: RouteSheetLayout, reduceMotion: Bool) {
        selectionTick += 1
        collapseTask?.cancel()
        selectionGeneration += 1
        let generation = selectionGeneration

        withAnimation(Self.cardSpring(reduceMotion: reduceMotion)) {
            selectedKind = kind
            isPresentingSelection = true
            listReveal = 0
        }

        if reduceMotion {
            mappedKind = kind
            displayProgress = CGFloat(max(MockData.route(kind).chain.count, 1))
        }

        let delay: UInt64 = reduceMotion ? 0 : 110_000_000
        collapseTask = Task { @MainActor [weak self] in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            }
            guard let self, !Task.isCancelled, generation == self.selectionGeneration, !self.isDragging else { return }
            self.animate(to: .compact, layout: layout, reduceMotion: reduceMotion, replayDraw: true)
        }
    }

    func animate(to next: RouteSheetDetent, layout: RouteSheetLayout, reduceMotion: Bool, replayDraw: Bool) {
        let previous = detent
        withAnimation(Self.sheetSpring(reduceMotion: reduceMotion)) {
            apply(next, layout: layout, previous: previous)
        }
        if next != .expanded && (replayDraw || previous == .expanded) {
            revealMap(layout: layout, detent: next, reduceMotion: reduceMotion, replayDraw: replayDraw)
        }
    }

    func finishDrag(predictedHeight: CGFloat, layout: RouteSheetLayout, reduceMotion: Bool) {
        isDragging = false
        let previous = detent
        let next = layout.snappedDetent(predictedHeight: predictedHeight, from: previous)
        withAnimation(Self.dragSpring(reduceMotion: reduceMotion)) {
            apply(next, layout: layout, previous: previous)
        }
        if next != .expanded && previous == .expanded {
            revealMap(layout: layout, detent: next, reduceMotion: reduceMotion, replayDraw: false)
        }
    }

    func cancelPendingCollapse() {
        selectionGeneration += 1
        collapseTask?.cancel()
        collapseTask = nil
    }

    func cancelPendingWork() {
        cancelPendingCollapse()
        drawGeneration += 1
        drawTask?.cancel()
        drawTask = nil
        drawStart = nil
        isDrawing = false
    }

    func renderedProgress(at date: Date) -> CGFloat {
        let count = CGFloat(max(mappedOption.chain.count, 1))
        guard let drawStart else { return count }
        let elapsed = date.timeIntervalSince(drawStart)
        if elapsed <= 0 { return 0 }
        if elapsed >= drawDuration { return count }
        return count * CGFloat(elapsed / drawDuration)
    }

    private func apply(_ next: RouteSheetDetent, layout: RouteSheetLayout, previous: RouteSheetDetent) {
        detent = next
        sheetHeight = layout.height(for: next)
        if next == .expanded {
            isPresentingSelection = false
            listReveal = 1
        } else if previous == .expanded {
            listReveal = 0
            isPresentingSelection = true
        }
    }

    private func revealMap(layout: RouteSheetLayout, detent: RouteSheetDetent, reduceMotion: Bool, replayDraw: Bool) {
        frameRequest = MapFrameRequest(
            token: frameRequest.token + 1,
            bottomCoverage: layout.footprint(for: detent) + 20,
            topCoverage: layout.safeTop + 16,
            viewport: CGSize(width: layout.containerWidth, height: layout.containerHeight),
            animated: !reduceMotion
        )
        playDraw(force: replayDraw, reduceMotion: reduceMotion)
    }

    private func playDraw(force: Bool, reduceMotion: Bool) {
        let count = CGFloat(max(MockData.route(selectedKind).chain.count, 1))
        if !force && drawnKind == selectedKind {
            mappedKind = selectedKind
            if drawStart == nil {
                displayProgress = count
            }
            return
        }

        drawTask?.cancel()
        drawnKind = selectedKind
        mappedKind = selectedKind

        if reduceMotion {
            drawStart = nil
            isDrawing = false
            displayProgress = count
            return
        }

        drawGeneration += 1
        let generation = drawGeneration
        drawDuration = 0.4 * Double(count)
        displayProgress = 0
        drawStart = Date()
        isDrawing = true
        drawTask = Task { @MainActor [weak self] in
            let nanoseconds = UInt64((self?.drawDuration ?? 1) * 1_000_000_000) + 60_000_000
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard let self, !Task.isCancelled, generation == self.drawGeneration else { return }
            self.drawStart = nil
            self.isDrawing = false
            self.displayProgress = CGFloat(max(self.mappedOption.chain.count, 1))
        }
    }
}

// MARK: - Existing route geometry

enum RouteGeometry {
    /// One coloured piece of `MockData.routeCoordinates`. Points are samples
    /// along that polyline, split across the route's real transport sequence.
    struct Segment: Identifiable {
        let id: Int
        let mode: TransportMode
        let coordinates: [CLLocationCoordinate2D]

        var midpoint: CLLocationCoordinate2D {
            coordinates[coordinates.count / 2]
        }
    }

    static func segments(for option: RouteOption, source: [CLLocationCoordinate2D] = MockData.routeCoordinates) -> [Segment] {
        let modes = option.chain
        guard modes.count >= 1, source.count >= 2 else { return [] }

        let weights: [Double]
        if option.legs.count == modes.count {
            weights = option.legs.map { minutes(in: $0.detail) }
        } else {
            weights = Array(repeating: 1, count: modes.count)
        }

        let lengths = segmentLengths(source)
        let total = lengths.reduce(0, +)
        guard total > 0 else { return [] }

        let weightSum = weights.reduce(0, +)
        var start = 0.0
        var segments: [Segment] = []

        for (index, mode) in modes.enumerated() {
            let portion = total * (weights[index] / weightSum)
            let end = index == modes.count - 1 ? total : min(start + portion, total)
            var points: [CLLocationCoordinate2D] = []
            let steps = 22
            for step in 0...steps {
                let distance = start + (end - start) * Double(step) / Double(steps)
                points.append(coordinate(at: distance, along: source, lengths: lengths, total: total))
            }
            if index == 0 { points[0] = source[0] }
            if index == modes.count - 1 { points[points.count - 1] = source[source.count - 1] }
            segments.append(Segment(id: index, mode: mode, coordinates: points))
            start = end
        }

        return segments
    }

    static func trimmed(_ coordinates: [CLLocationCoordinate2D], progress: CGFloat) -> [CLLocationCoordinate2D] {
        guard coordinates.count >= 2 else { return [] }
        let progress = min(max(progress, 0), 1)
        if progress <= 0.001 { return [] }
        if progress >= 0.999 { return coordinates }

        let scaled = progress * CGFloat(coordinates.count - 1)
        let index = min(Int(scaled), coordinates.count - 2)
        let fraction = Double(scaled - CGFloat(index))
        let start = coordinates[index]
        let end = coordinates[index + 1]
        let point = CLLocationCoordinate2D(
            latitude: start.latitude + (end.latitude - start.latitude) * fraction,
            longitude: start.longitude + (end.longitude - start.longitude) * fraction
        )
        var result = Array(coordinates.prefix(index + 1))
        result.append(point)
        return result
    }

    static func framedRegion(bottomCoverage: CGFloat, topCoverage: CGFloat, viewport: CGSize) -> MKCoordinateRegion {
        let fallback = MKCoordinateRegion(
            center: MockData.mapCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.24, longitudeDelta: 0.24)
        )
        let coords = MockData.routeCoordinates
        guard coords.count >= 2, viewport.width > 1, viewport.height > 1 else { return fallback }

        let latitudes = coords.map(\.latitude)
        let longitudes = coords.map(\.longitude)
        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max() else { return fallback }

        let latSpan = max(maxLat - minLat, 0.02)
        let lonSpan = max(maxLon - minLon, 0.02)
        let top = min(max(topCoverage, 0), viewport.height * 0.45)
        let bottom = min(max(bottomCoverage, 0), viewport.height * 0.72)
        let usable = max(viewport.height - top - bottom, viewport.height * 0.3)
        let verticalScale = viewport.height / usable
        let latDelta = max(latSpan * 1.5 * verticalScale, 0.06)
        let lonDelta = max(lonSpan * 1.55 * verticalScale, latDelta * viewport.width / max(viewport.height, 1))

        let visualCenterY = top + usable / 2
        let fraction = (viewport.height / 2 - visualCenterY) / viewport.height
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2 - latDelta * fraction,
            longitude: (minLon + maxLon) / 2
        )
        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }

    private static func minutes(in detail: String) -> Double {
        let token = detail.split { $0 == " " || $0 == "·" }.first
        if let token, let value = Double(token), value > 0 { return value }
        return 1
    }

    private static func segmentLengths(_ coordinates: [CLLocationCoordinate2D]) -> [Double] {
        guard coordinates.count >= 2 else { return [] }
        return (0..<(coordinates.count - 1)).map { index in
            let start = CLLocation(latitude: coordinates[index].latitude, longitude: coordinates[index].longitude)
            let end = CLLocation(latitude: coordinates[index + 1].latitude, longitude: coordinates[index + 1].longitude)
            return start.distance(from: end)
        }
    }

    private static func coordinate(
        at distance: Double,
        along coordinates: [CLLocationCoordinate2D],
        lengths: [Double],
        total: Double
    ) -> CLLocationCoordinate2D {
        if distance <= 0 { return coordinates[0] }
        if distance >= total { return coordinates[coordinates.count - 1] }

        var remaining = distance
        for index in lengths.indices {
            let length = lengths[index]
            if remaining <= length || index == lengths.count - 1 {
                let fraction = length > 0 ? min(max(remaining / length, 0), 1) : 0
                let start = coordinates[index]
                let end = coordinates[index + 1]
                return CLLocationCoordinate2D(
                    latitude: start.latitude + (end.latitude - start.latitude) * fraction,
                    longitude: start.longitude + (end.longitude - start.longitude) * fraction
                )
            }
            remaining -= length
        }
        return coordinates[coordinates.count - 1]
    }
}

// MARK: - Shared geometry match

struct RouteMatchedGeometry: ViewModifier {
    var active: Bool
    var namespace: Namespace.ID

    func body(content: Content) -> some View {
        if active {
            content.matchedGeometryEffect(id: "selected-journey", in: namespace, properties: .frame, anchor: .top)
        } else {
            content
        }
    }
}
