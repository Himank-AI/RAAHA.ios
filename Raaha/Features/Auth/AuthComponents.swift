import SwiftUI

// MARK: - Reusable Custom Text Field for Auth (Frosted Glassmorphic Design)
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
                .foregroundStyle(Color.midnightBlue.opacity(0.85))

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isFocused ? Color.neonLime : Color.royalBlue)
                    .frame(width: 22)

                if isSecure && !isPasswordVisible {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.royalBlue.opacity(0.5)))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.midnightBlue)
                        .focused($isFocused)
                        .textContentType(textContentType)
                } else {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.royalBlue.opacity(0.5)))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.midnightBlue)
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
                                .foregroundStyle(Color.royalBlue)
                        }
                    } else {
                        Button {
                            text = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.royalBlue.opacity(0.7))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.55))
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        isFocused
                            ? Color.neonLime.opacity(0.85)
                            : Color(hex: 0x7BBDE8).opacity(0.50),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
            .shadow(color: isFocused ? Color.neonLime.opacity(0.15) : Color(hex: 0x49769F).opacity(0.12), radius: 6, x: 0, y: 2)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - Reusable Frosted Glass Back Button
struct AuthBackButton: View {
    let action: () -> Void

    var body: some View {
        BackButton(action: action)
    }
}

// MARK: - Compact RAAHA Brand Header
struct CompactRaahaHeader: View {
    var body: some View {
        HStack(alignment: .top, spacing: 2) {
            Text("RAAHA")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(Color.white)

            RaahaLocationPin()
                .scaleEffect(0.8)
                .offset(x: -2, y: -4)
        }
    }
}
