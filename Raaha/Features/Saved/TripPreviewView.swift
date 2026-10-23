import SwiftUI

struct TripPreviewView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                hero

                infoCard(
                    symbol: "clock",
                    symbolTint: Color.steelBlue,
                    title: "Expected Travel Time"
                ) {
                    Text("45–60 min")
                        .font(.raahaTitle)
                        .foregroundStyle(Color.deepSpace)
                    Text("(from your current location)")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.steelBlue)
                }

                infoCard(
                    symbol: "sun.max",
                    symbolTint: Color.steelBlue,
                    title: "Weather Forecast"
                ) {
                    Text("Sunny · 34°C")
                        .font(.raahaBody)
                        .foregroundStyle(Color.deepSpace)
                    Text("Low chance of rain")
                        .font(.raahaSubheadline)
                        .foregroundStyle(Color.steelBlue)
                }

                infoCard(
                    symbol: "exclamationmark.triangle",
                    symbolTint: Color.strawberry,
                    title: "Travel Advisory"
                ) {
                    Text("Higher crowd density expected during weekend mornings.")
                        .font(.raahaSubheadline)
                        .foregroundStyle(Color.steelBlue)
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
                    .foregroundStyle(Color.deepSpace)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Color.honeydew))

                VStack(alignment: .leading, spacing: 2) {
                    Text(router.plan.destination)
                        .font(.raahaTitle2)
                        .foregroundStyle(Color.honeydew)
                    Text(router.plan.combinedText)
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.frostedBlue)
                }
                Spacer()
            }
            .padding(14)
            .background(LinearGradient.raahaHero)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.deepSpace.opacity(0.15), radius: 10, x: 0, y: 5)
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
                .background(Circle().fill(Color.frostedBlue.opacity(0.5)))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.deepSpace)
                content()
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lightCard(radius: 24)
        .accessibilityElement(children: .combine)
    }
}
