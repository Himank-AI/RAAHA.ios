import SwiftUI

struct MissedTrainView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var station = MockData.nearbyStations[0]
    @State private var isPickingStation = false
    @State private var selectedTrain = MockData.nextTrains.first?.id
    @State private var refreshTurns: Double = 0
    @State private var isLivePulsing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero

                locationPicker
                    .padding(.top, 22)

                HStack {
                    Text("Next Available Trains")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.deepSpace)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    liveBadge
                }
                .padding(.top, 26)
                .padding(.horizontal, 4)

                VStack(spacing: 12) {
                    ForEach(MockData.nextTrains) { train in
                        TrainOptionRow(train: train, isSelected: selectedTrain == train.id) {
                            withAnimation(.spring(duration: 0.3)) { selectedTrain = train.id }
                        }
                    }
                }
                .padding(.top, 14)

                infoRow
                    .padding(.top, 16)
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, 16, for: .scrollContent)
        .safeAreaInset(edge: .bottom) {
            refreshButton
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 8)
        }
        .raahaScreenBackground()
        .pushedChrome()
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                isLivePulsing = true
            }
        }
    }

    // MARK: Hero

    private var hero: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Missed\nMy Train?")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.deepSpace)
                .lineSpacing(-2)
                .padding(.top, 8)
                .accessibilityAddTraits(.isHeader)

            Text("Don't worry!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.deepSpace.opacity(0.75))
                .padding(.top, 14)

            Text("Find the next available trains\nfrom your current location.")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.deepSpace.opacity(0.7))
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .topLeading) {
            Image("missed_train_hero")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.12),
                            .init(color: .black, location: 0.32)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0.35),
                            .init(color: .black.opacity(0.5), location: 0.6),
                            .init(color: .clear, location: 0.88)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(x: 70, y: -100)
                .accessibilityHidden(true)
        }
    }

    // MARK: Location

    private var locationPicker: some View {
        Button {
            isPickingStation = true
        } label: {
            HStack(spacing: 14) {
                Image("icon_pin")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(MissedPalette.blueGradient))
                    .shadow(color: MissedPalette.blue.opacity(0.35), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Location")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(MissedPalette.blue)
                    Text(station)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.deepSpace)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.deepSpace)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .missedGlass(radius: 22)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Current location, \(station)")
        .accessibilityHint("Choose a different station")
        .confirmationDialog("Choose your station", isPresented: $isPickingStation, titleVisibility: .visible) {
            ForEach(MockData.nearbyStations, id: \.self) { name in
                Button(name) { station = name }
            }
        }
    }

    private var liveBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.transportWalk)
                .frame(width: 6, height: 6)
                .opacity(isLivePulsing ? 0.35 : 1)
            Text("Live Updates")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.deepSpace.opacity(0.7))
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Footer

    private var infoRow: some View {
        Button {
            router.push(.routeDetail(.fastest))
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "info")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(MissedPalette.blue.opacity(0.7)))

                Text("You can also check route options\nor view live train schedule.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.deepSpace.opacity(0.75))
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.deepSpace)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .missedGlass(radius: 22, fill: 0.55)
        }
        .buttonStyle(.plain)
    }

    private var refreshButton: some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.6)) {
                refreshTurns += 1
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .rotationEffect(.degrees(refreshTurns * 360))
                Text("Refresh Trains")
            }
        }
        .buttonStyle(.pillLight)
    }
}

// MARK: - Palette & surfaces

private enum MissedPalette {
    static let blue = Color(hex: 0x2563C9)
    static let blueGradient = LinearGradient(
        colors: [Color(hex: 0x3B7DE0), Color(hex: 0x1C4FAE)],
        startPoint: .top,
        endPoint: .bottom
    )
}

private extension View {
    func missedGlass(radius: CGFloat, fill: Double = 0.85) -> some View {
        background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.white.opacity(fill))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: Color.deepSpace.opacity(0.08), radius: 12, x: 0, y: 5)
    }
}

// MARK: - Train row

private struct TrainOptionRow: View {
    let train: MissedOption
    let isSelected: Bool
    let onTake: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image("local_train_illustration")
                .resizable()
                .scaledToFill()
                .frame(width: 66, height: 66, alignment: .trailing)
                .clipped()
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xDCE9F8), Color.white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(train.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.deepSpace)
                Text(train.destination)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.deepSpace.opacity(0.65))
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(MissedPalette.blue)
                    Text("\(train.minutesAway) min")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.deepSpace)
                        .monospacedDigit()
                    Rectangle()
                        .fill(Color.deepSpace.opacity(0.2))
                        .frame(width: 1, height: 14)
                    Text("Platform \(train.platform)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.deepSpace.opacity(0.65))
                }
                .padding(.top, 4)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .accessibilityElement(children: .combine)

            Spacer(minLength: 0)

            Button(action: onTake) {
                Text("Take This Train")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : Color.deepSpace)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 9)
                    .background {
                        if isSelected {
                            Capsule().fill(MissedPalette.blueGradient)
                        } else {
                            Capsule().fill(Color.white)
                        }
                    }
                    .overlay(
                        Capsule().strokeBorder(
                            isSelected ? Color.white.opacity(0.25) : MissedPalette.blue.opacity(0.15),
                            lineWidth: 1
                        )
                    )
                    .shadow(
                        color: isSelected ? MissedPalette.blue.opacity(0.35) : Color.deepSpace.opacity(0.08),
                        radius: 6, x: 0, y: 3
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Take \(train.name) \(train.destination)")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
        .padding(10)
        .padding(.trailing, 4)
        .missedGlass(radius: 20)
    }
}

#Preview {
    NavigationStack {
        MissedTrainView()
    }
    .environment(AppRouter())
}
