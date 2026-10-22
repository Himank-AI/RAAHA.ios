import SwiftUI

struct ProfileView: View {
    @State private var selectedInterests: Set<String> = ["Beaches"]

    private let interests: [(name: String, symbol: String)] = [
        ("Beaches", "beach.umbrella"),
        ("Mountains", "mountain.2"),
        ("Heritage", "building.columns"),
        ("Food", "fork.knife"),
        ("Adventure", "tent.fill"),
        ("Nature", "leaf")
    ]

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 10) {
                    infoRow(symbol: "person", label: "Name", value: "Akshaya Kumar")
                    infoRow(symbol: "envelope", label: "Email", value: "akshaya.kumar@gmail.com")
                    infoRow(symbol: "phone", label: "Phone", value: "+91 98765 43210")

                    interestsCard
                    preferencesCard
                }
                .padding(16)
                .navyCard(radius: 30, gradient: .raahaHero)
                .padding(.horizontal, 16)
                .padding(.top, 22)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
        }
        .background(LinearGradient.raahaScreen.ignoresSafeArea())
        .navyHeaderChrome()
    }

    // MARK: Header

    private var header: some View {
        NavyHeader {
            VStack(spacing: 10) {
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)
                        .foregroundStyle(Color.honeydew)
                        .accessibilityLabel("Profile photo")

                    Button {
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.raahaFootnoteSemibold)
                            .foregroundStyle(Color.honeydew)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.steelBlue))
                            .overlay(Circle().stroke(Color.honeydew, lineWidth: 2))
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .offset(x: 12, y: 12)
                    .accessibilityLabel("Change photo")
                }
                .padding(.top, 2)

                Text("Akshaya Kumar")
                    .font(.raahaTitle2)
                    .foregroundStyle(Color.honeydew)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: Rows

    private func infoRow(symbol: String, label: String, value: String) -> some View {
        Button {
        } label: {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.raahaBody)
                    .foregroundStyle(Color.deepSpace)
                    .frame(width: 26)
                VStack(alignment: .leading, spacing: 0) {
                    Text(label)
                        .font(.raahaCaption)
                        .foregroundStyle(Color.steelBlue)
                    Text(value)
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.deepSpace)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.frostedBlue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(minHeight: 52)
            .background(Capsule().fill(Color.honeydew))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }

    // MARK: Travel interests

    private var interestsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "safari")
                    .font(.raahaTitle3)
                    .foregroundStyle(Color.honeydew)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.deepSpace))
                VStack(alignment: .leading, spacing: 0) {
                    Text("Travel Interests")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.deepSpace)
                    Text("Select what you love")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.steelBlue)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.frostedBlue)
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                spacing: 8
            ) {
                ForEach(interests, id: \.name) { item in
                    interestChip(item.name, symbol: item.symbol)
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.honeydew))
    }

    private func interestChip(_ name: String, symbol: String) -> some View {
        let selected = selectedInterests.contains(name)
        return Button {
            if selected { selectedInterests.remove(name) } else { selectedInterests.insert(name) }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                Text(name).lineLimit(1).minimumScaleFactor(0.8)
            }
            .font(.raahaCaption)
            .foregroundStyle(selected ? Color.honeydew : Color.deepSpace)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(Capsule().fill(selected ? Color.deepSpace : Color.clear))
            .overlay(Capsule().stroke(Color.frostedBlue, lineWidth: 1.2))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    // MARK: Preferences

    private var preferencesCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "slider.horizontal.3")
                    .font(.raahaTitle3)
                    .foregroundStyle(Color.honeydew)
                    .frame(width: 40, height: 40)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.deepSpace))
                VStack(alignment: .leading, spacing: 0) {
                    Text("Preferences")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.deepSpace)
                    Text("Your favourite spots")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.steelBlue)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.frostedBlue)
            }
            .padding(.bottom, 10)

            HairlineDivider(color: Color.frostedBlue.opacity(0.6))

            preferenceRow(symbol: "slider.horizontal.below.rectangle", title: "Travel Preferences",
                          subtitle: "Modes, notifications, language")
            HairlineDivider(color: Color.frostedBlue.opacity(0.6))
            preferenceRow(symbol: "questionmark.circle", title: "Help & Support",
                          subtitle: "FAQs, contact us")
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.honeydew))
    }

    private func preferenceRow(symbol: String, title: String, subtitle: String) -> some View {
        Button {
        } label: {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.honeydew)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.deepSpace))
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.raahaSubheadlineMedium)
                        .foregroundStyle(Color.deepSpace)
                    Text(subtitle)
                        .font(.raahaCaption)
                        .foregroundStyle(Color.steelBlue)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.frostedBlue)
            }
            .padding(.vertical, 8)
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}
