import SwiftUI

struct MissedTrainView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("Don't worry. Let's find your next train.")
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.steelBlue)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                alertCard
                missedCard

                HStack {
                    Text("Next Available Trains")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.deepSpace)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("Illustrative")
                    }
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.frostedBlue.opacity(0.35)))
                }
                .padding(.top, 4)

                VStack(spacing: 12) {
                    ForEach(MockData.nextTrains) { option in
                        if option.isBest {
                            BestTrainCard(option: option)
                        } else {
                            OtherTrainCard(option: option)
                        }
                    }
                }

                // Action buttons
                Button {
                    router.showHome()
                } label: {
                    ChevronLabel(title: "Back to Home")
                }
                .buttonStyle(.pillDark)
                .padding(.top, 8)

                Button("Cancel") {
                    router.popToRoot()
                }
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.steelBlue)
                .frame(minHeight: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .contentMargins(.bottom, 32, for: .scrollContent)
        .background(MintWaveBackground())
        .pushedChrome(title: "Missed My Train?")
    }

    private var alertCard: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.raahaTitle3)
                .foregroundStyle(Color.honeydew)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.honeydew.opacity(0.25)))

            VStack(alignment: .leading, spacing: 4) {
                Text("You missed your train")
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.honeydew)
                Text("You reached the station after the train departed. Here are your next options.")
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.honeydew.opacity(0.92))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.strawberry)
        )
        .accessibilityElement(children: .combine)
    }

    private var missedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: "xmark")
                Text("Missed")
            }
            .font(.raahaFootnoteSemibold)
            .foregroundStyle(Color.honeydew)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(Color.strawberry))

            HStack(alignment: .top, spacing: 14) {
                Image("icon_train")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundStyle(Color.frostedBlue)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(Color.steelBlue.opacity(0.5)))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Chennai Central → Egmore")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.honeydew)
                    Text("Via Chennai Metro · Central to Egmore")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.frostedBlue)
                    Text("Original departure: 10:32 AM")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.frostedBlue)
                        .padding(.top, 4)
                }

                Spacer(minLength: 4)

                Text("10:32 AM")
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.honeydew)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.steelBlue.opacity(0.5)))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .navyCard(radius: 24, gradient: LinearGradient(colors: [Color.deepSpace], startPoint: .top, endPoint: .bottom))
        .accessibilityElement(children: .combine)
    }
}

private struct BestTrainCard: View {
    let option: MissedOption

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                // Fastest badge — uses steelBlue per the design spec
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.raahaCaption2)
                        .frame(width: 12, height: 12)
                    Text("Fastest")
                        .font(.raahaFootnoteSemibold)
                }
                .foregroundStyle(Color.honeydew)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.steelBlue))

                Text("Best Option")
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.frostedBlue)
            }

            HStack(alignment: .top, spacing: 14) {
                Image("icon_train")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(Color.frostedBlue)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.steelBlue.opacity(0.5)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.line)
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.honeydew)
                    Text(option.path)
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.frostedBlue)
                    Text(option.board)
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.frostedBlue)
                }

                Spacer(minLength: 4)
                TimeChip(text: option.duration)
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Departs")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.frostedBlue)
                    Text(option.departs)
                        .font(.raahaTitle3)
                        .foregroundStyle(Color.honeydew)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.frostedBlue)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Arrives")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.frostedBlue)
                    Text(option.arrives)
                        .font(.raahaTitle3)
                        .foregroundStyle(Color.honeydew)
                }
            }
            .padding(.top, 4)

            Text("Sample schedule · Availability not confirmed")
                .font(.raahaCaption2)
                .foregroundStyle(Color.frostedBlue.opacity(0.85))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .navyCard(radius: 24)
        .accessibilityElement(children: .combine)
    }
}

private struct OtherTrainCard: View {
    let option: MissedOption

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image("icon_train")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(Color.steelBlue)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.frostedBlue.opacity(0.45)))

            VStack(alignment: .leading, spacing: 4) {
                Text(option.line)
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.deepSpace)
                Text(option.path)
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.steelBlue)
                Text(option.board)
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.steelBlue)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 6) {
                TimeChip(text: option.duration, fill: Color.frostedBlue.opacity(0.5), tint: Color.steelBlue)
                Text("→ \(option.arrives)")
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.steelBlue)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.honeydew)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.frostedBlue.opacity(0.5), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
    }
}
