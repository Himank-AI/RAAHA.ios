import SwiftUI

// MARK: - Transport

enum TransportMode: Hashable {
    case walk, metro, bus, auto, bike, train, cab, car

    var title: String {
        switch self {
        case .walk: return "Walk"
        case .metro: return "Metro"
        case .bus: return "Bus"
        case .auto: return "Auto Rickshaw"
        case .bike: return "Bike"
        case .train: return "Local Train"
        case .cab: return "Cab"
        case .car: return "Car"
        }
    }

    /// Dedicated Transport Mode Colour
    var color: Color {
        switch self {
        case .walk:       return .transportWalk   // Nature Green #218C70
        case .bike:       return .transportBike   // Amber Orange #E58A27
        case .auto:       return .transportAuto   // Golden Yellow #C28A12
        case .bus:        return .transportBus    // Sky Blue #38A8D8
        case .cab, .car:  return .transportCab    // Royal Lavender #8064A9
        case .train:      return .transportTrain  // Steel Blue #457B9D
        case .metro:      return .transportMetro  // Ocean Teal #16859A
        }
    }

    /// Soft, light-tinted circular background derived from respective colour
    var tintedBackground: Color {
        switch self {
        case .bus: return .transportBusBg         // Light Sky Blue #E2F4FC
        default:   return color.opacity(0.14)
        }
    }

    /// Subtle rim stroke derived from respective colour
    var strokeColor: Color {
        switch self {
        case .bus: return color.opacity(0.35)
        default:   return color.opacity(0.28)
        }
    }

    /// SF Symbol used for the mode. Modes with a `customAssetName` must render that asset instead (see `ModeGlyph`).
    var symbolName: String {
        switch self {
        case .walk: return "figure.walk"
        case .metro: return "train.side.front.car"
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

    /// Match mode from string identifier
    static func mode(for name: String) -> TransportMode? {
        let lower = name.lowercased()
        if lower.contains("walk") { return .walk }
        if lower.contains("bike") || lower.contains("bicycle") { return .bike }
        if lower.contains("auto") { return .auto }
        if lower.contains("bus") { return .bus }
        if lower.contains("cab") || lower.contains("taxi") || lower.contains("car") { return .cab }
        if lower.contains("train") { return .train }
        if lower.contains("metro") { return .metro }
        return nil
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
        case .cheapest:    return Color(hex: 0x299D8F)  // Teal Green
        case .comfortable: return Color.frostedBlue     // #A8DADC
        case .safest:      return Color(hex: 0x18866B)  // Forest Green
        }
    }

    var badgeText: Color {
        // frostedBlue (#A8DADC) is a light fill — needs Deep Space Blue text
        self == .comfortable ? Color.deepSpace : Color.white
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
    var modeCountOverride: Int? = nil

    var id: RouteKind { kind }
    var modeCount: Int { modeCountOverride ?? Set(chain).count }
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

/// Previous / current / next stop around the rider on a ride leg.
struct RideStopsTimeline {
    struct Stop {
        let name: String
        let caption: String
    }

    let previous: Stop
    let current: Stop
    let next: Stop
}

enum LiveTimeline {
    case walk(WalkTimeline)
    case stops([StopItem])
    case pickupDrop(PickupDrop)
    case rideStops(RideStopsTimeline)
}

/// Detail lines and stop progress for an illustrated ride card (e.g. Train).
struct RideProgress {
    let lines: [String]
    let totalStops: Int
    /// Zero-based index of the stop the vehicle is currently at.
    let currentStopIndex: Int

    var stopsRemaining: Int { max(totalStops - currentStopIndex - 1, 0) }
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

struct WalkDirection {
    enum Turn {
        case straight, left, right, slightLeft, slightRight

        var phrase: String {
            switch self {
            case .straight: return "Straight for"
            case .left: return "Turn left in"
            case .right: return "Turn right in"
            case .slightLeft: return "Bear left in"
            case .slightRight: return "Bear right in"
            }
        }

        var symbolName: String {
            switch self {
            case .straight: return "arrow.up"
            case .left: return "arrow.turn.up.left"
            case .right: return "arrow.turn.up.right"
            case .slightLeft: return "arrow.up.left"
            case .slightRight: return "arrow.up.right"
            }
        }
    }

    let turn: Turn
    let distance: String
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
    var direction: WalkDirection? = nil
    var ride: RideProgress? = nil
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
    let name: String
    let destination: String
    let minutesAway: Int
    let platform: Int
}

struct PlannedTrip: Identifiable {
    let id = UUID()
    let title: String
    let origin: String
    let destination: String
    let scheduledDate: String
    let countdownText: String
    let primaryMode: TransportMode
    let estimatedDuration: String
    let estimatedFare: String
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
