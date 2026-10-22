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
                    .fill(Color.deepSpace)
                    .ignoresSafeArea(edges: .top)
            }
    }
}

// MARK: - Back button

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
        let icon = Image(systemName: "chevron.left")
            .font(.raahaHeadline)
            .foregroundStyle(Color.deepSpace)
        if #available(iOS 26.0, *) {
            // iOS 26 wraps toolbar items in Liquid Glass automatically.
            icon.frame(width: 28, height: 28)
        } else {
            icon
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.honeydew.opacity(0.9)))
        }
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

    /// Pushed screens: transparent bar, custom circular back button, optional centred title.
    func pushedChrome(title: String? = nil) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton()
                }
                ToolbarItem(placement: .principal) {
                    Text(title ?? "")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.deepSpace)
                }
            }
    }

    /// Pushed screens whose title sits left-aligned beside the back button (Trip Preview).
    func pushedChrome(leadingTitle: String) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 14) {
                        BackButton()
                        Text(leadingTitle)
                            .font(.raahaTitle3)
                            .foregroundStyle(Color.deepSpace)
                    }
                }
            }
    }
}
