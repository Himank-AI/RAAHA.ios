import SwiftUI

struct MissedTrainView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("Don't worry. Let's find your next train.")
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color.lightSkyBlue)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                alertCard
                missedCard

                HStack {
                    Text("Next Available Trains")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.honeydew)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("Illustrative")
                    }
                    .font(.raahaCaption)
                    .foregroundStyle(Color.lightSkyBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                            .background(.ultraThinMaterial, in: Capsule())
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
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
                .foregroundStyle(Color.lightSkyBlue)
                .frame(minHeight: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .contentMargins(.bottom, 32, for: .scrollContent)
        .raahaScreenBackground()
        .pushedChrome(title: "Missed My Train?")
    }

    private var alertCard: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.raahaTitle3)
                .foregroundStyle(Color.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.white.opacity(0.20)))

            VStack(alignment: .leading, spacing: 4) {
                Text("You missed your train")
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.white)
                Text("You reached the station after the train departed. Here are your next options.")
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.white.opacity(0.92))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.strawberry.opacity(0.85))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.strawberry.opacity(0.35), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .combine)
    }

    private var missedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: "xmark")
                Text("Missed")
            }
            .font(.raahaFootnoteSemibold)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(Color.strawberry))

            HStack(alignment: .top, spacing: 14) {
                Image("icon_train")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundStyle(Color.transportTrain)
                    .frame(width: 52, height: 52)
                    .background(
                        Circle()
                            .fill(Color.transportTrain.opacity(0.14))
                            .background(.regularMaterial, in: Circle())
                    )
                    .overlay(Circle().stroke(Color.transportTrain.opacity(0.28), lineWidth: 1))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Chennai Central → Egmore")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.honeydew)
                    Text("Via Chennai Metro · Central to Egmore")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.lightSkyBlue)
                    Text("Original departure: 10:32 AM")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.lightSkyBlue.opacity(0.85))
                        .padding(.top, 4)
                }

                Spacer(minLength: 4)

                Text("10:32 AM")
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                            .background(.ultraThinMaterial, in: Capsule())
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .navyCard(radius: 24)
        .accessibilityElement(children: .combine)
    }
}

private struct BestTrainCard: View {
    let option: MissedOption

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                // Fastest badge
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.raahaCaption2)
                        .frame(width: 12, height: 12)
                    Text("Fastest")
                        .font(.raahaFootnoteSemibold)
                }
                .foregroundStyle(Color.midnightBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.neonLime))
                .shadow(color: Color.neonLime.opacity(0.3), radius: 6, x: 0, y: 2)

                Text("Best Option")
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.lightSkyBlue)
            }

            HStack(alignment: .top, spacing: 14) {
                Image("icon_train")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(Color.transportTrain)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.transportTrain.opacity(0.14))
                            .background(.regularMaterial, in: Circle())
                    )
                    .overlay(Circle().stroke(Color.transportTrain.opacity(0.28), lineWidth: 1))

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.line)
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.honeydew)
                    Text(option.path)
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.lightSkyBlue)
                    Text(option.board)
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.lightSkyBlue.opacity(0.85))
                }

                Spacer(minLength: 4)
                TimeChip(text: option.duration)
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Departs")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.lightSkyBlue)
                    Text(option.departs)
                        .font(.raahaTitle3)
                        .foregroundStyle(Color.honeydew)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.neonLime)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Arrives")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.lightSkyBlue)
                    Text(option.arrives)
                        .font(.raahaTitle3)
                        .foregroundStyle(Color.honeydew)
                }
            }
            .padding(.top, 4)

            Text("Sample schedule · Availability not confirmed")
                .font(.raahaCaption2)
                .foregroundStyle(Color.lightSkyBlue.opacity(0.75))
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
                .foregroundStyle(Color.transportTrain)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.transportTrain.opacity(0.14))
                        .background(.regularMaterial, in: Circle())
                )
                .overlay(Circle().stroke(Color.transportTrain.opacity(0.28), lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text(option.line)
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.honeydew)
                Text(option.path)
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.lightSkyBlue)
                Text(option.board)
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.lightSkyBlue.opacity(0.85))
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 6) {
                TimeChip(text: option.duration)
                Text("→ \(option.arrives)")
                    .font(.raahaFootnote)
                    .foregroundStyle(Color.lightSkyBlue)
            }
        }
        .padding(16)
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
