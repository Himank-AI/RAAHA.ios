import SwiftUI

struct RouteModeChain: View {
    let modes: [TransportMode]
    var diameter: CGFloat = 28

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(modes.enumerated()), id: \.offset) { index, mode in
                if index > 0 {
                    connector(from: modes[index - 1], to: mode)
                }
                ZStack {
                    Circle()
                        .fill(mode.tintedBackground)
                        .background(.regularMaterial, in: Circle())
                        .frame(width: diameter, height: diameter)
                        .overlay(Circle().stroke(mode.strokeColor, lineWidth: 1))
                        .shadow(color: mode.color.opacity(0.16), radius: 4, x: 0, y: 1.5)

                    ModeGlyph(mode: mode)
                        .foregroundStyle(mode.color)
                        .frame(width: diameter * 0.5, height: diameter * 0.5)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(modes.map(\.title).joined(separator: ", "))
    }

    private func connector(from previous: TransportMode, to next: TransportMode) -> some View {
        HStack(spacing: 2) {
            Circle().fill(previous.color.opacity(0.60)).frame(width: 2.5, height: 2.5)
            Circle().fill(Color.steelBlue.opacity(0.40)).frame(width: 2.5, height: 2.5)
            Circle().fill(next.color.opacity(0.60)).frame(width: 2.5, height: 2.5)
        }
        .padding(.horizontal, 3)
    }
}

private struct SelectedCardFill: View {
    let isSelected: Bool
    let lift: CGFloat

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
    }

    var body: some View {
        if isSelected {
            selectedFill
        } else {
            shape
                .fill(Color.white.opacity(0.55))
                .background(.thinMaterial, in: shape)
        }
    }

    @ViewBuilder
    private var selectedFill: some View {
        let tint = Color(hex: 0x7BBDE8).opacity(0.22 + 0.16 * lift)
        ZStack {
            if #available(iOS 26.0, *) {
                shape.fill(Color.white.opacity(0.16))
                    .glassEffect(Glass.regular.tint(tint).interactive(lift > 0.35), in: shape)
            } else {
                shape.fill(.ultraThinMaterial)
                shape.fill(Color.white.opacity(0.30))
            }
            shape.fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.16 + 0.28 * lift), Color.white.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .center
                )
            )
        }
    }
}

struct AnimatedRouteCard: View {
    let option: RouteOption
    let isSelected: Bool
    var dim: CGFloat
    var lift: CGFloat
    var fadeIntoSummary: CGFloat
    var reduceMotion: Bool
    var blurUnselected: Bool
    var namespace: Namespace.ID
    var ownsGeometry: Bool
    let action: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            cardBody
        }
        .buttonStyle(TactileButtonStyle())
        .scaleEffect(cardScale, anchor: .center)
        .offset(y: yOffset)
        .opacity(cardOpacity)
        .blur(radius: blurRadius)
        .modifier(RouteMatchedGeometry(active: ownsGeometry, namespace: namespace))
        .zIndex(isSelected ? 1 : 0)
        .allowsHitTesting(dim < 0.85 && fadeIntoSummary < 0.5)
        .accessibilityHidden(dim > 0.85 || fadeIntoSummary > 0.85)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(option.kind.title), \(option.minutes) minutes, \(option.fareText)\(isSelected ? ", Selected" : "")")
        .accessibilityHint("Shows this route on the map")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                RouteBadge(kind: option.kind)
                Spacer()
                selectionIndicator
            }

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("Est.")
                            .font(.raahaFootnote)
                            .foregroundStyle(Color.steelBlue.opacity(0.85))
                        Text("\(option.minutes) min")
                            .font(.raahaTitle3)
                            .foregroundStyle(Color.deepSpace)
                    }
                    .lineLimit(1)

                    RouteModeChain(modes: option.chain)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 3) {
                    Text("Est. Cost")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.steelBlue.opacity(0.85))
                    Text(option.fareText)
                        .font(.raahaTitle3.weight(.bold))
                        .foregroundStyle(Color.deepSpace)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { SelectedCardFill(isSelected: isSelected, lift: lift) }
        .overlay { cardStroke }
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
        .shadow(color: Color.cyan.opacity(glowOpacity), radius: 16, x: 0, y: 0)
    }

    private var shadowColor: Color {
        isSelected ? Color(hex: 0x4E8EA2).opacity(0.20 + 0.26 * lift) : Color.steelBlue.opacity(0.14)
    }

    private var shadowRadius: CGFloat {
        isSelected ? 10 + 12 * lift : 6
    }

    private var shadowY: CGFloat {
        isSelected ? 4 + 6 * lift : 2
    }

    private var glowOpacity: Double {
        isSelected ? 0.20 * lift : 0
    }

    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.transportMetro : Color.clear)
                .overlay(
                    Circle()
                        .stroke(Color.steelBlue.opacity(isSelected ? 0 : 0.40), lineWidth: 1.5)
                )
                .frame(width: 24, height: 24)

            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(Color.white)
                .scaleEffect(isSelected ? 1 : 0.2)
                .opacity(isSelected ? 1 : 0)
                .symbolEffect(.bounce, value: isSelected)
        }
        .scaleEffect(isSelected ? 1 : 0.94)
        .animation(RouteSelectionTransition.checkSpring(reduceMotion: reduceMotion), value: isSelected)
        .accessibilityHidden(true)
    }

    private var cardStroke: some View {
        shape.stroke(
            LinearGradient(
                colors: isSelected
                    ? [
                        Color.white.opacity(0.98),
                        Color(hex: 0x7BBDE8).opacity(0.95),
                        Color.cyan.opacity(0.45 + 0.35 * lift),
                        Color.white.opacity(0.45)
                    ]
                    : [
                        Color.white.opacity(0.80),
                        Color(hex: 0xBDD8E9).opacity(0.50)
                    ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: isSelected ? 1.6 : 1
        )
    }

    private var cardScale: CGFloat {
        if reduceMotion { return 1 }
        if isSelected { return 1.018 + 0.028 * lift }
        return 1 - 0.055 * dim
    }

    private var yOffset: CGFloat {
        if reduceMotion { return 0 }
        if isSelected { return -7 * lift }
        return 12 * dim
    }

    private var cardOpacity: Double {
        if isSelected { return Double(1 - fadeIntoSummary) }
        return Double(1 - dim)
    }

    private var blurRadius: CGFloat {
        guard blurUnselected, !reduceMotion, !isSelected else { return 0 }
        return 1.4 * dim
    }
}
