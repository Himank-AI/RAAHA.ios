import SwiftUI

// MARK: - SplashAnimationView
// A fully animated multimodal Chennai transportation intro screen.
// Duration ≈ 5.5 s transport animation + 1.5 s logo reveal = ~7 s total.
// Respects @Environment(\.accessibilityReduceMotion) to skip to logo instantly.

struct SplashAnimationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var onFinished: () -> Void

    // Phase drives the whole sequence
    @State private var animationStarted: Bool = false

    // ── sky / clouds
    @State private var cloud1X: CGFloat = -200
    @State private var cloud2X: CGFloat = -300
    @State private var cloud3X: CGFloat = -400
    @State private var birdsY: CGFloat = 0
    @State private var birdsX: CGFloat = -50

    // ── cityscape rise
    @State private var cityscapeOffset: CGFloat = 120
    @State private var cityscapeOpacity: Double = 0

    // ── ground road
    @State private var roadOpacity: Double = 0

    // ── vehicle offsets & opacity (all start off-screen)
    @State private var bikeX: CGFloat = -220
    @State private var bikeOpacity: Double = 0
    @State private var bikeWheelAngle: Double = 0

    @State private var autoX: CGFloat = 440
    @State private var autoOpacity: Double = 0
    @State private var autoWheelAngle: Double = 0

    @State private var cabX: CGFloat = -260
    @State private var cabOpacity: Double = 0
    @State private var cabWheelAngle: Double = 0

    @State private var busX: CGFloat = 440
    @State private var busOpacity: Double = 0
    @State private var busWheelAngle: Double = 0

    @State private var trainX: CGFloat = -400
    @State private var trainOpacity: Double = 0
    @State private var trainWheelAngle: Double = 0

    @State private var metroX: CGFloat = 440
    @State private var metroOpacity: Double = 0
    @State private var metroGlowPulse: Bool = false

    // ── track rise
    @State private var railTrackOffset: CGFloat = 60
    @State private var railTrackOpacity: Double = 0
    @State private var flyoverOffset: CGFloat = 80
    @State private var flyoverOpacity: Double = 0

    // ── logo reveal
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var pinBounce: CGFloat = -20
    @State private var pinOpacity: Double = 0
    @State private var logoGlow: Double = 0

    // ── scene fade-out
    @State private var sceneFade: Double = 1

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // ── Background sky gradient
                skyGradient

                // ── Animated clouds
                clouds(width: w, height: h)

                // ── Animated birds
                birds(width: w, height: h)

                // ── Cityscape silhouette
                CityscapeSilhouette(width: w)
                    .offset(y: cityscapeOffset)
                    .opacity(cityscapeOpacity)

                // ── Elevated metro flyover
                FlyoverTrack(width: w)
                    .frame(width: w)
                    .position(x: w / 2, y: h * 0.42)
                    .offset(y: flyoverOffset)
                    .opacity(flyoverOpacity)

                // ── Railway track (ground level)
                RailTrack(width: w)
                    .frame(width: w)
                    .position(x: w / 2, y: h * 0.59)
                    .offset(y: railTrackOffset)
                    .opacity(railTrackOpacity)

                // ── Ground road surface
                RoadSurface(width: w)
                    .position(x: w / 2, y: h * 0.73)
                    .opacity(roadOpacity)

                // ══ VEHICLES ══

                // 1. Bike (left → right, ground road upper lane)
                BikeVehicle(wheelAngle: bikeWheelAngle)
                    .frame(width: 90, height: 52)
                    .position(x: bikeX, y: h * 0.69)
                    .opacity(bikeOpacity)

                // 2. Auto (right → left, ground road lower lane)
                AutoVehicle(wheelAngle: autoWheelAngle)
                    .frame(width: 80, height: 56)
                    .position(x: autoX, y: h * 0.715)
                    .opacity(autoOpacity)

                // 3. Cab (left → right, road upper lane)
                CabVehicle(wheelAngle: cabWheelAngle)
                    .frame(width: 100, height: 54)
                    .position(x: cabX, y: h * 0.705)
                    .opacity(cabOpacity)

                // 4. Bus (right → left, road lower lane)
                BusVehicle(wheelAngle: busWheelAngle)
                    .frame(width: 130, height: 68)
                    .position(x: busX, y: h * 0.700)
                    .opacity(busOpacity)

                // 5. Local Train (left → right, rail track)
                LocalTrainVehicle(wheelAngle: trainWheelAngle)
                    .frame(width: 220, height: 54)
                    .position(x: trainX, y: h * 0.588)
                    .opacity(trainOpacity)

                // 6. Metro (right → left, elevated flyover)
                MetroVehicle(glow: metroGlowPulse)
                    .frame(width: 200, height: 46)
                    .position(x: metroX, y: h * 0.408)
                    .opacity(metroOpacity)

                // ── Logo reveal overlay (layered on top at end)
                LogoRevealOverlay(
                    logoScale: logoScale,
                    logoOpacity: logoOpacity,
                    taglineOpacity: taglineOpacity,
                    pinBounce: pinBounce,
                    pinOpacity: pinOpacity,
                    logoGlow: logoGlow,
                    width: w,
                    height: h
                )
            }
            .opacity(sceneFade)
            .ignoresSafeArea()
            .onAppear { startSequence(width: w) }
        }
        .ignoresSafeArea()
    }

    // MARK: - Sky

    private var skyGradient: some View {
        LinearGradient(
            stops: [
                .init(color: Color(hex: 0xEAF4FB), location: 0.0),
                .init(color: Color(hex: 0xBDD8E9), location: 0.25),
                .init(color: Color(hex: 0x7BBDE8), location: 0.55),
                .init(color: Color(hex: 0x4E8EA2), location: 0.80),
                .init(color: Color(hex: 0x1D3557), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Clouds

    private func clouds(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            CloudShape()
                .fill(Color.white.opacity(0.70))
                .frame(width: 110, height: 38)
                .blur(radius: 2)
                .position(x: cloud1X, y: height * 0.14)

            CloudShape()
                .fill(Color.white.opacity(0.50))
                .frame(width: 80, height: 28)
                .blur(radius: 1.5)
                .position(x: cloud2X, y: height * 0.09)

            CloudShape()
                .fill(Color.white.opacity(0.40))
                .frame(width: 60, height: 22)
                .blur(radius: 1)
                .position(x: cloud3X, y: height * 0.17)
        }
    }

    // MARK: - Birds

    private func birds(width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 10) {
            ForEach(0..<4, id: \.self) { i in
                BirdShape()
                    .stroke(Color(hex: 0x0A4174).opacity(0.6), lineWidth: 1.2)
                    .frame(width: 14, height: 7)
                    .offset(y: i % 2 == 0 ? birdsY : -birdsY)
            }
        }
        .position(x: birdsX, y: height * 0.20)
    }

    // MARK: - Animation Sequence

    private func startSequence(width: CGFloat) {
        guard !reduceMotion else {
            // Immediately show logo for Reduce Motion users
            showLogoInstant()
            return
        }

        // ── 0.0s: Clouds start drifting (continuous)
        withAnimation(.linear(duration: 28).repeatForever(autoreverses: false)) {
            cloud1X = width + 120
        }
        withAnimation(.linear(duration: 36).repeatForever(autoreverses: false)) {
            cloud2X = width + 100
        }
        withAnimation(.linear(duration: 44).repeatForever(autoreverses: false)) {
            cloud3X = width + 80
        }
        // Birds flap (repeating offset)
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            birdsY = 3
        }
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            birdsX = width + 60
        }

        // ── 0.0s: Cityscape rises from below
        withAnimation(.spring(response: 1.1, dampingFraction: 0.72).delay(0.1)) {
            cityscapeOffset = 0
            cityscapeOpacity = 1
        }

        // ── 0.3s: Road appears
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            roadOpacity = 1
        }

        // ── 0.5s: Rail track rises
        withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.5)) {
            railTrackOffset = 0
            railTrackOpacity = 1
        }

        // ── 0.7s: Metro flyover rises
        withAnimation(.spring(response: 0.9, dampingFraction: 0.72).delay(0.7)) {
            flyoverOffset = 0
            flyoverOpacity = 1
        }

        // ── 1.0s: Bike enters left → right
        withAnimation(.easeIn(duration: 0.3).delay(1.0)) { bikeOpacity = 1 }
        withAnimation(.linear(duration: 2.8).delay(1.0)) {
            bikeX = width + 100
        }
        withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false).delay(1.0)) {
            bikeWheelAngle = 360
        }

        // ── 1.4s: Auto enters right → left
        withAnimation(.easeIn(duration: 0.3).delay(1.4)) { autoOpacity = 1 }
        withAnimation(.linear(duration: 2.4).delay(1.4)) {
            autoX = -100
        }
        withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false).delay(1.4)) {
            autoWheelAngle = -360
        }

        // ── 1.9s: Cab enters left → right
        withAnimation(.easeIn(duration: 0.3).delay(1.9)) { cabOpacity = 1 }
        withAnimation(.linear(duration: 2.6).delay(1.9)) {
            cabX = width + 140
        }
        withAnimation(.linear(duration: 2.6).repeatForever(autoreverses: false).delay(1.9)) {
            cabWheelAngle = 360
        }

        // ── 2.2s: Bus enters right → left
        withAnimation(.easeIn(duration: 0.3).delay(2.2)) { busOpacity = 1 }
        withAnimation(.linear(duration: 2.8).delay(2.2)) {
            busX = -160
        }
        withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false).delay(2.2)) {
            busWheelAngle = -360
        }

        // ── 2.6s: Local train enters left → right on track
        withAnimation(.easeIn(duration: 0.4).delay(2.6)) { trainOpacity = 1 }
        withAnimation(.linear(duration: 2.0).delay(2.6)) {
            trainX = width + 240
        }
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false).delay(2.6)) {
            trainWheelAngle = 360
        }

        // ── 3.0s: Metro enters right → left on flyover
        withAnimation(.easeIn(duration: 0.4).delay(3.0)) { metroOpacity = 1 }
        withAnimation(.linear(duration: 1.8).delay(3.0)) {
            metroX = -240
        }
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(3.0)) {
            metroGlowPulse = true
        }

        // ── 5.0s: Fade out scene, reveal logo
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            revealLogo()
        }
    }

    private func revealLogo() {
        // Fade scene softly
        withAnimation(.easeOut(duration: 0.8)) {
            sceneFade = 0.15
        }
        // Logo pops in
        withAnimation(.spring(response: 0.7, dampingFraction: 0.62).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        // Location pin bounces down
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.5)) {
            pinBounce = 0
            pinOpacity = 1
        }
        // Tagline fades in
        withAnimation(.easeOut(duration: 0.6).delay(0.9)) {
            taglineOpacity = 1
        }
        // Glow pulse
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true).delay(1.0)) {
            logoGlow = 1
        }
        // Dismiss after logo shown for 1.8 s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeInOut(duration: 0.5)) {
                sceneFade = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                onFinished()
            }
        }
    }

    private func showLogoInstant() {
        logoScale = 1
        logoOpacity = 1
        pinBounce = 0
        pinOpacity = 1
        taglineOpacity = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onFinished()
        }
    }
}

// MARK: - Logo Reveal Overlay

private struct LogoRevealOverlay: View {
    let logoScale: CGFloat
    let logoOpacity: Double
    let taglineOpacity: Double
    let pinBounce: CGFloat
    let pinOpacity: Double
    let logoGlow: Double
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 14) {
                // Logo word
                ZStack(alignment: .topTrailing) {
                    Text("RAAHA")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color(hex: 0xBDD8E9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: Color(hex: 0x0A4174).opacity(0.5 + 0.4 * logoGlow),
                            radius: 18 + 10 * logoGlow,
                            x: 0, y: 4
                        )

                    // Animated pin
                    SplashLocationPin()
                        .offset(x: 14, y: -10 + pinBounce)
                        .opacity(pinOpacity)
                        .scaleEffect(pinOpacity)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Motion swoosh underline
                Path { p in
                    p.move(to: CGPoint(x: 10, y: 4))
                    p.addQuadCurve(
                        to: CGPoint(x: 160, y: 4),
                        control: CGPoint(x: 85, y: -4)
                    )
                }
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: 0x7BBDE8).opacity(0.9), Color(hex: 0xA8DADC).opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 170, height: 10)
                .opacity(logoOpacity)
                .scaleEffect(logoScale)

                // Tagline
                Text("Every Path Leads to You")
                    .font(.system(size: 17, weight: .medium, design: .serif).italic())
                    .foregroundStyle(Color.white.opacity(0.92))
                    .tracking(0.5)
                    .opacity(taglineOpacity)
                    .padding(.top, 4)

                // Mode pills row
                HStack(spacing: 10) {
                    ForEach(SplashModePill.allCases, id: \.self) { pill in
                        SplashModePillView(pill: pill)
                    }
                }
                .opacity(taglineOpacity)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 80)
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Mode Pills

private enum SplashModePill: String, CaseIterable {
    case bike = "bicycle"
    case auto = "car.fill"
    case bus = "bus.fill"
    case train = "train.side.front.car"
    case metro = "tram.fill"
}

private struct SplashModePillView: View {
    let pill: SplashModePill
    @State private var appeared = false

    var body: some View {
        Image(systemName: pill.rawValue)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color(hex: 0x0A4174))
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.85))
                    .background(.ultraThinMaterial, in: Circle())
            )
            .overlay(Circle().stroke(Color(hex: 0xA8DADC).opacity(0.6), lineWidth: 1))
            .scaleEffect(appeared ? 1 : 0.1)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                let delay = Double(SplashModePill.allCases.firstIndex(of: pill) ?? 0) * 0.1
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay + 0.3)) {
                    appeared = true
                }
            }
    }
}

// MARK: - Cityscape Silhouette (SVG-drawn with SwiftUI Path)

private struct CityscapeSilhouette: View {
    let width: CGFloat

    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height

            // Sky-scrapers and Chennai temple silhouette
            var skyline = Path()

            // Far background tall buildings (deep blue tinted)
            let buildings: [(x: CGFloat, w: CGFloat, h: CGFloat)] = [
                (0.0, 0.07, 0.42), (0.08, 0.05, 0.36), (0.14, 0.09, 0.50),
                (0.24, 0.06, 0.38), (0.31, 0.11, 0.55), (0.43, 0.07, 0.44),
                (0.51, 0.05, 0.32), (0.57, 0.10, 0.48), (0.68, 0.06, 0.60),
                (0.75, 0.08, 0.40), (0.84, 0.07, 0.52), (0.92, 0.08, 0.35)
            ]
            for b in buildings {
                let bx = b.x * w
                let bw = b.w * w
                let bh = b.h * h
                skyline.addRect(CGRect(x: bx, y: h - bh, width: bw, height: bh))
                // Antenna
                skyline.move(to: CGPoint(x: bx + bw / 2, y: h - bh))
                skyline.addLine(to: CGPoint(x: bx + bw / 2, y: h - bh - 10))
            }
            ctx.fill(skyline, with: .color(Color(hex: 0x1D3557).opacity(0.55)))

            // Foreground trees (greenery along road)
            var trees = Path()
            let treePositions: [CGFloat] = [0.05, 0.15, 0.27, 0.38, 0.50, 0.62, 0.74, 0.86, 0.95]
            for tx in treePositions {
                let cx = tx * w
                let cy = h * 0.75
                // Trunk
                trees.addRect(CGRect(x: cx - 2, y: cy, width: 4, height: 14))
                // Canopy (triangle-ish with circle)
                trees.addEllipse(in: CGRect(x: cx - 10, y: cy - 20, width: 20, height: 22))
            }
            ctx.fill(trees, with: .color(Color(hex: 0x299D8F).opacity(0.65)))

            // Simple Kapaleeshwarar-style temple outline (left side)
            var temple = Path()
            let tx = w * 0.08
            let ty = h * 0.55
            // Gopuram tiers
            let tiers: [(w: CGFloat, h: CGFloat)] = [(46, 10), (38, 10), (30, 10), (22, 10), (14, 10), (8, 12)]
            var curY = ty
            for tier in tiers {
                let tierX = tx - tier.w / 2
                temple.addRect(CGRect(x: tierX, y: curY - tier.h, width: tier.w, height: tier.h))
                curY -= tier.h
            }
            // Kalasha on top
            temple.addEllipse(in: CGRect(x: tx - 4, y: curY - 10, width: 8, height: 10))
            ctx.fill(temple, with: .color(Color(hex: 0x457B9D).opacity(0.75)))

        }
        .frame(width: width, height: 220)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Road Surface

private struct RoadSurface: View {
    let width: CGFloat
    var body: some View {
        ZStack {
            // Main road asphalt
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: 0x1D3557).opacity(0.55))
                .frame(width: width, height: 48)

            // Center dashed divider
            HStack(spacing: 0) {
                ForEach(0..<12, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 20, height: 3)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 16, height: 3)
                }
            }

            // Kerb lines (top & bottom)
            VStack(spacing: 40) {
                Rectangle().fill(Color(hex: 0xA8DADC).opacity(0.4)).frame(height: 2)
                Rectangle().fill(Color(hex: 0xA8DADC).opacity(0.4)).frame(height: 2)
            }
            .frame(width: width)
        }
    }
}

// MARK: - Rail Track (Ground)

private struct RailTrack: View {
    let width: CGFloat
    var body: some View {
        ZStack {
            // Ballast bed
            Rectangle()
                .fill(Color(hex: 0x49769F).opacity(0.35))
                .frame(width: width, height: 22)

            // Rails
            VStack(spacing: 14) {
                ForEach(0..<2, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: 0x457B9D).opacity(0.80))
                        .frame(width: width, height: 3)
                }
            }

            // Sleepers (cross-ties)
            HStack(spacing: 0) {
                ForEach(0..<Int(width / 18), id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: 0x1D3557).opacity(0.55))
                        .frame(width: 10, height: 18)
                    Spacer().frame(width: 8)
                }
            }
        }
    }
}

// MARK: - Elevated Flyover / Metro Track

private struct FlyoverTrack: View {
    let width: CGFloat
    var body: some View {
        ZStack {
            // Flyover deck (concrete slab)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x457B9D).opacity(0.75), Color(hex: 0x1D3557).opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: 14)

            // Metro rails (top of deck)
            VStack(spacing: 10) {
                ForEach(0..<2, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: 0xA8DADC).opacity(0.90))
                        .frame(width: width, height: 3)
                }
            }
            .offset(y: -6)

            // Support pillars (below deck)
            HStack(spacing: 0) {
                ForEach(0..<Int(width / 60), id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: 0x1D3557).opacity(0.55))
                        .frame(width: 10, height: 36)
                        .offset(y: 25)
                    Spacer().frame(width: 50)
                }
            }
        }
    }
}

// MARK: - Vehicle: Motorcycle with Rider

private struct BikeVehicle: View {
    let wheelAngle: Double

    var body: some View {
        ZStack {
            // Body frame
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x457B9D), Color(hex: 0x1D3557)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 58, height: 20)
                .offset(x: 2, y: -6)

            // Rider silhouette
            Capsule()
                .fill(Color(hex: 0x1D3557).opacity(0.85))
                .frame(width: 16, height: 24)
                .offset(x: 4, y: -20)

            // Helmet
            Circle()
                .fill(Color(hex: 0x0A4174))
                .frame(width: 14, height: 14)
                .offset(x: 4, y: -30)

            // Handlebars
            Rectangle()
                .fill(Color(hex: 0xA8DADC).opacity(0.8))
                .frame(width: 14, height: 3)
                .offset(x: 18, y: -20)

            // Front wheel
            WheelView(diameter: 20, angle: wheelAngle, color: Color(hex: 0x1D3557))
                .offset(x: 28, y: 4)

            // Rear wheel
            WheelView(diameter: 20, angle: wheelAngle, color: Color(hex: 0x1D3557))
                .offset(x: -20, y: 4)

            // Exhaust puff
            ExhaustPuffView()
                .offset(x: -38, y: 2)
        }
    }
}

// MARK: - Vehicle: Auto-Rickshaw (facing left)

private struct AutoVehicle: View {
    let wheelAngle: Double

    var body: some View {
        ZStack {
            // Body (yellow-green auto style)
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x9EE600), Color(hex: 0x299D8F)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 54, height: 34)
                .offset(x: -2, y: -8)

            // Windshield
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: 0xA8DADC).opacity(0.6))
                .frame(width: 16, height: 16)
                .offset(x: -20, y: -12)

            // Top canopy
            Capsule()
                .fill(Color(hex: 0x1D3557).opacity(0.7))
                .frame(width: 50, height: 10)
                .offset(x: -2, y: -24)

            // Rear wheel
            WheelView(diameter: 18, angle: -wheelAngle, color: Color(hex: 0x1D3557))
                .offset(x: 18, y: 4)

            // Front wheel
            WheelView(diameter: 18, angle: -wheelAngle, color: Color(hex: 0x1D3557))
                .offset(x: -20, y: 6)
        }
    }
}

// MARK: - Vehicle: Cab (white taxi facing right)

private struct CabVehicle: View {
    let wheelAngle: Double

    var body: some View {
        ZStack {
            // Car body lower
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.92))
                .frame(width: 76, height: 28)
                .offset(y: 2)

            // Car cabin
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.85))
                .frame(width: 52, height: 24)
                .offset(x: -4, y: -16)

            // Windshield
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: 0x7BBDE8).opacity(0.65))
                .frame(width: 20, height: 16)
                .offset(x: 14, y: -16)

            // TAXI label
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: 0xF59E0B))
                .frame(width: 28, height: 10)
                .offset(y: -32)

            Text("TAXI")
                .font(.system(size: 5, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: 0x1D3557))
                .offset(y: -32)

            // Front headlight
            Circle()
                .fill(Color(hex: 0xF59E0B).opacity(0.8))
                .frame(width: 7, height: 7)
                .offset(x: 36, y: 2)

            // Rear wheel
            WheelView(diameter: 20, angle: wheelAngle, color: Color(hex: 0x1D3557))
                .offset(x: -26, y: 10)

            // Front wheel
            WheelView(diameter: 20, angle: wheelAngle, color: Color(hex: 0x1D3557))
                .offset(x: 24, y: 10)
        }
    }
}

// MARK: - Vehicle: City Bus (facing left)

private struct BusVehicle: View {
    let wheelAngle: Double

    var body: some View {
        ZStack {
            // Bus body
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x4E8EA2), Color(hex: 0x1D3557)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 100, height: 44)
                .offset(y: -6)

            // Windows row
            HStack(spacing: 5) {
                ForEach(0..<5, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: 0xA8DADC).opacity(0.70))
                        .frame(width: 13, height: 10)
                }
            }
            .offset(x: -5, y: -10)

            // Door
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: 0xA8DADC).opacity(0.5))
                .frame(width: 10, height: 18)
                .offset(x: -38, y: -2)

            // Destination board
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: 0xEAF4FB).opacity(0.9))
                .frame(width: 40, height: 8)
                .offset(x: -5, y: -24)

            Text("CHENNAI")
                .font(.system(size: 4, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: 0x1D3557))
                .offset(x: -5, y: -24)

            // Rear wheel
            WheelView(diameter: 22, angle: -wheelAngle, color: Color(hex: 0x0A4174))
                .offset(x: 32, y: 12)

            // Front wheel
            WheelView(diameter: 22, angle: -wheelAngle, color: Color(hex: 0x0A4174))
                .offset(x: -32, y: 12)
        }
    }
}

// MARK: - Vehicle: Local Train (facing right)

private struct LocalTrainVehicle: View {
    let wheelAngle: Double

    var body: some View {
        ZStack {
            // 2-car body
            HStack(spacing: 3) {
                TrainCarShape(isLeading: false, color: Color(hex: 0x457B9D))
                TrainCarShape(isLeading: true, color: Color(hex: 0x4E8EA2))
            }

            // Pantograph (wire collector arm) on first car
            Path { p in
                p.move(to: CGPoint(x: 60, y: -18))
                p.addLine(to: CGPoint(x: 70, y: -32))
                p.addLine(to: CGPoint(x: 80, y: -18))
            }
            .stroke(Color(hex: 0xA8DADC).opacity(0.8), lineWidth: 1.5)

            // Bogies (wheel sets)
            ForEach([-70, -30, 30, 70] as [CGFloat], id: \.self) { xOff in
                WheelView(diameter: 14, angle: wheelAngle, color: Color(hex: 0x1D3557))
                    .offset(x: xOff, y: 20)
            }
        }
    }
}

private struct TrainCarShape: View {
    let isLeading: Bool
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: isLeading ? 10 : 6)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.9), color.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 92, height: 36)

            // Windows
            HStack(spacing: 5) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: 0xEAF4FB).opacity(0.75))
                        .frame(width: 14, height: 10)
                }
            }
            .offset(y: -4)

            // Blue accent stripe
            Rectangle()
                .fill(Color(hex: 0x0A4174))
                .frame(width: 92, height: 5)
                .offset(y: 10)

            if isLeading {
                // Front headlight
                Circle()
                    .fill(Color(hex: 0xEAF4FB))
                    .frame(width: 6, height: 6)
                    .offset(x: 42, y: 4)
            }
        }
    }
}

// MARK: - Vehicle: Metro (facing left, elevated)

private struct MetroVehicle: View {
    let glow: Bool

    var body: some View {
        ZStack {
            // 2-car aerodynamic metro body
            HStack(spacing: 2) {
                MetroCarShape(isLeading: false, glow: glow)
                MetroCarShape(isLeading: true, glow: glow)
            }

            // Pantograph on rear car
            Path { p in
                p.move(to: CGPoint(x: -50, y: -16))
                p.addLine(to: CGPoint(x: -60, y: -28))
                p.addLine(to: CGPoint(x: -70, y: -16))
            }
            .stroke(Color(hex: 0xA8DADC).opacity(0.9), lineWidth: 1.5)

            // Bogies at bottom
            ForEach([-70, -30, 30, 70] as [CGFloat], id: \.self) { xOff in
                Rectangle()
                    .fill(Color(hex: 0x1D3557).opacity(0.8))
                    .frame(width: 24, height: 6)
                    .offset(x: xOff, y: 20)
            }
        }
    }
}

private struct MetroCarShape: View {
    let isLeading: Bool
    let glow: Bool

    var body: some View {
        ZStack {
            // Aerodynamic body
            RoundedRectangle(cornerRadius: isLeading ? 14 : 6)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0xEAF4FB).opacity(0.95),
                            Color(hex: 0xA8DADC).opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 90, height: 32)
                .shadow(
                    color: Color(hex: 0x7BBDE8).opacity(glow ? 0.80 : 0.30),
                    radius: glow ? 12 : 4
                )

            // Blue accent stripe
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x0A4174), Color(hex: 0x4E8EA2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 90, height: 7)
                .offset(y: 8)

            // Windows
            HStack(spacing: 5) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: 0x7BBDE8).opacity(0.65))
                        .frame(width: 14, height: 9)
                }
            }
            .offset(y: -5)

            // "METRO" text
            if isLeading {
                Text("METRO")
                    .font(.system(size: 4.5, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: 0x1D3557).opacity(0.85))
                    .offset(x: -30, y: 8)
            }
        }
    }
}

// MARK: - Wheel Helper

private struct WheelView: View {
    let diameter: CGFloat
    let angle: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: diameter, height: diameter)
            Circle()
                .fill(Color(hex: 0xA8DADC).opacity(0.4))
                .frame(width: diameter * 0.5, height: diameter * 0.5)
            // Spokes
            ForEach(0..<4, id: \.self) { i in
                Rectangle()
                    .fill(Color(hex: 0xA8DADC).opacity(0.6))
                    .frame(width: diameter * 0.42, height: 1.5)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
        .rotationEffect(.degrees(angle))
    }
}

// MARK: - Exhaust Puff

private struct ExhaustPuffView: View {
    @State private var puffScale: CGFloat = 0.3
    @State private var puffOpacity: Double = 0.5

    var body: some View {
        Circle()
            .fill(Color.white.opacity(puffOpacity))
            .frame(width: 10, height: 10)
            .blur(radius: 3)
            .scaleEffect(puffScale)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).repeatForever(autoreverses: false)) {
                    puffScale = 1.4
                    puffOpacity = 0
                }
            }
    }
}

// MARK: - Cloud Shape

private struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: CGRect(x: rect.width * 0.1, y: rect.height * 0.3,
                                width: rect.width * 0.5, height: rect.height * 0.65))
        p.addEllipse(in: CGRect(x: rect.width * 0.3, y: rect.height * 0.1,
                                width: rect.width * 0.42, height: rect.height * 0.70))
        p.addEllipse(in: CGRect(x: rect.width * 0.55, y: rect.height * 0.3,
                                width: rect.width * 0.4, height: rect.height * 0.60))
        p.addRect(CGRect(x: rect.width * 0.1, y: rect.height * 0.55,
                         width: rect.width * 0.86, height: rect.height * 0.45))
        return p
    }
}

// MARK: - Bird Shape (M-curve)

private struct BirdShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: 0, y: h * 0.5))
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: 0),
                       control: CGPoint(x: w * 0.25, y: h * 0.4))
        p.addQuadCurve(to: CGPoint(x: w, y: h * 0.5),
                       control: CGPoint(x: w * 0.75, y: h * 0.4))
        return p
    }
}

// MARK: - Splash Location Pin (larger, animated)

private struct SplashLocationPin: View {
    var body: some View {
        ZStack {
            PinTeardropShape()
                .fill(Color(hex: 0xE63946))
                .frame(width: 22, height: 30)
                .shadow(color: Color(hex: 0xE63946).opacity(0.5), radius: 8, x: 0, y: 3)

            Circle()
                .fill(Color.white)
                .frame(width: 7, height: 7)
                .offset(y: -5)
        }
    }
}
