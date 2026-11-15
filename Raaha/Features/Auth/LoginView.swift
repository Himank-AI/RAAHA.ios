import SwiftUI

/// Flow screens for RAAHA authentication
enum AuthFlowScreen: Hashable {
    case emailLogin
    case signUp
}

/// RAAHA Login / Sign Up screen.
struct LoginView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var navigationPath: [AuthFlowScreen] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            landingView
                .navigationDestination(for: AuthFlowScreen.self) { screen in
                    switch screen {
                    case .emailLogin:
                        EmailLoginView(
                            onSuccess: { handleLoginSuccess() },
                            onNavigateToSignUp: {
                                if !navigationPath.isEmpty {
                                    navigationPath.removeLast()
                                }
                                navigationPath.append(.signUp)
                            }
                        )
                        .navigationBarBackButtonHidden(true)

                    case .signUp:
                        SignUpView(
                            onSuccess: { handleLoginSuccess() },
                            onNavigateToSignIn: {
                                if !navigationPath.isEmpty {
                                    navigationPath.removeLast()
                                }
                                navigationPath.append(.emailLogin)
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                    }
                }
        }
    }

    private var landingView: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Color.clear
                Image("login_bottom_scene")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width)
                    .saturation(0.38)
                    .contrast(0.88)
                    .brightness(0.08)
                    .colorMultiply(Color(hex: 0xD7EEF8))
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.42),
                                .init(color: .black.opacity(0.55), location: 0.58),
                                .init(color: .black, location: 0.72)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(1.2, anchor: .bottom)
                    .accessibilityHidden(true)

                VStack(spacing: 0) {
                    Image("login_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.42)
                        .padding(.top, geo.safeAreaInsets.top + 36)
                        .accessibilityLabel("RAAHA")
                        .offset(y: 40)
                    Spacer(minLength: 0)
                    ZStack(alignment: .top) {
                        skyClouds(width: geo.size.width)
                            .opacity(0.72)
                            .offset(y: -62)
                        transitPanorama
                    }
                    .padding(.bottom, 6)
                    welcomeCard
                        .padding(.horizontal, 18)
                        .padding(.bottom, max(geo.safeAreaInsets.bottom, 10) + 64)
                        .offset(y: -42)
                }
            }
            .overlay(alignment: .topTrailing) {
                ZStack(alignment: .topTrailing) {
                    // Primary birds flock to the right of logo
                    Image("login_birds")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.12)
                        .padding(.top, geo.safeAreaInsets.top + 88)
                        .padding(.trailing, 6)
                        .accessibilityHidden(true)
                        .offset(x: -40, y: 40)

                    // Secondary birds flock higher up on top right
                    Image("birds")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.11)
                        .padding(.top, geo.safeAreaInsets.top + 34)
                        .padding(.trailing, 18)
                        .opacity(0.85)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .raahaScreenBackground()
        .ignoresSafeArea()
    }

    /// Left cloud, plus the same artwork mirrored across the vertical axis for the right side.
    private func skyClouds(width: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            cloudImage
                .frame(width: width * 0.34)
                .offset(x: -8)
            Spacer(minLength: 0)
            cloudImage
                .frame(width: width * 0.24)
                .scaleEffect(x: -1.5)
                .offset(x: 16, y: 18)
        }
        .accessibilityHidden(true)
    }

    private var cloudImage: some View {
        Image("login_cloud")
            .resizable()
            .scaledToFit()
    }

    /// City transit band. Sits just above the welcome card, fading into the sky at the top the way the reference does.
    private var transitPanorama: some View {
        Image("login_transit_panorama")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .saturation(0.82)
            .contrast(0.9)
            .brightness(0.05)
            .colorMultiply(Color(hex: 0xE4F4FC))
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black.opacity(0.4), location: 0.12),
                        .init(color: .black, location: 0.28),
                        .init(color: .black, location: 0.58),
                        .init(color: .black.opacity(0.65), location: 0.74),
                        .init(color: .black.opacity(0.12), location: 0.88),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .scaleEffect(1.15, anchor: .bottom)
            .offset(y: 20)
            .accessibilityHidden(true)
    }

    private var welcomeCard: some View {
        VStack(spacing: 14) {
            Text("Welcome to RAAHA!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.deepSpace)

            Text("Sign in to plan your next journey in Chennai")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.deepSpace.opacity(0.72))
                .padding(.bottom, 2)

            signInRow("Continue with Email", action: { navigationPath.append(.emailLogin) }) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color(hex: 0x3B82C4)))
            }

            signInRow("Continue with Google", action: handleLoginSuccess) {
                GoogleLogoView(size: 22)
                    .frame(width: 34, height: 34)
            }

            signInRow("Continue with Apple", action: handleLoginSuccess) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.black)
                    .frame(width: 34, height: 34)
            }

            HStack(spacing: 10) {
                Capsule()
                    .fill(Color.deepSpace.opacity(0.18))
                    .frame(width: 42, height: 1)
                Text("Don't have an account?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.deepSpace.opacity(0.8))
                Button("Sign Up") { navigationPath.append(.signUp) }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.neonLime)
                Capsule()
                    .fill(Color.deepSpace.opacity(0.18))
                    .frame(width: 42, height: 1)
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 22)
        .padding(.bottom, 16)
        .background { welcomeGlass }
        .shadow(color: Color.white.opacity(0.35), radius: 1, x: 0, y: 1)
        .shadow(color: Color(hex: 0x4E8EA2).opacity(0.28), radius: 24, x: 0, y: 14)
    }

    private var welcomeGlass: some View {
        let shape = RoundedRectangle(cornerRadius: 32, style: .continuous)
        return ZStack {
            shape.fill(.ultraThinMaterial)
            shape.fill(
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(0.18), location: 0),
                        .init(color: Color(hex: 0xEAF6FC).opacity(0.08), location: 0.45),
                        .init(color: Color(hex: 0xC5E4F4).opacity(0.04), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            shape.fill(
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(0.42), location: 0),
                        .init(color: Color.white.opacity(0.08), location: 0.14),
                        .init(color: Color.clear, location: 0.32)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            shape.fill(
                RadialGradient(
                    colors: [Color.white.opacity(0.28), Color.clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 240
                )
            )
        }
        .overlay {
            shape.strokeBorder(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.98),
                        Color.white.opacity(0.55),
                        Color(hex: 0x7BBDE8).opacity(0.30),
                        Color.white.opacity(0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.4
            )
        }
        .overlay {
            shape.inset(by: 1.5)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.65), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    ),
                    lineWidth: 1
                )
        }
    }

    private func signInRow<Icon: View>(_ title: String, action: @escaping () -> Void, @ViewBuilder icon: () -> Icon) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                icon()
                Rectangle()
                    .fill(Color.deepSpace.opacity(0.12))
                    .frame(width: 1, height: 22)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.deepSpace)
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.deepSpace.opacity(0.45))
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.92))
                    .background(.ultraThinMaterial, in: Capsule())
            )
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.9), lineWidth: 1))
            .shadow(color: Color.deepSpace.opacity(0.06), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions
    private func handleLoginSuccess() {
        withAnimation(.easeInOut(duration: 0.3)) {
            router.showLogin = false
            dismiss()
        }
    }
}

// MARK: - Custom RAAHA Location Pin
struct RaahaLocationPin: View {
    var body: some View {
        ZStack {
            PinTeardropShape()
                .fill(Color(hex: 0xEE4D4D))
                .frame(width: 17, height: 23)

            Circle()
                .fill(Color.white)
                .frame(width: 5.5, height: 5.5)
                .offset(y: -4)
        }
    }
}

struct PinTeardropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = rect.width / 2
        let center = CGPoint(x: rect.midX, y: radius)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(145),
            endAngle: .degrees(35),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Vector Google "G" Logo
struct GoogleLogoView: View {
    var size: CGFloat = 20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 24.0
            context.scaleBy(x: scale, y: scale)

            // Red (top arc)
            var red = Path()
            red.move(to: CGPoint(x: 12, y: 5))
            red.addCurve(to: CGPoint(x: 17.5, y: 7.2), control1: CGPoint(x: 14.1, y: 5), control2: CGPoint(x: 16, y: 5.8))
            red.addLine(to: CGPoint(x: 20.8, y: 3.9))
            red.addCurve(to: CGPoint(x: 12, y: 0.5), control1: CGPoint(x: 18.3, y: 1.6), control2: CGPoint(x: 15.3, y: 0.5))
            red.addCurve(to: CGPoint(x: 3.6, y: 5.4), control1: CGPoint(x: 8.3, y: 0.5), control2: CGPoint(x: 5.2, y: 2.5))
            red.addLine(to: CGPoint(x: 7.5, y: 8.5))
            red.addCurve(to: CGPoint(x: 12, y: 5), control1: CGPoint(x: 8.6, y: 6.4), control2: CGPoint(x: 10.2, y: 5))
            context.fill(red, with: .color(Color(hex: 0xEA4335)))

            // Yellow (bottom-left arc)
            var yellow = Path()
            yellow.move(to: CGPoint(x: 3.6, y: 5.4))
            yellow.addLine(to: CGPoint(x: 7.5, y: 8.5))
            yellow.addCurve(to: CGPoint(x: 7, y: 12), control1: CGPoint(x: 7.2, y: 9.6), control2: CGPoint(x: 7, y: 10.8))
            yellow.addCurve(to: CGPoint(x: 7.5, y: 15.5), control1: CGPoint(x: 7, y: 13.2), control2: CGPoint(x: 7.2, y: 14.4))
            yellow.addLine(to: CGPoint(x: 3.6, y: 18.6))
            yellow.addCurve(to: CGPoint(x: 2, y: 12), control1: CGPoint(x: 2.6, y: 16.6), control2: CGPoint(x: 2, y: 14.4))
            yellow.addCurve(to: CGPoint(x: 3.6, y: 5.4), control1: CGPoint(x: 2, y: 9.6), control2: CGPoint(x: 2.6, y: 7.4))
            context.fill(yellow, with: .color(Color(hex: 0xFBBC05)))

            // Green (bottom arc)
            var green = Path()
            green.move(to: CGPoint(x: 12, y: 19))
            green.addCurve(to: CGPoint(x: 7.5, y: 15.5), control1: CGPoint(x: 10.2, y: 19), control2: CGPoint(x: 8.6, y: 17.6))
            green.addLine(to: CGPoint(x: 3.6, y: 18.6))
            green.addCurve(to: CGPoint(x: 12, y: 23.5), control1: CGPoint(x: 5.2, y: 21.5), control2: CGPoint(x: 8.3, y: 23.5))
            green.addCurve(to: CGPoint(x: 20.3, y: 19.8), control1: CGPoint(x: 15.5, y: 23.5), control2: CGPoint(x: 18.4, y: 22.2))
            green.addLine(to: CGPoint(x: 16.5, y: 16.8))
            green.addCurve(to: CGPoint(x: 12, y: 19), control1: CGPoint(x: 15.3, y: 18.2), control2: CGPoint(x: 13.8, y: 19))
            context.fill(green, with: .color(Color(hex: 0x34A853)))

            // Blue (crossbar & right arc)
            var blue = Path()
            blue.move(to: CGPoint(x: 22, y: 12))
            blue.addLine(to: CGPoint(x: 12, y: 12))
            blue.addLine(to: CGPoint(x: 12, y: 16.5))
            blue.addLine(to: CGPoint(x: 17.8, y: 16.5))
            blue.addCurve(to: CGPoint(x: 16.5, y: 16.8), control1: CGPoint(x: 17.4, y: 16.6), control2: CGPoint(x: 17, y: 16.7))
            blue.addLine(to: CGPoint(x: 20.3, y: 19.8))
            blue.addCurve(to: CGPoint(x: 22, y: 12), control1: CGPoint(x: 21.4, y: 17.6), control2: CGPoint(x: 22, y: 14.9))
            context.fill(blue, with: .color(Color(hex: 0x4285F4)))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    LoginView()
        .environment(AppRouter())
}

