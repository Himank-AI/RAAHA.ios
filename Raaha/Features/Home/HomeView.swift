import SwiftUI

// MARK: - HomeView

/// Creative, premium, interactive Home screen for RAAHA Chennai multimodal journey planner.
struct HomeView: View {
    @Environment(AppRouter.self) private var router

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
        .lightHeaderChrome()
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

    private var greetingSymbol: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<17: return "sun.max"
        default: return "moon.stars"
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text("\(greeting), Akshaya")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.lightSkyBlue)

                Image(systemName: greetingSymbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.royalBlue)
            }

            Text("Where to in\nChennai?")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.royalBlue)
                .lineSpacing(1)
                .fixedSize(horizontal: false, vertical: true)

            Text("Plan your journey\nacross Chennai with\nall modes, in one place.")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.lightSkyBlue.opacity(0.85))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 200, alignment: .leading)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .padding(.top, 8)
        .background(alignment: .topTrailing) {
            transitIllustration
                .ignoresSafeArea(edges: .top)
        }
    }

    private var transitIllustration: some View {
        Image("transit_illustration")
            .resizable()
            .scaledToFill()
            .containerRelativeFrame(.horizontal) { length, _ in length * 0.68 }
            .offset(y: -44)
            .frame(height: 290, alignment: .topTrailing)
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black.opacity(0.15), location: 0.12),
                        .init(color: .black.opacity(0.70), location: 0.32),
                        .init(color: .black, location: 0.55)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .black, location: 0.0),
                        .init(color: .black, location: 0.45),
                        .init(color: .black.opacity(0.65), location: 0.65),
                        .init(color: .black.opacity(0.20), location: 0.82),
                        .init(color: .clear, location: 0.96)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    // MARK: - Journey Planner Card

    private var plannerCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                // FROM row
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.brightBlue, Color.electricBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 38, height: 38)
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        Image(systemName: "location.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.white)
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
                                .fill(Color.lightSkyBlue.opacity(0.4))
                                .frame(width: 3, height: 3)
                        }
                    }
                    .frame(width: 38)

                    Rectangle()
                        .fill(Color.white.opacity(0.15))
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
                                .fill(Color.royalBlue.opacity(0.65))
                                .background(.ultraThinMaterial, in: Circle())
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.white.opacity(0.30), lineWidth: 1))
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.neonLime)
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
                            .fill(
                                LinearGradient(
                                    colors: [Color.brightBlue, Color.electricBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 38, height: 38)
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        Image("icon_pin")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(Color.white)
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
                Text("Find Best Routes")
                    .font(.raahaHeadline)
            }
            .buttonStyle(.pillLight)
            .sensoryFeedback(.impact(weight: .medium), trigger: from)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.55))
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.80), Color(hex: 0x7BBDE8).opacity(0.30)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color(hex: 0x49769F).opacity(0.20), radius: 18, x: 0, y: 8)
    }

    private func fieldRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.raahaCaption2)
                .foregroundStyle(Color.lightSkyBlue.opacity(0.85))

            HStack {
                Text(value)
                    .font(.raahaSubheadlineMedium)
                    .foregroundStyle(Color.midnightBlue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.lightSkyBlue.opacity(0.8))
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
                        .foregroundStyle(Color.lightSkyBlue)

                    TextField("", text: $query,
                              prompt: Text(prompt).foregroundStyle(Color.lightSkyBlue.opacity(0.7)))
                        .font(.raahaBody)
                        .foregroundStyle(Color.white)
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
                                .foregroundStyle(Color.lightSkyBlue)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.20), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Current location shortcut
                Button {
                    commit("Current Location")
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                            .font(.raahaHeadline)
                            .foregroundStyle(Color.neonLime)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Use Current Location")
                                .font(.raahaHeadline)
                                .foregroundStyle(Color.white)
                            Text("Chennai Metropolitan Area")
                                .font(.raahaCaption)
                                .foregroundStyle(Color.lightSkyBlue)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
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
                                .foregroundStyle(Color.lightSkyBlue)
                            Text(place)
                                .font(.raahaSubheadlineMedium)
                                .foregroundStyle(Color.white)
                            Spacer()
                            if place == current {
                                Image(systemName: "checkmark")
                                    .font(.raahaCaption)
                                    .foregroundStyle(Color.neonLime)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .raahaScreenBackground()
            .navigationTitle(title)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.lightSkyBlue)
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
                        .foregroundStyle(Color.lightSkyBlue)
                }

                Spacer(minLength: 8)

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.neonLime, Color(hex: 0x9EE600)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: Color.neonLime.opacity(0.35), radius: 8, x: 0, y: 3)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.midnightBlue)
                }
            }
            .padding(.leading, 22)
            .padding(.trailing, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, minHeight: 84)
            .background(SmartRouteBackground())
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.midnightBlue.opacity(0.35), radius: 14, x: 0, y: 6)
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
                // 1. Base deep midnight to royal blue gradient background
                LinearGradient(
                    stops: [
                        .init(color: Color.midnightBlue, location: 0.0),
                        .init(color: Color.royalBlue.opacity(0.85), location: 0.50),
                        .init(color: Color.midnightBlue, location: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // 2. Electric blue atmospheric glow
                Circle()
                    .fill(Color.electricBlue.opacity(0.45))
                    .frame(width: 140, height: 140)
                    .blur(radius: 25)
                    .offset(x: w * 0.35, y: -h * 0.1)

                // 3. Subtle translucent wave contour
                Path { p in
                    p.move(to: CGPoint(x: w * 0.60, y: 0))
                    p.addCurve(
                        to: CGPoint(x: w, y: h * 0.70),
                        control1: CGPoint(x: w * 0.72, y: h * 0.25),
                        control2: CGPoint(x: w * 0.85, y: h * 0.45)
                    )
                    p.addLine(to: CGPoint(x: w, y: 0))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color.brightBlue.opacity(0.35),
                            Color.electricBlue.opacity(0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottomTrailing
                    )
                )

                // 4. Sweeping glass ribbon
                Path { p in
                    p.move(to: CGPoint(x: w * 0.50, y: 0))
                    p.addCurve(
                        to: CGPoint(x: w * 0.38, y: h),
                        control1: CGPoint(x: w * 0.52, y: h * 0.40),
                        control2: CGPoint(x: w * 0.45, y: h * 0.75)
                    )
                    p.addLine(to: CGPoint(x: w * 0.46, y: h))
                    p.addCurve(
                        to: CGPoint(x: w * 0.58, y: 0),
                        control1: CGPoint(x: w * 0.53, y: h * 0.75),
                        control2: CGPoint(x: w * 0.60, y: h * 0.40)
                    )
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color.lightSkyBlue.opacity(0.25),
                            Color.brightBlue.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
}
