import SwiftUI

struct ArrivedView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                badge
                    .padding(.top, 12)

                Text("You've Arrived!")
                    .font(.raahaTitle)
                    .foregroundStyle(Color.deepSpace)
                    .padding(.top, 20)

                Text(router.journeyTo)
                    .font(.raahaTitle3)
                    .foregroundStyle(Color.statusGreen)
                    .padding(.top, 6)

                Text("Great journey! You've successfully completed your multimodal trip to \(router.journeyTo).")
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.steelBlue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                HStack(spacing: 6) {
                    Circle().fill(Color.statusGreen).frame(width: 6, height: 6)
                    Text("Journey Complete")
                }
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.statusGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(Color.honeydew))
                .overlay(Capsule().stroke(Color.frostedBlue, lineWidth: 1))
                .padding(.top, 12)

                summary
                    .padding(.top, 20)

                Button("Back to Home") {
                    router.showHome()
                }
                .font(.raahaBody)
                .foregroundStyle(Color.steelBlue)
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
        .background(MintWaveBackground())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Destination Reached")
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.deepSpace)
            }
        }
    }

    private var badge: some View {
        ZStack {
            Circle().fill(Color.frostedBlue.opacity(0.22)).frame(width: 180, height: 180)
            Circle().fill(Color.frostedBlue.opacity(0.35)).frame(width: 140, height: 140)
            Circle().fill(Color.deepSpace).frame(width: 110, height: 110)
            Image("icon_pin")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundStyle(Color.honeydew)
            Image(systemName: "checkmark")
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.honeydew)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.statusGreen))
                .overlay(Circle().stroke(Color.honeydew, lineWidth: 2))
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
                    .foregroundStyle(Color.honeydew)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.statusGreen))
            }

            HStack(spacing: 0) {
                stat(symbol: "clock", label: "Arrived At", value: "10:43 AM")
                Rectangle().fill(Color.frostedBlue.opacity(0.3)).frame(width: 1, height: 44)
                stat(symbol: "stopwatch", label: "Total Time", value: "62 min")
                Rectangle().fill(Color.frostedBlue.opacity(0.3)).frame(width: 1, height: 44)
                stat(symbol: "map", label: "Distance", value: "9.4 km")
            }

            HairlineDivider(color: Color.frostedBlue.opacity(0.3))

            Text("TRANSPORT USED")
                .font(.raahaCaption2)
                .foregroundStyle(Color.frostedBlue)

            HStack(spacing: 6) {
                transportChip("Walk", symbol: "figure.walk")
                transportChip("Metro", asset: "icon_metro")
                transportChip("Auto", asset: "icon_auto")
                transportChip("Walk", symbol: "figure.walk")
                Text("₹ 112")
                    .font(.raahaCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.honeydew)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 28)
                    .background(Capsule().fill(Color.statusGreen))
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
                Text(label)
            }
            .font(.raahaCaption2)
            .foregroundStyle(Color.frostedBlue)
            Text(value)
                .font(.raahaTitle3)
                .foregroundStyle(Color.honeydew)
        }
        .frame(maxWidth: .infinity)
    }

    private func transportChip(_ title: String, symbol: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
            Text(title)
        }
        .font(.raahaCaption)
        .foregroundStyle(Color.frostedBlue)
        .padding(.horizontal, 8)
        .frame(minHeight: 28)
        .background(Capsule().fill(Color.steelBlue.opacity(0.4)))
    }

    private func transportChip(_ title: String, asset: String) -> some View {
        HStack(spacing: 4) {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
            Text(title)
        }
        .font(.raahaCaption)
        .foregroundStyle(Color.frostedBlue)
        .padding(.horizontal, 8)
        .frame(minHeight: 28)
        .background(Capsule().fill(Color.steelBlue.opacity(0.4)))
    }
}
