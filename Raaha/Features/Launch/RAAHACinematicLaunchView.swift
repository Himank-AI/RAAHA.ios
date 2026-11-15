import SwiftUI

/// One-time opening. Plays over the real Home screen, then lets that screen through.
struct RAAHACinematicLaunchView: View {
    var manager: LaunchTransitionManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                reduced
            } else {
                timed
            }
        }
        .ignoresSafeArea()
    }

    private var timed: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let sample = manager.sample(at: timeline.date)
            CinematicScene(sample: sample)
                .allowsHitTesting(sample.veil < 0.40)
                .onChange(of: sample.handoff) { _, started in
                    if started { manager.beginHandoff() }
                }
                .onChange(of: sample.done) { _, finished in
                    if finished { manager.finish(animated: false) }
                }
                .onChange(of: sample.logo > 0.55) { _, arrived in
                    if arrived { manager.noteLogoArrival() }
                }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: manager.logoCue)
        .onAppear {
            manager.start(reduceMotion: false)
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(4600))
                manager.finish(animated: false)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("RAAHA. Every journey, connected.")
        .accessibilityAction(named: Text("Skip")) {
            manager.finish(animated: true)
        }
    }

    private var reduced: some View {
        CinematicScene(sample: .hold)
            .onAppear {
                manager.start(reduceMotion: true)
                manager.beginHandoff()
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(480))
                    manager.finish(animated: true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("RAAHA. Every journey, connected.")
    }
}

private struct CinematicScene: View {
    var sample: LaunchSample

    var body: some View {
        ZStack {
            Color.oceanicBDD8E9.opacity((1 - sample.awaken) * (1 - sample.veil))
            GeometryReader { geo in
                let focus = CGPoint(
                    x: geo.size.width * LaunchSample.focus.x,
                    y: geo.size.height * LaunchSample.focus.y
                )
                ZStack {
                    RAAHACityEnvironment(sample: sample)
                    if !sample.frozen {
                        RAAHATransportAnimation(sample: sample)
                    }
                    RAAHAFloatingGlassOrb(sample: sample)
                        .position(focus)
                    RAAHALogoReveal(sample: sample)
                        .position(focus)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}
