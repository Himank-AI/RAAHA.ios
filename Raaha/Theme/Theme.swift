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

    /// RAAHA fluid calm motion background with subtle low-opacity organic waves.
    func raahaScreenBackground() -> some View {
        self.background(RaahaScreenBackground())
    }
}

// MARK: - Fluid Calm Motion Screen Background

struct RaahaScreenBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                // 1. Base Calm Motion screen gradient
                LinearGradient(
                    stops: [
                        .init(color: Color.frostedBlue.opacity(0.85), location: 0.0),
                        .init(color: Color.honeydew.opacity(0.95), location: 0.55),
                        .init(color: Color.honeydew, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // 2. Primary upper flowing wave (sweeping from top-right across center)
                Path { p in
                    p.move(to: CGPoint(x: w * 0.42, y: 0))
                    p.addCurve(
                        to: CGPoint(x: w, y: h * 0.38),
                        control1: CGPoint(x: w * 0.62, y: h * 0.12),
                        control2: CGPoint(x: w * 0.84, y: h * 0.22)
                    )
                    p.addLine(to: CGPoint(x: w, y: 0))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: 0x2A9D8F).opacity(0.11), location: 0.0),
                            .init(color: Color.steelBlue.opacity(0.07), location: 0.6),
                            .init(color: Color.frostedBlue.opacity(0.01), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // 3. Signature fluid ribbon wave (flowing down through mid-screen)
                Path { p in
                    p.move(to: CGPoint(x: w * 0.86, y: h * 0.08))
                    p.addCurve(
                        to: CGPoint(x: w * 0.16, y: h * 0.64),
                        control1: CGPoint(x: w * 0.94, y: h * 0.32),
                        control2: CGPoint(x: w * 0.34, y: h * 0.48)
                    )
                    p.addCurve(
                        to: CGPoint(x: w * 0.32, y: h),
                        control1: CGPoint(x: w * 0.06, y: h * 0.76),
                        control2: CGPoint(x: w * 0.18, y: h * 0.92)
                    )
                    p.addLine(to: CGPoint(x: w * 0.44, y: h))
                    p.addCurve(
                        to: CGPoint(x: w * 0.28, y: h * 0.66),
                        control1: CGPoint(x: w * 0.30, y: h * 0.92),
                        control2: CGPoint(x: w * 0.18, y: h * 0.78)
                    )
                    p.addCurve(
                        to: CGPoint(x: w * 0.96, y: h * 0.08),
                        control1: CGPoint(x: w * 0.46, y: h * 0.50),
                        control2: CGPoint(x: w * 1.02, y: h * 0.32)
                    )
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: 0x4FB8A6).opacity(0.12), location: 0.0),
                            .init(color: Color(hex: 0x2A8C8E).opacity(0.08), location: 0.45),
                            .init(color: Color.steelBlue.opacity(0.05), location: 0.8),
                            .init(color: Color.frostedBlue.opacity(0.0), location: 1.0)
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )

                // 4. Secondary lower-screen ambient wave
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h * 0.52))
                    p.addCurve(
                        to: CGPoint(x: w * 0.82, y: h),
                        control1: CGPoint(x: w * 0.22, y: h * 0.64),
                        control2: CGPoint(x: w * 0.52, y: h * 0.88)
                    )
                    p.addLine(to: CGPoint(x: 0, y: h))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.steelBlue.opacity(0.07), location: 0.0),
                            .init(color: Color(hex: 0x2A9D8F).opacity(0.04), location: 0.5),
                            .init(color: Color.clear, location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // 5. Delicate accent crest along the right edge
                Path { p in
                    p.move(to: CGPoint(x: w, y: h * 0.58))
                    p.addCurve(
                        to: CGPoint(x: w * 0.58, y: h),
                        control1: CGPoint(x: w * 0.80, y: h * 0.74),
                        control2: CGPoint(x: w * 0.68, y: h * 0.88)
                    )
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: 0x45A399).opacity(0.07), location: 0.0),
                            .init(color: Color.clear, location: 1.0)
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

