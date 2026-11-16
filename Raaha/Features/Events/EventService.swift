import Foundation

protocol EventInventoryProviding {
    func events(at date: Date) -> [EventModel]
}

/// Development samples. Titles, organisers, and schedules are placeholders.
/// Venues and photographs come from places Explore already has. None of these
/// are real concerts, tickets, or paid campaigns.
struct DevelopmentSampleEventInventory: EventInventoryProviding {
    func events(at date: Date) -> [EventModel] {
        SampleEventCatalog.make(relativeTo: date).filter { $0.isListed(at: date) }
    }
}

/// Production inventory. Empty until a verified feed or an approved campaign is supplied.
struct ApprovedEventInventory: EventInventoryProviding {
    var approved: [EventModel] = []

    func events(at date: Date) -> [EventModel] {
        approved.filter { !$0.isSample && $0.isListed(at: date) }
    }
}

@MainActor
struct EventService {
    var inventory: EventInventoryProviding
    var tracker: AdImpressionTracker

    static var current: EventService {
        #if DEBUG
        EventService(inventory: DevelopmentSampleEventInventory(), tracker: .shared)
        #else
        EventService(inventory: ApprovedEventInventory(), tracker: .shared)
        #endif
    }

    func visible(at date: Date = Date()) -> [EventModel] {
        inventory.events(at: date).filter { event in
            guard event.isListed(at: date) else { return false }
            guard event.isSponsored else { return true }
            guard tracker.sponsoredDiscoveryEnabled,
                  let campaignID = event.campaignID
            else { return false }
            return tracker.canDisplay(campaignID: campaignID)
        }
    }

    func matching(_ category: EventCategory, at date: Date = Date()) -> [EventModel] {
        visible(at: date)
            .filter { category.includes($0.category) }
            .sorted { $0.startDate < $1.startDate }
    }

    func comingUp(_ filter: EventTimeFilter, category: EventCategory, at date: Date = Date()) -> [EventModel] {
        matching(category, at: date).filter {
            EventSchedule.matches($0, filter: filter, now: date)
        }
    }
}

@MainActor
enum EventNavigationManager {
    /// Samples never open a ticket page. A link is used only when a verified URL exists.
    static func ticketURL(for event: EventModel) -> URL? {
        guard !event.isSample else { return nil }
        return event.ticketURL
    }

    static func planJourney(
        to event: EventModel,
        placementID: String,
        router: AppRouter,
        tracker: AdImpressionTracker
    ) {
        recordClick(event, tracker: tracker, placementID: placementID)
        let origin = router.journeyFrom.trimmingCharacters(in: .whitespacesAndNewlines)
        router.planJourney(
            from: origin.isEmpty ? "Current Location" : origin,
            to: event.venue.name
        )
    }

    static func recordClick(
        _ event: EventModel,
        tracker: AdImpressionTracker,
        placementID: String
    ) {
        guard event.isSponsored,
              let campaignID = event.campaignID,
              let advertiserID = event.advertiserID
        else { return }
        tracker.recordClick(
            campaignID: campaignID,
            advertiserID: advertiserID,
            placementID: placementID
        )
    }
}

private enum SampleEventCatalog {
    static let summary = "Development sample. Not a real event."
    static let detail = "Development sample. This is not a real event, organiser, ticket, or paid campaign. The place and photograph already exist in Explore so Plan Journey can open a route."

    static func make(relativeTo now: Date, calendar: Calendar = .current) -> [EventModel] {
        let today = calendar.startOfDay(for: now)
        let weekend = EventSchedule.weekendInterval(containing: now, calendar: calendar)
        let saturday = weekend.start
        let sunday = calendar.date(byAdding: .day, value: 1, to: saturday) ?? saturday

        return [
            sample(
                id: "sample.event.concert",
                title: "Sample concert",
                category: .concerts,
                placeID: "chennai_marina_beach",
                start: clock(today, hour: 19, calendar: calendar),
                hours: 3
            ),
            sample(
                id: "sample.event.fair",
                title: "Sample cultural fair",
                category: .fairs,
                placeID: "chennai_valluvar_kottam",
                start: clock(saturday, hour: 11, calendar: calendar),
                hours: 6
            ),
            sample(
                id: "sample.event.food",
                title: "Sample food festival",
                category: .food,
                placeID: "chennai_phoenix_marketcity",
                start: clock(sunday, hour: 12, calendar: calendar),
                hours: 6
            ),
            sample(
                id: "sample.event.exhibition",
                title: "Sample exhibition",
                category: .exhibitions,
                placeID: "chennai_egmore_museum",
                start: clock(today, hour: 10, dayOffset: 10, calendar: calendar),
                hours: 8
            ),
            sample(
                id: "sample.event.workshop",
                title: "Sample workshop",
                category: .workshops,
                placeID: "chennai_semmozhi_poonga",
                start: clock(today, hour: 15, dayOffset: 12, calendar: calendar),
                hours: 2
            ),
            sample(
                id: "sample.event.comedy",
                title: "Sample comedy show",
                category: .comedy,
                placeID: "chennai_writers_cafe",
                start: clock(today, hour: 20, dayOffset: 16, calendar: calendar),
                hours: 2
            ),
            sample(
                id: "sample.event.theatre",
                title: "Sample theatre performance",
                category: .comedy,
                placeID: "chennai_kapaleeshwarar",
                start: clock(today, hour: 18, dayOffset: 18, calendar: calendar),
                hours: 3
            ),
            sample(
                id: "sample.event.expired",
                title: "Sample expired listing",
                category: .concerts,
                placeID: "chennai_marina_beach",
                start: clock(today, hour: 18, dayOffset: -2, calendar: calendar),
                hours: 2
            ),
            sample(
                id: "sample.event.cancelled",
                title: "Sample cancelled listing",
                category: .fairs,
                placeID: "chennai_guindy_park",
                start: clock(today, hour: 16, dayOffset: 3, calendar: calendar),
                hours: 3,
                isCancelled: true
            )
        ].compactMap { $0 }
    }

    private static func sample(
        id: String,
        title: String,
        category: EventCategory,
        placeID: String,
        start: Date,
        hours: Int,
        isCancelled: Bool = false,
        calendar: Calendar = .current
    ) -> EventModel? {
        guard let place = ExploreMockData.allPlaces.first(where: { $0.id == placeID }) else { return nil }
        let end = calendar.date(byAdding: .hour, value: hours, to: start) ?? start
        return EventModel(
            id: id,
            title: title,
            summary: summary,
            detail: detail,
            category: category,
            imageAssetName: place.localAssetImageName,
            imageURL: nil,
            startDate: start,
            endDate: end,
            venue: EventVenue(
                name: place.name,
                address: place.address,
                locality: place.locality,
                latitude: place.coordinate.latitude,
                longitude: place.coordinate.longitude,
                imageAssetName: place.localAssetImageName
            ),
            ticketPriceText: nil,
            ticketURL: nil,
            organiser: "Sample organiser",
            isSponsored: true,
            campaignID: id,
            advertiserID: "sample.local",
            placementID: "explore.events",
            isSample: true,
            isCancelled: isCancelled,
            isActive: true
        )
    }

    private static func clock(
        _ day: Date,
        hour: Int,
        dayOffset: Int = 0,
        calendar: Calendar
    ) -> Date {
        let shifted = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: day)) ?? day
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: shifted) ?? shifted
    }
}
