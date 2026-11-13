import SwiftUI

// MARK: - Colour palette (Exact 7-Color Oceanic Gradient & Premium Glassmorphism)

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

    // MARK: - Exact User Reference Gradient (7 Oceanic Blue Tones)
    /// #001D39 – Deep Abyssal Navy (Tone 1)
    static let oceanic001D39 = Color(hex: 0x001D39)
    /// #0A4174 – Prussian Blue / Deep Cerulean (Tone 2)
    static let oceanic0A4174 = Color(hex: 0x0A4174)
    /// #49769F – Muted Slate Blue (Tone 3)
    static let oceanic49769F = Color(hex: 0x49769F)
    /// #4E8EA2 – Oceanic Teal / Deep Steel (Tone 4)
    static let oceanic4E8EA2 = Color(hex: 0x4E8EA2)
    /// #6EA2B3 – Soft Mineral Blue / Aqua Slate (Tone 5)
    static let oceanic6EA2B3 = Color(hex: 0x6EA2B3)
    /// #7BBDE8 – Vibrant Sky Blue / Cornflower (Tone 6)
    static let oceanic7BBDE8 = Color(hex: 0x7BBDE8)
    /// #BDD8E9 – Pale Ice / Frosted Powder (Tone 7)
    static let oceanicBDD8E9 = Color(hex: 0xBDD8E9)

    // MARK: - Semantic Aliases Mapped to the 7-Color Gradient & Deep Space Blue
    /// Primary text — Deep Space Blue #1D3557
    static let midnightBlue = Color(hex: 0x1D3557)
    static let royalBlue = Color(hex: 0x0A4174)
    static let electricBlue = Color(hex: 0x4E8EA2)
    static let brightBlue = Color(hex: 0x7BBDE8)
    /// Light-mode secondary text — Muted Slate Blue for readability on pale backgrounds
    static let lightSkyBlue = Color(hex: 0x49769F)
    /// Light-mode tertiary / caption text — Oceanic Teal
    static let icyBlue = Color(hex: 0x4E8EA2)

    // MARK: - Reference Accent: Neon Lime Green
    /// Neon Lime Green #C6FF00 – high-contrast accent for key numbers, active states, indicators
    static let neonLime = Color(hex: 0xC6FF00)

    // MARK: - RAAHA Brand Palette (Preserved)
    /// Honeydew #F1FAEE
    static let honeydew = Color(hex: 0xF1FAEE)
    /// Frosted Blue #A8DADC
    static let frostedBlue = Color(hex: 0xA8DADC)
    /// Steel Blue #457B9D
    static let steelBlue = Color(hex: 0x457B9D)
    /// Deep Space Blue #1D3557 – Primary transport labels, headings, and high-contrast text
    static let deepSpace = Color(hex: 0x1D3557)
    /// Strawberry Red #E63946 – Primary alert / accent
    static let strawberry = Color(hex: 0xE63946)

    // MARK: - Dedicated Transport Mode Colour System
    /// Walk: Nature Green — #218C70
    static let transportWalk = Color(hex: 0x218C70)
    /// Bike: Amber Orange — #E58A27
    static let transportBike = Color(hex: 0xE58A27)
    /// Auto Rickshaw: Golden Yellow — #C28A12
    static let transportAuto = Color(hex: 0xC28A12)
    /// Bus: Sky Blue — #38A8D8
    static let transportBus = Color(hex: 0x38A8D8)
    /// Bus Background: Light Sky Blue — #E2F4FC
    static let transportBusBg = Color(hex: 0xE2F4FC)
    /// Cab / Car: Royal Lavender — #8064A9
    static let transportCab = Color(hex: 0x8064A9)
    /// Local Train: Steel Blue — #457B9D
    static let transportTrain = Color(hex: 0x457B9D)
    /// Metro: Ocean Teal — #16859A
    static let transportMetro = Color(hex: 0x16859A)

    // MARK: - Semantic Brand Color Aliases (light-mode oceanic glassmorphism)
    /// Teal Green #2A9D8F
    static let tealGreen = Color(hex: 0x2A9D8F)
    /// Status Green – Vibrant Neon Lime Green for arrival, live status, verified badges
    static let statusGreen = Color(hex: 0xC6FF00)
}

// MARK: - Typography (SF Pro via the system font, Dynamic Type text styles)

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

// MARK: - Gradients (Smooth 7-Step Oceanic Gradient Spectrum)

extension LinearGradient {
    /// Full screen background gradient — light oceanic, pale ice top to sky blue to teal bottom.
    static let raahaScreen = LinearGradient(
        stops: [
            .init(color: Color(hex: 0xEAF4FB), location: 0.0),  // Near-white icy top
            .init(color: Color(hex: 0xBDD8E9), location: 0.18), // Pale Ice
            .init(color: Color(hex: 0x7BBDE8), location: 0.42), // Sky Blue
            .init(color: Color(hex: 0x6EA2B3), location: 0.65), // Mineral Aqua
            .init(color: Color(hex: 0x4E8EA2), location: 0.85), // Oceanic Teal
            .init(color: Color(hex: 0x49769F), location: 1.0)   // Muted Slate
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Large "hero" card: rich oceanic from sky blue into teal/prussian.
    static let raahaHero = LinearGradient(
        stops: [
            .init(color: Color(hex: 0x7BBDE8).opacity(0.85), location: 0),
            .init(color: Color(hex: 0x4E8EA2).opacity(0.92), location: 0.50),
            .init(color: Color(hex: 0x0A4174).opacity(0.96), location: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Banner card: Sky blue leading into oceanic teal.
    static let raahaBanner = LinearGradient(
        stops: [
            .init(color: Color(hex: 0x7BBDE8), location: 0.0),
            .init(color: Color(hex: 0x4E8EA2), location: 1.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Frosted oceanic glass card — light teal/sky overlay.
    static let raahaNavy = LinearGradient(
        colors: [
            Color(hex: 0x7BBDE8).opacity(0.30),
            Color(hex: 0x4E8EA2).opacity(0.50)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Glowing oceanic card with vibrant sky blue highlights.
    static let raahaNavyGlow = LinearGradient(
        stops: [
            .init(color: Color(hex: 0xBDD8E9).opacity(0.55), location: 0.0),
            .init(color: Color(hex: 0x7BBDE8).opacity(0.45), location: 0.35),
            .init(color: Color(hex: 0x4E8EA2).opacity(0.70), location: 1.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Rich Sky-to-Teal Oceanic pill button surface.
    static let raahaPill = LinearGradient(
        colors: [Color(hex: 0x4E8EA2), Color(hex: 0x0A4174)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Neon Lime accent pill surface.
    static let raahaNeonPill = LinearGradient(
        colors: [Color(hex: 0xD8FF33), Color.neonLime],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Glass specular edge highlight stroke.
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

// MARK: - Surfaces (Frosted Glassmorphism — Light Oceanic Mode)

extension View {
    /// Frosted glass card with white/ice glass surface and oceanic specular rim — light mode.
    func navyCard(
        radius: CGFloat = 24,
        gradient: LinearGradient = .raahaNavy
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.white.opacity(0.55))
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: radius, style: .continuous)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(
                        LinearGradient.glassRim,
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color(hex: 0x49769F).opacity(0.22), radius: 16, x: 0, y: 6)
    }

    /// Lighter frosted glass card — prominent white glass, light oceanic rim.
    func lightCard(radius: CGFloat = 22) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.white.opacity(0.65))
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: radius, style: .continuous)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
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
            .shadow(color: Color(hex: 0x4E8EA2).opacity(0.18), radius: 12, x: 0, y: 5)
    }

    /// Floating glass capsule for tab bars and pill controls — light oceanic.
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
            .shadow(color: Color(hex: 0x49769F).opacity(0.30), radius: 18, x: 0, y: 8)
    }

    /// RAAHA Light Oceanic Screen Background.
    func raahaScreenBackground() -> some View {
        self.background(RaahaScreenBackground())
    }
}

// MARK: - Light Oceanic Background with Atmospheric Depth

struct RaahaScreenBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                // 1. Base Gradient: Light Oceanic — icy white top to muted teal/slate bottom
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: 0xEAF4FB), location: 0.0),  // Near-white icy
                        .init(color: Color(hex: 0xBDD8E9), location: 0.20), // Pale Ice
                        .init(color: Color(hex: 0x7BBDE8), location: 0.45), // Sky Blue
                        .init(color: Color(hex: 0x6EA2B3), location: 0.68), // Mineral Aqua
                        .init(color: Color(hex: 0x4E8EA2), location: 0.88), // Oceanic Teal
                        .init(color: Color(hex: 0x49769F), location: 1.0)   // Muted Slate
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // 2. Upper-left bright white/icy sunlight bloom
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

                // 3. Mid-right Sky Blue (#7BBDE8) ambient bloom
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

                // 4. Lower-left Teal (#4E8EA2) depth glow
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

                // 5. Frosted wave shape — upper band
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

                // 6. Frosted wave shape — lower band
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
