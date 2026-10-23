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

    // Swap rotation state
    @State private var swapRotation: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 18) {
                    plannerCard
                    smartRouteCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
            .scrollDismissesKeyboard(.interactively)
        }
        .raahaScreenBackground()
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

                    Text("Plan your journey across Chennai\nwith all modes, in one place.")
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
                            .fill(Color.deepSpace)
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
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Not sure where to go?")
                        .font(.system(size: 18.5, weight: .bold))
                        .foregroundStyle(Color.white)

                    Text("Try our Smart Route Planner")
                        .font(.system(size: 13.5, weight: .regular))
                        .foregroundStyle(Color(hex: 0xA4C8D8).opacity(0.85))
                }

                Spacer(minLength: 8)

                ZStack {
                    Circle()
                        .fill(Color(hex: 0x5DA1AB))
                        .frame(width: 48, height: 48)
                        .shadow(color: Color.deepSpace.opacity(0.15), radius: 6, x: 0, y: 3)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.white)
                }
            }
            .padding(.leading, 22)
            .padding(.trailing, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, minHeight: 84)
            .background(SmartRouteBackground())
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.deepSpace.opacity(0.16), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Not sure where to go? Try our Smart Route Planner")
        .accessibilityHint("Plans a smart route across Chennai")
    }
}

// MARK: - Smart Route Banner Fluid Waves Background

private struct SmartRouteBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                // 1. Base deep oceanic blue background
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: 0x163D5C), location: 0.0),
                        .init(color: Color(hex: 0x18476A), location: 0.50),
                        .init(color: Color(hex: 0x123652), location: 0.85),
                        .init(color: Color(hex: 0x0F2B42), location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                // 2. Bottom-right dark rounded cove (organic depth under the button)
                Path { p in
                    p.move(to: CGPoint(x: w * 0.70, y: h))
                    p.addCurve(
                        to: CGPoint(x: w, y: h * 0.55),
                        control1: CGPoint(x: w * 0.76, y: h * 0.60),
                        control2: CGPoint(x: w * 0.88, y: h * 0.40)
                    )
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0x174961).opacity(0.85),
                            Color(hex: 0x103147).opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // 3. Top-right sweeping teal wave (entering from top edge toward right)
                Path { p in
                    p.move(to: CGPoint(x: w * 0.73, y: 0))
                    p.addCurve(
                        to: CGPoint(x: w, y: h * 0.65),
                        control1: CGPoint(x: w * 0.76, y: h * 0.35),
                        control2: CGPoint(x: w * 0.88, y: h * 0.52)
                    )
                    p.addLine(to: CGPoint(x: w, y: 0))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: 0x4FB8A6).opacity(0.65), location: 0.0),
                            .init(color: Color(hex: 0x2E8D94).opacity(0.35), location: 0.5),
                            .init(color: Color(hex: 0x195262).opacity(0.1), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottomTrailing
                    )
                )

                // 4. Dark organic peninsula separating the two waves
                Path { p in
                    p.move(to: CGPoint(x: w * 0.74, y: 0))
                    p.addCurve(
                        to: CGPoint(x: w * 0.60, y: h),
                        control1: CGPoint(x: w * 0.72, y: h * 0.38),
                        control2: CGPoint(x: w * 0.65, y: h * 0.78)
                    )
                    p.addLine(to: CGPoint(x: w * 0.68, y: h))
                    p.addCurve(
                        to: CGPoint(x: w * 0.79, y: 0),
                        control1: CGPoint(x: w * 0.73, y: h * 0.78),
                        control2: CGPoint(x: w * 0.78, y: h * 0.38)
                    )
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0x11334E).opacity(0.85),
                            Color(hex: 0x0E283E).opacity(0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // 5. The primary vibrant seafoam/teal ribbon
                Path { p in
                    p.move(to: CGPoint(x: w * 0.67, y: 0))
                    // Left outer curve swooping down-left
                    p.addCurve(
                        to: CGPoint(x: w * 0.54, y: h),
                        control1: CGPoint(x: w * 0.67, y: h * 0.36),
                        control2: CGPoint(x: w * 0.60, y: h * 0.74)
                    )
                    // Bottom width
                    p.addLine(to: CGPoint(x: w * 0.58, y: h))
                    // Right inner curve back up
                    p.addCurve(
                        to: CGPoint(x: w * 0.75, y: 0),
                        control1: CGPoint(x: w * 0.64, y: h * 0.74),
                        control2: CGPoint(x: w * 0.71, y: h * 0.36)
                    )
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: 0x54C4AE), location: 0.0),
                            .init(color: Color(hex: 0x45A699), location: 0.28),
                            .init(color: Color(hex: 0x308C93), location: 0.58),
                            .init(color: Color(hex: 0x226B7A).opacity(0.6), location: 0.85),
                            .init(color: Color(hex: 0x184D5E).opacity(0.0), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}


