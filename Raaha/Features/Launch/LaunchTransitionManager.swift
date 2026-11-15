import SwiftUI

/// One-shot clock for the opening sequence. Lives on the root view so tab
/// changes and pushed screens do not replay it.
@MainActor
@Observable
final class LaunchTransitionManager {
    static let duration: TimeInterval = 3.6

    var isPresenting = true
    var handoffStarted = false
    /// 0 while Home is waiting to enter, 1 once it has settled.
    var homeReveal: CGFloat = 0
    var smartReveal: CGFloat = 0
    var chromeReveal: CGFloat = 0
    var logoCue = 0

    private(set) var startedAt: Date?

    func start(reduceMotion: Bool) {
        guard startedAt == nil else { return }
        startedAt = Date()
        if reduceMotion {
            homeReveal = 1
            smartReveal = 1
            chromeReveal = 1
        }
    }

    func sample(at date: Date) -> LaunchSample {
        guard let startedAt else { return .zero }
        let elapsed = date.timeIntervalSince(startedAt)
        let t = min(max(elapsed / Self.duration, 0), 1)
        return LaunchSample(t: t, seconds: elapsed)
    }

    func beginHandoff() {
        guard !handoffStarted else { return }
        handoffStarted = true
        revealContent()
    }

    /// Brings the Home cards and tab bar in. Safe to call again.
    func revealContent() {
        guard homeReveal < 1 || smartReveal < 1 || chromeReveal < 1 else { return }
        guard !isPresenting || handoffStarted else { return }
        homeReveal = 1
        smartReveal = 1
        chromeReveal = 1
    }

    func noteLogoArrival() {
        guard logoCue == 0 else { return }
        logoCue = 1
    }

    func finish(animated: Bool) {
        guard isPresenting else { return }
        if !handoffStarted {
            handoffStarted = true
            revealContent()
        }
        if animated {
            withAnimation(.easeOut(duration: 0.35)) {
                isPresenting = false
            }
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                isPresenting = false
            }
        }
    }
}

typealias RAAHALaunchTransition = LaunchTransitionManager

/// Normalized progress through the 3.6s sequence. One clock keeps the city,
/// transport, glass, and logo in step.
struct LaunchSample: Equatable {
    var t: CGFloat
    var seconds: TimeInterval
    var frozen: Bool = false

    static let zero = LaunchSample(t: 0, seconds: 0)
    /// Still frame for Reduce Motion: the city and mark, with nothing moving.
    static let hold = LaunchSample(t: 1, seconds: 0, frozen: true)

    /// Shared focal point. The glass portal and the logo sit here.
    static let focus = CGPoint(x: 0.50, y: 0.40)

    var awaken: CGFloat { frozen ? 1 : curve(0.00, 0.08) }
    var city: CGFloat { frozen ? 1 : curve(0.04, 0.24) }
    var camera: CGFloat { frozen ? 0 : curve(0.06, 0.52) }
    var metro: CGFloat { frozen ? 0 : curve(0.16, 0.50) }
    var routeDraw: CGFloat { frozen ? 0 : curve(0.16, 0.42) }
    var travel: CGFloat { frozen ? 0 : curve(0.22, 0.50) }
    var orb: CGFloat { frozen ? 1 : curve(0.42, 0.54) }
    var ripple: CGFloat { frozen ? 0 : curve(0.44, 0.58) }
    var networkFade: CGFloat { frozen ? 1 : curve(0.48, 0.64) }
    var logo: CGFloat { frozen ? 1 : curve(0.50, 0.62) }
    var wordmark: CGFloat { frozen ? 1 : curve(0.56, 0.66) }
    var tagline: CGFloat { frozen ? 1 : curve(0.60, 0.70) }
    var sweep: CGFloat { frozen ? 0 : curve(0.62, 0.80) }
    var veil: CGFloat { frozen ? 0 : curve(0.84, 1.00) }
    var dissolve: CGFloat { frozen ? 0 : curve(0.86, 1.00) }

    var handoff: Bool { !frozen && t >= 0.82 }
    var done: Bool { !frozen && t >= 0.995 }

    var networkOpacity: CGFloat { (1 - networkFade) * (1 - veil) }

    /// Ease-out with a small overshoot so the mark settles instead of stopping hard.
    var logoPop: CGFloat {
        if frozen { return 1 }
        let x = logo
        let base = 1 - pow(1 - x, 3)
        let overshoot = sin(x * .pi) * (1 - x) * 0.14
        return base + overshoot
    }

    var logoScale: CGFloat {
        (0.56 + 0.44 * logoPop) * (1 - 0.10 * dissolve)
    }

    var logoOpacity: CGFloat {
        (frozen ? 1 : min(logo * 2.4, 1)) * (1 - dissolve)
    }

    var sweepStrength: CGFloat {
        sin(sweep * .pi) * (1 - dissolve)
    }

    private func curve(_ start: CGFloat, _ end: CGFloat) -> CGFloat {
        let x = min(max((t - start) / (end - start), 0), 1)
        return x * x * (3 - 2 * x)
    }
}
