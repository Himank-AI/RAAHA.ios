import SwiftUI

// MARK: - Colour palette (strictly the five RAAHA brand colours + one status green)

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    /// Strawberry Red  #E63946 – accents, alerts, selected segment
    static let strawberry = Color(hex: 0xE63946)
    /// Honeydew  #F1FAEE – light surfaces, text on navy
    static let honeydew = Color(hex: 0xF1FAEE)
    /// Frosted Blue  #A8DADC – secondary text on navy, chips
    static let frostedBlue = Color(hex: 0xA8DADC)
    /// Steel Blue  #457B9D – secondary text on light, icon fills
    static let steelBlue = Color(hex: 0x457B9D)
    /// Deep Space Blue  #1D3557 – headers, cards, primary text
    static let deepSpace = Color(hex: 0x1D3557)

    /// Teal Green  #2A9D8F – Cheapest badge fill.
    static let tealGreen = Color(hex: 0x2A9D8F)
    /// Safe Green  #16866A – Safest badge fill, arrival state.
    static let statusGreen = Color(hex: 0x16866A)
}

// MARK: - Typography (SF Pro via the system font, Dynamic Type text styles)

extension Font {
    static let raahaLargeTitle = Font.system(.largeTitle, weight: .bold)
    static let raahaTitle = Font.system(.title, weight: .bold)
    static let raahaTitle2 = Font.system(.title2, weight: .bold)
    static let raahaTitle3 = Font.system(.title3, weight: .semibold)
    static let raahaHeadline = Font.system(.headline, weight: .semibold)
    static let raahaBody = Font.system(.body)
    static let raahaSubheadline = Font.system(.subheadline)
    static let raahaSubheadlineMedium = Font.system(.subheadline, weight: .medium)
    static let raahaFootnote = Font.system(.footnote)
    static let raahaFootnoteSemibold = Font.system(.footnote, weight: .semibold)
    static let raahaCaption = Font.system(.caption)
    static let raahaCaption2 = Font.system(.caption2)
}

// MARK: - Gradients

extension LinearGradient {
    /// Page background under navy headers: frosted blue fading into honeydew.
    static let raahaScreen = LinearGradient(
        colors: [Color.frostedBlue.opacity(0.9), Color.honeydew],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Large "hero" card: steel blue glow top-leading into deep navy.
    static let raahaHero = LinearGradient(
        stops: [
            .init(color: Color.steelBlue, location: 0),
            .init(color: Color.deepSpace, location: 0.72)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Banner card: navy on the leading edge into steel blue.
    static let raahaBanner = LinearGradient(
        stops: [
            .init(color: Color.deepSpace, location: 0.2),
            .init(color: Color.steelBlue, location: 1)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Flat navy card with a faint steel glow (route steps, live cards).
    static let raahaNavy = LinearGradient(
        colors: [Color.deepSpace, Color(hex: 0x1A3D62)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Navy card that picks up steel blue from the leading edge.
    static let raahaNavyGlow = LinearGradient(
        stops: [
            .init(color: Color.steelBlue.opacity(0.75), location: 0),
            .init(color: Color.deepSpace, location: 0.45)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Honeydew pill button surface.
    static let raahaPill = LinearGradient(
        colors: [Color.honeydew, Color(hex: 0xDDEBDF)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Surfaces

extension View {
    /// Rounded navy (or gradient) card with the soft RAAHA shadow.
    func navyCard(
        radius: CGFloat = 24,
        gradient: LinearGradient = .raahaNavy
    ) -> some View {
        self
            .background(gradient, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: Color.deepSpace.opacity(0.18), radius: 12, x: 0, y: 6)
    }

    /// Rounded honeydew card.
    func lightCard(radius: CGFloat = 22) -> some View {
        self
            .background(Color.honeydew, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: Color.deepSpace.opacity(0.08), radius: 10, x: 0, y: 4)
    }

    /// Floating-bar glass. Uses Liquid Glass on iOS 26+, material on earlier versions.
    @ViewBuilder
    func glassCapsule() -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            self
                .background(Capsule().fill(Color.honeydew.opacity(0.45)))
                .glassEffect(.regular, in: Capsule())
        } else {
            self
                .background(.ultraThinMaterial, in: Capsule())
                .background(Capsule().fill(Color.honeydew.opacity(0.6)))
                .shadow(color: Color.deepSpace.opacity(0.15), radius: 14, x: 0, y: 6)
        }
        #else
        self
            .background(.ultraThinMaterial, in: Capsule())
            .background(Capsule().fill(Color.honeydew.opacity(0.6)))
            .shadow(color: Color.deepSpace.opacity(0.15), radius: 14, x: 0, y: 6)
        #endif
    }
}
