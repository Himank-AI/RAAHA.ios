
import SwiftUI

// MARK: - Buttons

struct PillButtonStyle: ButtonStyle {
    enum Kind { case light, dark, accent }
    var kind: Kind = .light

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.raahaHeadline)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(surface)
            .overlay(
                Capsule().stroke(strokeColor, lineWidth: 1)
            )
            .clipShape(Capsule())
            .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(
                .spring(response: 0.22, dampingFraction: 0.72),
                value: configuration.isPressed
            )
    }

    private var textColor: Color {
        switch kind {
        case .light, .dark: return .white
        case .accent: return Color(hex: 0x001D39)
        }
    }

    private var strokeColor: Color {
        switch kind {
        case .light: return Color.white.opacity(0.45)
        case .dark: return Color.white.opacity(0.20)
        case .accent: return Color.white.opacity(0.55)
        }
    }

    private var shadowColor: Color {
        switch kind {
        case .light: return Color(hex: 0x4E8EA2).opacity(0.45)
        case .dark: return Color(hex: 0x001D39).opacity(0.35)
        case .accent: return Color(hex: 0xC6FF00).opacity(0.45)
        }
    }

    @ViewBuilder
    private var surface: some View {
        switch kind {
        case .light:
            LinearGradient(
                colors: [Color(hex: 0x7BBDE8), Color(hex: 0x4E8EA2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            Capsule()
                .fill(Color(hex: 0x001D39).opacity(0.75))
                .background(.ultraThinMaterial, in: Capsule())
        case .accent:
            LinearGradient(
                colors: [Color(hex: 0xD8FF33), Color.neonLime],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    static var pillLight: PillButtonStyle { PillButtonStyle(kind: .light) }
    static var pillDark: PillButtonStyle { PillButtonStyle(kind: .dark) }
    static var pillAccent: PillButtonStyle { PillButtonStyle(kind: .accent) }
}

/// Tactile spring button style for cards and list items.
struct TactileButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.98

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? 0.94 : 1.0)
            .animation(
                .spring(response: 0.22, dampingFraction: 0.75),
                value: configuration.isPressed
            )
    }
}

/// Label for dark pills that carry a trailing chevron.
struct ChevronLabel: View {
    let title: String

    var body: some View {
        ZStack(alignment: .trailing) {
            Text(title).frame(maxWidth: .infinity)
            Image(systemName: "chevron.right")
                .font(.raahaFootnoteSemibold)
                .padding(.trailing, 22)
        }
    }
}

// MARK: - Small Building Blocks

/// A circular badge with a transport glyph.
struct ModeBadge: View {
    let mode: TransportMode
    var size: CGFloat = 40
    var fill: Color = Color.white.opacity(0.55)
    var tint: Color = Color.midnightBlue

    var body: some View {
        ZStack {
            Circle()
                .fill(fill)
                .background(.regularMaterial, in: Circle())
                .overlay(
                    Circle().stroke(
                        Color(hex: 0x7BBDE8).opacity(0.40),
                        lineWidth: 1
                    )
                )
                .shadow(
                    color: Color(hex: 0x49769F).opacity(0.20),
                    radius: 6,
                    x: 0,
                    y: 3
                )

            glyph
                .foregroundStyle(tint)
                .frame(width: size * 0.5, height: size * 0.5)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var glyph: some View {
        if let asset = mode.customAssetName {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: mode.symbolName)
                .resizable()
                .scaledToFit()
        }
    }
}

struct TimeChip: View {
    let text: String
    var fill: Color = Color.white.opacity(0.55)
    var tint: Color = Color.midnightBlue

    var body: some View {
        Text(text)
            .font(.raahaFootnoteSemibold)
            .foregroundStyle(tint)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(fill)
                    .background(.regularMaterial, in: Capsule())
                    .overlay(
                        Capsule().stroke(
                            Color(hex: 0x7BBDE8).opacity(0.40),
                            lineWidth: 0.8
                        )
                    )
            )
            .shadow(
                color: Color(hex: 0x49769F).opacity(0.15),
                radius: 4,
                x: 0,
                y: 2
            )
    }
}

struct SectionHeader: View {
    let title: String
    var action: String? = "See all"
    var showsChevron = false
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.raahaHeadline)
                .foregroundStyle(Color.midnightBlue)

            Spacer()

            if let action {
                Button {
                    onAction?()
                } label: {
                    HStack(spacing: 2) {
                        Text(action)
                        if showsChevron {
                            Image(systemName: "chevron.right")
                                .font(.raahaCaption2)
                        }
                    }
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.royalBlue)
                }
                .buttonStyle(.plain)
                .disabled(onAction == nil)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

/// Image that fills a fixed-height slot without disturbing layout.
struct FillImage: View {
    let name: String
    var height: CGFloat? = nil

    var body: some View {
        Color.clear
            .frame(height: height)
            .overlay {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

struct RouteBadge: View {
    let kind: RouteKind

    var body: some View {
        HStack(spacing: 5) {
            Group {
                switch kind {
                case .fastest:
                    Image(systemName: "bolt.fill")
                case .cheapest:
                    Text("₹")
                case .comfortable:
                    Image(systemName: "sparkles")
                case .safest:
                    Image(systemName: "shield.fill")
                }
            }
            .font(.raahaCaption2)
            .frame(width: 12, height: 12)

            Text(kind.title)
                .font(.raahaFootnoteSemibold)
        }
        .foregroundStyle(kind == .cheapest ? Color.midnightBlue : Color.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(badgeFill(for: kind))
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.35), lineWidth: 0.8)
                )
        )
    }

    private func badgeFill(for kind: RouteKind) -> Color {
        switch kind {
        case .fastest: return Color.electricBlue
        case .cheapest: return Color.neonLime
        case .comfortable: return Color.brightBlue
        case .safest: return Color(hex: 0x10B981)
        }
    }
}

struct LightingTag: View {
    let lighting: Lighting

    var body: some View {
        let lit = lighting == .wellLit

        HStack(spacing: 4) {
            Image(systemName: lit ? "lightbulb.fill" : "lightbulb.slash")
            Text(lit ? "Well lit" : "Not well lit")
        }
        .font(.raahaCaption2)
        .foregroundStyle(lit ? Color.midnightBlue : Color.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 3.5)
        .background(
            Capsule()
                .fill(lit ? Color.neonLime : Color.strawberry)
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.3), lineWidth: 0.8)
                )
        )
    }
}

struct DashedVLine: View {
    var color: Color = Color.lightSkyBlue.opacity(0.55)

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: proxy.size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
        }
        .frame(width: 2)
    }
}

struct HairlineDivider: View {
    var color: Color = Color(hex: 0x49769F).opacity(0.20)

    var body: some View {
        Rectangle().fill(color).frame(height: 1)
    }
}

// MARK: - Slide to Start Live Journey Slider

struct SlideToStartJourneyButton: View {
    var title: String = "Start Live Journey"
    let action: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var hasTriggered: Bool = false

    private let height: CGFloat = 62
    private let knobSize: CGFloat = 52
    private let padding: CGFloat = 5

    var body: some View {
        GeometryReader { proxy in
            let trackWidth = proxy.size.width
            let maxDrag = max(0, trackWidth - knobSize - (padding * 2))
            let progress = maxDrag > 0 ? (dragOffset / maxDrag) : 0
            let textOpacity = max(0.0, 1.0 - Double(progress) * 1.6)

            ZStack(alignment: .leading) {

                // 1. Frosted Glass Capsule Track
                Capsule()
                    .fill(Color.white.opacity(0.55))
                    .background(.regularMaterial, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.80),
                                        Color(hex: 0x7BBDE8).opacity(0.30)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(
                        color: Color(hex: 0x49769F).opacity(0.25),
                        radius: 14,
                        x: 0,
                        y: 6
                    )

                // 2. Progressive Oceanic Colour Fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: 0x7BBDE8).opacity(0.75),
                                Color(hex: 0x4E8EA2).opacity(0.65)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(
                            knobSize + padding * 2,
                            dragOffset + knobSize + padding * 2
                        )
                    )

                // 3. Center Label and Trailing Chevrons
                HStack {
                    Spacer(minLength: knobSize + padding + 8)

                    Text(title)
                        .font(.system(size: 16.5, weight: .bold))
                        .foregroundStyle(Color.honeydew)
                        .opacity(textOpacity)

                    Spacer(minLength: 8)

                    HStack(spacing: 4) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.electricBlue.opacity(0.45))

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.electricBlue.opacity(0.70))

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.electricBlue)
                    }
                    .padding(.trailing, 22)
                    .opacity(textOpacity)
                }

                // 4. Draggable Circular Knob
                ZStack {
                    Circle()
                        .fill(
                            progress > 0.85
                                ? LinearGradient.raahaNeonPill
                                : LinearGradient.raahaPill
                        )
                        .frame(width: knobSize, height: knobSize)
                        .overlay(
                            Circle().stroke(
                                Color.white.opacity(0.65),
                                lineWidth: 1.2
                            )
                        )
                        .shadow(
                            color: Color.electricBlue.opacity(
                                isDragging ? 0.45 : 0.25
                            ),
                            radius: isDragging ? 14 : 8,
                            x: 0,
                            y: isDragging ? 5 : 3
                        )
                        .scaleEffect(isDragging ? 1.07 : 1.0)
                        .animation(
                            .spring(response: 0.25, dampingFraction: 0.65),
                            value: isDragging
                        )

                    Image(systemName: progress > 0.85 ? "checkmark" : "chevron.right")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(
                            progress > 0.85 ? Color.midnightBlue : Color.white
                        )
                        .contentTransition(.symbolEffect(.replace))
                }
                .offset(x: padding + dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard !hasTriggered else { return }

                            isDragging = true

                            dragOffset = min(
                                max(0, value.translation.width),
                                maxDrag
                            )
                        }
                        .onEnded { value in
                            guard !hasTriggered else { return }

                            isDragging = false

                            if dragOffset >= maxDrag * 0.70 {
                                hasTriggered = true

                                withAnimation(
                                    .spring(response: 0.22, dampingFraction: 0.75)
                                ) {
                                    dragOffset = maxDrag
                                }

                                triggerHapticSuccess()
                                action()

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    hasTriggered = false

                                    withAnimation(
                                        .spring(response: 0.35, dampingFraction: 0.75)
                                    ) {
                                        dragOffset = 0
                                    }
                                }
                            } else {
                                withAnimation(
                                    .spring(response: 0.35, dampingFraction: 0.72)
                                ) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
            .frame(height: height)
            .clipShape(Capsule())
        }
        .frame(height: height)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint("Slide right or double-tap to start live journey")
        .accessibilityAction {
            guard !hasTriggered else { return }
            hasTriggered = true
            triggerHapticSuccess()
            action()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                hasTriggered = false
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    dragOffset = 0
                }
            }
        }
    }

    private func triggerHapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

import SwiftUI
import UIKit

// MARK: - RAAHA Journey Ignition Slider

struct JourneyIgnitionSlider: View {

    let action: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var hasTriggered = false
    @State private var ignitionRotation: Double = 0

    private let thumbSize: CGFloat = 52
    private let sliderHeight: CGFloat = 68

    private let navy = Color(hex: 0x001D39)
    private let blue = Color(hex: 0x0A4174)
    private let glow = Color(hex: 0x7BBDE8)

    var body: some View {

        GeometryReader { geometry in

            let maxDrag = max(
                geometry.size.width - thumbSize - 12,
                0
            )

            let progress = maxDrag > 0
                ? min(dragOffset / maxDrag, 1)
                : 0

            ZStack(alignment: .leading) {

                // Background track
                Capsule()
                    .fill(Color.white.opacity(0.65))
                    .overlay(
                        Capsule()
                            .stroke(
                                Color.white.opacity(0.75),
                                lineWidth: 1.2
                            )
                    )

                // Glowing progress track
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                blue,
                                glow,
                                navy
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: min(
                            dragOffset + thumbSize + 12,
                            geometry.size.width
                        )
                    )
                    .shadow(
                        color: glow.opacity(isDragging ? 0.65 : 0.2),
                        radius: isDragging ? 12 : 4
                    )

                // Slider label
                HStack {
                    Spacer()

                    VStack(spacing: 2) {

                        Text(
                            hasTriggered
                            ? "Journey Ignited!"
                            : "Slide to start your journey"
                        )
                        .font(.system(
                            size: 14,
                            weight: .semibold,
                            design: .rounded
                        ))
                        .foregroundStyle(
                            hasTriggered || progress > 0.55
                            ? .white
                            : navy
                        )

//                        if !hasTriggered {
//                            Text("Your next adventure awaits")
//                                .font(.system(size: 10))
//                                .foregroundStyle(
//                                    progress > 0.55
//                                    ? Color.white.opacity(0.8)
//                                    : navy.opacity(0.55)
//                                )
//                        }
                    }

                    Spacer()
                }
                .opacity(isDragging ? 0.75 : 1)

                // Ignition thumb
                ZStack {

                    // Outer glow
                    Circle()
                        .fill(glow.opacity(0.22))
                        .frame(width: 66, height: 66)
                        .blur(radius: 9)
                        .opacity(isDragging || hasTriggered ? 1 : 0)

                    // Rotating ignition ring
                    Circle()
                        .trim(from: 0, to: max(progress, 0.02))
                        .stroke(
                            AngularGradient(
                                colors: [
                                    glow,
                                    .white,
                                    blue,
                                    glow
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(
                                lineWidth: 3,
                                lineCap: .round
                            )
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(
                            .degrees(ignitionRotation)
                        )

                    // Thumb background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    navy,
                                    blue
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(
                            width: thumbSize,
                            height: thumbSize
                        )
                        .shadow(
                            color: navy.opacity(0.3),
                            radius: 7,
                            x: 0,
                            y: 3
                        )

                    // Arrow changes into checkmark
                    Image(
                        systemName: hasTriggered
                        ? "checkmark"
                        : "arrow.right"
                    )
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
                    .contentTransition(.symbolEffect(.replace))
                }
                .scaleEffect(
                    hasTriggered ? 1.22 : (isDragging ? 1.10 : 1)
                )
                .offset(
                    x: 6 + dragOffset,
                    y: hasTriggered ? -5 : 0
                )
                .shadow(
                    color: glow.opacity(isDragging ? 0.6 : 0),
                    radius: 15
                )
                .gesture(

                    DragGesture(minimumDistance: 0)

                        .onChanged { value in

                            guard !hasTriggered else { return }

                            isDragging = true

                            dragOffset = min(
                                max(0, value.translation.width),
                                maxDrag
                            )

                            ignitionRotation =
                                Double(progress * 360)
                        }

                        .onEnded { _ in

                            guard !hasTriggered else { return }

                            isDragging = false

                            if dragOffset >= maxDrag * 0.70 {

                                hasTriggered = true

                                withAnimation(
                                    .spring(
                                        response: 0.28,
                                        dampingFraction: 0.55
                                    )
                                ) {
                                    dragOffset = maxDrag
                                }

                                UINotificationFeedbackGenerator()
                                    .notificationOccurred(.success)

                                action()

                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 0.8
                                ) {

                                    withAnimation(
                                        .spring(
                                            response: 0.4,
                                            dampingFraction: 0.72
                                        )
                                    ) {

                                        dragOffset = 0
                                        hasTriggered = false
                                        ignitionRotation = 0
                                    }
                                }

                            } else {

                                withAnimation(
                                    .spring(
                                        response: 0.4,
                                        dampingFraction: 0.72
                                    )
                                ) {

                                    dragOffset = 0
                                    ignitionRotation = 0
                                }
                            }
                        }
                )
            }
        }
        .frame(height: sliderHeight)
    }
}

