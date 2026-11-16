import CoreLocation
import Foundation
import Observation

// MARK: - Provider

/// Inventory source for sponsored discovery. A future direct-sold or
/// third-party provider can replace this without changing the cards.
protocol SponsoredInventoryProviding {
    func campaigns(at date: Date) -> [SponsoredCampaign]
}

/// Development-only sample inventory. Every campaign points at a place that
/// already exists in Explore. These are not paid campaigns.
struct DevelopmentSampleSponsoredProvider: SponsoredInventoryProviding {
    func campaigns(at date: Date) -> [SponsoredCampaign] {
        let windowStart = Date(timeIntervalSince1970: 0)
        let windowEnd = Date(timeIntervalSince1970: 2_200_000_000)
        return DevelopmentSampleSponsoredProvider.placeIDs.compactMap { placeID in
            guard let place = ExploreMockData.allPlaces.first(where: { $0.id == placeID }) else { return nil }
            return SponsoredCampaign(
                id: "sample.\(place.id)",
                advertiserID: "sample.local",
                placeID: place.id,
                placementID: "trips.discover",
                summary: "\(place.category.title) in \(place.locality).",
                starts: windowStart,
                ends: windowEnd,
                isActive: true,
                isSample: true
            )
        }.filter { $0.isRunning(at: date) }
    }

    private static let placeIDs = [
        "chennai_marina_beach",
        "chennai_besant_beach",
        "chennai_phoenix_marketcity",
        "chennai_murugan_idli",
        "chennai_writers_cafe",
        "chennai_egmore_museum"
    ]
}

/// Production inventory. Stays empty until approved campaigns are supplied.
struct ApprovedSponsoredInventory: SponsoredInventoryProviding {
    var approved: [SponsoredCampaign] = []

    func campaigns(at date: Date) -> [SponsoredCampaign] {
        approved.filter { $0.isRunning(at: date) && !$0.isSample }
    }
}

// MARK: - Tracker

@MainActor
@Observable
final class AdImpressionTracker {
    static let shared = AdImpressionTracker()

    private(set) var revision = 0
    private(set) var cycle = 0
    private(set) var events: [AdEvent] = []
    private(set) var reports: [AdReport] = []

    var sponsoredDiscoveryEnabled: Bool {
        didSet {
            UserDefaults.standard.set(sponsoredDiscoveryEnabled, forKey: Keys.enabled)
            revision += 1
        }
    }

    private var impressionDates: [String: [Date]] = [:]
    private var hiddenCampaignIDs: Set<String>
    private var reportedCampaignIDs: Set<String>

    private let impressionCap = 3
    private let minimumInterval: TimeInterval = 30

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.enabled) == nil {
            sponsoredDiscoveryEnabled = true
        } else {
            sponsoredDiscoveryEnabled = defaults.bool(forKey: Keys.enabled)
        }
        hiddenCampaignIDs = Set(defaults.stringArray(forKey: Keys.hidden) ?? [])
        reportedCampaignIDs = Set(defaults.stringArray(forKey: Keys.reported) ?? [])
    }

    func noteVisit() {
        cycle += 1
        revision += 1
    }

    func canDisplay(campaignID: String) -> Bool {
        sponsoredDiscoveryEnabled
            && !hiddenCampaignIDs.contains(campaignID)
            && !reportedCampaignIDs.contains(campaignID)
            && impressionCount(campaignID) < impressionCap
    }

    /// Counts a view only after the caller has confirmed the visibility threshold.
    func recordImpression(campaignID: String, advertiserID: String, placementID: String, at date: Date = Date()) {
        guard sponsoredDiscoveryEnabled else { return }
        if let last = impressionDates[campaignID]?.last, date.timeIntervalSince(last) < minimumInterval {
            return
        }
        impressionDates[campaignID, default: []].append(date)
        events.append(AdEvent(
            id: UUID().uuidString,
            campaignID: campaignID,
            advertiserID: advertiserID,
            placementID: placementID,
            kind: .impression,
            date: date
        ))
        if impressionCount(campaignID) >= impressionCap {
            revision += 1
        }
    }

    func recordClick(campaignID: String, advertiserID: String, placementID: String, at date: Date = Date()) {
        events.append(AdEvent(
            id: UUID().uuidString,
            campaignID: campaignID,
            advertiserID: advertiserID,
            placementID: placementID,
            kind: .click,
            date: date
        ))
    }

    func hide(campaignID: String) {
        hiddenCampaignIDs.insert(campaignID)
        UserDefaults.standard.set(Array(hiddenCampaignIDs), forKey: Keys.hidden)
        revision += 1
    }

    func report(campaignID: String, placementID: String, note: String) {
        reportedCampaignIDs.insert(campaignID)
        reports.append(AdReport(
            id: UUID().uuidString,
            campaignID: campaignID,
            placementID: placementID,
            note: note,
            date: Date()
        ))
        UserDefaults.standard.set(Array(reportedCampaignIDs), forKey: Keys.reported)
        revision += 1
    }

    private func impressionCount(_ campaignID: String) -> Int {
        impressionDates[campaignID]?.count ?? 0
    }

    private enum Keys {
        static let enabled = "raaha.sponsoredDiscovery.enabled"
        static let hidden = "raaha.sponsored.hiddenCampaigns"
        static let reported = "raaha.sponsored.reportedCampaigns"
    }
}

struct AdEvent: Identifiable, Hashable {
    enum Kind: String, Hashable { case impression, click }
    let id: String
    let campaignID: String
    let advertiserID: String
    let placementID: String
    let kind: Kind
    let date: Date
}

// MARK: - Selection

@MainActor
struct SponsoredContentService {
    var inventory: SponsoredInventoryProviding
    var tracker: AdImpressionTracker

    static var development: SponsoredContentService {
        #if DEBUG
        SponsoredContentService(
            inventory: DevelopmentSampleSponsoredProvider(),
            tracker: .shared
        )
        #else
        SponsoredContentService(
            inventory: ApprovedSponsoredInventory(),
            tracker: .shared
        )
        #endif
    }

    func feed(context: SponsoredContext, now: Date = Date(), carouselLimit: Int = 4) -> SponsoredFeed {
        guard tracker.sponsoredDiscoveryEnabled else { return SponsoredFeed(featured: nil, more: []) }

        let savedPlaces = savedDestinations(in: context.savedJourneyTexts)
        let candidates = inventory.campaigns(at: now).compactMap { campaign -> RankedPlacement? in
            guard tracker.canDisplay(campaignID: campaign.id),
                  let place = ExploreMockData.allPlaces.first(where: { $0.id == campaign.placeID })
            else { return nil }
            let match = relevance(for: place, saved: savedPlaces, filter: context.exploreFilter)
            return RankedPlacement(
                placement: SponsoredPlacement(campaign: campaign, place: place, reason: match.reason),
                score: match.score
            )
        }

        guard !candidates.isEmpty else { return SponsoredFeed(featured: nil, more: []) }

        let ranked = candidates.sorted { lhs, rhs in
            if lhs.score != rhs.score { return lhs.score > rhs.score }
            return lhs.placement.id < rhs.placement.id
        }
        let topScore = ranked[0].score
        let featuredPool = topScore > 0 ? ranked.filter { $0.score == topScore } : ranked
        let featured = featuredPool[context.cycle % featuredPool.count].placement
        let more = ranked
            .map(\.placement)
            .filter { $0.id != featured.id }
            .prefix(carouselLimit)

        return SponsoredFeed(featured: featured, more: Array(more))
    }

    private struct RankedPlacement {
        let placement: SponsoredPlacement
        let score: Int
    }

    private struct SavedDestination {
        let label: String
        let place: ExplorePlace
    }

    private func savedDestinations(in texts: [String]) -> [SavedDestination] {
        let places = ExploreMockData.allPlaces.sorted { $0.name.count > $1.name.count }
        var matches: [SavedDestination] = []
        for text in texts {
            let folded = text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            guard let place = places.first(where: { place in
                let name = place.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                return folded.contains(name)
            }) else { continue }
            let journeyName = text.components(separatedBy: " · ").first ?? place.name
            if !matches.contains(where: { $0.place.id == place.id }) {
                matches.append(SavedDestination(label: journeyName, place: place))
            }
        }
        return matches
    }

    private func relevance(
        for place: ExplorePlace,
        saved: [SavedDestination],
        filter: ExploreFilter?
    ) -> (score: Int, reason: SponsoredReason) {
        if let exact = saved.first(where: { $0.place.id == place.id }) {
            return (100, .savedJourney(exact.label))
        }

        let near = saved.compactMap { destination -> (SavedDestination, Int)? in
            let meters = Int(distance(from: destination.place.coordinate, to: place.coordinate).rounded())
            guard meters <= 3_000 else { return nil }
            return (destination, meters)
        }.min { $0.1 < $1.1 }

        if let near {
            return (70, .nearSavedJourney(name: near.0.label, meters: near.1))
        }

        if let filter, filter != .all, filter.matches(place) {
            return (40, .exploreCategory(filter))
        }

        return (0, .general)
    }

    private func distance(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDistance {
        CLLocation(latitude: start.latitude, longitude: start.longitude)
            .distance(from: CLLocation(latitude: end.latitude, longitude: end.longitude))
    }
}

enum AdNavigationManager {
    @MainActor
    static func openExploreAll(router: AppRouter) {
        router.openExplore(filter: .all, placeID: nil)
    }

    @MainActor
    static func open(
        _ placement: SponsoredPlacement,
        placementID: String,
        router: AppRouter,
        tracker: AdImpressionTracker
    ) {
        tracker.recordClick(
            campaignID: placement.campaign.id,
            advertiserID: placement.campaign.advertiserID,
            placementID: placementID
        )
        router.openExplore(filter: filter(for: placement.place), placeID: placement.place.id)
    }

    static func filter(for place: ExplorePlace) -> ExploreFilter {
        switch place.category {
        case .restaurant: return .restaurants
        case .cafe: return .cafes
        case .park: return .parks
        case .beach: return .beaches
        case .shopping: return .shopping
        case .entertainment: return .entertainment
        case .landmark, .attraction, .other: return .touristSpots
        }
    }
}
