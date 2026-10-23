import SwiftUI

// MARK: - HomeView

/// Creative, premium, interactive Home screen for RAAHA Chennai multimodal journey planner.
struct HomeView: View {
    @EnvironmentObject private var router: AppRouter

    @State private var from: String = "Current Location"
    @State private var to: String   = "Phoenix Mall, Velachery"

    // Sheet states
    @State private var editingFrom = false
    @State private var editingTo   = false

    // Quick mode filter selection
    @State private var selectedMode: TransportMode? = nil

    // Swap rotation state
    @State private var swapRotation: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    plannerCard
                    modeShortcuts
                    quickDestinations
                    commuteStatusCard
                    smartRouteCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(LinearGradient.raahaScreen.ignoresSafeArea())
        .navyHeaderChrome()
        // Origin picker sheet
        .sheet(isPresented: $editingFrom) {
            LocationPickerSheet(
                title: "Choose Origin",
                prompt: "Search locality or station…",
                current: from,
                suggestions: LocationSuggestions.origins
            ) { chosen in
                from = chosen
            }
        }
        // Destination picker sheet
        .sheet(isPresented: $editingTo) {
            LocationPickerSheet(
                title: "Choose Destination",
                prompt: "Search Chennai destination…",
                current: to,
                suggestions: LocationSuggestions.destinations
            ) { chosen in
                to = chosen
            }
        }
    }

    // MARK: - Dynamic Greeting Header

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var header: some View {
        NavyHeader {
            ZStack(alignment: .trailing) {
                // Background artistic vehicle graphic
                Image("home_vehicles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 195)
                    .padding(.trailing, -16)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(greeting), Akshay")
                        .font(.raahaSubheadlineMedium)
                        .foregroundStyle(Color.frostedBlue)

                    Text("Where to in Chennai?")
                        .font(.raahaTitle)
                        .foregroundStyle(Color.honeydew)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text("Seamless multimodal routes across Metro, Bus, Auto & Suburban Rail.")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.frostedBlue.opacity(0.9))
                        .frame(maxWidth: 195, alignment: .leading)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 136)
        }
    }

    // MARK: - Journey Planner Card

    private var plannerCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                // FROM row
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.frostedBlue)
                            .frame(width: 36, height: 36)
                        Image(systemName: "location.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.deepSpace)
                    }

                    Button {
                        editingFrom = true
                    } label: {
                        fieldRow(label: "FROM", value: from)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("From: \(from). Tap to change origin.")
                }

                // Middle connector & swap button
                HStack(spacing: 14) {
                    VStack(spacing: 3) {
                        ForEach(0..<4, id: \.self) { _ in
                            Circle()
                                .fill(Color.frostedBlue.opacity(0.5))
                                .frame(width: 3, height: 3)
                        }
                    }
                    .frame(width: 36)

                    Rectangle()
                        .fill(Color.frostedBlue.opacity(0.2))
                        .frame(height: 1)

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                            swapRotation += 180
                            let temp = from
                            from = to
                            to = temp
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.deepSpace.opacity(0.85))
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.frostedBlue.opacity(0.35), lineWidth: 1))
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.honeydew)
                                .rotationEffect(.degrees(swapRotation))
                        }
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: swapRotation)
                    .accessibilityLabel("Swap origin and destination")
                }
                .frame(height: 38)
                .padding(.vertical, 2)

                // TO row
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.strawberry)
                            .frame(width: 36, height: 36)
                        Image("icon_pin")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(Color.honeydew)
                    }

                    Button {
                        editingTo = true
                    } label: {
                        fieldRow(label: "TO", value: to)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("To: \(to). Tap to change destination.")
                }
            }

            // Start Journey Call-To-Action Button
            Button {
                router.planJourney(from: from, to: to)
            } label: {
                HStack(spacing: 8) {
                    Text("Find Best Routes")
                        .font(.raahaHeadline)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .buttonStyle(.pillLight)
            .sensoryFeedback(.impact(weight: .medium), trigger: from)
        }
        .padding(18)
        .navyCard(radius: 24, gradient: .raahaHero)
    }

    private func fieldRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.raahaCaption2)
                .foregroundStyle(Color.frostedBlue.opacity(0.85))

            HStack {
                Text(value)
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.honeydew)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.frostedBlue.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    // MARK: - Mode Shortcuts

    private var modeShortcuts: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Modes in Chennai")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                Spacer()
                if selectedMode != nil {
                    Button("Clear filter") {
                        withAnimation(.spring(response: 0.25)) { selectedMode = nil }
                    }
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.strawberry)
                }
            }
            .padding(.horizontal, 4)

            HStack(spacing: 10) {
                modeItem(.metro, label: "Metro", icon: "tram.fill", customAsset: "icon_metro")
                modeItem(.bus, label: "Bus", icon: "bus.fill", customAsset: nil)
                modeItem(.auto, label: "Auto", icon: "car.fill", customAsset: "icon_auto")
                modeItem(.train, label: "Rail", icon: "train.side.front.car", customAsset: "icon_train")
                modeItem(.bike, label: "Bike", icon: "bicycle", customAsset: "icon_bike")
            }
        }
    }

    private func modeItem(_ mode: TransportMode, label: String, icon: String, customAsset: String?) -> some View {
        let isSelected = selectedMode == mode
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                selectedMode = isSelected ? nil : mode
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.strawberry : Color.honeydew)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.deepSpace.opacity(0.08), radius: 6, x: 0, y: 3)

                    if let customAsset {
                        Image(customAsset)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(isSelected ? Color.honeydew : Color.deepSpace)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(isSelected ? Color.honeydew : Color.deepSpace)
                    }
                }

                Text(label)
                    .font(.raahaCaption2)
                    .foregroundStyle(isSelected ? Color.strawberry : Color.deepSpace)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedMode)
        .accessibilityLabel("\(label) mode filter")
    }

    // MARK: - Quick Destinations

    private var quickDestinations: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Popular Destinations", action: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(LocationSuggestions.destinations, id: \.self) { dest in
                        Button {
                            to = dest
                            router.planJourney(from: from, to: dest)
                        } label: {
                            HStack(spacing: 6) {
                                Image("icon_pin")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(Color.honeydew)
                                Text(dest)
                                    .font(.raahaFootnoteSemibold)
                                    .foregroundStyle(Color.honeydew)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.deepSpace))
                            .shadow(color: Color.deepSpace.opacity(0.12), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(TactileButtonStyle())
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .lightCard(radius: 20)
    }

    // MARK: - Daily Commute Live Card

    private var commuteStatusCard: some View {
        Button {
            router.planJourney(from: "Alandur Metro", to: "T. Nagar")
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.deepSpace)
                        .frame(width: 48, height: 48)
                    Image("icon_metro")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.honeydew)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Circle().fill(Color.statusGreen).frame(width: 6, height: 6)
                        Text("METRO ON TIME · BLUE LINE")
                            .font(.raahaCaption2)
                            .foregroundStyle(Color.statusGreen)
                    }

                    Text("Alandur → T. Nagar")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.deepSpace)

                    Text("Next train in 4 min · Est. 18 min travel")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.steelBlue)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.steelBlue)
            }
            .padding(14)
            .lightCard(radius: 20)
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityLabel("Daily commute: Alandur to T Nagar. Next train in 4 minutes.")
    }

    // MARK: - Smart Planner Banner

    private var smartRouteCard: some View {
        SmartRouteBanner {
            router.planJourney(from: from, to: to)
        }
    }
}

// MARK: - LocationPickerSheet

struct LocationPickerSheet: View {
    let title: String
    let prompt: String
    let current: String
    let suggestions: [String]
    let onSelect: (String) -> Void

    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    private var filtered: [String] {
        if query.isEmpty { return suggestions }
        return suggestions.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.steelBlue)

                    TextField("", text: $query,
                              prompt: Text(prompt).foregroundStyle(Color.steelBlue))
                        .font(.raahaBody)
                        .foregroundStyle(Color.deepSpace)
                        .submitLabel(.search)
                        .onSubmit {
                            if !query.isEmpty {
                                commit(query)
                            }
                        }

                    if !query.isEmpty {
                        Button {
                            query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.steelBlue)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 50)
                .background(Color.frostedBlue.opacity(0.25), in: Capsule())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Current location shortcut
                Button {
                    commit("Current Location")
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                            .font(.raahaHeadline)
                            .foregroundStyle(Color.steelBlue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Use Current Location")
                                .font(.raahaHeadline)
                                .foregroundStyle(Color.deepSpace)
                            Text("Chennai Metropolitan Area")
                                .font(.raahaCaption)
                                .foregroundStyle(Color.steelBlue)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)

                HairlineDivider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)

                // Suggestions List
                List(filtered, id: \.self) { place in
                    Button {
                        commit(place)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(Color.steelBlue)
                            Text(place)
                                .font(.raahaSubheadlineMedium)
                                .foregroundStyle(Color.deepSpace)
                            Spacer()
                            if place == current {
                                Image(systemName: "checkmark")
                                    .font(.raahaCaption)
                                    .foregroundStyle(Color.statusGreen)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
            .background(Color.honeydew.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.steelBlue)
                }
            }
        }
    }

    private func commit(_ value: String) {
        onSelect(value)
        dismiss()
    }
}

// MARK: - Location Suggestions (Strict Chennai Only)

enum LocationSuggestions {
    static let origins: [String] = [
        "Current Location",
        "Chennai Central",
        "Egmore Railway Station",
        "Chennai Airport",
        "T. Nagar",
        "Alandur Metro Station",
        "Adyar",
        "Guindy",
        "Anna Nagar",
        "Tambaram",
        "Koyambedu CMBT",
        "Velachery"
    ]

    static let destinations: [String] = [
        "Phoenix Mall, Velachery",
        "Marina Beach",
        "Besant Nagar Beach",
        "Kapaleeshwarar Temple, Mylapore",
        "Chennai Airport",
        "T. Nagar",
        "Anna Nagar",
        "San Thome Basilica",
        "Egmore Museum",
        "Guindy National Park"
    ]
}

// MARK: - SmartRouteBanner (Shared by Home and Trips)

struct SmartRouteBanner: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Not sure where to go?")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.honeydew)
                    Text("Explore curated Chennai destinations")
                        .font(.raahaSubheadline)
                        .foregroundStyle(Color.frostedBlue)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.raahaBody)
                    .foregroundStyle(Color.deepSpace)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.frostedBlue))
            }
            .padding(18)
            .navyCard(radius: 20, gradient: .raahaBanner)
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens curated destinations")
    }
}
