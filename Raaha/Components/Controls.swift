import SwiftUI

// MARK: - Buttons

struct PillButtonStyle: ButtonStyle {
    enum Kind { case light, dark }
    var kind: Kind = .light

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.raahaHeadline)
            .foregroundStyle(kind == .light ? Color.deepSpace : Color.honeydew)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(surface)
            .clipShape(Capsule())
            .shadow(color: Color.deepSpace.opacity(kind == .light ? 0.18 : 0.25), radius: 8, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    @ViewBuilder
    private var surface: some View {
        if kind == .light {
            LinearGradient.raahaPill
        } else {
            Color.deepSpace
        }
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    static var pillLight: PillButtonStyle { PillButtonStyle(kind: .light) }
    static var pillDark: PillButtonStyle { PillButtonStyle(kind: .dark) }
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
