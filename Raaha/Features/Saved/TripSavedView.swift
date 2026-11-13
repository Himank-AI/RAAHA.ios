import SwiftUI

struct TripSavedView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            illustration
                .padding(.bottom, 28)

            Text("Trip Saved!")
                .font(.raahaLargeTitle)
                .foregroundStyle(Color.honeydew)

            Text(router.plan.destination)
                .font(.raahaTitle3)
                .foregroundStyle(Color.neonLime)
                .padding(.top, 8)

            Text(router.plan.combinedText)
                .font(.raahaSubheadline)
                .foregroundStyle(Color.lightSkyBlue)
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
            .foregroundStyle(Color.lightSkyBlue)
            .frame(minHeight: 44)
            .padding(.top, 10)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .raahaScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    /// Calendar-with-check illustration drawn natively.
    private var illustration: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.08))
                .background(.ultraThinMaterial, in: Circle())
                .frame(width: 210, height: 210)
                .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))

            // Calendar
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.midnightBlue.opacity(0.85))
                    .frame(width: 130, height: 118)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.12))
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
                .foregroundStyle(Color.midnightBlue)
                .frame(width: 66, height: 66)
                .background(Circle().fill(Color.neonLime))
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .shadow(color: Color.neonLime.opacity(0.4), radius: 8, x: 0, y: 3)
                .offset(x: 52, y: 44)
        }
        .frame(height: 220)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Trip saved")
    }

    private var cell: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(Color.lightSkyBlue.opacity(0.6))
            .frame(width: 26, height: 20)
    }

    private var ring: some View {
        Capsule()
            .fill(Color.lightSkyBlue)
            .frame(width: 10, height: 30)
    }
}

#Preview {
    TripSavedView()
        .environment(AppRouter())
}
