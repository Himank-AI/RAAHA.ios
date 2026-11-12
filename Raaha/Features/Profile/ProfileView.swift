import SwiftUI

struct ProfileView: View {
    // MARK: - State
    @Environment(AppRouter.self) private var router
    @State private var selectedCommuteModes: Set<String> = ["Metro", "Bus", "Local Train"]
    @State private var selectedInterests: Set<String> = ["Beaches", "Heritage", "Food"]
    @State private var showLogoutDialog: Bool = false

    private let commuteModes: [(name: String, symbol: String, customAsset: String?)] = [
        ("Bike", "bicycle", "icon_bike"),
        ("Auto", "car.fill", "icon_auto"),
        ("Cab", "car.fill", nil),
        ("Bus", "bus.fill", nil),
        ("Local Train", "train.side.front.car", "icon_train"),
        ("Metro", "tram.fill", "icon_metro")
    ]

    private let interests: [(name: String, symbol: String)] = [
        ("Beaches", "beach.umbrella"),
        ("Mountains", "mountain.2"),
        ("Heritage", "building.columns"),
        ("Food", "fork.knife"),
        ("Adventure", "tent.fill"),
        ("Nature", "leaf"),
        ("Cafes", "cup.and.saucer.fill"),
        ("Metro", "tram.fill"),
        ("Photography", "camera.aperture")
    ]

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    // 1. Commute Preferences Group (Same chip layout as Discovery Interests)
                    commutePreferencesSection

                    // 2. Saved Chennai Places Group
                    savedPlacesSection

                    // 3. Discovery Interests Group
                    travelInterestsSection

                    // 4. Transit & Support Group (Only FAQs and Help + Logout)
                    transitSupportSection

                    // Version Footer
                    footerNote
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
        }
        .raahaScreenBackground()
        .navyHeaderChrome()
        .confirmationDialog(
            "Log out of RAAHA?",
            isPresented: $showLogoutDialog,
            titleVisibility: .visible
        ) {
            Button("Log Out", role: .destructive) {
                router.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will need to sign in again to sync your journeys.")
        }
    }

    // MARK: - Header (Includes 28 Trips Taken)
    private var header: some View {
        NavyHeader {
            HStack(spacing: 16) {
                // Profile Avatar with verified badge
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(Color.lightSkyBlue)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                        .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 2))

                    Circle()
                        .fill(Color.neonLime)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.midnightBlue)
                        )
                        .overlay(Circle().stroke(Color.midnightBlue, lineWidth: 2))
                        .offset(x: 2, y: 2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Akshaya Kumar")
                        .font(.raahaTitle2)
                        .foregroundStyle(Color.white)

                    Text("akshaya.kumar@gmail.com")
                        .font(.raahaCaption)
                        .foregroundStyle(Color(hex: 0xBDD8E9))

                    // Trips taken with numbers only arranged neatly
                    HStack(spacing: 6) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.neonLime)
                        Text("28")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.neonLime)
                        Text("Trips Taken")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4.5)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                            .background(.ultraThinMaterial, in: Capsule())
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
                    .padding(.top, 2)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 154, alignment: .leading)
        }
    }

    // MARK: - Commute Preferences (Same chip layout as Discovery Interests)
    private var commutePreferencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Commute Preferences", icon: "slider.horizontal.3")

            VStack(alignment: .leading, spacing: 10) {
                Text("Select your preferred Chennai transit options:")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.lightSkyBlue.opacity(0.85))

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                    spacing: 8
                ) {
                    ForEach(commuteModes, id: \.name) { item in
                        modeChip(item.name, symbol: item.symbol, customAsset: item.customAsset)
                    }
                }
            }
            .padding(14)
            .navyCard(radius: 20)
        }
    }

    private func modeChip(_ name: String, symbol: String, customAsset: String?) -> some View {
        let isSelected = selectedCommuteModes.contains(name)
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isSelected {
                    selectedCommuteModes.remove(name)
                } else {
                    selectedCommuteModes.insert(name)
                }
            }
        } label: {
            HStack(spacing: 5) {
                if let customAsset {
                    Image(customAsset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                } else {
                    Image(systemName: symbol)
                        .font(.system(size: 11))
                }
                Text(name)
                    .font(.raahaCaption)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.midnightBlue : Color.white)
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? AnyShapeStyle(.emraldGreen)
                        : AnyShapeStyle(Color.white.opacity(0.08))
                    )
                    .background(.ultraThinMaterial, in: Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: isSelected ? .emraldGreen.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Saved Places Section
    private var savedPlacesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Frequent Locations", icon: "mappin.and.ellipse")

            VStack(spacing: 0) {
                placeRow(
                    symbol: "house.fill",
                    title: "Home",
                    detail: "Chennai Central, Park Town",
                    color: Color.brightBlue
                )
                HairlineDivider(color: Color.white.opacity(0.12))
                placeRow(
                    symbol: "briefcase.fill",
                    title: "Workplace",
                    detail: "T. Nagar Smart City Complex",
                    color: Color.electricBlue
                )
            }
            .padding(.horizontal, 14)
            .navyCard(radius: 20)
        }
    }

    private func placeRow(symbol: String, title: String, detail: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(color == Color.neonLime ? Color.midnightBlue : Color.white)
                .frame(width: 32, height: 32)
                .background(Circle().fill(color))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.honeydew)
                Text(detail)
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.lightSkyBlue.opacity(0.85))
            }

            Spacer()

            Button {
            } label: {
                Text("Edit")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.lightSkyBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .background(.ultraThinMaterial, in: Capsule())
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Discovery Interests Section
    private var travelInterestsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Discovery Interests", icon: "sparkles")

            VStack(alignment: .leading, spacing: 10) {
                Text("Customize your Chennai Explore recommendations:")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.lightSkyBlue.opacity(0.85))

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                    spacing: 8
                ) {
                    ForEach(interests, id: \.name) { item in
                        interestChip(item.name, symbol: item.symbol)
                    }
                }
            }
            .padding(14)
            .navyCard(radius: 20)
        }
    }

    private func interestChip(_ name: String, symbol: String) -> some View {
        let isSelected = selectedInterests.contains(name)
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isSelected {
                    selectedInterests.remove(name)
                } else {
                    selectedInterests.insert(name)
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 11))
                Text(name)
                    .font(.raahaCaption)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.midnightBlue : Color.white)
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? AnyShapeStyle(Color.neonLime)
                        : AnyShapeStyle(Color.white.opacity(0.08))
                    )
                    .background(.ultraThinMaterial, in: Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.neonLime.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Transit & Support Section (Only FAQs and Help + Logout)
    private var transitSupportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Transit & Support", icon: "gearshape.fill")

            VStack(spacing: 0) {
                // Chennai Transit FAQs and Help
                actionRow(
                    symbol: "questionmark.circle.fill",
                    title: "Chennai Transit FAQs and Help",
                    trailing: "Guide"
                )

                HairlineDivider(color: Color.white.opacity(0.12))

                // Logout button
                Button {
                    showLogoutDialog = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            .font(.raahaSubheadlineMedium)
                            .foregroundStyle(Color.strawberry)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.strawberry.opacity(0.2))
                                    .background(.ultraThinMaterial, in: Circle())
                            )

                        Text("Logout")
                            .font(.raahaSubheadlineMedium)
                            .foregroundStyle(Color.strawberry)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.raahaCaption)
                            .foregroundStyle(Color.lightSkyBlue.opacity(0.5))
                    }
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .navyCard(radius: 20)
        }
    }

    private func actionRow(symbol: String, title: String, trailing: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.honeydew)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .background(.ultraThinMaterial, in: Circle())
                )
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))

            Text(title)
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.honeydew)

            Spacer()

            Text(trailing)
                .font(.raahaCaption)
                .foregroundStyle(Color.lightSkyBlue)

            Image(systemName: "chevron.right")
                .font(.raahaCaption)
                .foregroundStyle(Color.lightSkyBlue.opacity(0.5))
        }
        .padding(.vertical, 10)
    }

    // MARK: - Section Title Helper
    private func sectionTitle(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.neonLime)
            Text(title)
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.honeydew)
        }
        .padding(.leading, 4)
    }

    // MARK: - Footer Note
    private var footerNote: some View {
        VStack(spacing: 4) {
            Text("RAAHA Chennai • Multimodal Urban Transit")
                .font(.raahaCaption)
                .foregroundStyle(Color.lightSkyBlue)
            Text("Version 2.2.0 (Build 50) • Native SwiftUI")
                .font(.raahaCaption2)
                .foregroundStyle(Color.lightSkyBlue.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}
