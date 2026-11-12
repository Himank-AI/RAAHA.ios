import SwiftUI

struct ArrivedView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                badge
                    .padding(.top, 12)

                Text("You've Arrived!")
                    .font(.raahaTitle)
                    .foregroundStyle(Color.honeydew)
                    .padding(.top, 20)

                Text(router.journeyTo)
                    .font(.raahaTitle3)
                    .foregroundStyle(Color.neonLime)
                    .padding(.top, 6)

                Text("Great journey! You've successfully completed your multimodal trip to \(router.journeyTo).")
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.lightSkyBlue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                HStack(spacing: 6) {
                    Circle().fill(Color.neonLime).frame(width: 6, height: 6)
                    Text("Journey Complete")
                }
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.neonLime)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                        .background(.ultraThinMaterial, in: Capsule())
                )
                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                .padding(.top, 12)

                summary
                    .padding(.top, 20)

                Button("Back to Home") {
                    router.showHome()
                }
                .font(.raahaBody)
                .foregroundStyle(Color.lightSkyBlue)
                .frame(minHeight: 44)
                .padding(.top, 8)

                Button {
                    router.showTrips()
                } label: {
                    ChevronLabel(title: "View Journey Summary")
                }
                .buttonStyle(.pillDark)
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
        }
        .contentMargins(.bottom, 24, for: .scrollContent)
        .raahaScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            Text("Destination Reached")
                .font(.raahaSubheadline)
                .foregroundStyle(Color.honeydew)
                .padding(.top, 4)
                .padding(.bottom, 4)
        }
    }

    private var badge: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.06)).frame(width: 180, height: 180)
            Circle().fill(Color.white.opacity(0.10)).frame(width: 140, height: 140)
            Circle().fill(Color.midnightBlue.opacity(0.85)).frame(width: 110, height: 110)
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
            Image("icon_pin")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundStyle(Color.neonLime)
            Image(systemName: "checkmark")
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.midnightBlue)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.neonLime))
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(color: Color.neonLime.opacity(0.35), radius: 6, x: 0, y: 2)
                .offset(x: 38, y: -34)
        }
        .frame(height: 180)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Journey complete")
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Journey Summary")
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.honeydew)
                Spacer()
                Text("Completed")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.midnightBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.neonLime))
            }

            HStack(spacing: 0) {
                stat(symbol: "clock", label: "Arrived At", value: "10:43 AM")
                Rectangle().fill(Color.white.opacity(0.18)).frame(width: 1, height: 44)
                stat(symbol: "stopwatch", label: "Total Time", value: "62 min")
                Rectangle().fill(Color.white.opacity(0.18)).frame(width: 1, height: 44)
                stat(symbol: "map", label: "Distance", value: "9.4 km")
            }

            HairlineDivider(color: Color.white.opacity(0.15))

            Text("TRANSPORT USED")
                .font(.raahaCaption2)
                .foregroundStyle(Color.lightSkyBlue)

            HStack(spacing: 6) {
                transportChip("Walk", symbol: "figure.walk")
                transportChip("Metro", asset: "icon_metro")
                transportChip("Auto", asset: "icon_auto")
                transportChip("Walk", symbol: "figure.walk")
                Text("₹ 112")
                    .font(.raahaCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.midnightBlue)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 28)
                    .background(Capsule().fill(Color.neonLime))
            }
        }
        .padding(16)
        .navyCard(radius: 24)
        .accessibilityElement(children: .combine)
    }

    private func stat(symbol: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.lightSkyBlue)
                Text(label)
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.lightSkyBlue)
            }
            Text(value)
                .font(.raahaHeadline)
                .foregroundStyle(Color.neonLime)
        }
        .frame(maxWidth: .infinity)
    }

    private func transportChip(_ name: String, symbol: String? = nil, asset: String? = nil) -> some View {
        HStack(spacing: 4) {
            if let asset {
                Image(asset)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
            } else if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 11))
            }
            Text(name)
                .font(.raahaCaption2)
        }
        .foregroundStyle(Color.honeydew)
        .padding(.horizontal, 8)
        .frame(minHeight: 28)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.10))
                .background(.ultraThinMaterial, in: Capsule())
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}
