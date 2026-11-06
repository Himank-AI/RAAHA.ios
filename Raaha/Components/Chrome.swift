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

// MARK: - Back button (Frosted Glass Circular Button from Reference 1)

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            glyph
        }
        .accessibilityLabel("Back")
    }

    @ViewBuilder
    private var glyph: some View {
        Image(systemName: "chevron.left")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Color.white)
            .frame(width: 40, height: 40)
            .background(Circle().fill(Color.white.opacity(0.14)))
            .background(.ultraThinMaterial, in: Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
            .shadow(color: Color.midnightBlue.opacity(0.35), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Navigation chrome

extension View {
    /// Tab-root screens: light status bar over the navy header, transparent empty nav bar.
    func navyHeaderChrome() -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }

    /// Tab-root screens with light header: dark status bar over light background.
    func lightHeaderChrome() -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }

    /// Pushed screens: transparent bar, custom circular back button, optional centred title.
    func pushedChrome(title: String? = nil) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton()
                }
                ToolbarItem(placement: .principal) {
                    Text(title ?? "")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.honeydew)
                }
            }
    }

    /// Pushed screens whose title sits left-aligned beside the back button (Trip Preview).
    func pushedChrome(leadingTitle: String) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 14) {
                        BackButton()
                        Text(leadingTitle)
                            .font(.raahaTitle3)
                            .foregroundStyle(Color.honeydew)
                    }
                }
            }
    }
}
