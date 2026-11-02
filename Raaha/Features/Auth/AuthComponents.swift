import SwiftUI

// MARK: - Reusable Custom Text Field for Auth
struct AuthInputField: View {
    let title: String
    let placeholder: String
    let systemImage: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var isSecure: Bool = false
    @State private var isPasswordVisible: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.deepSpace.opacity(0.8))

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isFocused ? Color.strawberry : Color.steelBlue)
                    .frame(width: 22)

                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.deepSpace)
                        .focused($isFocused)
                        .textContentType(textContentType)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.deepSpace)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .textContentType(textContentType)
                }

                if !text.isEmpty {
                    if isSecure {
                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.steelBlue)
                        }
                    } else {
                        Button {
                            text = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.steelBlue.opacity(0.6))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.85))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        isFocused ? Color.strawberry.opacity(0.75) : Color(hex: 0x78B9C8).opacity(0.35),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
            .shadow(color: isFocused ? Color.strawberry.opacity(0.12) : Color.deepSpace.opacity(0.04), radius: 6, x: 0, y: 2)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - Reusable Frosted Back Button
struct AuthBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.deepSpace)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .background(.ultraThinMaterial, in: Circle())
                )
                .overlay(
                    Circle()
                        .stroke(Color(hex: 0x78B9C8).opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.deepSpace.opacity(0.06), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(TactileButtonStyle(scale: 0.92))
    }
}

// MARK: - Compact RAAHA Brand Header
struct CompactRaahaHeader: View {
    var body: some View {
        HStack(alignment: .top, spacing: 2) {
            Text("RAAHA")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(Color.deepSpace)

            RaahaLocationPin()
                .scaleEffect(0.8)
                .offset(x: -2, y: -4)
        }
    }
}
