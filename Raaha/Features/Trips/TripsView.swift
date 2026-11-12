import SwiftUI

// MARK: - TripsView

/// Premium, interactive Trips screen featuring a clear hierarchy for Upcoming, Saved, and Recent journeys.
struct TripsView: View {
    @Environment(AppRouter.self) private var router

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

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Filter Chips Bar
                    filterBar

                    // 1. Upcoming & Planned Trips
                    if activeFilter == .all || activeFilter == .upcoming {
                        upcomingSection
                    }

                    // 2. Saved Journeys
                    if activeFilter == .all || activeFilter == .saved {
                        savedSection
                    }

                    // 3. Recent Trips
                    if activeFilter == .all || activeFilter == .recent {
                        recentSection
                    }

                    // Smart Planner Suggestion
                    SmartRouteBanner {
                        router.planJourney(from: "Current Location", to: "Marina Beach")
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
        }
        .raahaScreenBackground()
        .navyHeaderChrome()
    }

    // MARK: - Header

    private var header: some View {
        NavyHeader {
            VStack(alignment: .leading, spacing: 8) {
                Text("Trips")
                    .font(.raahaTitle)
                    .foregroundStyle(Color.white)
                    .accessibilityAddTraits(.isHeader)

                Text("Your upcoming journeys, bookmarked routes, and travel history across Chennai.")
                    .font(.raahaSubheadline)
                    .foregroundStyle(Color(hex: 0xBDD8E9))

                quickCommuteCard
                    .padding(.top, 4)
            }
        }
    }

    private var quickCommuteCard: some View {
        Button {
            router.planJourney(from: "Chennai Central", to: "T. Nagar")
        } label: {
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
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    Image(systemName: "house.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Home → Work")
                        .font(.raahaHeadline)
                        .foregroundStyle(Color.midnightBlue)
                    Text("Chennai Central → T. Nagar")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.royalBlue)
                    Text("via Metro + Walk · 22 min")
                        .font(.raahaCaption2)
                        .foregroundStyle(Color.royalBlue.opacity(0.85))
                }

                Spacer(minLength: 4)

                VStack(alignment: .trailing, spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                        Text("Fastest")
                    }
                    .font(.raahaCaption2)
                    .foregroundStyle(Color.midnightBlue)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3.5)
                    .background(Capsule().fill(Color.neonLime))
                    .shadow(color: Color.neonLime.opacity(0.3), radius: 6, x: 0, y: 2)

                    Image(systemName: "chevron.right")
                        .font(.raahaFootnoteSemibold)
                        .foregroundStyle(Color.royalBlue)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.80))
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color(hex: 0x7BBDE8).opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.midnightBlue.opacity(0.18), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityLabel("Fastest route: Home to Work via Metro and Walk.")
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(TripFilter.allCases) { filter in
                let isSelected = activeFilter == filter
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                        activeFilter = filter
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(.raahaFootnoteSemibold)
                        .foregroundStyle(isSelected ? Color.white : Color.royalBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    isSelected
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color.brightBlue, Color.electricBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    : AnyShapeStyle(Color.white.opacity(0.65))
                                )
                                .background(
                                    .regularMaterial,
                                    in: Capsule()
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.8),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isSelected ? Color.electricBlue.opacity(0.45) : Color.clear,
                            radius: 8, x: 0, y: 3
                        )
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: activeFilter)
            }
            Spacer()
        }
    }

    // MARK: - 1. Upcoming & Planned Trips

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Upcoming & Planned", action: nil)

            if upcomingTrips.isEmpty {
                emptyPlaceholder(text: "No upcoming journeys scheduled.")
            } else {
                ForEach(upcomingTrips) { trip in
                    UpcomingTripCard(trip: trip) {
                        router.planJourney(from: trip.origin, to: trip.destination)
                    }
                }
            }
        }
    }

    // MARK: - 2. Saved Journeys

    private var savedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Saved Journeys", action: nil)

            let bookmarkedList = savedJourneys.filter { $0.isBookmarked }
            if bookmarkedList.isEmpty {
                emptyPlaceholder(text: "No saved journeys bookmarked.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(bookmarkedList) { journey in
                            SavedJourneyCard(journey: journey) {
                                router.planJourney(from: "Current Location", to: journey.name)
                            } onToggleBookmark: {
                                toggleBookmark(for: journey)
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func toggleBookmark(for journey: SavedJourney) {
        if let idx = savedJourneys.firstIndex(where: { $0.id == journey.id }) {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                let cur = savedJourneys[idx].isBookmarked
                savedJourneys[idx] = SavedJourney(
                    name: journey.name,
                    route: journey.route,
                    imageName: journey.imageName,
                    isBookmarked: !cur
                )
            }
        }
    }

    // MARK: - 3. Recent Trips

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Recent Trips", action: nil)

            VStack(spacing: 8) {
                ForEach(MockData.recentTrips) { trip in
                    RecentTripRow(trip: trip) {
                        let parts = trip.route.components(separatedBy: " → ")
                        let from = parts.first ?? "Current Location"
                        let to   = parts.last  ?? trip.route
                        router.planJourney(from: from, to: to)
                    }
                }
            }
        }
    }

    private func emptyPlaceholder(text: String) -> some View {
        HStack {
            Image(systemName: "tray")
                .foregroundStyle(Color.lightSkyBlue)
            Text(text)
                .font(.raahaFootnote)
                .foregroundStyle(Color.lightSkyBlue)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Upcoming Trip Card

private struct UpcomingTripCard: View {
    let trip: PlannedTrip
    let onPlan: () -> Void

    var body: some View {
        Button(action: onPlan) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(trip.countdownText)
                                .font(.raahaCaption2)
                                .foregroundStyle(Color.midnightBlue)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 3.5)
                                .background(Capsule().fill(Color.neonLime))
                                .shadow(color: Color.neonLime.opacity(0.35), radius: 6, x: 0, y: 2)

                            Text(trip.scheduledDate)
                                .font(.raahaCaption)
                                .foregroundStyle(Color.lightSkyBlue)
                        }

                        Text(trip.title)
                            .font(.raahaHeadline)
                            .foregroundStyle(Color.midnightBlue)
                    }

                    Spacer()

                    ModeBadge(mode: trip.primaryMode, size: 38, fill: Color.white.opacity(0.55), tint: Color.royalBlue)
                }

                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.brightBlue)

                    Text("\(trip.origin) → \(trip.destination)")
                        .font(.raahaFootnote)
                        .foregroundStyle(Color.midnightBlue.opacity(0.85))
                        .lineLimit(1)

                    Spacer()

                    Text("\(trip.estimatedDuration) · \(trip.estimatedFare)")
                        .font(.raahaFootnoteSemibold)
                        .foregroundStyle(Color.royalBlue)
                }

                HStack {
                    Spacer()
                    Button("Start Live Trip", action: onPlan)
                        .font(.raahaFootnoteSemibold)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.brightBlue, Color.electricBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .shadow(color: Color.electricBlue.opacity(0.4), radius: 8, x: 0, y: 3)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.65))
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color(hex: 0x7BBDE8).opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color(hex: 0x49769F).opacity(0.18), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(TactileButtonStyle())
    }
}

// MARK: - Saved Journey Card

private struct SavedJourneyCard: View {
    let journey: SavedJourney
    let action: () -> Void
    let onToggleBookmark: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Image(journey.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 170, height: 100)
                        .clipped()

                    Button {
                        onToggleBookmark()
                    } label: {
                        Image(systemName: journey.isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(journey.isBookmarked ? Color.neonLime : Color.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.midnightBlue.opacity(0.75))
                                    .background(.ultraThinMaterial, in: Circle())
                            )
                            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                            .shadow(radius: 4)
                    }
                    .padding(8)
                    .sensoryFeedback(.impact(weight: .light), trigger: journey.isBookmarked)
                    .accessibilityLabel(journey.isBookmarked ? "Remove bookmark" : "Add bookmark")
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(journey.name)
                        .font(.raahaSubheadlineMedium)
                        .foregroundStyle(Color.midnightBlue)
                        .lineLimit(1)

                    Text(journey.route)
                        .font(.raahaCaption2)
                        .foregroundStyle(Color.royalBlue.opacity(0.85))
                        .lineLimit(1)

                    HStack {
                        Label("Route", systemImage: "arrow.right.circle.fill")
                            .font(.raahaCaption2)
                            .foregroundStyle(Color.royalBlue)
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .padding(12)
            }
            .frame(width: 170)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.65))
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color(hex: 0x7BBDE8).opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color(hex: 0x49769F).opacity(0.15), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(TactileButtonStyle())
    }
}

// MARK: - Recent Trip Row

private struct RecentTripRow: View {
    let trip: RecentTrip
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Color(hex: 0x7BBDE8).opacity(0.4), lineWidth: 1))

                    if let asset = trip.customAsset {
                        Image(asset)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.royalBlue)
                    } else {
                        Image(systemName: trip.symbol)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.royalBlue)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(trip.route)
                        .font(.raahaSubheadlineMedium)
                        .foregroundStyle(Color.midnightBlue)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(trip.mode)
                            .font(.raahaCaption)
                            .foregroundStyle(Color.royalBlue.opacity(0.85))
                        Text("·")
                            .foregroundStyle(Color.royalBlue.opacity(0.5))
                        Text("\(trip.day), \(trip.time)")
                            .font(.raahaCaption2)
                            .foregroundStyle(Color.royalBlue.opacity(0.85))
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("Repeat")
                        .font(.raahaCaption)
                        .foregroundStyle(Color.midnightBlue)
                    Image(systemName: "arrow.clockwise")
                        .font(.raahaCaption2)
                        .foregroundStyle(Color.brightBlue)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.60))
                        .background(.regularMaterial, in: Capsule())
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.65))
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color(hex: 0x7BBDE8).opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color(hex: 0x49769F).opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(TactileButtonStyle())
        .accessibilityLabel("Trip: \(trip.route) via \(trip.mode) on \(trip.day). Tap to repeat.")
    }
}
