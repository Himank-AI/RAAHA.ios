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
            .clipShape(Capsule())
            .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.72), value: configuration.isPressed)
    }

    private var textColor: Color {
        switch kind {
        case .light: return Color.deepSpace
        case .dark, .accent: return Color.honeydew
        }
    }

    private var shadowColor: Color {
        switch kind {
        case .light: return Color.deepSpace.opacity(0.12)
        case .dark: return Color.deepSpace.opacity(0.24)
        case .accent: return Color.strawberry.opacity(0.32)
        }
    }

    @ViewBuilder
    private var surface: some View {
        switch kind {
        case .light:  LinearGradient.raahaPill
        case .dark:   Color.deepSpace
        case .accent: Color.strawberry
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

/// A circular badge with a transport glyph.
struct ModeBadge: View {
    let mode: TransportMode
    var size: CGFloat = 40
    var fill: Color = Color.honeydew
    var tint: Color = Color.deepSpace

    var body: some View {
        ZStack {
            Circle().fill(fill)
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
    var fill: Color = Color.frostedBlue
    var tint: Color = Color.deepSpace

    var body: some View {
        Text(text)
            .font(.raahaFootnoteSemibold)
            .foregroundStyle(tint)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(fill))
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
                .foregroundStyle(Color.deepSpace)
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
                    .foregroundStyle(Color.steelBlue)
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
                case .cheapest:    Text("₹")
                case .comfortable: Image(systemName: "sparkles")
                case .safest:      Image(systemName: "shield.fill")
                }
            }
            .font(.raahaCaption2)
            .frame(width: 12, height: 12)

            Text(kind.title)
                .font(.raahaFootnoteSemibold)
        }
        .foregroundStyle(kind.badgeText)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(kind.badgeFill))
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
        .foregroundStyle(lit ? Color.statusGreen : Color(hex: 0x9B1C28))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Capsule().fill(lit ? Color(hex: 0xD8F5E3) : Color(hex: 0xFAD7DA)))
    }
}

struct DashedVLine: View {
    var color: Color = Color.frostedBlue.opacity(0.65)

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
    var color: Color = Color.frostedBlue.opacity(0.22)

    var body: some View {
        Rectangle().fill(color).frame(height: 1)
    }
}

// MARK: - Slide to Start Live Journey Slider Button

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
                // 1. Dark capsule track (Deep Space Blue with subtle gradient)
                Capsule()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.deepSpace, location: 0.0),
                                .init(color: Color(hex: 0x142B46), location: 0.50),
                                .init(color: Color.deepSpace, location: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.frostedBlue.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(color: Color.deepSpace.opacity(0.25), radius: 10, x: 0, y: 5)

                // 2. Active fill highlight behind the knob as it slides
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: 0x2A9D8F).opacity(0.35),
                                Color(hex: 0x4FB8A6).opacity(0.12)
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
                        .font(.system(size: 16.5, weight: .semibold))
                        .foregroundStyle(Color.honeydew)
                        .opacity(textOpacity)

                    Spacer(minLength: 8)

                    // Three progressive trailing chevrons (>>>) like inspiration image
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.frostedBlue.opacity(0.30))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.frostedBlue.opacity(0.60))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.frostedBlue.opacity(0.95))
                    }
                    .padding(.trailing, 22)
                    .opacity(textOpacity)
                }

                // 4. Draggable Circular Knob with Chevron
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.honeydew,
                                    Color(hex: 0xDDF0E4)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: knobSize, height: knobSize)
                        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 2, y: 0)

                    Image(systemName: progress > 0.85 ? "checkmark" : "chevron.right")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(Color.deepSpace)
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
                                // Successful slide to confirm
                                hasTriggered = true
                                withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                                    dragOffset = maxDrag
                                }
                                triggerHapticSuccess()
                                action()

                                // Reset back after animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    hasTriggered = false
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        dragOffset = 0
                                    }
                                }
                            } else {
                                // Snap back to start position
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint("Slide right or double-tap to start live journey")
        .accessibilityAction {
            action()
        }
    }

    private func triggerHapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

