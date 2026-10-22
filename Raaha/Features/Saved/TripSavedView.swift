import SwiftUI

struct TripSavedView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            illustration
                .padding(.bottom, 28)

            Text("Trip Saved!")
                .font(.raahaLargeTitle)
                .foregroundStyle(Color.deepSpace)

            Text(router.plan.destination)
                .font(.raahaTitle3)
                .foregroundStyle(Color.steelBlue)
                .padding(.top, 8)

            Text(router.plan.combinedText)
                .font(.raahaSubheadline)
                .foregroundStyle(Color.steelBlue)
                .padding(.top, 6)

            Button {
                router.showTrips()
            } label: {
                ChevronLabel(title: "View Saved Trips")
            }
            .buttonStyle(.pillDark)
            .padding(.top, 32)

            Button("Back to Explore") {
                router.popToRoot()
            }
            .font(.raahaHeadline)
            .foregroundStyle(Color.steelBlue)
            .frame(minHeight: 44)
            .padding(.top, 10)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(MintWaveBackground())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    /// Calendar-with-check illustration drawn natively.
    private var illustration: some View {
        ZStack {
            Circle()
                .fill(Color.frostedBlue.opacity(0.35))
                .frame(width: 210, height: 210)

            // Calendar
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.deepSpace)
                    .frame(width: 130, height: 118)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.honeydew)
                    .frame(width: 118, height: 82)
                    .offset(y: 30)
                    .overlay(alignment: .center) {
                        VStack(spacing: 8) {
                            HStack(spacing: 8) { cell; cell; cell }
                            HStack(spacing: 8) { cell; cell; Color.clear.frame(width: 26, height: 20) }
                        }
                        .offset(y: 30)
                    }

                HStack(spacing: 56) {
                    ring
                    ring
                }
                .offset(y: -10)
            }
            .offset(y: -2)

            // Check badge
            Image(systemName: "checkmark")
                .font(.raahaLargeTitle)
                .foregroundStyle(Color.honeydew)
                .frame(width: 66, height: 66)
                .background(Circle().fill(Color.steelBlue))
                .overlay(Circle().stroke(Color.honeydew, lineWidth: 3))
                .offset(x: 52, y: 44)
        }
        .frame(height: 220)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Trip saved")
    }

    private var cell: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(Color.frostedBlue)
            .frame(width: 26, height: 20)
    }

    private var ring: some View {
        Capsule()
            .fill(Color.frostedBlue)
            .frame(width: 10, height: 30)
    }
}
