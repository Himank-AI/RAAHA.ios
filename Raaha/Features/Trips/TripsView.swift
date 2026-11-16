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
                    FeaturedJourneyCard(
                        journey: MockData.frequentJourney,
                        appeared: entered,
                        reduceMotion: reduceMotion
                    ) {
                        let commute = MockData.frequentJourney
                        router.planJourney(from: commute.origin, to: commute.destination)
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

                    SmartRoutePlannerCard()
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .animation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.86), value: activeFilter)
            }
            .contentMargins(.bottom, 24, for: .scrollContent)
        }
        .raahaScreenBackground()
        .navyHeaderChrome()
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
                UpcomingTripsCarousel(
                    trips: upcomingTrips,
                    revealed: entered,
                    reduceMotion: reduceMotion
                ) { trip in
                    router.planJourney(from: trip.origin, to: trip.destination)
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
        NavyHeader {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trips")
                        .font(.raahaTitle)
                        .foregroundStyle(Color.white)
                        .accessibilityAddTraits(.isHeader)

                    Text("Your upcoming journeys, bookmarked routes, and travel history across Chennai.")
                        .font(.raahaCaption)
                        .foregroundStyle(Color(hex: 0xBDD8E9))
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 8) {
                    summaryPill(count: upcomingCount, label: "Upcoming")
                    summaryPill(count: savedCount, label: "Saved")
                }
            }
        }
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
    let journey: FrequentJourney
    var appeared: Bool
    var reduceMotion: Bool
    let action: () -> Void

    @State private var tapPulse = 0
    @State private var sheen = false

    var body: some View {
        Button {
            tapPulse += 1
            action()
        } label: {
            FeaturedJourneySurface(journey: journey, sheen: sheen, reduceMotion: reduceMotion)
        }
        .buttonStyle(FeaturedCardButtonStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: tapPulse)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared || reduceMotion ? 1 : 0.98)
        .offset(y: appeared || reduceMotion ? 0 : 14)
        .animation(reduceMotion ? nil : .spring(response: 0.52, dampingFraction: 0.84), value: appeared)
        .onAppear {
            guard appeared, !reduceMotion, !sheen else { return }
            withAnimation(.easeOut(duration: 0.85).delay(0.15)) {
                sheen = true
            }
        }
        .onChange(of: appeared) { _, isVisible in
            guard isVisible, !reduceMotion else { return }
            withAnimation(.easeOut(duration: 0.85).delay(0.15)) {
                sheen = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(journey.homeName), \(journey.origin), to \(journey.workName), \(journey.destination). \(journey.modeSummary). \(journey.durationText). \(journey.badge). View route.")
        .accessibilityAddTraits(.isButton)
    }
}

private struct FeaturedJourneySurface: View {
    let journey: FrequentJourney
    var sheen: Bool
    var reduceMotion: Bool
    @Environment(\.featuredCardPressed) private var pressed

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text("FREQUENT JOURNEY")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.15)
                    .foregroundStyle(Coastal.deep)
                Spacer(minLength: 8)
                JourneyStatusBadge(text: journey.badge)
            }

            HStack(alignment: .center, spacing: 8) {
                locationColumn(
                    symbol: "house.fill",
                    role: journey.homeName,
                    place: journey.origin,
                    alignment: .leading
                )
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Coastal.soft)
                    .accessibilityHidden(true)
                locationColumn(
                    symbol: "briefcase.fill",
                    role: journey.workName,
                    place: journey.destination,
                    alignment: .trailing
                )
            }

            ViewThatFits(in: .horizontal) {
                detailRow(showsTitle: true)
                detailRow(showsTitle: false)
            }
        }
        .padding(14)
        .background { featuredFill }
        .overlay { featuredHighlight }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.85), lineWidth: 1)
        }
        .shadow(
            color: Coastal.deep.opacity(pressed ? 0.18 : 0.12),
            radius: pressed ? 16 : 12,
            y: pressed ? 10 : 6
        )
    }

    private func detailRow(showsTitle: Bool) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: -6) {
                ForEach(Array(journey.modes.enumerated()), id: \.offset) { _, mode in
                    ModeBadge(mode: mode, size: 28)
                }
            }
            Text(journey.modeSummary)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Coastal.deep)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Spacer(minLength: 6)
            Text(journey.durationText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Coastal.navy)
            viewRouteArrow(showsTitle: showsTitle)
        }
    }

    private func locationColumn(
        symbol: String,
        role: String,
        place: String,
        alignment: HorizontalAlignment
    ) -> some View {
        HStack(spacing: 8) {
            if alignment == .trailing {
                placeText(role: role, place: place, alignment: .trailing)
                locationIcon(symbol)
            } else {
                locationIcon(symbol)
                placeText(role: role, place: place, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment == .trailing ? .trailing : .leading)
    }

    private func locationIcon(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Coastal.deep)
            .frame(width: 28, height: 28)
            .background(Circle().fill(Color.white.opacity(0.78)))
            .accessibilityHidden(true)
    }

    private func placeText(role: String, place: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 1) {
            Text(role)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Coastal.muted)
            Text(place)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Coastal.navy)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func viewRouteArrow(showsTitle: Bool) -> some View {
        HStack(spacing: 4) {
            if showsTitle {
                Text("View Route")
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
            }
            Image(systemName: "arrow.right")
                .font(.system(size: 11, weight: .bold))
                .offset(x: pressed && !reduceMotion ? 4 : 0)
                .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.7), value: pressed)
        }
        .foregroundStyle(Coastal.deep)
        .padding(.horizontal, showsTitle ? 10 : 8)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.opacity(0.72)))
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var featuredFill: some View {
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)
        ZStack {
            shape.fill(
                LinearGradient(
                    colors: [Coastal.white, Coastal.ice, Coastal.soft.opacity(0.38)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            if #available(iOS 26, *) {
                shape.fill(Color.clear)
                    .glassEffect(.regular.tint(Color.white.opacity(0.42)), in: shape)
            } else {
                shape.fill(.ultraThinMaterial)
            }
        }
    }

    private var featuredHighlight: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [Color.clear, Color.white.opacity(0.7), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 0.42)
            .offset(x: sheen ? geo.size.width : -geo.size.width * 0.5)
            .frame(maxHeight: .infinity, alignment: .top)
            .mask(
                LinearGradient(
                    colors: [Color.white, Color.white.opacity(0.15), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct FeaturedCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .offset(y: configuration.isPressed ? -3 : 0)
            .animation(.spring(response: 0.32, dampingFraction: 0.74), value: configuration.isPressed)
            .environment(\.featuredCardPressed, configuration.isPressed)
    }
}

private struct FeaturedPressKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    fileprivate var featuredCardPressed: Bool {
        get { self[FeaturedPressKey.self] }
        set { self[FeaturedPressKey.self] = newValue }
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

private struct UpcomingTripsCarousel: View {
    let trips: [PlannedTrip]
    var revealed: Bool
    var reduceMotion: Bool
    let onPlan: (PlannedTrip) -> Void

    @State private var selection: PlannedTrip.ID?

    private var activeID: PlannedTrip.ID? {
        selection ?? trips.first?.id
    }

    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 15) {
                    ForEach(Array(trips.enumerated()), id: \.element.id) { index, trip in
                        UpcomingJourneyCard(
                            trip: trip,
                            index: index,
                            revealed: revealed,
                            reduceMotion: reduceMotion,
                            isSelected: activeID == trip.id
                        ) {
                            onPlan(trip)
                        }
                        .containerRelativeFrame(.horizontal) { width, _ in
                            width * 0.84
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 6)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selection)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()

            if trips.count > 1 {
                HStack(spacing: 6) {
                    ForEach(trips) { trip in
                        let active = trip.id == activeID
                        Capsule()
                            .fill(active ? Coastal.deep : Coastal.soft.opacity(0.55))
                            .frame(width: active ? 16 : 6, height: 6)
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.82), value: activeID)
                .accessibilityHidden(true)
            }
        }
        .onAppear {
            if selection == nil {
                selection = trips.first?.id
            }
        }
    }
}

struct UpcomingJourneyCard: View {
    let trip: PlannedTrip
    var index: Int
    var revealed: Bool
    var reduceMotion: Bool
    var isSelected: Bool = false
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
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("\(trip.origin) → \(trip.destination)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Coastal.muted)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, minHeight: 36, alignment: .topLeading)
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
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
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
        .scaleEffect(reduceMotion || isSelected ? 1 : 0.975)
        .animation(
            reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.84).delay(Double(index) * 0.06),
            value: revealed
        )
        .animation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.78), value: isSelected)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(trip.title), \(trip.origin) to \(trip.destination), \(trip.scheduledDate)")
    }
}

// MARK: - Saved card

struct SavedJourneyCard: View {
    let journey: SavedJourney
    let action: () -> Void
    let onToggleBookmark: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.savedCardPressed) private var pressed
    @State private var appeared = false

    private let cardWidth: CGFloat = 228
    private let photoHeight: CGFloat = 152

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Image(journey.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: photoHeight)
                        .scaleEffect(pressed && !reduceMotion ? 1.05 : 1)
                        .frame(width: cardWidth, height: photoHeight)
                        .clipped()
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 22,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 22,
                                style: .continuous
                            )
                        )

                    Button(action: onToggleBookmark) {
                        Image(systemName: journey.isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Coastal.deep)
                            .contentTransition(.symbolEffect(.replace))
                            .symbolEffect(.bounce, value: journey.isBookmarked)
                            .frame(width: 32, height: 32)
                            .background {
                                Circle().fill(.ultraThinMaterial)
                                Circle().fill(Color.white.opacity(0.78))
                            }
                            .overlay(Circle().stroke(Color.white.opacity(0.92), lineWidth: 0.8))
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                    .sensoryFeedback(.impact(weight: .light), trigger: journey.isBookmarked)
                    .accessibilityLabel(journey.isBookmarked ? "Remove bookmark" : "Save journey")
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(journey.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Coastal.navy)
                        .lineLimit(1)
                    Text(journey.route)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Coastal.muted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 14)
                .frame(width: cardWidth, alignment: .leading)
            }
            .frame(width: cardWidth)
            .background(Coastal.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white, lineWidth: 1)
            }
            .shadow(color: Coastal.navy.opacity(0.12), radius: 12, y: 6)
        }
        .buttonStyle(SavedCardButtonStyle())
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared || reduceMotion ? 1 : 0.96)
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(.spring(response: 0.48, dampingFraction: 0.84)) {
                    appeared = true
                }
            }
        }
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

private struct SavedCardPressedKey: EnvironmentKey {
    static let defaultValue = false
}

private extension EnvironmentValues {
    var savedCardPressed: Bool {
        get { self[SavedCardPressedKey.self] }
        set { self[SavedCardPressedKey.self] = newValue }
    }
}

private struct SavedCardButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .environment(\.savedCardPressed, configuration.isPressed)
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.97 : 1)
            .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.72), value: configuration.isPressed)
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
        .environment(AdImpressionTracker.shared)
}
