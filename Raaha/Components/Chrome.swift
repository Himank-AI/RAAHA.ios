import SwiftUI

// MARK: - Navy header used by the four tab roots

struct NavyHeader<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                UnevenRoundedRectangle(bottomLeadingRadius: 32, bottomTrailingRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: 0x0A4174).opacity(0.92),
                                Color(hex: 0x49769F).opacity(0.80)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .background(
                        .ultraThinMaterial,
                        in: UnevenRoundedRectangle(bottomLeadingRadius: 32, bottomTrailingRadius: 32, style: .continuous)
                    )
                    .overlay(
                        UnevenRoundedRectangle(bottomLeadingRadius: 32, bottomTrailingRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(color: Color(hex: 0x49769F).opacity(0.35), radius: 14, x: 0, y: 6)
                    .ignoresSafeArea(edges: .top)
            }
    }
}

// MARK: - Back button (Unified Frosted Glass Circular Back Button)

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            if let action = action {
                action()
            } else {
                dismiss()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 38, height: 38)

                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(hex: 0x0A4174))
                    .offset(x: -1)
            }
            .frame(width: 38, height: 38)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

// MARK: - Navigation chrome (100% Pure SwiftUI)

extension View {
    /// Tab-root screens: light status bar over the navy header, transparent empty nav bar.
    func navyHeaderChrome() -> some View {
        self
            .toolbar(.hidden, for: .navigationBar)
    }

    /// Tab-root screens with light header: dark status bar over light background.
    func lightHeaderChrome() -> some View {
        self
            .toolbar(.hidden, for: .navigationBar)
    }

    /// Pushed screens: completely transparent header in pure SwiftUI, custom circular back button, optional centred title.
    func pushedChrome(title: String? = nil) -> some View {
        self
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) {
                HStack(spacing: 0) {
                    BackButton()

                    Spacer(minLength: 8)

                    if let title, !title.isEmpty {
                        Text(title)
                            .font(.raahaHeadline)
                            .foregroundStyle(Color.midnightBlue)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    // Symmetrical invisible spacer to balance the back button width
                    Color.clear
                        .frame(width: 38, height: 38)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 4)
            }
    }

    /// Pushed screens whose title sits left-aligned beside the back button (Trip Preview).
    func pushedChrome(leadingTitle: String) -> some View {
        self
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) {
                HStack(spacing: 12) {
                    BackButton()
                    Text(leadingTitle)
                        .font(.raahaTitle3)
                        .foregroundStyle(Color.midnightBlue)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 4)
            }
    }
}
