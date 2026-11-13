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
                Capsule()
                    .stroke(strokeColor, lineWidth: 1)
            )
            .clipShape(Capsule())
            .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }

    private var textColor: Color {
        switch kind {
        case .light: return Color.white
        case .dark: return Color.white
        case .accent: return Color(hex: 0x001D39) // High contrast dark text on Neon Lime
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
            .animation(.spring(response: 0.22, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

/// Label for dark pills that carry a trailing chevron ("Save Trip ›").
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

// MARK: - Small building blocks

/// A circular badge with a dedicated transport glyph and mode-tinted circular background.
struct ModeBadge: View {
    let mode: TransportMode
    var size: CGFloat = 40
    var fill: Color? = nil
    var tint: Color? = nil

    var body: some View {
        let badgeTint = tint ?? mode.color
        let badgeFill = fill ?? mode.tintedBackground

        ZStack {
            Circle()
                .fill(badgeFill)
                .background(.regularMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(tint != nil ? Color(hex: 0x7BBDE8).opacity(0.40) : mode.strokeColor, lineWidth: 1)
                )
                .shadow(color: (tint != nil ? Color(hex: 0x49769F) : mode.color).opacity(0.18), radius: 6, x: 0, y: 3)

            glyph
                .foregroundStyle(badgeTint)
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
                        Capsule()
                            .stroke(Color(hex: 0x7BBDE8).opacity(0.40), lineWidth: 0.8)
                    )
            )
            .shadow(color: Color(hex: 0x49769F).opacity(0.15), radius: 4, x: 0, y: 2)
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
                        if showsChevron { Image(systemName: "chevron.right").font(.raahaCaption2) }
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
                case .fastest:     Image(systemName: "bolt.fill")
                case .cheapest:    Image(systemName: "indianrupeesign")
                case .comfortable: Image(systemName: "sparkles")
                case .safest:      Image(systemName: "shield.fill")
                }
            }
            .font(.system(size: 11, weight: .bold))
            .frame(width: 12, height: 12)

            Text(kind.title)
                .font(.raahaFootnoteSemibold)
        }
        .foregroundStyle(kind == .comfortable ? Color(hex: 0x1D3557) : Color.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(badgeFill(for: kind))
                .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 0.8))
        )
    }

    private func badgeFill(for kind: RouteKind) -> Color {
        switch kind {
        case .fastest:     return Color(hex: 0x457B9D)
        case .cheapest:    return Color(hex: 0x299D8F)
        case .comfortable: return Color(hex: 0xA8DADC)
        case .safest:      return Color(hex: 0x18866B)
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
        .foregroundStyle(lit ? Color(hex: 0x0A4174) : Color.strawberry)
        .padding(.horizontal, 9)
        .padding(.vertical, 3.5)
        .background(
            Capsule()
                .fill(lit ? Color(hex: 0x7BBDE8).opacity(0.25) : Color.strawberry.opacity(0.20))
                .overlay(Capsule().stroke(lit ? Color(hex: 0x4E8EA2).opacity(0.35) : Color.strawberry.opacity(0.35), lineWidth: 0.8))
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

// MARK: - Slide to Start Live Journey Slider Button (Frosted Glassmorphism with Neon Lime Finish)

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
                                    colors: [Color.white.opacity(0.80), Color(hex: 0x7BBDE8).opacity(0.30)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: Color(hex: 0x49769F).opacity(0.25), radius: 14, x: 0, y: 6)

                // 2. Active fill highlight behind the knob as it slides
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: 0x7BBDE8).opacity(0.40),
                                Color(hex: 0x4E8EA2).opacity(0.30)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(knobSize + padding * 2, dragOffset + knobSize + padding * 2))

                // 3. Center Label & Trailing Chevrons
                HStack {
                    Spacer(minLength: knobSize + padding + 8)

                    Text(title)
                        .font(.system(size: 16.5, weight: .bold))
                        .foregroundStyle(Color.midnightBlue)
                        .opacity(textOpacity)

                    Spacer(minLength: 8)

                    // Three progressive trailing chevrons (>>>) in oceanic tones
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(hex: 0x4E8EA2).opacity(0.35))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(hex: 0x4E8EA2).opacity(0.70))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(hex: 0x0A4174))
                    }
                    .padding(.trailing, 22)
                    .opacity(textOpacity)
                }

                // 4. Draggable Circular Knob with Chevron
                ZStack {
                    Circle()
                        .fill(
                            progress > 0.85
                                ? LinearGradient(colors: [Color(hex: 0x299D8F), Color(hex: 0x18866B)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient.raahaPill
                        )
                        .frame(width: knobSize, height: knobSize)
                        .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1.2))
                        .shadow(color: Color(hex: 0x0A4174).opacity(0.35), radius: 8, x: 2, y: 3)

                    Image(systemName: progress > 0.85 ? "checkmark" : "chevron.right")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(Color.white)
                        .contentTransition(.symbolEffect(.replace))
                }
                .offset(x: padding + dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard !hasTriggered else { return }
                            isDragging = true
                            dragOffset = min(max(0, value.translation.width), maxDrag)
                        }
                        .onEnded { value in
                            guard !hasTriggered else { return }
                            isDragging = false
                            if dragOffset >= maxDrag * 0.70 {
                                hasTriggered = true
                                withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                                    dragOffset = maxDrag
                                }
                                action()

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    hasTriggered = false
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        dragOffset = 0
                                    }
                                }
                            } else {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
            .frame(height: height)
        }
        .frame(height: height)
        .sensoryFeedback(.success, trigger: hasTriggered) { _, newValue in newValue == true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint("Slide right or double-tap to start live journey")
        .accessibilityAction {
            action()
        }
    }
}
