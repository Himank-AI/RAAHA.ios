import SwiftUI

struct TripPreviewView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Hero card: image + destination banner
                hero

                // Expected Travel Time card
                infoCard(
                    symbol: "clock",
                    symbolTint: Color(hex: 0x2A90D4)
                ) {
                    Text("Expected Travel Time")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.midnightBlue)

                    Text("45–60 min")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.midnightBlue)

                    Text("(from your current location)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: 0x49769F))
                }

                // Weather Forecast card
                infoCard(
                    symbol: "sun.max",
                    symbolTint: Color(hex: 0x2A90D4)
                ) {
                    Text("Weather Forecast")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.midnightBlue)

                    Text("Sunny · 34°C")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.midnightBlue)

                    Text("Low chance of rain")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: 0x2A90D4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .contentMargins(.bottom, 16, for: .scrollContent)
        .safeAreaInset(edge: .bottom) {
            Button {
                router.push(.tripSaved)
            } label: {
                HStack {
                    Spacer()
                    Text("Save Trip")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color(hex: 0x1D3A5A))
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.clear)
        }
        .raahaScreenBackground()
        .pushedChrome(leadingTitle: "Trip Preview")
    }

    // MARK: - Hero Card
    private var hero: some View {
        VStack(spacing: 0) {
            // Beach photo
            FillImage(name: "preview_beach", height: 180)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 24,
                        style: .continuous
                    )
                )
                .accessibilityHidden(true)

            // Dark navy destination banner
            HStack(spacing: 14) {
                // Pin icon circle
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(router.plan.destination)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    Text(router.plan.combinedText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(hex: 0xBDD8E9))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(hex: 0x1A3250))
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 24,
                    bottomTrailingRadius: 24,
                    topTrailingRadius: 0,
                    style: .continuous
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.midnightBlue.opacity(0.18), radius: 12, x: 0, y: 5)
    }

    // MARK: - Info Card
    private func infoCard<Body: View>(
        symbol: String,
        symbolTint: Color,
        @ViewBuilder content: () -> Body
    ) -> some View {
        HStack(alignment: .center, spacing: 16) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(Color(hex: 0xDCEEF8))
                    .frame(width: 50, height: 50)
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(symbolTint)
            }

            VStack(alignment: .leading, spacing: 3) {
                content()
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.72))
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.85), lineWidth: 1)
                )
        )
        .shadow(color: Color(hex: 0x49769F).opacity(0.10), radius: 8, x: 0, y: 3)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    TripPreviewView()
        .environment(AppRouter())
}
