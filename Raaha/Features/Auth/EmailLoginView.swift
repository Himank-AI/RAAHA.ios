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
        ZStack(alignment: .top) {
            // Background ignoring safe area
            LinearGradient.raahaScreen
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Back button
                    HStack {
                        AuthBackButton {
                            dismiss()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 6)

                    VStack(alignment: .leading, spacing: 14) {
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
                                            .foregroundStyle(rememberMe ? Color.neonLime : Color.lightSkyBlue)

                                        Text("Remember me")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(Color.midnightBlue.opacity(0.85))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())

                                Spacer()

                                Button {
                                    showForgotPasswordAlert = true
                                } label: {
                                    Text("Forgot Password?")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.neonLime)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
                        )
                        .shadow(color: Color.midnightBlue.opacity(0.40), radius: 16, x: 0, y: 6)

                        // Primary Sign In Button
                        signInButton

                        // Or Divider
                        socialDivider

                        // Social Buttons Row
                        socialButtonsRow

                        // Switch to Sign Up Prompt
                        signUpPrompt
                            .padding(.top, 4)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
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
                .foregroundStyle(Color.midnightBlue)

            Text("Enter your credentials to manage your journeys, metro passes, and saved Chennai routes.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.royalBlue.opacity(0.75))
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
        .disabled(isLoading)
    }

    // MARK: - Social Divider
    private var socialDivider: some View {
        HStack(spacing: 14) {
            LinearGradient(
                colors: [Color.clear, Color.white.opacity(0.35)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)

            Text("or continue with")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.90))

            LinearGradient(
                colors: [Color.white.opacity(0.35), Color.clear],
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
                        .foregroundStyle(Color.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 1)
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
                        .foregroundStyle(Color.white)
                    Text("Apple")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 1)
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
                .foregroundStyle(Color.white.opacity(0.90))

            Button {
                onNavigateToSignUp()
            } label: {
                VStack(spacing: 2) {
                    Text("Sign Up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.neonLime)

                    // Hand-drawn red curved underline
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 1))
                        p.addQuadCurve(to: CGPoint(x: 52, y: 1), control: CGPoint(x: 26, y: 4))
                    }
                    .stroke(
                        Color.neonLime,
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

#Preview {
    EmailLoginView(onSuccess: {}, onNavigateToSignUp: {})
}
