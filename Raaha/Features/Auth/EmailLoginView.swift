import SwiftUI

/// Screen presented when user taps "Continue with Email" on the RAAHA login landing screen.
struct EmailLoginView: View {
    let onSuccess: () -> Void
    let onNavigateToSignUp: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = true
    @State private var isLoading: Bool = false
    @State private var showForgotPasswordAlert: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Back button only (no RAAHA logo)
                    HStack {
                        AuthBackButton {
                            dismiss()
                        }
                        Spacer()
                    }
                    .padding(.top, proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top + 8 : 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)

                    VStack(alignment: .leading, spacing: 24) {
                        // Header Titles
                        headerTitles

                        // Error Message Banner (if any)
                        if let error = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(Color.strawberry)
                                Text(error)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.strawberry)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.strawberry.opacity(0.12))
                            )
                        }

                        // Form Card
                        VStack(spacing: 16) {
                            AuthInputField(
                                title: "Email Address",
                                placeholder: "name@example.com",
                                systemImage: "envelope.fill",
                                text: $email,
                                keyboardType: .emailAddress,
                                textContentType: .emailAddress
                            )

                            AuthInputField(
                                title: "Password",
                                placeholder: "Enter your password",
                                systemImage: "lock.fill",
                                text: $password,
                                textContentType: .password,
                                isSecure: true
                            )

                            // Remember Me & Forgot Password Row
                            HStack {
                                Button {
                                    rememberMe.toggle()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                            .font(.system(size: 17))
                                            .foregroundStyle(rememberMe ? Color.strawberry : Color.steelBlue)

                                        Text("Remember me")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(Color.deepSpace.opacity(0.85))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())

                                Spacer()

                                Button {
                                    showForgotPasswordAlert = true
                                } label: {
                                    Text("Forgot Password?")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.strawberry)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white.opacity(0.72))
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color(hex: 0x78B9C8).opacity(0.4), lineWidth: 1.2)
                        )
                        .shadow(color: Color.deepSpace.opacity(0.06), radius: 10, x: 0, y: 4)

                        // Primary Sign In Button
                        signInButton

                        // Or Divider
                        socialDivider

                        // Social Buttons Row
                        socialButtonsRow

                        // Switch to Sign Up Prompt
                        signUpPrompt
                            .padding(.top, 6)
                            .padding(.bottom, proxy.safeAreaInsets.bottom > 0 ? 16 : 24)
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .raahaScreenBackground()
        .ignoresSafeArea()
        .alert("Reset Password", isPresented: $showForgotPasswordAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(email.isEmpty ? "Please enter your email address to receive password reset instructions." : "Password reset instructions have been sent to \(email).")
        }
    }

    // MARK: - Header Titles
    private var headerTitles: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sign in with Email")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.deepSpace)

            Text("Enter your credentials to manage your journeys, metro passes, and saved Chennai routes.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.steelBlue)
                .lineSpacing(2)
        }
    }

    // MARK: - Sign In Action Button
    private var signInButton: some View {
        Button {
            performSignIn()
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Sign In")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0xEE4D4D), Color(hex: 0xD83A3A)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color(hex: 0xEE4D4D).opacity(0.35), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(TactileButtonStyle())
        .disabled(isLoading)
    }

    // MARK: - Social Divider
    private var socialDivider: some View {
        HStack(spacing: 14) {
            LinearGradient(
                colors: [Color.clear, Color(hex: 0x76B6C4).opacity(0.45)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)

            Text("or continue with")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.steelBlue)

            LinearGradient(
                colors: [Color(hex: 0x76B6C4).opacity(0.45), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
        }
    }

    // MARK: - Social Buttons Row
    private var socialButtonsRow: some View {
        HStack(spacing: 12) {
            // Google
            Button {
                performSignIn()
            } label: {
                HStack(spacing: 8) {
                    GoogleLogoView(size: 18)
                    Text("Google")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.deepSpace)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.85))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(hex: 0x78B9C8).opacity(0.4), lineWidth: 1)
                )
            }
            .buttonStyle(TactileButtonStyle())

            // Apple
            Button {
                performSignIn()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.black)
                    Text("Apple")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.deepSpace)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.85))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(hex: 0x78B9C8).opacity(0.4), lineWidth: 1)
                )
            }
            .buttonStyle(TactileButtonStyle())
        }
    }

    // MARK: - Sign Up Prompt
    private var signUpPrompt: some View {
        HStack(spacing: 6) {
            Text("Don't have an account?")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.deepSpace.opacity(0.85))

            Button {
                onNavigateToSignUp()
            } label: {
                VStack(spacing: 2) {
                    Text("Sign Up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(hex: 0xEE4D4D))

                    // Hand-drawn red curved underline
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 1))
                        p.addQuadCurve(to: CGPoint(x: 52, y: 1), control: CGPoint(x: 26, y: 4))
                    }
                    .stroke(
                        Color(hex: 0xEE4D4D),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 52, height: 4)
                }
            }
            .buttonStyle(TactileButtonStyle(scale: 0.95))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Sign In Logic
    private func performSignIn() {
        errorMessage = nil

        // If email and password are empty, show validation or default for preview
        if email.isEmpty {
            email = "traveler@raaha.in"
        }
        if password.isEmpty {
            password = "password123"
        }

        isLoading = true
        // Simulate quick authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            isLoading = false
            onSuccess()
        }
    }
}
