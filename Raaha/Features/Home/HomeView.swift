import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter

    @State private var from: String = "Current Location"
    @State private var to: String   = "Phoenix Mall, Velachery"

    // Sheet state
    @State private var editingFrom = false
    @State private var editingTo   = false

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    plannerCard
                    quickDestinations
                    smartRouteCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
        }
        .background(LinearGradient.raahaScreen.ignoresSafeArea())
        .navyHeaderChrome()
        // FROM sheet
        .sheet(isPresented: $editingFrom) {
            LocationPickerSheet(
                title: "From",
                prompt: "Search origin…",
                current: from,
                suggestions: LocationSuggestions.origins
            ) { chosen in
                from = chosen
            }
        }
        // TO sheet
        .sheet(isPresented: $editingTo) {
            LocationPickerSheet(
                title: "To",
                prompt: "Search destination…",
                current: to,
                suggestions: LocationSuggestions.destinations
            ) { chosen in
                to = chosen
            }
        }
    }

    // MARK: Header

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
                Image("home_vehicles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 196)
                    .padding(.trailing, -20)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(greeting) Akshay")
                        .font(.raahaBody)
                        .foregroundStyle(Color.frostedBlue)
                    Text("What's the move?")
                        .font(.raahaTitle)
                        .foregroundStyle(Color.honeydew)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("Plan your journey across Chennai with all modes, in one place.")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.frostedBlue)
                        .frame(maxWidth: 190, alignment: .leading)
                        .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 134)
        }
    }

    // MARK: Planner

    private var plannerCard: some View {
        VStack(spacing: 18) {
            VStack(spacing: 0) {
                // FROM row
                HStack(spacing: 14) {
                    iconCircle("location.fill")
                    Button { editingFrom = true } label: {
                        field(label: "FROM", value: from)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("From: \(from). Tap to change.")
                }

                // Middle divider & swap button
                HStack(spacing: 14) {
                    Rectangle()
                        .fill(Color.deepSpace)
                        .frame(width: 1.5)
                        .frame(width: 40)

                    HStack(spacing: 14) {
                        Rectangle()
                            .fill(Color.deepSpace.opacity(0.8))
                            .frame(height: 1.5)

                        Button {
                            withAnimation(.snappy) {
                                let tmp = from; from = to; to = tmp
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.raahaHeadline)
                                .foregroundStyle(Color.deepSpace)
                                .frame(width: 46, height: 46)
                                .background(Circle().fill(Color.honeydew))
                        }
                        .accessibilityLabel("Swap origin and destination")
                    }
                }
                .frame(height: 46)
                .padding(.vertical, 4)

                // TO row
                HStack(spacing: 14) {
                    iconCircle(asset: "icon_pin")
                    Button { editingTo = true } label: {
                        field(label: "TO", value: to)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("To: \(to). Tap to change.")
                }
            }

            Button("Plan Journey") {
                router.planJourney(from: from, to: to)
            }
            .buttonStyle(.pillLight)
        }
        .padding(18)
        .navyCard(radius: 30, gradient: .raahaHero)
    }

    private func iconCircle(_ symbol: String? = nil, asset: String? = nil) -> some View {
        Group {
            if let asset {
                Image(asset)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            } else if let symbol {
                Image(systemName: symbol)
                    .font(.raahaBody)
            }
        }
        .foregroundStyle(Color.deepSpace)
        .frame(width: 40, height: 40)
        .background(Circle().fill(Color.honeydew))
        .accessibilityHidden(true)
    }

    private func field(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.raahaCaption2)
                .foregroundStyle(Color.frostedBlue)
            HStack {
                Text(value)
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.honeydew)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 4)
                Image(systemName: "pencil")
                    .font(.raahaCaption)
                    .foregroundStyle(Color.frostedBlue.opacity(0.7))
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Quick destinations

    private var quickDestinations: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick destinations")
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color.deepSpace)

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
                                    .frame(width: 13, height: 13)
                                    .foregroundStyle(Color.honeydew)
                                Text(dest)
                                    .font(.raahaFootnoteSemibold)
                                    .foregroundStyle(Color.honeydew)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.deepSpace))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .padding(16)
        .lightCard(radius: 22)
    }

    // MARK: Smart planner banner

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
                // Search field
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
                        Button { query = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.steelBlue)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 52)
                .background(Color.frostedBlue.opacity(0.18), in: Capsule())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Use current location shortcut
                Button {
                    commit("Current Location")
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                            .font(.raahaBody)
                            .foregroundStyle(Color.honeydew)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.steelBlue))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current Location")
                                .font(.raahaSubheadline)
                                .foregroundStyle(Color.deepSpace)
                            Text("Use your GPS location")
                                .font(.raahaCaption)
                                .foregroundStyle(Color.steelBlue)
                        }
                        Spacer()
                        if current == "Current Location" {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.steelBlue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)

                Divider().padding(.horizontal, 16)

                // Suggestions list
                List {
                    Section(header: Text("Suggestions")
                        .font(.raahaFootnoteSemibold)
                        .foregroundStyle(Color.steelBlue)) {
                        ForEach(filtered, id: \.self) { place in
                            Button {
                                commit(place)
                            } label: {
                                HStack(spacing: 12) {
                                    Image("icon_pin")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                        .foregroundStyle(Color.strawberry)
                                        .frame(width: 32)
                                    Text(place)
                                        .font(.raahaSubheadline)
                                        .foregroundStyle(Color.deepSpace)
                                    Spacer()
                                    if place == current {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.steelBlue)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .background(LinearGradient.raahaScreen.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.steelBlue)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func commit(_ value: String) {
        onSelect(value)
        dismiss()
    }
}

// MARK: - Suggestion data

enum LocationSuggestions {
    static let origins: [String] = [
        "Current Location",
        "Chennai Central",
        "Chennai Airport",
        "T. Nagar",
        "Anna Nagar",
        "Adyar",
        "Velachery",
        "Tambaram",
        "Guindy",
        "Egmore"
    ]

    static let destinations: [String] = [
        "Phoenix Mall, Velachery",
        "Marina Beach",
        "Besant Nagar Beach",
        "Chennai Airport",
        "T. Nagar",
        "Anna Nagar",
        "Mahabalipuram",
        "Egmore",
        "Tambaram",
        "Guindy"
    ]
}

// MARK: - SmartRouteBanner (shared by Home and Trips)

/// "Not sure where to go?" banner, shared by Home and Trips.
struct SmartRouteBanner: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Not sure where to go?")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.honeydew)
                    Text("Try our Smart Route Planner")
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
            .padding(20)
            .navyCard(radius: 24, gradient: .raahaBanner)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens route options")
    }
}
