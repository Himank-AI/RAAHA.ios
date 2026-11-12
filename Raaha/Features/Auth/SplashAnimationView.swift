import SwiftUI

// ============================================================
// MARK: – RAAHA Cinematic Splash  (5.8 s, pure SwiftUI 60 fps)
//
//  Scene 1   0.0 – 2.0 s   Chennai multimodal cityscape
//  Scene 2   2.0 – 3.2 s   Cinematic iPhone zoom-in transition
//  Scene 3   3.2 – 5.8 s   RAAHA brand reveal
// ============================================================

// MARK: - Helpers

private func clamp01(_ v: Double) -> Double { max(0, min(1, v)) }
private func easeOut(_ t: Double) -> Double { 1 - pow(1 - t, 3) }
private func easeIn(_ t: Double) -> Double  { t * t * t }
private func easeIO(_ t: Double) -> Double {
    t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
}

// MARK: - Entry Point

struct SplashAnimationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var onFinished: () -> Void

    @State private var startDate: Date?
    @State private var finished = false

    private let kDuration = 5.8

    var body: some View {
        GeometryReader { proxy in
            if reduceMotion {
                // Instant brand reveal for accessibility
                ZStack {
                    raahaBackground
                    BrandRevealView(t: 1.0, size: proxy.size)
                }
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { onFinished() }
                }
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: finished)) { ctx in
                    let t: Double = {
                        guard let s = startDate else { return 0 }
                        return min(ctx.date.timeIntervalSince(s), kDuration + 0.2)
                    }()
                    SplashStageView(t: t, size: proxy.size)
                        .onChange(of: t) { _, newT in
                            guard !finished, newT >= kDuration else { return }
                            finished = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onFinished() }
                        }
                }
                .onAppear { startDate = Date() }
            }
        }
        .ignoresSafeArea()
    }

    private var raahaBackground: some View {
        LinearGradient(
            stops: [
                .init(color: Color(hex: 0xEAF4FB), location: 0.0),
                .init(color: Color(hex: 0xBDD8E9), location: 0.18),
                .init(color: Color(hex: 0x7BBDE8), location: 0.42),
                .init(color: Color(hex: 0x4E8EA2), location: 0.72),
                .init(color: Color(hex: 0x1D3557), location: 1.0)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Stage Orchestrator

private struct SplashStageView: View {
    let t: Double
    let size: CGSize

    // ── Phase normalised 0…1
    var cityP:    Double { clamp01(t / 2.0) }
    var transP:   Double { clamp01((t - 2.0) / 1.2) }
    var brandP:   Double { clamp01((t - 3.2) / 2.6) }
    var fadeInP:  Double { clamp01(t / 0.35) }
    var fadeOutP: Double { clamp01((t - 5.5) / 0.3) }

    // City fades out as phone zooms in
    var cityOpacity: Double { max(0, 1 - easeIn(max(0, transP - 0.4) / 0.6)) }
    // Ken-Burns slow zoom on city
    var cityZoom: CGFloat { 1 + CGFloat(easeOut(cityP) * 0.045) }

    var body: some View {
        ZStack {
            // 1. Sky – always visible, hue-shifts into deep blue for brand phase
            SkyGradientLayer(transP: transP, brandP: brandP)

            // 2. City scene
            CitySceneView(cityT: cityP * 2.0, size: size)
                .scaleEffect(cityZoom, anchor: UnitPoint(x: 0.5, y: 0.85))
                .opacity(cityOpacity)

            // 3. Atmospheric depth haze (bottom of city scene)
            if cityOpacity > 0 {
                LinearGradient(
                    stops: [.init(color: .clear, location: 0.55),
                            .init(color: Color(hex: 0xBDD8E9).opacity(0.30), location: 1.0)],
                    startPoint: .top, endPoint: .bottom
                )
                .opacity(cityOpacity)
                .allowsHitTesting(false)
            }

            // 4. iPhone zoom transition
            if transP > 0 {
                PhoneTransitionView(transP: transP, brandP: brandP, size: size)
            }

            // 5. Brand reveal (draws inside phone screen once large enough)
            if brandP > 0 {
                BrandRevealView(t: brandP, size: size)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: phoneScreenRadius(transP: transP, size: size),
                            style: .continuous
                        )
                    )
                    .opacity(easeOut(brandP) > 0 ? 1 : 0)
            }

            // 6. Fade-in and fade-out veils
            Color.black.opacity(1.0 - easeOut(fadeInP))
                .allowsHitTesting(false)
            Color.black.opacity(easeIn(fadeOutP))
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }

    private func phoneScreenRadius(transP: Double, size: CGSize) -> CGFloat {
        let p = clamp01(transP / 0.9)
        let full = size.width / 2 // effectively 0 when phone fills screen
        return max(0, 32 * (1 - easeIO(p)))
    }
}

// MARK: - Sky Gradient Layer

private struct SkyGradientLayer: View {
    let transP: Double
    let brandP: Double

    // Sky slowly shifts from cyan-day to deep brand blue
    var topAlpha: Double { 1.0 - easeIO(brandP) * 0.7 }
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(hex: 0xEAF4FB).opacity(topAlpha), location: 0.0),
                .init(color: Color(hex: 0xBDD8E9).opacity(0.9), location: 0.18),
                .init(color: Color(hex: 0x7BBDE8).opacity(0.9 - brandP * 0.3), location: 0.42),
                .init(color: Color(hex: 0x4E8EA2), location: 0.72),
                .init(color: Color(hex: 0x1D3557), location: 1.0)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - City Scene (Scene 1)

private struct CitySceneView: View {
    let cityT: Double   // 0…2 seconds
    let size: CGSize

    private var w: CGFloat { size.width }
    private var h: CGFloat { size.height }

    // ── Shared vehicle road/track/flyover Y positions
    private var roadY:  CGFloat { h * 0.740 }
    private var railY:  CGFloat { h * 0.615 }
    private var flyY:   CGFloat { h * 0.435 }

    // ── Generic position helpers
    private func posLR(enter: Double, exit: Double, offScreen: CGFloat = 120) -> CGFloat {
        let p = clamp01((cityT - enter) / max(0.01, exit - enter))
        return -offScreen + CGFloat(easeIO(p)) * (w + offScreen * 2)
    }
    private func posRL(enter: Double, exit: Double, offScreen: CGFloat = 120) -> CGFloat {
        let p = clamp01((cityT - enter) / max(0.01, exit - enter))
        return w + offScreen - CGFloat(easeIO(p)) * (w + offScreen * 2)
    }
    private func vFade(_ enter: Double) -> Double { clamp01((cityT - enter) / 0.25) }
    private func wheelAngle(_ enter: Double, _ exit: Double, r: CGFloat = 14) -> Angle {
        let progress = clamp01((cityT - enter) / max(0.01, exit - enter))
        return .degrees(Double(progress) * Double(w + 240) / Double(r) * 180 / .pi)
    }

    // ── Vehicle positions
    private var bikeX:    CGFloat { posLR(enter: 0.05, exit: 1.75, offScreen: 110) }
    private var autoX:    CGFloat { posRL(enter: 0.30, exit: 2.00, offScreen: 95) }
    private var cabX:     CGFloat { posLR(enter: 0.10, exit: 2.00, offScreen: 130) }
    private var busX:     CGFloat { posRL(enter: 0.00, exit: 2.00, offScreen: 155) }
    private var trainX:   CGFloat { posLR(enter: 0.00, exit: 1.85, offScreen: 260) }
    private var metroX:   CGFloat { posRL(enter: 0.00, exit: 1.80, offScreen: 240) }

    private var bikeWh:   Angle { wheelAngle(0.05, 1.75, r: 11) }
    private var autoWh:   Angle { .degrees(-wheelAngle(0.30, 2.00, r: 11).degrees) }
    private var cabWh:    Angle { wheelAngle(0.10, 2.00, r: 13) }
    private var busWh:    Angle { .degrees(-wheelAngle(0.00, 2.00, r: 16).degrees) }
    private var trainWh:  Angle { wheelAngle(0.00, 1.85, r: 10) }

    // Cloud drift
    private var cloud1X: CGFloat { -80  + CGFloat(cityT / 2.0) * 50 }
    private var cloud2X: CGFloat { w * 0.45 + CGFloat(cityT / 2.0) * 30 }
    private var cloud3X: CGFloat { w * 0.72 + CGFloat(cityT / 2.0) * 20 }

    var body: some View {
        ZStack {
            // ── Static cityscape drawn in Canvas (buildings, temple, trees, sun)
            CityBackgroundCanvas(size: size)

            // ── Animated clouds
            AnimatedCloudsLayer(c1x: cloud1X, c2x: cloud2X, c3x: cloud3X, h: h)

            // ── Birds  
            BirdsLayer(cityT: cityT, h: h, w: w)

            // ── Metro flyover structure
            MetroFlyoverView(w: w)
                .frame(width: w, height: 20)
                .position(x: w / 2, y: flyY)

            // ── Ground rail track
            GroundRailView(w: w)
                .frame(width: w, height: 20)
                .position(x: w / 2, y: railY)

            // ── Road surface
            RoadSurfaceView(w: w)
                .frame(width: w, height: 50)
                .position(x: w / 2, y: roadY)

            // ── METRO  (r→l, elevated, most prominent)
            MetroTrainView()
                .frame(width: 220, height: 44)
                .scaleEffect(x: -1) // flip to face left
                .position(x: metroX, y: flyY - 22)
                .opacity(vFade(0.0))
                .shadow(color: Color(hex: 0x0A4174).opacity(0.35), radius: 8, y: 6)

            // ── LOCAL TRAIN  (l→r)
            LocalTrainView(wheelAngle: trainWh)
                .frame(width: 240, height: 52)
                .position(x: trainX, y: railY - 20)
                .opacity(vFade(0.0))
                .shadow(color: Color(hex: 0x1D3557).opacity(0.3), radius: 6, y: 4)

            // ── BUS  (r→l)
            CityBusView(wheelAngle: busWh)
                .frame(width: 148, height: 66)
                .scaleEffect(x: -1) // face left
                .position(x: busX, y: roadY - 24)
                .opacity(vFade(0.0))
                .shadow(color: Color(hex: 0x1D3557).opacity(0.28), radius: 6, y: 5)

            // ── CAB  (l→r)
            CabCarView(wheelAngle: cabWh)
                .frame(width: 112, height: 50)
                .position(x: cabX, y: roadY - 16)
                .opacity(vFade(0.1))
                .shadow(color: Color(hex: 0x1D3557).opacity(0.25), radius: 5, y: 4)

            // ── AUTO  (r→l)
            AutoRickshawView(wheelAngle: autoWh)
                .frame(width: 90, height: 56)
                .scaleEffect(x: -1) // face left
                .position(x: autoX, y: roadY - 20)
                .opacity(vFade(0.3))
                .shadow(color: Color(hex: 0x1D3557).opacity(0.22), radius: 4, y: 3)

            // ── BIKE  (l→r, foreground)
            MotorbikeView(wheelAngle: bikeWh)
                .frame(width: 100, height: 54)
                .position(x: bikeX, y: roadY - 14)
                .opacity(vFade(0.05))
                .shadow(color: Color(hex: 0x1D3557).opacity(0.22), radius: 4, y: 3)
        }
    }
}

// MARK: - City Background Canvas

private struct CityBackgroundCanvas: View {
    let size: CGSize

    var body: some View {
        Canvas { ctx, cs in
            let w = cs.width, h = cs.height

            // ── Atmospheric sun bloom (upper right)
            ctx.drawLayer { lc in
                let sunC = CGPoint(x: w * 0.78, y: h * 0.07)
                lc.opacity = 0.6
                let sunPath = Path(ellipseIn: CGRect(x: sunC.x - w * 0.38, y: sunC.y - h * 0.22,
                                                     width: w * 0.76, height: h * 0.44))
                lc.fill(sunPath, with: .linearGradient(
                    Gradient(stops: [
                        .init(color: Color(hex: 0xEAF4FB).opacity(0.9), location: 0),
                        .init(color: Color(hex: 0x7BBDE8).opacity(0.3), location: 0.6),
                        .init(color: .clear, location: 1)
                    ]),
                    startPoint: sunC,
                    endPoint: CGPoint(x: sunC.x, y: h * 0.4)
                ))
            }

            // ── Far background skyline
            let skylineColor = Color(hex: 0x1D3557).opacity(0.52)
            let bldgs: [(Double, Double, Double)] = [
                // (xFrac, widthFrac, heightFrac of canvas)
                (0.00, 0.052, 0.38), (0.055, 0.038, 0.31),
                (0.095, 0.072, 0.48), (0.17, 0.042, 0.35),
                (0.215, 0.080, 0.55), (0.30, 0.055, 0.42),
                (0.36, 0.038, 0.30), (0.40, 0.078, 0.50),
                (0.48, 0.045, 0.37), (0.53, 0.062, 0.58),
                (0.60, 0.040, 0.40), (0.645, 0.070, 0.46),
                (0.72, 0.052, 0.53), (0.78, 0.038, 0.33),
                (0.82, 0.072, 0.47), (0.90, 0.052, 0.38),
                (0.955, 0.045, 0.42)
            ]
            let groundY = h * 0.78
            for b in bldgs {
                let bx = CGFloat(b.0) * w
                let bw = CGFloat(b.1) * w
                let bh = CGFloat(b.2) * h * 0.78
                let rect = CGRect(x: bx, y: groundY - bh, width: bw, height: bh)
                var bPath = Path(rect)
                // Antenna
                bPath.move(to: CGPoint(x: bx + bw / 2, y: groundY - bh))
                bPath.addLine(to: CGPoint(x: bx + bw / 2, y: groundY - bh - 7))
                ctx.fill(bPath, with: .color(skylineColor))
                // Window rows
                let rows = max(2, Int(bh / 15))
                for row in 0..<rows {
                    let wy = groundY - bh + 7 + CGFloat(row) * 13
                    let winRect = CGRect(x: bx + bw * 0.2, y: wy, width: bw * 0.65, height: 4)
                    ctx.fill(Path(winRect), with: .color(Color(hex: 0xEAF4FB).opacity(0.28)))
                }
            }

            // ── Kapaleeshwarar Temple gopuram (left side)
            drawTemple(ctx: ctx, cx: w * 0.11, groundY: groundY * 0.98, h: h)

            // ── Modern glass tower cluster (right of centre)
            drawGlassTowers(ctx: ctx, startX: w * 0.60, groundY: groundY, h: h)

            // ── Greenery / tree canopy band
            drawTreeBand(ctx: ctx, w: w, h: h, bandY: groundY * 0.98)

            // ── Ground plane (grass strip)
            let grass = Path(CGRect(x: 0, y: groundY, width: w, height: h * 0.25))
            ctx.fill(grass, with: .linearGradient(
                Gradient(colors: [Color(hex: 0x299D8F).opacity(0.35), Color(hex: 0x1D3557).opacity(0.5)]),
                startPoint: CGPoint(x: 0, y: groundY),
                endPoint: CGPoint(x: 0, y: h)
            ))
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }

    private func drawTemple(ctx: GraphicsContext, cx: CGFloat, groundY: CGFloat, h: CGFloat) {
        // Layered gopuram tiers (each narrower and taller as we go up)
        let tiers: [(w: CGFloat, h: CGFloat)] = [
            (52, 10), (44, 10), (36, 10), (28, 9), (20, 9), (13, 9), (8, 10)
        ]
        var curY = groundY
        for tier in tiers {
            let rect = CGRect(x: cx - tier.w / 2, y: curY - tier.h, width: tier.w, height: tier.h)
            ctx.fill(Path(rect), with: .color(Color(hex: 0x457B9D).opacity(0.80)))
            // Decorative line at base of each tier
            ctx.stroke(Path(CGRect(x: cx - tier.w / 2, y: curY - tier.h,
                                   width: tier.w, height: 1.5)),
                       with: .color(Color(hex: 0xA8DADC).opacity(0.4)), lineWidth: 1)
            curY -= tier.h
        }
        // Kalasha finial
        ctx.fill(Path(ellipseIn: CGRect(x: cx - 5, y: curY - 10, width: 10, height: 10)),
                 with: .color(Color(hex: 0x457B9D).opacity(0.9)))
        // Base plinth
        ctx.fill(Path(CGRect(x: cx - 28, y: groundY, width: 56, height: 6)),
                 with: .color(Color(hex: 0x1D3557).opacity(0.5)))
    }

    private func drawGlassTowers(ctx: GraphicsContext, startX: CGFloat, groundY: CGFloat, h: CGFloat) {
        let towers: [(x: CGFloat, w: CGFloat, h: CGFloat)] = [
            (startX,       28, 0.52),
            (startX + 32,  22, 0.44),
            (startX + 58,  32, 0.60),
            (startX + 94,  24, 0.48)
        ]
        for t in towers {
            let bh = t.h * h
            let rect = CGRect(x: t.x, y: groundY - bh, width: t.w, height: bh)
            ctx.fill(Path(rect), with: .linearGradient(
                Gradient(colors: [Color(hex: 0x4E8EA2).opacity(0.55), Color(hex: 0x1D3557).opacity(0.65)]),
                startPoint: CGPoint(x: t.x, y: groundY - bh),
                endPoint: CGPoint(x: t.x, y: groundY)
            ))
            // Glass reflection stripe
            let refRect = CGRect(x: t.x + 3, y: groundY - bh + 4, width: 6, height: bh - 8)
            ctx.fill(Path(refRect), with: .color(Color(hex: 0xEAF4FB).opacity(0.18)))
        }
    }

    private func drawTreeBand(ctx: GraphicsContext, w: CGFloat, h: CGFloat, bandY: CGFloat) {
        let treeXs: [CGFloat] = [0.03, 0.09, 0.19, 0.28, 0.35, 0.47, 0.56, 0.68, 0.76, 0.85, 0.93, 0.98]
        for xFrac in treeXs {
            let tx = xFrac * w
            // Trunk
            ctx.fill(Path(CGRect(x: tx - 2, y: bandY - 2, width: 4, height: 14)),
                     with: .color(Color(hex: 0x1D3557).opacity(0.5)))
            // Canopy (layered circles for depth)
            ctx.fill(Path(ellipseIn: CGRect(x: tx - 12, y: bandY - 24, width: 24, height: 22)),
                     with: .color(Color(hex: 0x299D8F).opacity(0.70)))
            ctx.fill(Path(ellipseIn: CGRect(x: tx - 8, y: bandY - 28, width: 16, height: 16)),
                     with: .color(Color(hex: 0x4E8EA2).opacity(0.55)))
        }
    }
}

// MARK: - Animated Clouds

private struct AnimatedCloudsLayer: View {
    let c1x, c2x, c3x, h: CGFloat
    var body: some View {
        ZStack {
            cloud(w: 100, opacity: 0.65).position(x: c1x, y: h * 0.12)
            cloud(w: 72, opacity: 0.48).position(x: c2x, y: h * 0.08)
            cloud(w: 56, opacity: 0.38).position(x: c3x, y: h * 0.16)
        }
        .allowsHitTesting(false)
    }
    private func cloud(w: CGFloat, opacity: Double) -> some View {
        SplashCloudShape()
            .fill(Color.white.opacity(opacity))
            .frame(width: w, height: w * 0.38)
            .blur(radius: 2.5)
    }
}

// MARK: - Birds

private struct BirdsLayer: View {
    let cityT: Double
    let h, w: CGFloat
    @State private var flapOffset: CGFloat = 0
    var body: some View {
        let bx = -40 + CGFloat(cityT / 2.0) * (w + 100)
        HStack(spacing: 11) {
            ForEach(0..<5, id: \.self) { i in
                SplashBirdShape()
                    .stroke(Color(hex: 0x0A4174).opacity(0.55), lineWidth: 1.1)
                    .frame(width: 13, height: 6)
                    .offset(y: i % 2 == 0 ? flapOffset : -flapOffset)
            }
        }
        .position(x: bx, y: h * 0.18)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                flapOffset = 2.5
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Metro Flyover Structure

private struct MetroFlyoverView: View {
    let w: CGFloat
    var body: some View {
        ZStack {
            // Deck (concrete)
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color(hex: 0x457B9D).opacity(0.80), Color(hex: 0x1D3557).opacity(0.60)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: w, height: 14)
            // Rails
            VStack(spacing: 11) {
                ForEach(0..<2, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: 0xA8DADC).opacity(0.88))
                        .frame(width: w, height: 2.5)
                }
            }
            .offset(y: -6)
            // Pillars
            HStack(spacing: 0) {
                ForEach(0..<Int(w / 55), id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: 0x1D3557).opacity(0.55))
                        .frame(width: 9, height: 34)
                        .offset(y: 24)
                    Spacer().frame(width: 46)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Ground Rail Track

private struct GroundRailView: View {
    let w: CGFloat
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: 0x49769F).opacity(0.30))
                .frame(width: w, height: 20)
            VStack(spacing: 13) {
                ForEach(0..<2, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: 0x457B9D).opacity(0.82))
                        .frame(width: w, height: 3)
                }
            }
            HStack(spacing: 0) {
                ForEach(0..<Int(w / 18), id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: 0x1D3557).opacity(0.52))
                        .frame(width: 9, height: 18)
                    Spacer().frame(width: 9)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Road Surface

private struct RoadSurfaceView: View {
    let w: CGFloat
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color(hex: 0x1D3557).opacity(0.58), Color(hex: 0x0A4174).opacity(0.45)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: w, height: 50)
            // Centre white dashes
            HStack(spacing: 0) {
                ForEach(0..<12, id: \.self) { _ in
                    Rectangle().fill(Color.white.opacity(0.52)).frame(width: 22, height: 3)
                    Rectangle().fill(Color.clear).frame(width: 18, height: 3)
                }
            }
            // Kerb lines
            VStack(spacing: 42) {
                Rectangle().fill(Color(hex: 0xA8DADC).opacity(0.38)).frame(height: 1.5)
                Rectangle().fill(Color(hex: 0xA8DADC).opacity(0.38)).frame(height: 1.5)
            }
            .frame(width: w)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - METRO TRAIN (sleek, elevated)

private struct MetroTrainView: View {
    var body: some View {
        HStack(spacing: 2) {
            metroCarView(isNose: true)
            metroCarView(isNose: false)
        }
        .overlay(alignment: .topLeading) {
            // Pantograph
            Path { p in
                p.move(to: CGPoint(x: 60, y: 4))
                p.addLine(to: CGPoint(x: 68, y: -12))
                p.addLine(to: CGPoint(x: 76, y: 4))
            }
            .stroke(Color(hex: 0xA8DADC).opacity(0.8), lineWidth: 1.4)
        }
    }

    private func metroCarView(isNose: Bool) -> some View {
        ZStack {
            // Body
            UnevenRoundedRectangle(
                topLeadingRadius: isNose ? 14 : 4,
                bottomLeadingRadius: isNose ? 10 : 4,
                bottomTrailingRadius: 4,
                topTrailingRadius: 4
            )
            .fill(LinearGradient(
                colors: [Color(hex: 0xEAF4FB).opacity(0.95), Color(hex: 0xA8DADC).opacity(0.88)],
                startPoint: .top, endPoint: .bottom
            ))
            .frame(width: 102, height: 32)
            .shadow(color: Color(hex: 0x7BBDE8).opacity(0.5), radius: 8)
            // Blue accent stripe
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color(hex: 0x0A4174), Color(hex: 0x4E8EA2)],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(width: 102, height: 7)
                .offset(y: 8)
            // Windows
            HStack(spacing: 5) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: 0x7BBDE8).opacity(0.68))
                        .frame(width: 15, height: 10)
                }
            }
            .offset(y: -5)
            // Bogies
            HStack {
                bogieShape
                Spacer()
                bogieShape
            }
            .padding(.horizontal, 10)
            .offset(y: 18)
        }
        .frame(width: 102, height: 44)
    }

    private var bogieShape: some View {
        Rectangle()
            .fill(Color(hex: 0x1D3557).opacity(0.8))
            .frame(width: 22, height: 6)
    }
}

// MARK: - LOCAL TRAIN

private struct LocalTrainView: View {
    let wheelAngle: Angle
    var body: some View {
        HStack(spacing: 3) {
            trainCarView(isLead: true)
            trainCarView(isLead: false)
        }
        .overlay(alignment: .topTrailing) {
            Path { p in
                p.move(to: CGPoint(x: 160, y: 4))
                p.addLine(to: CGPoint(x: 168, y: -10))
                p.addLine(to: CGPoint(x: 176, y: 4))
            }
            .stroke(Color(hex: 0xA8DADC).opacity(0.75), lineWidth: 1.3)
        }
    }

    private func trainCarView(isLead: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: isLead ? 10 : 5, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(hex: 0x457B9D).opacity(0.9), Color(hex: 0x4E8EA2).opacity(0.75)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: 110, height: 34)
            // Windows
            HStack(spacing: 5) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: 0xEAF4FB).opacity(0.72))
                        .frame(width: 16, height: 11)
                }
            }
            .offset(y: -5)
            // Blue underline stripe
            Rectangle()
                .fill(Color(hex: 0x0A4174).opacity(0.8))
                .frame(width: 110, height: 5)
                .offset(y: 10)
            if isLead {
                Circle()
                    .fill(Color(hex: 0xEAF4FB))
                    .frame(width: 7, height: 7)
                    .offset(x: 50, y: 2)
            }
            // Wheels
            HStack {
                SplashWheelView(d: 14, angle: wheelAngle)
                Spacer()
                SplashWheelView(d: 14, angle: wheelAngle)
            }
            .padding(.horizontal, 12)
            .offset(y: 18)
        }
        .frame(width: 110, height: 52)
    }
}

// MARK: - CITY BUS

private struct CityBusView: View {
    let wheelAngle: Angle
    var body: some View {
        ZStack {
            // Body
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(hex: 0x4E8EA2).opacity(0.90), Color(hex: 0x1D3557).opacity(0.80)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: 120, height: 44)
                .offset(y: -6)
            // White accent band
            Rectangle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 120, height: 8)
                .offset(y: -16)
            // Windows row
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: 0xA8DADC).opacity(0.70))
                        .frame(width: 14, height: 11)
                }
            }
            .offset(y: -10)
            // Door
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: 0xA8DADC).opacity(0.5))
                .frame(width: 10, height: 18)
                .offset(x: -44, y: -2)
            // Destination board
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: 0xEAF4FB).opacity(0.9))
                    .frame(width: 44, height: 8)
                Text("CHENNAI")
                    .font(.system(size: 4.5, weight: .black))
                    .foregroundStyle(Color(hex: 0x1D3557))
            }
            .offset(x: -5, y: -24)
            // Front light
            Circle()
                .fill(Color(hex: 0xEAF4FB).opacity(0.8))
                .frame(width: 7, height: 7)
                .offset(x: 58, y: -4)
            // Wheels
            HStack(spacing: 60) {
                SplashWheelView(d: 20, angle: wheelAngle)
                SplashWheelView(d: 20, angle: wheelAngle)
            }
            .offset(y: 14)
        }
        .frame(width: 148, height: 66)
    }
}

// MARK: - CAB / TAXI

private struct CabCarView: View {
    let wheelAngle: Angle
    var body: some View {
        ZStack {
            // Car body (lower)
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.94), Color(hex: 0xBDD8E9).opacity(0.85)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: 90, height: 28)
                .offset(y: 2)
            // Cabin (upper)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.88))
                .frame(width: 64, height: 26)
                .offset(x: -4, y: -15)
            // Windshield
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: 0x7BBDE8).opacity(0.65))
                .frame(width: 22, height: 18)
                .offset(x: 18, y: -16)
            // Rear window
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: 0x7BBDE8).opacity(0.5))
                .frame(width: 16, height: 14)
                .offset(x: -20, y: -17)
            // TAXI badge
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: 0xF59E0B))
                    .frame(width: 30, height: 10)
                Text("TAXI")
                    .font(.system(size: 5, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: 0x1D3557))
            }
            .offset(y: -32)
            // Headlight
            Ellipse()
                .fill(Color(hex: 0xF59E0B).opacity(0.85))
                .frame(width: 10, height: 7)
                .offset(x: 44, y: 2)
            // Wheels
            HStack(spacing: 50) {
                SplashWheelView(d: 18, angle: wheelAngle)
                SplashWheelView(d: 18, angle: wheelAngle)
            }
            .offset(y: 12)
        }
        .frame(width: 112, height: 50)
    }
}

// MARK: - AUTO RICKSHAW

private struct AutoRickshawView: View {
    let wheelAngle: Angle
    var body: some View {
        ZStack {
            // Main body
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(hex: 0x9EE600).opacity(0.92), Color(hex: 0x299D8F).opacity(0.85)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 58, height: 36)
                .offset(x: 2, y: -6)
            // Canopy
            Capsule()
                .fill(Color(hex: 0x1D3557).opacity(0.72))
                .frame(width: 55, height: 11)
                .offset(x: 2, y: -24)
            // Windshield
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: 0xA8DADC).opacity(0.62))
                .frame(width: 18, height: 18)
                .offset(x: -20, y: -10)
            // Front light
            Circle()
                .fill(Color(hex: 0xEAF4FB).opacity(0.8))
                .frame(width: 6, height: 6)
                .offset(x: -32, y: -4)
            // Wheels (auto has 3: 2 rear, 1 front)
            HStack(spacing: 36) {
                SplashWheelView(d: 16, angle: wheelAngle)
                SplashWheelView(d: 16, angle: wheelAngle)
            }
            .offset(y: 10)
        }
        .frame(width: 90, height: 56)
    }
}

// MARK: - MOTORBIKE with two riders

private struct MotorbikeView: View {
    let wheelAngle: Angle
    @State private var exhaustScale: CGFloat = 0.4
    @State private var exhaustOpacity: Double = 0.5

    var body: some View {
        ZStack {
            // Bike frame
            Capsule()
                .fill(LinearGradient(
                    colors: [Color(hex: 0x457B9D), Color(hex: 0x1D3557)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 62, height: 18)
                .offset(x: 2, y: -4)
            // Fuel tank hump
            Ellipse()
                .fill(Color(hex: 0x0A4174))
                .frame(width: 22, height: 12)
                .offset(x: 6, y: -11)
            // Pillion rider (rear)
            Capsule()
                .fill(Color(hex: 0x1D3557).opacity(0.85))
                .frame(width: 14, height: 22)
                .offset(x: -8, y: -20)
            Circle()
                .fill(Color(hex: 0x0A4174))
                .frame(width: 13, height: 13)
                .offset(x: -8, y: -30)
            // Main rider
            Capsule()
                .fill(Color(hex: 0x1D3557).opacity(0.90))
                .frame(width: 14, height: 24)
                .offset(x: 8, y: -20)
            // Helmet
            Circle()
                .fill(Color(hex: 0x0A4174))
                .frame(width: 14, height: 14)
                .overlay(
                    Ellipse()
                        .fill(Color(hex: 0xA8DADC).opacity(0.5))
                        .frame(width: 8, height: 5)
                        .offset(x: 2, y: -1)
                )
                .offset(x: 8, y: -31)
            // Handlebars
            Rectangle()
                .fill(Color(hex: 0xA8DADC).opacity(0.75))
                .frame(width: 14, height: 2.5)
                .rotationEffect(.degrees(-15))
                .offset(x: 24, y: -18)
            // Front fork
            Rectangle()
                .fill(Color(hex: 0x457B9D))
                .frame(width: 3, height: 16)
                .rotationEffect(.degrees(10))
                .offset(x: 30, y: -4)
            // Wheels
            SplashWheelView(d: 20, angle: wheelAngle).offset(x: 30, y: 7)
            SplashWheelView(d: 20, angle: wheelAngle).offset(x: -24, y: 7)
            // Exhaust puff
            Circle()
                .fill(Color.white.opacity(exhaustOpacity))
                .frame(width: 10, height: 10)
                .scaleEffect(exhaustScale)
                .blur(radius: 3)
                .offset(x: -40, y: 2)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.75).repeatForever(autoreverses: false)) {
                        exhaustScale = 1.6; exhaustOpacity = 0
                    }
                }
        }
        .frame(width: 100, height: 54)
    }
}

// MARK: - Wheel

private struct SplashWheelView: View {
    let d: CGFloat
    let angle: Angle
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0x1D3557))
                .frame(width: d, height: d)
            Circle()
                .fill(Color(hex: 0xA8DADC).opacity(0.35))
                .frame(width: d * 0.48, height: d * 0.48)
            // Spokes
            ForEach(0..<4, id: \.self) { i in
                Rectangle()
                    .fill(Color(hex: 0xA8DADC).opacity(0.55))
                    .frame(width: d * 0.44, height: 1.5)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
        .rotationEffect(angle)
    }
}

// MARK: - Phone Transition (Scene 2)

private struct PhoneTransitionView: View {
    let transP: Double   // 0→1  (2.0s – 3.2s)
    let brandP: Double
    let size: CGSize

    // The phone starts small in the city scene and zooms to fill the frame
    private var phoneScale: CGFloat {
        // Spring-like: overshoot slightly then settle
        let p = easeIO(transP)
        return 0.22 + CGFloat(p) * 0.90
    }
    private var phoneOpacity: Double { clamp01(transP / 0.15) }
    // Phone y-position: starts centred in city scene (bottom half), zooms to screen centre
    private var phoneY: CGFloat {
        let start = size.height * 0.60
        let end = size.height * 0.50
        return start + CGFloat(easeIO(transP)) * (end - start)
    }

    private var phoneW: CGFloat { size.width * 0.72 }
    private var phoneH: CGFloat { phoneW * 2.165 } // iPhone 16 Pro aspect ratio

    var body: some View {
        ZStack {
            // ── Phone chassis (titanium frame)
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0x2a2a2e),
                            Color(hex: 0x1a1a1e),
                            Color(hex: 0x2e2e34)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: phoneW, height: phoneH)
                .shadow(color: Color.black.opacity(0.55), radius: 32, y: 16)

            // ── Titanium rim highlight
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color(hex: 0x9E9EA6).opacity(0.2),
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: phoneW, height: phoneH)

            // ── Screen area (inset from chassis)
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color(hex: 0x1D3557))
                .frame(width: phoneW - 12, height: phoneH - 12)
                .overlay {
                    // Screen shows brand background
                    if brandP > 0 {
                        LinearGradient(
                            stops: [
                                .init(color: Color(hex: 0xEAF4FB), location: 0.0),
                                .init(color: Color(hex: 0xBDD8E9), location: 0.18),
                                .init(color: Color(hex: 0x7BBDE8), location: 0.42),
                                .init(color: Color(hex: 0x4E8EA2), location: 0.72),
                                .init(color: Color(hex: 0x1D3557), location: 1.0)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                        .opacity(easeOut(brandP))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))

            // ── Dynamic Island
            Capsule()
                .fill(Color(hex: 0x0a0a0c))
                .frame(width: 100, height: 32)
                .offset(y: -(phoneH / 2 - 28))

            // ── Side buttons (volume left)
            Group {
                ForEach([phoneH * -0.22, phoneH * -0.10] as [CGFloat], id: \.self) { yOff in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: 0x2a2a2e))
                        .frame(width: 4, height: 36)
                        .offset(x: -(phoneW / 2 + 2), y: yOff)
                }
                // Power button (right)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: 0x2a2a2e))
                    .frame(width: 4, height: 48)
                    .offset(x: phoneW / 2 + 2, y: phoneH * -0.08)
            }
        }
        .frame(width: phoneW, height: phoneH)
        .scaleEffect(phoneScale)
        .position(x: size.width / 2, y: phoneY)
        .opacity(phoneOpacity)
    }
}

// MARK: - Brand Reveal (Scene 3)

struct BrandRevealView: View {
    let t: Double      // 0…1
    let size: CGSize

    // Individual element timings
    private var logoT:    Double { clamp01(t / 0.35) }
    private var pinT:     Double { clamp01((t - 0.25) / 0.30) }
    private var swooshT:  Double { clamp01((t - 0.35) / 0.30) }
    private var taglineT: Double { clamp01((t - 0.55) / 0.40) }
    private var pillsT:   Double { clamp01((t - 0.70) / 0.30) }
    private var glowT:    Double { clamp01((t - 0.60) / 0.40) }

    // Logo spring scale
    private var logoScale: CGFloat {
        let raw = easeOut(logoT)
        // Slight overshoot
        if logoT < 0.75 { return CGFloat(raw) * 1.08 }
        return CGFloat(raw)
    }

    // Pin drop (bounces in from above)
    private var pinOffset: CGFloat { -20 + CGFloat(easeOut(pinT)) * 20 }

    var body: some View {
        // Full-screen brand background
        ZStack {
            RaahaScreenBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // ── RAAHA Wordmark
                    ZStack(alignment: .topTrailing) {
                        Text("RAAHA")
                            .font(.system(size: 56, weight: .black, design: .rounded))
                            .tracking(3.5)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color(hex: 0xBDD8E9)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: 0x0A4174).opacity(0.3 + 0.4 * glowT),
                                    radius: 16 + 12 * glowT, x: 0, y: 4)

                        // Location pin
                        SplashPinView()
                            .offset(x: 14, y: -10 + pinOffset)
                            .opacity(easeOut(pinT))
                            .scaleEffect(0.5 + CGFloat(easeOut(pinT)) * 0.5)
                    }
                    .scaleEffect(max(0.01, logoScale))
                    .opacity(easeOut(logoT))
                    .padding(.bottom, 10)

                    // ── Motion swoosh line
                    SwooshLineView()
                        .opacity(easeOut(swooshT))
                        .scaleEffect(x: CGFloat(easeOut(swooshT)), anchor: .leading)
                        .padding(.bottom, 18)

                    // ── Tagline
                    Text("Every Path Leads to You")
                        .font(.system(size: 17, weight: .medium, design: .serif).italic())
                        .foregroundStyle(Color.white.opacity(0.92))
                        .tracking(0.5)
                        .opacity(easeOut(taglineT))
                        .padding(.bottom, 24)

                    // ── Mode pills
                    HStack(spacing: 10) {
                        ForEach(Array(modePills.enumerated()), id: \.offset) { idx, pill in
                            pillView(icon: pill, delay: Double(idx) * 0.08)
                        }
                    }
                    .opacity(easeOut(pillsT))
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 90)
            }
        }
        .ignoresSafeArea()
    }

    private let modePills = ["bicycle", "car.fill", "bus.fill", "tram.fill", "train.side.front.car"]

    private func pillView(icon: String, delay: Double) -> some View {
        let localT = max(0, pillsT - delay / 0.3)
        return Image(systemName: icon)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color(hex: 0x0A4174))
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.82))
                    .background(.ultraThinMaterial, in: Circle())
            )
            .overlay(Circle().stroke(Color(hex: 0xA8DADC).opacity(0.6), lineWidth: 1))
            .scaleEffect(max(0.01, CGFloat(easeOut(clamp01(localT * 3)))))
            .opacity(easeOut(clamp01(localT * 3)))
    }
}

// MARK: - Swoosh Line

private struct SwooshLineView: View {
    var body: some View {
        Path { p in
            p.move(to: CGPoint(x: 10, y: 4))
            p.addQuadCurve(to: CGPoint(x: 164, y: 4), control: CGPoint(x: 87, y: -5))
        }
        .stroke(
            LinearGradient(
                colors: [Color(hex: 0x7BBDE8).opacity(0.9), Color(hex: 0xA8DADC).opacity(0.4)],
                startPoint: .leading, endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 2.8, lineCap: .round)
        )
        .frame(width: 174, height: 10)
    }
}

// MARK: - Splash Location Pin

private struct SplashPinView: View {
    var body: some View {
        ZStack {
            PinTeardropShape()
                .fill(Color(hex: 0xE63946))
                .frame(width: 22, height: 30)
                .shadow(color: Color(hex: 0xE63946).opacity(0.55), radius: 8, x: 0, y: 3)
            Circle()
                .fill(Color.white)
                .frame(width: 7, height: 7)
                .offset(y: -5)
        }
    }
}

// MARK: - Shared Shapes

private struct SplashCloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: CGRect(x: rect.width*0.08, y: rect.height*0.28,
                                width: rect.width*0.50, height: rect.height*0.68))
        p.addEllipse(in: CGRect(x: rect.width*0.28, y: rect.height*0.08,
                                width: rect.width*0.44, height: rect.height*0.70))
        p.addEllipse(in: CGRect(x: rect.width*0.54, y: rect.height*0.28,
                                width: rect.width*0.40, height: rect.height*0.62))
        p.addRect(CGRect(x: rect.width*0.08, y: rect.height*0.55,
                         width: rect.width*0.86, height: rect.height*0.45))
        return p
    }
}

private struct SplashBirdShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: 0, y: h * 0.5))
        p.addQuadCurve(to: CGPoint(x: w*0.5, y: 0), control: CGPoint(x: w*0.25, y: h*0.3))
        p.addQuadCurve(to: CGPoint(x: w, y: h*0.5), control: CGPoint(x: w*0.75, y: h*0.3))
        return p
    }
}
