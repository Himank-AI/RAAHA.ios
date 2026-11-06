import SwiftUI

/// Screen presented when user taps "Sign Up" on the RAAHA landing or email sign-in screen.
struct SignUpView: View {
    let onSuccess: () -> Void
    let onNavigateToSignIn: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var agreeToTerms: Bool = true
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    // Password strength calculation
    private var passwordStrength: (level: Int, title: String, color: Color) {
        if password.isEmpty {
            return (0, "", .clear)
        } else if password.count < 6 {
            return (1, "Weak", Color.strawberry)
        } else if password.count < 8 {
            return (2, "Fair", Color(hex: 0xF59E0B))
        } else if password.count < 10 {
            return (3, "Good", Color.brightBlue)
        } else {
            return (4, "Strong", Color.neonLime)
        }
    }

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
                    .padding(.bottom, 16)

                    VStack(alignment: .leading, spacing: 22) {
                        // Header Titles
                        headerTitles

                        // Error Message Banner
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
                                    .fill(Color.strawberry.opacity(0.18))
                            )
                        }

                        // Form Card
                        VStack(spacing: 16) {
                            // Full Name
                            AuthInputField(
                                title: "Full Name",
                                placeholder: "e.g. Aditi Raman",
                                systemImage: "person.fill",
                                text: $fullName,
                                textContentType: .name
                            )

                            // Email Address
                            AuthInputField(
                                title: "Email Address",
                                placeholder: "aditi@example.com",
                                systemImage: "envelope.fill",
                                text: $email,
                                keyboardType: .emailAddress,
                                textContentType: .emailAddress
                            )

                            // Mobile Number Field
                            phoneNumberField

                            // Password
                            VStack(alignment: .leading, spacing: 6) {
                                AuthInputField(
                                    title: "Password",
                                    placeholder: "At least 8 characters",
                                    systemImage: "lock.fill",
                                    text: $password,
                                    textContentType: .newPassword,
                                    isSecure: true
                                )

                                // Real-time password strength meter
                                if !password.isEmpty {
                                    passwordStrengthView
                                        .padding(.top, 2)
                                }
                            }

                            // Terms Agreement Checkbox
                            termsAgreementCheckbox
                                .padding(.top, 4)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.midnightBlue.opacity(0.35), radius: 20, x: 0, y: 10)

                        // Primary Create Account Button
                        createAccountButton

                        // Social Divider
                        socialDivider

                        // Social Buttons Row
                        socialButtonsRow

                        // Switch to Sign In Prompt
                        signInPrompt
                            .padding(.top, 4)
                            .padding(.bottom, proxy.safeAreaInsets.bottom > 0 ? 18 : 28)
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
    }

    // MARK: - Header Titles
    private var headerTitles: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Create Account")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
        }
    }

    // MARK: - Mobile Number Field
    private var phoneNumberField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Mobile Number")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.9))

                Text("(for transit alerts)")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.lightSkyBlue)
            }

            HStack(spacing: 10) {
                // Country Code Pill
                HStack(spacing: 4) {
                    Text("🇮🇳")
                        .font(.system(size: 14))
                    Text("+91")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .padding(.horizontal, 10)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.20), lineWidth: 1)
                )

                // Phone Input
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.lightSkyBlue)

                    TextField("98765 43210", text: $phoneNumber)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.white)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
                .padding(.horizontal, 14)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.20), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Password Strength View
    private var passwordStrengthView: some View {
        let strength = passwordStrength
        return HStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(1...4, id: \.self) { index in
                    Capsule()
                        .fill(index <= strength.level ? strength.color : Color.white.opacity(0.15))
                        .frame(height: 4)
                }
            }

            Text(strength.title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(strength.color)
                .frame(width: 50, alignment: .trailing)
        }
    }

    // MARK: - Terms Agreement Checkbox
    private var termsAgreementCheckbox: some View {
        Button {
            agreeToTerms.toggle()
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundStyle(agreeToTerms ? Color.neonLime : Color.lightSkyBlue)
                    .offset(y: 1)

                Text("I agree to RAAHA's Terms of Service and Privacy Policy for Chennai travel services.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Create Account Button
    private var createAccountButton: some View {
        Button {
            performSignUp()
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create Account")
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
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(color: Color.electricBlue.opacity(0.45), radius: 12, x: 0, y: 5)
            )
        }
        .buttonStyle(TactileButtonStyle())
        .disabled(isLoading)
    }

    // MARK: - Social Divider
    private var socialDivider: some View {
        HStack(spacing: 14) {
            LinearGradient(
                colors: [Color.clear, Color.white.opacity(0.25)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)

            Text("or sign up with")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.lightSkyBlue)

            LinearGradient(
                colors: [Color.white.opacity(0.25), Color.clear],
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
                performSignUp()
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
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
            }
            .buttonStyle(TactileButtonStyle())

            // Apple
            Button {
                performSignUp()
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
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
            }
            .buttonStyle(TactileButtonStyle())
        }
    }

    // MARK: - Sign In Prompt
    private var signInPrompt: some View {
        HStack(spacing: 6) {
            Text("Already have an account?")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.85))

            Button {
                onNavigateToSignIn()
            } label: {
                VStack(spacing: 2) {
                    Text("Sign In")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.neonLime)

                    // Hand-drawn curved underline
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 1))
                        p.addQuadCurve(to: CGPoint(x: 48, y: 1), control: CGPoint(x: 24, y: 4))
                    }
                    .stroke(
                        Color.neonLime,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 48, height: 4)
                }
            }
            .buttonStyle(TactileButtonStyle(scale: 0.95))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Sign Up Logic
    private func performSignUp() {
        errorMessage = nil

        if fullName.isEmpty {
            fullName = "Chennai Traveler"
        }
        if email.isEmpty {
            email = "traveler@raaha.in"
        }
        if password.isEmpty {
            password = "securePassword123"
        }

        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            onSuccess()
        }
    }
}