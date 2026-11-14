import SwiftUI

struct ProfileView: View {
    // MARK: - State
    @Environment(AppRouter.self) private var router
    @State private var selectedCommuteModes: Set<String> = ["Bus"]
    @State private var selectedInterests: Set<String> = ["Beaches", "Heritage", "Food"]
    @State private var showLogoutDialog: Bool = false

    private let commuteModes: [(name: String, symbol: String, customAsset: String?)] = [
        ("Bike", "bicycle", "icon_bike"),
        ("Auto", "car.fill", "icon_auto"),
        ("Cab", "car.fill", nil),
        ("Bus", "bus.fill", nil),
        ("Local Train", "train.side.front.car", "icon_train"),
        ("Metro", "train.side.front.car", "icon_metro")
    ]

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
            // Top card from ExploreView (NavyHeader)
            header

            ScrollView {
                VStack(spacing: 16) {
                    // 1. Commute Preferences Group
                    commutePreferencesSection

                    // 2. Saved Chennai Places Group
                    savedPlacesSection

                    // 3. Discovery Interests Group
                    travelInterestsSection

                    // 4. Transit & Support Group
                    transitSupportSection

                    // Version Footer
                    footerNote
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
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

    // MARK: - Header (Top card from ExploreView / NavyHeader)
    private var header: some View {
        NavyHeader {
            VStack(alignment: .leading, spacing: 14) {
                Text("Profile")
                    .font(.raahaTitle)
                    .foregroundStyle(Color.white)
                    .accessibilityAddTraits(.isHeader)

                HStack(spacing: 16) {
                    // Profile Avatar with verified badge
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .foregroundStyle(Color.lightSkyBlue)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                            .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 2))

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.brightBlue, Color.electricBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.white)
                            )
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                            .offset(x: 2, y: 2)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Akshaya Kumar")
                            .font(.raahaTitle2)
                            .foregroundStyle(Color.white)

                        Text("akshaya.kumar@gmail.com")
                            .font(.raahaCaption)
                            .foregroundStyle(Color(hex: 0xBDD8E9))

                        // Trips Taken Pill Badge
                        HStack(spacing: 6) {
                            Image(systemName: "bus.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color(hex: 0x2A90D4))

                            Text("25")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color(hex: 0x2A90D4))

                            Text("Trips Taken")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.midnightBlue.opacity(0.75))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4.5)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        )
                        .padding(.top, 2)
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Commute Preferences Section
    private var commutePreferencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Commute Preferences", icon: "slider.horizontal.3")

            VStack(alignment: .leading, spacing: 12) {
                Text("Select your preferred Chennai transit options:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: 0x49769F))

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
            .profileCard(radius: 24)
        }
    }

    private func modeChip(_ name: String, symbol: String, customAsset: String?) -> some View {
        let isSelected = selectedCommuteModes.contains(name)
        let mode = TransportMode.mode(for: name)
        let modeColor = mode?.color ?? Color.steelBlue

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isSelected {
                    selectedCommuteModes.remove(name)
                } else {
                    selectedCommuteModes.insert(name)
                }
            }
        } label: {
            HStack(spacing: 6) {
                if let customAsset {
                    Image(customAsset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                } else {
                    Image(systemName: symbol)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(name)
                    .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.white : modeColor)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [Color(hex: 0x4EA8DE), Color(hex: 0x2A82BE)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Color.white.opacity(0.85))
                    )
                    .background(.ultraThinMaterial, in: Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.40) : Color.white.opacity(0.90), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Color(hex: 0x2A82BE).opacity(0.35) : Color.black.opacity(0.04),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Saved Places Section
    private var savedPlacesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Frequent Locations", icon: "mappin.fill")

            VStack(spacing: 0) {
                placeRow(
                    symbol: "house.fill",
                    title: "Home",
                    detail: "Chennai Central, Park Town",
                    color: Color(hex: 0x4EA8DE)
                )
                HairlineDivider(color: Color(hex: 0x49769F).opacity(0.12))
                placeRow(
                    symbol: "briefcase.fill",
                    title: "Workplace",
                    detail: "T. Nagar Smart City Complex",
                    color: Color(hex: 0x2A82BE)
                )
            }
            .padding(.horizontal, 14)
            .profileCard(radius: 24)
        }
    }

    private func placeRow(symbol: String, title: String, detail: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.midnightBlue)

                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: 0x49769F))
            }

            Spacer()

            Button {
            } label: {
                Text("Edit")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x2A90D4))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.85))
                            .background(.ultraThinMaterial, in: Capsule())
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.9), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Discovery Interests Section
    private var travelInterestsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Discovery Interests", icon: "sparkles")

            VStack(alignment: .leading, spacing: 12) {
                Text("Customize your Chennai Explore recommendations:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: 0x49769F))

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
            .profileCard(radius: 24)
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
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : Color(hex: 0x2A90D4))

                Text(name)
                    .font(.system(size: 12, weight: isSelected ? .bold : .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.white : Color.midnightBlue)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [Color(hex: 0x4EA8DE), Color(hex: 0x2A82BE)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Color.white.opacity(0.85))
                    )
                    .background(.ultraThinMaterial, in: Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.40) : Color.white.opacity(0.90), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Color(hex: 0x2A82BE).opacity(0.35) : Color.black.opacity(0.04),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Transit & Support Section
    private var transitSupportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Transit & Support", icon: "gearshape.fill")

            VStack(spacing: 0) {
                actionRow(
                    symbol: "questionmark.circle.fill",
                    title: "Chennai Transit FAQs and Help",
                    trailing: "Guide"
                )

                HairlineDivider(color: Color(hex: 0x49769F).opacity(0.12))

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
                                    .fill(Color.strawberry.opacity(0.15))
                                    .background(.ultraThinMaterial, in: Circle())
                            )

                        Text("Logout")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.strawberry)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.raahaCaption)
                            .foregroundStyle(Color(hex: 0x49769F).opacity(0.5))
                    }
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .profileCard(radius: 24)
        }
    }

    private func actionRow(symbol: String, title: String, trailing: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color(hex: 0x2A90D4))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .background(.ultraThinMaterial, in: Circle())
                )
                .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 1))

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.midnightBlue)

            Spacer()

            Text(trailing)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: 0x49769F))

            Image(systemName: "chevron.right")
                .font(.raahaCaption)
                .foregroundStyle(Color(hex: 0x49769F).opacity(0.5))
        }
        .padding(.vertical, 10)
    }

    // MARK: - Section Title Helper
    private func sectionTitle(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(hex: 0x2A90D4))
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.midnightBlue)
        }
        .padding(.leading, 4)
    }

    // MARK: - Footer Note
    private var footerNote: some View {
        VStack(spacing: 4) {
            Text("RAAHA Chennai • Multimodal Urban Transit")
                .font(.raahaCaption)
                .foregroundStyle(Color(hex: 0x49769F).opacity(0.85))
            Text("Version 2.2.0 (Build 50) • Native SwiftUI")
                .font(.raahaCaption2)
                .foregroundStyle(Color(hex: 0x49769F).opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

// MARK: - Profile Card Surface Extension
private extension View {
    func profileCard(radius: CGFloat = 24) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.white.opacity(0.70))
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: radius, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(Color.white.opacity(0.85), lineWidth: 1.2)
                    )
                    .shadow(color: Color(hex: 0x49769F).opacity(0.12), radius: 12, x: 0, y: 4)
            )
    }
}

#Preview {
    ProfileView()
        .environment(AppRouter())
}
