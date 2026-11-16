import SwiftUI

struct EventDiscoverySection: View {
    @Binding var selectedEvent: EventModel?

    @Environment(AppRouter.self) private var router
    @Environment(AdImpressionTracker.self) private var tracker
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var category: EventCategory = .all
    @State private var timeFilter: EventTimeFilter = .today
    @State private var appeared = false

    private var service: EventService { .current }

    var body: some View {
        let events = service.visible()
        if !events.isEmpty {
            let matching = service.matching(category)
            VStack(alignment: .leading, spacing: 16) {
                header
                categoryFilters
                if matching.isEmpty {
                    Text("No events in this category.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(EventInk.muted)
                } else {
                    if let featured = matching.first {
                        FeaturedEventCard(
                            event: featured,
                            reduceMotion: reduceMotion,
                            onOpen: { open(featured, placementID: "explore.events.featured") }
                        )
                        .modifier(EventImpressionMarker(event: featured, placementID: "explore.events.featured"))
                    }

                    let more = Array(matching.dropFirst())
                    if !more.isEmpty {
                        moreEvents(more)
                    }

                    comingUp
                }
            }
            .opacity(appeared || reduceMotion ? 1 : 0)
            .offset(y: appeared || reduceMotion ? 0 : 14)
            .onAppear {
                guard !appeared else { return }
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                        appeared = true
                    }
                }
            }
            .animation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.84), value: category)
            .animation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.84), value: timeFilter)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Discover More")
                .font(.raahaHeadline)
                .foregroundStyle(EventInk.navy)
            Text("Find exciting events and experiences around Chennai.")
                .font(.raahaCaption)
                .foregroundStyle(EventInk.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EventCategory.allCases) { item in
                    let selected = category == item
                    Button {
                        withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.82)) {
                            category = item
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: item.symbol)
                                .font(.system(size: 12, weight: .semibold))
                            Text(item.title)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                        }
                        .foregroundStyle(selected ? EventInk.white : EventInk.deep)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(selected ? EventInk.deep : EventInk.ice))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func moreEvents(_ events: [EventModel]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("More Events Around You")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(EventInk.navy)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 14) {
                    ForEach(events) { event in
                        EventCarouselCard(event: event, reduceMotion: reduceMotion) {
                            open(event, placementID: "explore.events.carousel")
                        }
                        .containerRelativeFrame(.horizontal) { width, _ in width * 0.78 }
                        .modifier(EventImpressionMarker(event: event, placementID: "explore.events.carousel"))
                        .modifier(EventScrollEffect(enabled: !reduceMotion))
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 4)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }

    private var comingUp: some View {
        let rows = service.comingUp(timeFilter, category: category)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Coming Up")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(EventInk.navy)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(EventTimeFilter.allCases) { filter in
                        let selected = timeFilter == filter
                        Button {
                            withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.82)) {
                                timeFilter = filter
                            }
                        } label: {
                            Text(filter.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(selected ? EventInk.white : EventInk.deep)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Capsule().fill(selected ? EventInk.soft : EventInk.ice))
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                }
            }

            if rows.isEmpty {
                Text("No events in this range.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(EventInk.muted)
            } else {
                VStack(spacing: 10) {
                    ForEach(rows) { event in
                        ComingUpRow(event: event, reduceMotion: reduceMotion) {
                            open(event, placementID: "explore.events.coming")
                        }
                        .modifier(EventImpressionMarker(event: event, placementID: "explore.events.coming"))
                    }
                }
            }
        }
    }

    private func open(_ event: EventModel, placementID: String) {
        EventNavigationManager.recordClick(event, tracker: tracker, placementID: placementID)
        selectedEvent = event
    }
}

// MARK: - Featured

private struct FeaturedEventCard: View {
    let event: EventModel
    let reduceMotion: Bool
    let onOpen: () -> Void
    @Environment(\.eventCardPressed) private var pressed

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    EventPhoto(event: event, height: 188, pressed: pressed, reduceMotion: reduceMotion)
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.42)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)
                    Text(event.category.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(EventInk.deep.opacity(0.9)))
                        .padding(14)
                }
                .frame(height: 188)
                .clipped()

                VStack(alignment: .leading, spacing: 14) {
                    Text(event.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(EventInk.navy)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 10) {
                        featuredFact(symbol: "calendar", title: "Date and time", value: event.scheduleText)
                        featuredFact(symbol: "icon_pin", title: "Venue", value: event.venue.name, usesAsset: true)
                        featuredFact(
                            symbol: "location",
                            title: "Address",
                            value: "\(event.venue.address), \(event.venue.locality)"
                        )
                    }

                    HStack(spacing: 6) {
                        Text("Discover Event")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(EventInk.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(EventInk.deep))
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(EventCardButtonStyle())
        .background(EventInk.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(EventInk.ice, lineWidth: 1)
        )
        .shadow(color: EventInk.navy.opacity(0.08), radius: 12, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.title), \(event.scheduleText), \(event.venue.name), \(event.venue.address)")
        .accessibilityHint("Opens the event")
    }

    private func featuredFact(symbol: String, title: String, value: String, usesAsset: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Group {
                if usesAsset {
                    IconPin(size: 16)
                } else {
                    Image(systemName: symbol)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
                .foregroundStyle(EventInk.deep)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(EventInk.muted)
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(EventInk.navy)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Carousel

private struct EventCarouselCard: View {
    let event: EventModel
    let reduceMotion: Bool
    let onOpen: () -> Void
    @Environment(\.eventCardPressed) private var pressed

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    EventPhoto(event: event, height: 124, pressed: pressed, reduceMotion: reduceMotion)
                    EventStatusChips(event: event, showsFeatured: false)
                        .padding(8)
                }
                .frame(height: 124)
                .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(EventInk.navy)
                        .lineLimit(2)
                        .frame(minHeight: 38, alignment: .topLeading)
                    Text(event.category.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(EventInk.deep)
                    Text(event.scheduleText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(EventInk.muted)
                        .lineLimit(2)
                    Text(event.venue.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(EventInk.muted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("View Event")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(EventInk.deep)
                        .padding(.top, 2)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(EventCardButtonStyle())
        .background(EventInk.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: EventInk.navy.opacity(0.08), radius: 10, y: 5)
        .accessibilityLabel("\(event.title), \(event.scheduleText), \(event.venue.name)")
    }
}

// MARK: - Coming up

private struct ComingUpRow: View {
    let event: EventModel
    let reduceMotion: Bool
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(alignment: .top, spacing: 12) {
                EventPhoto(event: event, height: 72, pressed: false, reduceMotion: reduceMotion)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(event.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(EventInk.navy)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(event.scheduleText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(EventInk.muted)
                        .lineLimit(2)
                    Text(event.venue.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(EventInk.deep)
                        .lineLimit(1)
                    EventStatusChips(event: event, showsFeatured: false)
                        .padding(.top, 2)
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .background(EventInk.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
            )
        }
        .buttonStyle(EventCardButtonStyle())
        .accessibilityLabel("\(event.title), \(event.scheduleText), \(event.venue.name)")
    }
}

// MARK: - Shared pieces

struct EventPhoto: View {
    let event: EventModel
    let height: CGFloat
    var pressed: Bool
    var reduceMotion: Bool

    var body: some View {
        ZStack {
            if let assetName = event.imageAssetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [EventInk.soft, EventInk.deep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: event.category.symbol)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .scaleEffect(!reduceMotion && pressed ? 1.04 : 1)
        .clipped()
    }
}

struct EventStatusChips: View {
    let event: EventModel
    var showsFeatured: Bool

    var body: some View {
        HStack(spacing: 4) {
            if event.isSample {
                chip("SAMPLE", foreground: EventInk.deep, fill: EventInk.ice)
            }
            if event.isSponsored {
                chip("SPONSORED", foreground: EventInk.navy, fill: Color.white.opacity(0.94))
            }
            if showsFeatured {
                chip("FEATURED", foreground: Color.white, fill: EventInk.deep.opacity(0.88))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(event.isSample ? "Sample sponsored event" : "Sponsored")
    }

    private func chip(_ title: String, foreground: Color, fill: Color) -> some View {
        Text(title)
            .font(.system(size: 9, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(foreground)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(fill, in: Capsule())
    }
}

private struct EventPlacementSheet: View {
    let event: EventModel
    @Environment(AdImpressionTracker.self) private var tracker
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About this placement")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(EventInk.navy)
            Text(event.isSample
                 ? "This is a development sample. It is not a real event and it is not a paid campaign."
                 : "This event is a sponsored placement.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(EventInk.navy)
                .fixedSize(horizontal: false, vertical: true)

            if let campaignID = event.campaignID {
                VStack(spacing: 8) {
                    sheetButton("Hide this placement") {
                        tracker.hide(campaignID: campaignID)
                        dismiss()
                    }
                    sheetButton("Report this placement") {
                        tracker.report(
                            campaignID: campaignID,
                            placementID: event.placementID,
                            note: "Reported from Explore events"
                        )
                        dismiss()
                    }
                    sheetButton("Turn off sponsored discovery") {
                        tracker.sponsoredDiscoveryEnabled = false
                        dismiss()
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EventInk.white)
    }

    private func sheetButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(EventInk.navy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(EventInk.ice, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct EventImpressionMarker: ViewModifier {
    let event: EventModel
    let placementID: String
    @Environment(AdImpressionTracker.self) private var tracker

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *),
           event.isSponsored,
           let campaignID = event.campaignID,
           let advertiserID = event.advertiserID {
            content.onScrollVisibilityChange(threshold: 0.6) { visible in
                guard visible else { return }
                tracker.recordImpression(
                    campaignID: campaignID,
                    advertiserID: advertiserID,
                    placementID: placementID
                )
            }
        } else {
            content
        }
    }
}

private struct EventScrollEffect: ViewModifier {
    var enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.scrollTransition(.interactive, axis: .horizontal) { view, phase in
                view
                    .opacity(phase.isIdentity ? 1 : 0.9)
                    .scaleEffect(phase.isIdentity ? 1 : 0.98)
            }
        } else {
            content
        }
    }
}

private struct EventCardButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .environment(\.eventCardPressed, configuration.isPressed)
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.98 : 1)
            .animation(
                reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.74),
                value: configuration.isPressed
            )
    }
}

private struct EventCardPressedKey: EnvironmentKey {
    static let defaultValue = false
}

private extension EnvironmentValues {
    var eventCardPressed: Bool {
        get { self[EventCardPressedKey.self] }
        set { self[EventCardPressedKey.self] = newValue }
    }
}

enum EventInk {
    static let ice = Color(hex: 0xDCEFF5)
    static let soft = Color(hex: 0x75BBD0)
    static let deep = Color(hex: 0x176487)
    static let navy = Color(hex: 0x173D5C)
    static let muted = Color(hex: 0x326F89)
    static let white = Color(hex: 0xF5FAFC)
}
