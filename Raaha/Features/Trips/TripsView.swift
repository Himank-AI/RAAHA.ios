import SwiftUI

// MARK: - Coastal palette for Trips

private enum Coastal {
    static let ice = Color(hex: 0xDCEFF5)
    static let soft = Color(hex: 0x75BBD0)
    static let deep = Color(hex: 0x176487)
    static let navy = Color(hex: 0x173D5C)
    static let muted = Color(hex: 0x326F89)
    static let white = Color(hex: 0xF5FAFC)
}

// MARK: - TripsView

/// Personal travel dashboard for upcoming, saved, and recent journeys.
struct TripsView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum TripFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case upcoming = "Upcoming"
        case saved = "Saved"
        case recent = "Recent"

        var id: String { rawValue }
    }

    @State private var activeFilter: TripFilter = .all
    @State private var savedJourneys: [SavedJourney] = MockData.savedJourneys
    @State private var upcomingTrips: [PlannedTrip] = MockData.upcomingTrips
    @State private var entered = false
    @Namespace private var filterSpace

    private var bookmarkedJourneys: [SavedJourney] {
        savedJourneys.filter(\.isBookmarked)
    }

    var body: some View {
        VStack(spacing: 0) {
            TripsHeader(
                upcomingCount: upcomingTrips.count,
                savedCount: bookmarkedJourneys.count
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    FeaturedJourneyCard(appeared: entered, reduceMotion: reduceMotion) {
                        router.planJourney(from: "Chennai Central", to: "T. Nagar")
                    }

                    TripsSegmentedControl(
                        selection: $activeFilter,
                        namespace: filterSpace,
                        reduceMotion: reduceMotion
                    )

                    if activeFilter == .all || activeFilter == .upcoming {
                        upcomingSection
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if activeFilter == .all || activeFilter == .saved {
                        savedSection
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if activeFilter == .all || activeFilter == .recent {
                        recentSection
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    CoastalPlannerCard {
                        router.planJourney(from: "Current Location", to: "Marina Beach")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .animation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.86), value: activeFilter)
            }
            .contentMargins(.bottom, 156, for: .scrollContent)
        }
        .raahaScreenBackground()
        .lightHeaderChrome()
        .onAppear {
            if reduceMotion {
                entered = true
            } else {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.84)) {
                    entered = true
                }
            }
        }
    }

    // MARK: Upcoming

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Upcoming", action: nil)

            if upcomingTrips.isEmpty {
                TripsEmptyState(
                    title: "No upcoming journeys",
                    message: "Plans you schedule will show up here."
                )
            } else {
                ForEach(Array(upcomingTrips.enumerated()), id: \.element.id) { index, trip in
                    UpcomingJourneyCard(trip: trip, index: index, revealed: entered, reduceMotion: reduceMotion) {
                        router.planJourney(from: trip.origin, to: trip.destination)
                    }
                }
            }
        }
    }

    // MARK: Saved

    private var savedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Saved Journeys", action: nil)

            if bookmarkedJourneys.isEmpty {
                TripsEmptyState(
                    title: "Nothing saved yet",
                    message: "Bookmark a journey and it will stay here."
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(bookmarkedJourneys) { journey in
                            SavedJourneyCard(journey: journey) {
                                router.planJourney(from: "Current Location", to: journey.name)
                            } onToggleBookmark: {
                                toggleBookmark(for: journey)
                            }
                            .modifier(SavedCardScrollEffect(enabled: !reduceMotion))
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.vertical, 4)
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollClipDisabled()
            }
        }
    }

    // MARK: Recent

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recent", action: nil)

            if MockData.recentTrips.isEmpty {
                TripsEmptyState(
                    title: "No recent trips",
                    message: "Journeys you finish will be listed here."
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(MockData.recentTrips) { trip in
                        RecentTripRow(trip: trip) {
                            let parts = trip.route.components(separatedBy: " → ")
                            let from = parts.first ?? "Current Location"
                            let to = parts.last ?? trip.route
                            router.planJourney(from: from, to: to)
                        }
                    }
                }
            }
        }
    }

    private func toggleBookmark(for journey: SavedJourney) {
        guard let idx = savedJourneys.firstIndex(where: { $0.id == journey.id }) else { return }
        let current = savedJourneys[idx]
        let updated = SavedJourney(
            id: current.id,
            name: current.name,
            route: current.route,
            imageName: current.imageName,
            isBookmarked: !current.isBookmarked
        )
        if reduceMotion {
            savedJourneys[idx] = updated
        } else {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                savedJourneys[idx] = updated
            }
        }
    }
}

// MARK: - Header

struct TripsHeader: View {
    let upcomingCount: Int
    let savedCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Journeys")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Coastal.navy)
                    .accessibilityAddTraits(.isHeader)
                Text("Your travel plans, all in one place.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Coastal.muted)
            }

            HStack(spacing: 8) {
                summaryPill(count: upcomingCount, label: "Upcoming")
                summaryPill(count: savedCount, label: "Saved")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private func summaryPill(count: Int, label: String) -> some View {
        HStack(spacing: 6) {
            Text("\(count)")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Coastal.deep)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Coastal.muted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(Coastal.ice.opacity(0.9)))
        .overlay(Capsule().stroke(Color.white.opacity(0.8), lineWidth: 0.8))
    }
}

// MARK: - Featured journey

struct FeaturedJourneyCard: View {
    var appeared: Bool
    var reduceMotion: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: -6) {
                        ModeBadge(mode: .metro, size: 32)
                        ModeBadge(mode: .walk, size: 32)
                    }
                    Spacer()
                    JourneyStatusBadge(text: "Fastest")
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Home → Work")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Coastal.navy)
                    HStack(spacing: 6) {
                        Text("Chennai Central")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                        Text("T. Nagar")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Coastal.muted)
                    .lineLimit(1)
                }

                HStack {
                    Text("22 min · Metro + Walk")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Coastal.deep)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Coastal.deep)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.7)))
                }
            }
            .padding(16)
            .background { featuredFill }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.75), lineWidth: 1)
            }
            .shadow(color: Coastal.deep.opacity(0.12), radius: 14, y: 8)
        }
        .buttonStyle(TactileButtonStyle(scale: 0.98))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared || reduceMotion ? 0 : 16)
        .accessibilityLabel("Home to Work, Chennai Central to T. Nagar, via Metro and Walk, 22 minutes. Fastest route.")
    }

    @ViewBuilder
    private var featuredFill: some View {
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)
        ZStack {
            shape.fill(
                LinearGradient(
                    colors: [Coastal.white, Coastal.ice, Coastal.soft.opacity(0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            if #available(iOS 26, *) {
                shape.fill(Color.clear)
                    .glassEffect(.regular.tint(Coastal.ice.opacity(0.35)), in: shape)
            } else {
                shape.fill(.ultraThinMaterial)
            }
        }
    }
}

// MARK: - Filters

struct TripsSegmentedControl: View {
    @Binding var selection: TripsView.TripFilter
    var namespace: Namespace.ID
    var reduceMotion: Bool

    var body: some View {
        HStack(spacing: 4) {
            ForEach(TripsView.TripFilter.allCases) { filter in
                let isSelected = selection == filter
                Button {
                    guard selection != filter else { return }
                    if reduceMotion {
                        selection = filter
                    } else {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                            selection = filter
                        }
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                        .foregroundStyle(isSelected ? Coastal.white : Coastal.navy.opacity(0.72))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Coastal.deep)
                                    .matchedGeometryEffect(id: "trips-filter", in: namespace)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background {
            Capsule().fill(.ultraThinMaterial)
            Capsule().fill(Color.white.opacity(0.45))
        }
        .overlay(Capsule().stroke(Color.white.opacity(0.7), lineWidth: 0.8))
        .sensoryFeedback(.selection, trigger: selection)
    }
}

// MARK: - Upcoming card

struct UpcomingJourneyCard: View {
    let trip: PlannedTrip
    var index: Int
    var revealed: Bool
    var reduceMotion: Bool
    let onPlan: () -> Void

    @State private var livePulse = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: onPlan) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(trip.scheduledDate)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Coastal.muted)
                            JourneyStatusBadge(text: trip.countdownText)
                        }
                        Spacer()
                        ModeBadge(mode: trip.primaryMode, size: 40)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Coastal.navy)
                            .multilineTextAlignment(.leading)
                        Text("\(trip.origin) → \(trip.destination)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Coastal.muted)
                            .lineLimit(1)
                        Text(trip.primaryMode.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Coastal.deep)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.estimatedDuration)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Coastal.navy)
                    Text(trip.estimatedFare)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Coastal.muted)
                }
                Spacer()
                Button {
                    livePulse += 1
                    onPlan()
                } label: {
                    Text("Start Live Trip")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Coastal.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Coastal.soft, Coastal.deep],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                }
                .buttonStyle(LiveTripButtonStyle())
                .sensoryFeedback(.impact(weight: .medium), trigger: livePulse)
            }
        }
        .padding(16)
        .background { frostedCard(radius: 22) }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
        }
        .shadow(color: Coastal.navy.opacity(0.08), radius: 12, y: 6)
        .opacity(revealed || reduceMotion ? 1 : 0)
        .offset(y: revealed || reduceMotion ? 0 : 18)
        .animation(
            reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.84).delay(Double(index) * 0.06),
            value: revealed
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(trip.title), \(trip.origin) to \(trip.destination), \(trip.scheduledDate)")
    }
}

// MARK: - Saved card

struct SavedJourneyCard: View {
    let journey: SavedJourney
    let action: () -> Void
    let onToggleBookmark: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(journey.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 176, height: 112)
                    .clipped()
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [Color.clear, Coastal.navy.opacity(0.28)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    }

                Button(action: onToggleBookmark) {
                    Image(systemName: journey.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(journey.isBookmarked ? Coastal.deep : Coastal.white)
                        .frame(width: 30, height: 30)
                        .background {
                            Circle().fill(.ultraThinMaterial)
                            Circle().fill(Color.white.opacity(journey.isBookmarked ? 0.82 : 0.22))
                        }
                        .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 0.8))
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .padding(8)
                .sensoryFeedback(.impact(weight: .light), trigger: journey.isBookmarked)
                .accessibilityLabel(journey.isBookmarked ? "Remove bookmark" : "Save journey")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(journey.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Coastal.navy)
                    .lineLimit(1)
                Text(journey.route)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Coastal.muted)
                    .lineLimit(2)
            }
            .padding(12)
            .frame(width: 176, alignment: .leading)
        }
        .frame(width: 176)
        .background(Coastal.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        }
        .shadow(color: Coastal.navy.opacity(0.10), radius: 10, y: 5)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture(perform: action)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(journey.name), \(journey.route)")
    }
}

// MARK: - Status badge

struct JourneyStatusBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Coastal.muted)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Capsule().fill(Coastal.ice))
    }
}

// MARK: - Empty state

struct TripsEmptyState: View {
    let title: String
    let message: String

    var body: some View {
        HStack(spacing: 14) {
            Image("birds")
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 40)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Coastal.navy)
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Coastal.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { frostedCard(radius: 18) }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.75), lineWidth: 1)
        }
    }
}

// MARK: - Recent row

private struct RecentTripRow: View {
    let trip: RecentTrip
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            let mode = TransportMode.mode(for: trip.mode)
            let modeColor = mode?.color ?? Coastal.deep

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill((mode?.tintedBackground) ?? Coastal.ice)
                        .frame(width: 42, height: 42)
                    if let asset = trip.customAsset {
                        Image(asset)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(modeColor)
                    } else {
                        Image(systemName: trip.symbol)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(modeColor)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(trip.route)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Coastal.navy)
                        .lineLimit(1)
                    Text("\(trip.mode) · \(trip.day), \(trip.time)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Coastal.muted)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text("Repeat")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Coastal.deep)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Coastal.ice))
            }
            .padding(12)
            .background { frostedCard(radius: 18) }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            }
        }
        .buttonStyle(TactileButtonStyle(scale: 0.985))
        .accessibilityLabel("Trip \(trip.route) via \(trip.mode) on \(trip.day). Repeat this journey.")
    }
}

// MARK: - Shared surfaces

private struct CoastalPlannerCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Not sure where to go?")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Coastal.navy)
                    Text("Try our Smart Route Planner")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Coastal.muted)
                }
                Spacer(minLength: 8)
                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Coastal.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle().fill(
                            LinearGradient(
                                colors: [Coastal.soft, Coastal.deep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    )
            }
            .padding(16)
            .background { frostedCard(radius: 22) }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            }
            .shadow(color: Coastal.navy.opacity(0.08), radius: 12, y: 6)
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityLabel("Not sure where to go? Try our Smart Route Planner")
        .accessibilityHint("Plans a route from Current Location to Marina Beach")
    }
}

private struct SavedCardScrollEffect: ViewModifier {
    var enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.scrollTransition(.interactive, axis: .horizontal) { view, phase in
                view
                    .opacity(phase.isIdentity ? 1 : 0.82)
                    .scaleEffect(phase.isIdentity ? 1 : 0.96)
            }
        } else {
            content
        }
    }
}

private struct LiveTripButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

@ViewBuilder
private func frostedCard(radius: CGFloat) -> some View {
    let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
    ZStack {
        if #available(iOS 26, *) {
            shape.fill(Color.clear)
                .glassEffect(.regular.tint(Color.white.opacity(0.55)), in: shape)
        } else {
            shape.fill(.ultraThinMaterial)
            shape.fill(Coastal.white.opacity(0.78))
        }
    }
}

#Preview {
    TripsView()
        .environment(AppRouter())
}
