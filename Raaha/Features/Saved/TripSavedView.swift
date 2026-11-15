import SwiftUI

struct TripSavedView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            // App-matching wavy background
            RaahaScreenBackground()

            VStack(spacing: 0) {
                Spacer()

                // Calendar illustration
                illustration
                    .padding(.bottom, 32)

                // "Trip Saved!" heading with decorative dashes
                HStack(spacing: 10) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: 0x2A90D4))
                    Text("Trip Saved!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x1D3557))
                    Image(systemName: "sparkle")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: 0x2A90D4))
                }
                .padding(.bottom, 20)

                // Destination pill
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x2A90D4))
                    Text(router.plan.destination)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x1D3557))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: Color(hex: 0x49769F).opacity(0.15), radius: 8, x: 0, y: 3)
                )
                .padding(.bottom, 10)

                // Date & time
                Text(router.plan.combinedText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: 0x49769F))
                    .padding(.bottom, 36)

                // View Saved Trips button
                Button {
                    router.showTrips()
                } label: {
                    HStack {
                        Spacer()
                        Text("View Saved Trips")
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
                .padding(.horizontal, 24)
                .padding(.bottom, 14)

                // Back to Explore link
                Button {
                    router.popToRoot()
                } label: {
                    Text("Back to Explore")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(hex: 0x1D3557))
                        .underline(true, color: Color(hex: 0x1D3557).opacity(0.5))
                }
                .frame(minHeight: 44)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Calendar Illustration
    private var illustration: some View {
        ZStack {
            // Outer frosted circle
            Circle()
                .fill(Color.white.opacity(0.45))
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1.5))
                .frame(width: 200, height: 200)
                .shadow(color: Color(hex: 0x49769F).opacity(0.12), radius: 20, x: 0, y: 8)

            // Calendar body
            ZStack(alignment: .top) {
                // Main calendar rectangle
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .frame(width: 120, height: 110)
                    .shadow(color: Color(hex: 0x1D3557).opacity(0.12), radius: 8, x: 0, y: 4)

                // Dark navy header bar
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: 0x1A3A6E))
                    .frame(width: 120, height: 42)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 16,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 16,
                            style: .continuous
                        )
                    )

                // Calendar rings
                HStack(spacing: 52) {
                    calendarRing
                    calendarRing
                }
                .offset(y: -6)

                // Grid cells
                VStack(spacing: 7) {
                    HStack(spacing: 7) {
                        calendarCell; calendarCell; calendarCell
                    }
                    HStack(spacing: 7) {
                        calendarCell; calendarCell; calendarCell
                    }
                }
                .offset(y: 52)
            }
            .offset(y: -6)

            // Blue checkmark badge
            ZStack {
                Circle()
                    .fill(Color(hex: 0x2A90D4))
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .shadow(color: Color(hex: 0x2A90D4).opacity(0.4), radius: 8, x: 0, y: 4)

                Image(systemName: "checkmark")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .offset(x: 50, y: 46)

            // Sparkle lines around badge
            Group {
                sparkLine(angle: -45, length: 10).offset(x: 80, y: 18)
                sparkLine(angle: 0,   length: 8).offset(x: 90, y: 46)
                sparkLine(angle: 45,  length: 10).offset(x: 80, y: 72)
            }
        }
        .frame(height: 220)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Trip saved")
    }

    private var calendarRing: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(Color(hex: 0x7BBDE8))
            .frame(width: 8, height: 22)
    }

    private var calendarCell: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(Color(hex: 0xDCEEF8))
            .frame(width: 24, height: 18)
    }

    private func sparkLine(angle: Double, length: CGFloat) -> some View {
        Capsule()
            .fill(Color(hex: 0x2A90D4).opacity(0.6))
            .frame(width: 2, height: length)
            .rotationEffect(.degrees(angle))
    }
}

#Preview {
    TripSavedView()
        .environment(AppRouter())
}
