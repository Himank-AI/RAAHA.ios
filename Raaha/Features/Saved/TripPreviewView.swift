import SwiftUI

struct TripPreviewView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                hero

                infoCard(
                    symbol: "clock",
                    symbolTint: Color.neonLime,
                    title: "Expected Travel Time"
                ) {
                    Text("45–60 min")
                        .font(.raahaTitle)
                        .foregroundStyle(Color.neonLime)
                    Text("(from your current location)")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.lightSkyBlue)
                }

                infoCard(
                    symbol: "sun.max",
                    symbolTint: Color.neonLime,
                    title: "Weather Forecast"
                ) {
                    Text("Sunny · 34°C")
                        .font(.raahaBody)
                        .foregroundStyle(Color.honeydew)
                    Text("Low chance of rain")
                        .font(.raahaSubheadline)
                        .foregroundStyle(Color.lightSkyBlue)
                }

                infoCard(
                    symbol: "exclamationmark.triangle",
                    symbolTint: Color.strawberry,
                    title: "Travel Advisory"
                ) {
                    Text("Higher crowd density expected during weekend mornings.")
                        .font(.raahaSubheadline)
                        .foregroundStyle(Color.lightSkyBlue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .contentMargins(.bottom, 16, for: .scrollContent)
        .safeAreaInset(edge: .bottom) {
            Button {
                router.push(.tripSaved)
            } label: {
                ChevronLabel(title: "Save Trip")
            }
            .buttonStyle(.pillDark)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .raahaScreenBackground()
        .pushedChrome(leadingTitle: "Trip Preview")
    }

    private var hero: some View {
        VStack(spacing: 0) {
            FillImage(name: "preview_beach", height: 150)
                .accessibilityHidden(true)

            HStack(spacing: 14) {
                Image("icon_pin")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(Color.neonLime)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .background(.ultraThinMaterial, in: Circle())
                    )
                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(router.plan.destination)
                        .font(.raahaTitle2)
                        .foregroundStyle(Color.honeydew)
                    Text(router.plan.combinedText)
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.lightSkyBlue)
                }
                Spacer()
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color.royalBlue.opacity(0.85), Color.midnightBlue.opacity(0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
        .shadow(color: Color.midnightBlue.opacity(0.35), radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .combine)
    }

    private func infoCard<Body: View>(
        symbol: String,
        symbolTint: Color,
        title: String,
        @ViewBuilder content: () -> Body
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.raahaTitle3)
                .foregroundStyle(symbolTint)
                .frame(width: 52, height: 52)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .background(.ultraThinMaterial, in: Circle())
                )
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.honeydew)
                content()
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.midnightBlue.opacity(0.2), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .combine)
    }
}
