
import SwiftUI

// MARK: - Colour Palette

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

    // MARK: - Oceanic Gradient (7 Colours)

    static let oceanic001D39 = Color(hex: 0x001D39)
    static let oceanic0A4174 = Color(hex: 0x0A4174)
    static let oceanic49769F = Color(hex: 0x49769F)
    static let oceanic4E8EA2 = Color(hex: 0x4E8EA2)
    static let oceanic6EA2B3 = Color(hex: 0x6EA2B3)
    static let oceanic7BBDE8 = Color(hex: 0x7BBDE8)
    static let oceanicBDD8E9 = Color(hex: 0xBDD8E9)

    // MARK: - Semantic Brand Colours

    static let midnightBlue = Color(hex: 0x001D39)
    static let royalBlue = Color(hex: 0x0A4174)
    static let electricBlue = Color(hex: 0x4E8EA2)
    static let brightBlue = Color(hex: 0x7BBDE8)
    static let lightSkyBlue = Color(hex: 0x49769F)
    static let icyBlue = Color(hex: 0x4E8EA2)

    static let neonLime = Color(hex: 0xC6FF00)

    static let strawberry = Color(hex: 0xFF4D5E)
    static let honeydew = Color(hex: 0x001D39)
    static let frostedBlue = Color(hex: 0x0A4174)
    static let steelBlue = Color(hex: 0x49769F)
    static let deepSpace = Color(hex: 0x001D39)

    static let tealGreen = Color(hex: 0x4E8EA2)
    static let statusGreen = Color(hex: 0xC6FF00)

    // MARK: - RAAHA Transport Colours

    /// Local Train - Railway Blue
    static let localTrain = Color(hex: 0x2878C7)

    /// Metro - Metro Purple
    static let metro = Color(hex: 0x8055B7)

    /// Bus - Traffic Red
    static let bus = Color(hex: 0xD94B45)

    /// Auto - Indian Auto Yellow
    static let auto = Color(hex: 0xE5A400)

    /// Cab / Taxi - Charcoal
    static let cab = Color(hex: 0x424B57)

    /// Walking - Nature Green
    static let walking = Color(hex: 0x29965C)

    /// Bicycle - Cycle Orange
    static let bicycle = Color(hex: 0xD97732)
}

// MARK: - Typography

extension Font {
    static let raahaLargeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let raahaTitle = Font.system(.title, design: .rounded).weight(.bold)
    static let raahaTitle2 = Font.system(.title2, design: .rounded).weight(.bold)
    static let raahaTitle3 = Font.system(.title3, design: .rounded).weight(.semibold)
    static let raahaHeadline = Font.system(.headline).weight(.semibold)
    static let raahaBody = Font.system(.body)
    static let raahaSubheadline = Font.system(.subheadline)
    static let raahaSubheadlineMedium = Font.system(.subheadline).weight(.medium)
    static let raahaFootnote = Font.system(.footnote)
    static let raahaFootnoteSemibold = Font.system(.footnote).weight(.semibold)
    static let raahaCaption = Font.system(.caption)
    static let raahaCaption2 = Font.system(.caption2)
}

// MARK: - Gradients

extension LinearGradient {

    /// Full-screen oceanic gradient.
    static let raahaScreen = LinearGradient(
        stops: [
            .init(color: Color(hex: 0xEAF4FB), location: 0.0),
            .init(color: Color(hex: 0xBDD8E9), location: 0.18),
            .init(color: Color(hex: 0x7BBDE8), location: 0.42),
            .init(color: Color(hex: 0x6EA2B3), location: 0.65),
            .init(color: Color(hex: 0x4E8EA2), location: 0.85),
            .init(color: Color(hex: 0x49769F), location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Hero card gradient.
    static let raahaHero = LinearGradient(
        stops: [
            .init(color: Color(hex: 0x7BBDE8).opacity(0.85), location: 0),
            .init(color: Color(hex: 0x4E8EA2).opacity(0.92), location: 0.50),
            .init(color: Color(hex: 0x0A4174).opacity(0.96), location: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Banner gradient.
    static let raahaBanner = LinearGradient(
        stops: [
            .init(color: Color(hex: 0x7BBDE8), location: 0.0),
            .init(color: Color(hex: 0x4E8EA2), location: 1.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Frosted glass gradient.
    static let raahaNavy = LinearGradient(
        colors: [
            Color(hex: 0x7BBDE8).opacity(0.30),
            Color(hex: 0x4E8EA2).opacity(0.50)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Glowing oceanic card gradient.
    static let raahaNavyGlow = LinearGradient(
        stops: [
            .init(color: Color(hex: 0xBDD8E9).opacity(0.55), location: 0.0),
            .init(color: Color(hex: 0x7BBDE8).opacity(0.45), location: 0.35),
            .init(color: Color(hex: 0x4E8EA2).opacity(0.70), location: 1.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Oceanic pill gradient.
    static let raahaPill = LinearGradient(
        colors: [
            Color(hex: 0x4E8EA2),
            Color(hex: 0x0A4174)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Neon Lime pill gradient.
    static let raahaNeonPill = LinearGradient(
        colors: [
            Color(hex: 0xD8FF33),
            Color.neonLime
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Glass edge highlight.
    static let glassRim = LinearGradient(
        colors: [
            Color.white.opacity(0.80),
            Color(hex: 0xBDD8E9).opacity(0.50),
            Color(hex: 0x7BBDE8).opacity(0.25),
            Color.white.opacity(0.10)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Surfaces (Frosted Glassmorphism)

extension View {

    /// Frosted glass card.
    func navyCard(
        radius: CGFloat = 24,
        gradient: LinearGradient = .raahaNavy
    ) -> some View {
        self
            .background(
                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .fill(Color.white.opacity(0.55))
                .background(
                    .regularMaterial,
                    in: RoundedRectangle(
                        cornerRadius: radius,
                        style: .continuous
                    )
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .stroke(
                    LinearGradient.glassRim,
                    lineWidth: 1.2
                )
            )
            .shadow(
                color: Color(hex: 0x49769F).opacity(0.22),
                radius: 16,
                x: 0,
                y: 6
            )
    }

    /// Lighter frosted glass card.
    func lightCard(radius: CGFloat = 22) -> some View {
        self
            .background(
                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .fill(Color.white.opacity(0.65))
                .background(
                    .regularMaterial,
                    in: RoundedRectangle(
                        cornerRadius: radius,
                        style: .continuous
                    )
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.90),
                            Color(hex: 0x7BBDE8).opacity(0.45),
                            Color(hex: 0xBDD8E9).opacity(0.20)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
            )
            .shadow(
                color: Color(hex: 0x4E8EA2).opacity(0.18),
                radius: 12,
                x: 0,
                y: 5
            )
    }

    /// Floating glass capsule.
    @ViewBuilder
    func glassCapsule() -> some View {
        self
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.72))
                    .background(.regularMaterial, in: Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.90),
                                Color(hex: 0x7BBDE8).opacity(0.40),
                                Color(hex: 0xBDD8E9).opacity(0.20)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(
                color: Color(hex: 0x49769F).opacity(0.30),
                radius: 18,
                x: 0,
                y: 8
            )
    }

    /// RAAHA screen background.
    func raahaScreenBackground() -> some View {
        self.background(RaahaScreenBackground())
    }
}

// MARK: - Light Oceanic Background

struct RaahaScreenBackground: View {

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {

                // 1. Base gradient
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: 0xEAF4FB), location: 0.0),
                        .init(color: Color(hex: 0xBDD8E9), location: 0.20),
                        .init(color: Color(hex: 0x7BBDE8), location: 0.45),
                        .init(color: Color(hex: 0x6EA2B3), location: 0.68),
                        .init(color: Color(hex: 0x4E8EA2), location: 0.88),
                        .init(color: Color(hex: 0x49769F), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // 2. Upper-left sunlight bloom
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.70),
                                Color(hex: 0xBDD8E9).opacity(0.40),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: w * 0.65
                        )
                    )
                    .frame(width: w * 1.1, height: w * 1.1)
                    .position(x: w * 0.15, y: h * 0.10)
                    .blur(radius: 60)

                // 3. Mid-right sky blue bloom
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: 0x7BBDE8).opacity(0.45),
                                Color(hex: 0xBDD8E9).opacity(0.20),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: w * 0.60
                        )
                    )
                    .frame(width: w * 1.0, height: w * 1.0)
                    .position(x: w * 0.88, y: h * 0.38)
                    .blur(radius: 65)

                // 4. Lower-left teal depth glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: 0x4E8EA2).opacity(0.35),
                                Color(hex: 0x49769F).opacity(0.18),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: w * 0.55
                        )
                    )
                    .frame(width: w * 0.90, height: w * 0.90)
                    .position(x: w * 0.18, y: h * 0.72)
                    .blur(radius: 70)

                // 5. Upper frosted wave
                Path { p in
                    p.move(to: CGPoint(x: -20, y: h * 0.30))
                    p.addCurve(
                        to: CGPoint(x: w * 0.52, y: h * 0.24),
                        control1: CGPoint(x: w * 0.15, y: h * 0.32),
                        control2: CGPoint(x: w * 0.32, y: h * 0.22)
                    )
                    p.addCurve(
                        to: CGPoint(x: w + 20, y: h * 0.29),
                        control1: CGPoint(x: w * 0.70, y: h * 0.26),
                        control2: CGPoint(x: w * 0.88, y: h * 0.33)
                    )
                    p.addLine(to: CGPoint(x: w + 20, y: h + 20))
                    p.addLine(to: CGPoint(x: -20, y: h + 20))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.18), location: 0.0),
                            .init(color: Color(hex: 0x7BBDE8).opacity(0.08), location: 0.5),
                            .init(color: Color.clear, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // 6. Lower frosted wave
                Path { p in
                    p.move(to: CGPoint(x: -20, y: h * 0.62))
                    p.addCurve(
                        to: CGPoint(x: w * 0.55, y: h * 0.58),
                        control1: CGPoint(x: w * 0.18, y: h * 0.66),
                        control2: CGPoint(x: w * 0.36, y: h * 0.56)
                    )
                    p.addCurve(
                        to: CGPoint(x: w + 20, y: h * 0.65),
                        control1: CGPoint(x: w * 0.72, y: h * 0.60),
                        control2: CGPoint(x: w * 0.90, y: h * 0.70)
                    )
                    p.addLine(to: CGPoint(x: w + 20, y: h + 20))
                    p.addLine(to: CGPoint(x: -20, y: h + 20))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.10), location: 0.0),
                            .init(color: Color.clear, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // 7. Luminous crest line
                Path { p in
                    p.move(to: CGPoint(x: -20, y: h * 0.30))
                    p.addCurve(
                        to: CGPoint(x: w * 0.52, y: h * 0.24),
                        control1: CGPoint(x: w * 0.15, y: h * 0.32),
                        control2: CGPoint(x: w * 0.32, y: h * 0.22)
                    )
                    p.addCurve(
                        to: CGPoint(x: w + 20, y: h * 0.29),
                        control1: CGPoint(x: w * 0.70, y: h * 0.26),
                        control2: CGPoint(x: w * 0.88, y: h * 0.33)
                    )
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.60),
                            Color(hex: 0xBDD8E9).opacity(0.40),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1.5
                )
                .blur(radius: 1)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
