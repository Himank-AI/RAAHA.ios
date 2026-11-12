import SwiftUI

/// Flow screens for RAAHA authentication
enum AuthFlowScreen: Hashable {
    case emailLogin
    case signUp
}

/// RAAHA Login / Sign Up screen.
/// Layers the Chennai multimodal transportation hero illustration on top of the established RAAHA calm motion screen background.
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
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1 & 2. Overlapping Hero Section (Illustration with Centered Branding brought down)
                    ZStack(alignment: .top) {
                        heroIllustration(width: proxy.size.width)

                        brandingHeader
                            .padding(.top, proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top + 6 : 20)
                    }

                    // 3. Welcome Titles
                    welcomeHeadings
                        .padding(.top, 2)
                        .padding(.bottom, 20)

                    // 4. Action Buttons (Email, Google, Apple)
                    actionButtons
                        .padding(.horizontal, 24)

                    // 5. "or" Divider
                    orDivider
                        .padding(.top, 16)
                        .padding(.bottom, 14)

                    // 6. Sign Up Option
                    signUpPrompt
                        .padding(.bottom, 20)

                    // 7. Terms of Service & Privacy Policy
                    termsFooter
                        .padding(.horizontal, 28)
                        .padding(.bottom, proxy.safeAreaInsets.bottom > 0 ? 16 : 28)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
            }
        }
        // Exact established RAAHA Trips screen background preserved
        .raahaScreenBackground()
        .ignoresSafeArea()
    }

    // MARK: - 1. Branding Header
    private var brandingHeader: some View {
        VStack(spacing: 6) {
            ZStack {
                // Soft electric blue motion swoosh trailing behind logo
                Path { p in
                    p.move(to: CGPoint(x: 10, y: 32))
                    p.addQuadCurve(
                        to: CGPoint(x: 200, y: 12),
                        control: CGPoint(x: 115, y: 36)
                    )
                }
                .stroke(
                    LinearGradient(
                        colors: [Color.brightBlue.opacity(0.8), Color.lightSkyBlue.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                )
                .frame(width: 210, height: 42)

                // Center-aligned RAAHA text with pin overlaid at top-trailing
                Text("RAAHA")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.electricBlue.opacity(0.6), radius: 10, x: 0, y: 3)
                    .overlay(alignment: .topTrailing) {
                        RaahaLocationPin()
                            .offset(x: 18, y: -6)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // Center-aligned Tagline
            Text("Every Path Leads to You")
                .font(.system(size: 15, weight: .medium, design: .serif).italic())
                .foregroundStyle(Color.icyBlue)
                .tracking(0.3)
                .shadow(color: Color.midnightBlue.opacity(0.6), radius: 4, x: 0, y: 1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - 2. Multimodal Hero Illustration
    private func heroIllustration(width: CGFloat) -> some View {
        Image("chennai_multimodal_panorama")
            .resizable()
            .scaledToFill()
            .frame(width: width, height: 360, alignment: .top)
            .offset(y: -40)          // shift image upward inside the clipped frame
            .clipped()
            // Gentle gradient mask blending edges into the deep blue gradient background
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black.opacity(0.85), location: 0.06),
                        .init(color: .black, location: 0.18),
                        .init(color: .black, location: 0.86),
                        .init(color: .black.opacity(0.4), location: 0.94),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .padding(.vertical, -4)
    }

    // MARK: - 3. Welcome Headings
    private var welcomeHeadings: some View {
        VStack(spacing: 5) {
            Text("Welcome to RAAHA!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)

            VStack(spacing: 3) {
                Text("Plan. Travel. Explore Chennai.")
                    .font(.system(size: 16, weight: .medium, design: .serif).italic())
                    .foregroundStyle(Color.white.opacity(0.92))

                // Glowing electric cyan accent underline
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 2))
                    p.addQuadCurve(to: CGPoint(x: 100, y: 2), control: CGPoint(x: 50, y: -1))
                }
                .stroke(
                    LinearGradient(
                        colors: [Color.neonLime, Color.brightBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 100, height: 4)
            }
        }
    }

    // MARK: - 4. Action Buttons (Fintech Glassmorphism Style)
    private var actionButtons: some View {
        VStack(spacing: 14) {
            // Continue with Email (Electric Blue Primary Button)
            Button {
                navigationPath.append(.emailLogin)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 20)

                    Text("Continue with Email")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.brightBlue, Color.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.40), lineWidth: 1)
                        )
                        .shadow(color: Color.electricBlue.opacity(0.45), radius: 12, x: 0, y: 6)
                )
            }
            .buttonStyle(TactileButtonStyle())

            // Continue with Google (Frosted Glass Pill)
            Button {
                handleLoginSuccess()
            } label: {
                HStack(spacing: 10) {
                    GoogleLogoView(size: 20)
                        .frame(width: 20)

                    Text("Continue with Google")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .background(.ultraThinMaterial, in: Capsule())
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.30), lineWidth: 1.2)
                )
                .shadow(color: Color.midnightBlue.opacity(0.25), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(TactileButtonStyle())

            // Continue with Apple (Frosted Glass Pill)
            Button {
                handleLoginSuccess()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 20)

                    Text("Continue with Apple")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .background(.ultraThinMaterial, in: Capsule())
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.30), lineWidth: 1.2)
                )
                .shadow(color: Color.midnightBlue.opacity(0.25), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(TactileButtonStyle())
        }
    }

    // MARK: - 5. "or" Divider
    private var orDivider: some View {
        HStack(spacing: 16) {
            LinearGradient(
                colors: [Color.clear, Color.white.opacity(0.35)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)

            Text("or")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.90))

            LinearGradient(
                colors: [Color.white.opacity(0.35), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
        }
        .padding(.horizontal, 44)
    }

    // MARK: - 6. Sign Up Prompt
    private var signUpPrompt: some View {
        HStack(spacing: 6) {
            Text("Don't have an account?")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.92))

            Button {
                navigationPath.append(.signUp)
            } label: {
                VStack(spacing: 2) {
                    Text("Sign Up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.neonLime)

                    // Hand-drawn style neon lime curved underline
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 1))
                        p.addQuadCurve(to: CGPoint(x: 56, y: 1), control: CGPoint(x: 28, y: 4.5))
                    }
                    .stroke(
                        Color.neonLime,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 56, height: 4)
                }
            }
            .buttonStyle(TactileButtonStyle(scale: 0.95))
        }
    }

    // MARK: - 7. Terms of Service & Privacy Policy
    private var termsFooter: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "shield.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.85))

            VStack(alignment: .leading, spacing: 2) {
                Text("By continuing, you agree to our")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.85))

                HStack(spacing: 3) {
                    Button {
                        // Terms tapped
                    } label: {
                        Text("Terms of Service")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white)
                    }

                    Text("and")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.85))

                    Button {
                        // Privacy tapped
                    } label: {
                        Text("Privacy Policy")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
            }
        }
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

