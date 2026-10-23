import SwiftUI

struct ProfileView: View {
    // MARK: - State
    @State private var preferMetroAndRail: Bool = true
    @State private var wellLitRoutes: Bool = true
    @State private var ecoFriendlyRouting: Bool = true
    @State private var hapticsEnabled: Bool = true

    @State private var selectedInterests: Set<String> = ["Beaches", "Heritage", "Food"]
    @State private var showResetCacheDialog: Bool = false
    @State private var cacheClearedNotification: Bool = false

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
                    // 1. Commute Impact Stats Card
                    commuteImpactCard

                    // 2. Commute Preferences Group
                    commutePreferencesSection

                    // 3. Saved Chennai Places Group
                    savedPlacesSection

                    // 4. Travel Interests Group
                    travelInterestsSection

                    // 5. Transit App Info & Settings Group
                    appSettingsSection

                    // Version Footer
                    footerNote
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
        }
        .background(LinearGradient.raahaScreen.ignoresSafeArea())
        .navyHeaderChrome()
        .confirmationDialog(
            "Clear Transit Cache?",
            isPresented: $showResetCacheDialog,
            titleVisibility: .visible
        ) {
            Button("Clear Cache", role: .destructive) {
                withAnimation {
                    cacheClearedNotification = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { cacheClearedNotification = false }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will refresh local Chennai timetable and station indices.")
        }
        .overlay(alignment: .top) {
            if cacheClearedNotification {
                Text("✓ Transit cache cleared successfully")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.honeydew)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.deepSpace).shadow(radius: 8))
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        NavyHeader {
            HStack(spacing: 16) {
                // Profile Avatar with Edit badge
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(Color.frostedBlue)
                        .background(Circle().fill(Color.steelBlue.opacity(0.4)))
                        .overlay(Circle().stroke(Color.honeydew.opacity(0.4), lineWidth: 2))

                    Circle()
                        .fill(Color.strawberry)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.honeydew)
                        )
                        .overlay(Circle().stroke(Color.deepSpace, lineWidth: 2))
                        .offset(x: 2, y: 2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Akshaya Kumar")
                        .font(.raahaTitle2)
                        .foregroundStyle(Color.honeydew)

                    Text("akshaya.kumar@gmail.com")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.frostedBlue.opacity(0.85))

                    HStack(spacing: 6) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 10))
                        Text("Chennai Verified Commuter")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(Color.honeydew)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.steelBlue.opacity(0.5)))
                }

                Spacer()
            }
            .padding(.top, 4)
            .padding(.bottom, 6)
        }
    }

    // MARK: - Commute Impact Stats Card
    private var commuteImpactCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Chennai Commute Impact", systemImage: "chart.bar.xaxis")
                    .font(.raahaFootnoteSemibold)
                    .foregroundStyle(Color.honeydew)
                Spacer()
                Text("This Month")
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.frostedBlue)
            }

            HStack(spacing: 8) {
                statBox(title: "Trips Taken", value: "28", icon: "tram.fill", color: Color.frostedBlue)
                statBox(title: "Fare Saved", value: "₹920", icon: "indianrupeesign", color: Color.honeydew)
                statBox(title: "CO₂ Reduced", value: "5.4 kg", icon: "leaf.fill", color: Color(red: 0.5, green: 0.85, blue: 0.6))
            }
        }
        .padding(14)
        .navyCard(radius: 20, gradient: .raahaNavyGlow)
    }

    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.raahaHeadline)
                .foregroundStyle(Color.honeydew)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.frostedBlue.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.deepSpace.opacity(0.5))
        )
    }

    // MARK: - Commute Preferences Section
    private var commutePreferencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Commute Preferences", icon: "slider.horizontal.3")

            VStack(spacing: 0) {
                preferenceToggleRow(
                    symbol: "tram.fill",
                    title: "Prefer Metro & Suburban Rail",
                    subtitle: "Fastest non-congested transit corridors",
                    isOn: $preferMetroAndRail
                )
                HairlineDivider(color: Color.frostedBlue.opacity(0.2))
                preferenceToggleRow(
                    symbol: "lightbulb.fill",
                    title: "Well-Lit Walk Pathways",
                    subtitle: "Prioritize safer night connections",
                    isOn: $wellLitRoutes
                )
                HairlineDivider(color: Color.frostedBlue.opacity(0.2))
                preferenceToggleRow(
                    symbol: "leaf.fill",
                    title: "Eco-Friendly Routing",
                    subtitle: "Minimize carbon footprint per journey",
                    isOn: $ecoFriendlyRouting
                )
                HairlineDivider(color: Color.frostedBlue.opacity(0.2))
                preferenceToggleRow(
                    symbol: "iphone.radiowaves.left.and.right",
                    title: "Tactile Haptic Feedback",
                    subtitle: "Physical clicks on tabs, chips & cards",
                    isOn: $hapticsEnabled
                )
            }
            .padding(.horizontal, 14)
            .navyCard(radius: 20)
        }
    }

    private func preferenceToggleRow(symbol: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.honeydew)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color.steelBlue.opacity(0.6)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.honeydew)
                Text(subtitle)
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.frostedBlue.opacity(0.8))
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.strawberry)
                .sensoryFeedback(.selection, trigger: isOn.wrappedValue)
        }
        .padding(.vertical, 11)
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
                    color: Color.steelBlue
                )
                HairlineDivider(color: Color.frostedBlue.opacity(0.2))
                placeRow(
                    symbol: "briefcase.fill",
                    title: "Workplace",
                    detail: "T. Nagar Smart City Complex",
                    color: Color.frostedBlue
                )
                HairlineDivider(color: Color.frostedBlue.opacity(0.2))
                placeRow(
                    symbol: "figure.run",
                    title: "Fitness",
                    detail: "Besant Nagar Beach Promenade",
                    color: Color.honeydew
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
                .foregroundStyle(Color.deepSpace)
                .frame(width: 32, height: 32)
                .background(Circle().fill(color))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.honeydew)
                Text(detail)
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.frostedBlue.opacity(0.8))
            }

            Spacer()

            Button {
            } label: {
                Text("Edit")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.frostedBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().stroke(Color.frostedBlue.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Travel Interests Section
    private var travelInterestsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Discovery Interests", icon: "sparkles")

            VStack(alignment: .leading, spacing: 10) {
                Text("Customize your Chennai Explore recommendations:")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.frostedBlue.opacity(0.85))

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
            .foregroundStyle(isSelected ? Color.deepSpace : Color.honeydew)
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(
                Capsule()
                    .fill(isSelected ? Color.honeydew : Color.deepSpace.opacity(0.6))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.frostedBlue.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - App & Support Section
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Transit & Support", icon: "gearshape.fill")

            VStack(spacing: 0) {
                actionRow(
                    symbol: "map.fill",
                    title: "Chennai Metropolitan Boundary",
                    trailing: "1,189 km²"
                )
                HairlineDivider(color: Color.frostedBlue.opacity(0.2))
                actionRow(
                    symbol: "questionmark.circle.fill",
                    title: "Chennai Transit FAQs & Help",
                    trailing: "Guide"
                )
                HairlineDivider(color: Color.frostedBlue.opacity(0.2))
                Button {
                    showResetCacheDialog = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.raahaSubheadlineMedium)
                            .foregroundStyle(Color.strawberry)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.strawberry.opacity(0.2)))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reset Transit Cache")
                                .font(.raahaSubheadlineMedium)
                                .foregroundStyle(Color.strawberry)
                            Text("Clears temporary route indices")
                                .font(.raahaCaption2)
                                .foregroundStyle(Color.frostedBlue.opacity(0.7))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.raahaCaption)
                            .foregroundStyle(Color.frostedBlue.opacity(0.5))
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
                .background(Circle().fill(Color.steelBlue.opacity(0.6)))

            Text(title)
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.honeydew)

            Spacer()

            Text(trailing)
                .font(.raahaCaption)
                .foregroundStyle(Color.frostedBlue)

            Image(systemName: "chevron.right")
                .font(.raahaCaption)
                .foregroundStyle(Color.frostedBlue.opacity(0.5))
        }
        .padding(.vertical, 10)
    }

    // MARK: - Section Title Helper
    private func sectionTitle(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.steelBlue)
            Text(title)
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.deepSpace)
        }
        .padding(.leading, 4)
    }

    // MARK: - Footer Note
    private var footerNote: some View {
        VStack(spacing: 4) {
            Text("RAAHA Chennai • Multimodal Urban Transit")
                .font(.raahaCaption)
                .foregroundStyle(Color.steelBlue)
            Text("Version 2.2.0 (Build 50) • Native SwiftUI")
                .font(.raahaCaption2)
                .foregroundStyle(Color.steelBlue.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}
