import SwiftUI

// MARK: - Transport

enum TransportMode: Hashable {
    case walk, metro, bus, auto, bike, train, cab, car

    var title: String {
        switch self {
        case .walk: return "Walk"
        case .metro: return "Metro"
        case .bus: return "Bus"
        case .auto: return "Auto"
        case .bike: return "Bike"
        case .train: return "Train"
        case .cab: return "Cab"
        case .car: return "Car"
        }
    }

    /// SF Symbol used for the mode.
    var symbolName: String {
        switch self {
        case .walk: return "figure.walk"
        case .metro: return "tram.fill"
        case .bus: return "bus.fill"
        case .auto: return "car.fill"
        case .bike: return "bicycle"
        case .train: return "train.side.front.car"
        case .cab, .car: return "car.fill"
        }
    }

    /// Bundled asset name for modes that use custom glyphs.
    var customAssetName: String? {
        switch self {
        case .auto:  return "icon_auto"
        case .bike:  return "icon_bike"
        case .train: return "icon_train"
        case .metro: return "icon_metro"
        default:     return nil
        }
    }
}

// MARK: - Routes

enum RouteKind: String, CaseIterable, Hashable, Identifiable {
    case fastest, cheapest, comfortable, safest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fastest: return "Fastest"
        case .cheapest: return "Cheapest"
        case .comfortable: return "Most Comfortable"
        case .safest: return "Safest"
        }
    }

    var badgeFill: Color {
        switch self {
        case .fastest:     return Color.steelBlue      // #457B9D
        case .cheapest:    return Color.tealGreen       // #2A9D8F
        case .comfortable: return Color.frostedBlue     // #A8DADC
        case .safest:      return Color.statusGreen     // #16866A
        }
    }

    var badgeText: Color {
        // frostedBlue (#A8DADC) is a light fill — needs dark text
        self == .comfortable ? Color.deepSpace : Color.honeydew
    }
}

enum Lighting {
    case wellLit, notWellLit
}

struct RouteLeg: Identifiable, Hashable {
    let id: String
    let mode: TransportMode
    let title: String
    let detail: String
    let description: String
    var fare: String? = nil
    var lighting: Lighting? = nil
}

struct RouteOption: Identifiable {
    let kind: RouteKind
    let minutes: Int
    let fare: Int
    let chain: [TransportMode]
    let legs: [RouteLeg]
    let liveScreens: [LiveScreen]

    var id: RouteKind { kind }
    var modeCount: Int { Set(chain).count }
    var fareText: String { "₹ \(fare)" }
    var modesText: String { "\(modeCount) modes" }
}

// MARK: - Live journey

enum LiveScreen: Hashable {
    case walk, walkEnd, metro, auto, bus, train
}

enum StopState {
    case boarded, next, upcoming, arriving
}

struct StopItem: Identifiable {
    let id = UUID()
    let name: String
    let caption: String
    let state: StopState
}

struct WalkTimeline {
    let startTitle: String
    let startCaption: String
    let walkTitle: String
    let walkCaption: String
    let walkChip: String
    let endTitle: String
    let endCaption: String
}

struct PickupDrop {
    let pickup: String
    let pickupTime: String
    let drop: String
    let dropTime: String
}

enum LiveTimeline {
    case walk(WalkTimeline)
    case stops([StopItem])
    case pickupDrop(PickupDrop)
}

struct NextLine: Identifiable {
    let id = UUID()
    let text: String
    var trailing: String? = nil
}

struct NextTransfer {
    let icon: TransportMode
    let chip: String
    let headline: String
    let lines: [NextLine]
}

struct LiveContent {
    let mode: TransportMode
    let title: String
    let subtitle: String
    let chips: [String]
    let timeline: LiveTimeline
    let showsMissedAlert: Bool
    let next: NextTransfer
    let tips: [String]
}

// MARK: - Trips, places, plan

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let imageName: String
}

struct SavedJourney: Identifiable {
    let id = UUID()
    let name: String
    let route: String
    let imageName: String
    let isBookmarked: Bool
}

struct RecentTrip: Identifiable {
    let id = UUID()
    let route: String
    let mode: String
    let symbol: String
    var customAsset: String? = nil
    let day: String
    let time: String
}

struct MissedOption: Identifiable {
    let id = UUID()
    let line: String
    let path: String
    let board: String
    let duration: String
    let departs: String
    let arrives: String
    let isBest: Bool
}

struct TripPlan {
    var destination: String = "Chennai Beach"
    var date: Date = TripPlan.nextSaturdayAtTen()

    static let destinations = ["Chennai Beach", "Marina Beach", "Kapaleeshwarar Temple", "Besant Nagar Beach"]

    var dateText: String { Self.format(date, "EEE, d MMM yyyy") }
    var timeText: String { Self.format(date, "h:mm a") }
    var combinedText: String { "\(dateText) · \(timeText)" }

    private static func format(_ date: Date, _ pattern: String) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = pattern
        return f.string(from: date)
    }

    private static func nextSaturdayAtTen() -> Date {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: start) // 1 = Sunday … 7 = Saturday
        let delta = (7 - weekday + 7) % 7
        let add = delta == 0 ? 7 : delta
        let saturday = cal.date(byAdding: .day, value: add, to: start) ?? start
        return cal.date(bySettingHour: 10, minute: 0, second: 0, of: saturday) ?? saturday
    }
}
