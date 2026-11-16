import Foundation

/// Filters shown above the events inventory.
enum EventCategory: String, CaseIterable, Identifiable, Hashable {
    case all
    case concerts
    case fairs
    case food
    case exhibitions
    case workshops
    case comedy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All Events"
        case .concerts: return "Concerts"
        case .fairs: return "Fairs & Festivals"
        case .food: return "Food Festivals"
        case .exhibitions: return "Exhibitions"
        case .workshops: return "Workshops"
        case .comedy: return "Comedy & Theatre"
        }
    }

    var symbol: String {
        switch self {
        case .all: return "calendar"
        case .concerts: return "music.mic"
        case .fairs: return "flag.fill"
        case .food: return "fork.knife"
        case .exhibitions: return "photo.on.rectangle.angled"
        case .workshops: return "wrench.and.screwdriver"
        case .comedy: return "theatermasks"
        }
    }

    func includes(_ category: EventCategory) -> Bool {
        self == .all || self == category
    }
}

enum EventTimeFilter: String, CaseIterable, Identifiable, Hashable {
    case today = "Today"
    case weekend = "This Weekend"
    case upcoming = "Upcoming"

    var id: String { rawValue }
}

enum EventListingState: Hashable {
    case scheduled
    case cancelled
    case expired
}

/// A real place already stored in Explore. Sample events borrow it only so
/// Plan Journey can open an existing route.
struct EventVenue: Hashable {
    let name: String
    let address: String
    let locality: String
    let latitude: Double
    let longitude: Double
    let imageAssetName: String?
}

/// One event listing. Ticket price and ticket URL stay empty unless a
/// verified source supplied them.
struct EventModel: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let detail: String
    let category: EventCategory
    let imageAssetName: String?
    let imageURL: URL?
    let startDate: Date
    let endDate: Date
    let venue: EventVenue
    let ticketPriceText: String?
    let ticketURL: URL?
    let organiser: String?
    let isSponsored: Bool
    let campaignID: String?
    let advertiserID: String?
    let placementID: String
    let isSample: Bool
    let isCancelled: Bool
    let isActive: Bool

    func listingState(at date: Date) -> EventListingState {
        if isCancelled { return .cancelled }
        if !isActive || endDate <= date { return .expired }
        return .scheduled
    }

    func isListed(at date: Date) -> Bool {
        listingState(at: date) == .scheduled
    }

    var ticketLine: String {
        ticketPriceText ?? "Ticket price not verified"
    }

    var scheduleText: String {
        Self.schedule.string(from: startDate)
    }

    private static let schedule: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, d MMM · h:mm a"
        return formatter
    }()
}

/// A paid or sample sponsored placement. Organic listings stay on `EventModel`.
struct SponsoredEvent: Identifiable, Hashable {
    let event: EventModel

    var id: String { event.campaignID ?? event.id }
    var isSample: Bool { event.isSample }
}

enum EventSchedule {
    static func weekendInterval(containing date: Date, calendar: Calendar = .current) -> DateInterval {
        let weekday = calendar.component(.weekday, from: date)
        let daysUntilSaturday: Int
        if weekday == 7 {
            daysUntilSaturday = 0
        } else if weekday == 1 {
            daysUntilSaturday = -1
        } else {
            daysUntilSaturday = 7 - weekday
        }
        let saturday = calendar.date(
            byAdding: .day,
            value: daysUntilSaturday,
            to: calendar.startOfDay(for: date)
        ) ?? calendar.startOfDay(for: date)
        let monday = calendar.date(byAdding: .day, value: 2, to: saturday) ?? saturday
        return DateInterval(start: saturday, end: monday)
    }

    static func matches(
        _ event: EventModel,
        filter: EventTimeFilter,
        now: Date,
        calendar: Calendar = .current
    ) -> Bool {
        switch filter {
        case .today:
            return calendar.isDate(event.startDate, inSameDayAs: now)
        case .weekend:
            return weekendInterval(containing: now, calendar: calendar).contains(event.startDate)
        case .upcoming:
            return event.startDate >= weekendInterval(containing: now, calendar: calendar).end
        }
    }
}
