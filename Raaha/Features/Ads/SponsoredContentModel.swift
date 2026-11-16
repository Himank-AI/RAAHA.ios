import CoreLocation
import Foundation

/// A sponsored placement that always points at an existing Explore place.
/// Sample campaigns are development inventory and are not paid.
struct SponsoredCampaign: Identifiable, Hashable {
    let id: String
    let advertiserID: String
    let placeID: String
    let placementID: String
    let summary: String
    let starts: Date
    let ends: Date
    let isActive: Bool
    let isSample: Bool

    func isRunning(at date: Date) -> Bool {
        isActive && starts <= date && date < ends
    }
}

enum SponsoredReason: Hashable {
    case savedJourney(String)
    case nearSavedJourney(name: String, meters: Int)
    case exploreCategory(ExploreFilter)
    case general

    var explanation: String {
        switch self {
        case .savedJourney(let name):
            return "This place matches your saved journey “\(name)”."
        case .nearSavedJourney(let name, let meters):
            return "This place is \(SponsoredReason.distanceText(meters)) from \(name), measured from their map coordinates."
        case .exploreCategory(let filter):
            return "\(filter.title) are shown first because you last browsed that category in Explore."
        case .general:
            return "This is a general discovery placement. It does not use personal details or claim to be near you."
        }
    }

    private static func distanceText(_ meters: Int) -> String {
        if meters < 1000 { return "\(meters) m" }
        return String(format: "%.1f km", Double(meters) / 1000)
    }
}

struct SponsoredPlacement: Identifiable, Hashable {
    let campaign: SponsoredCampaign
    let place: ExplorePlace
    let reason: SponsoredReason

    var id: String { campaign.id }
    var isSample: Bool { campaign.isSample }
}

struct SponsoredFeed: Equatable {
    var featured: SponsoredPlacement?
    var more: [SponsoredPlacement]

    var isEmpty: Bool { featured == nil && more.isEmpty }
    var usesSampleInventory: Bool {
        let items = [featured].compactMap { $0 } + more
        return !items.isEmpty && items.allSatisfy(\.isSample)
    }
}

struct SponsoredContext: Equatable {
    var savedJourneyTexts: [String]
    var exploreFilter: ExploreFilter?
    var cycle: Int
}

/// Request that opens an existing Explore place through the current tab architecture.
struct ExploreRequest: Equatable {
    var placeID: String?
    var filter: ExploreFilter
    var token: UUID
}

struct AdReport: Identifiable, Hashable {
    let id: String
    let campaignID: String
    let placementID: String
    let note: String
    let date: Date
}
