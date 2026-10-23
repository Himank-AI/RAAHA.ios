import Foundation
import CoreLocation

/// All prototype content lives here. No backend, no network.
enum MockData {

    // MARK: Route options

    static let routes: [RouteOption] = [
        RouteOption(
            kind: .fastest,
            minutes: 58,
            fare: 112,
            chain: [.walk, .metro, .auto, .walk],
            legs: [
                RouteLeg(id: "f1", mode: .walk, title: "Walk", detail: "2 min · 180 m",
                         description: "From your location to\nChennai Metro Station"),
                RouteLeg(id: "f2", mode: .metro, title: "Metro (Green Line)", detail: "22 min · 5 stops",
                         description: "Chennai Metro Station →\nSt. Thomas Mount", fare: "₹ 40"),
                RouteLeg(id: "f3", mode: .auto, title: "Auto", detail: "10 min · 3.2 km",
                         description: "St. Thomas Mount →\nPhoenix Mall", fare: "₹ 72"),
                RouteLeg(id: "f4", mode: .walk, title: "Walk", detail: "4 min · 350 m",
                         description: "From drop-off to your destination")
            ],
            liveScreens: [.walk, .metro, .auto, .walkEnd]
        ),
        RouteOption(
            kind: .cheapest,
            minutes: 97,
            fare: 68,
            chain: [.walk, .bus, .walk, .bike, .train],
            legs: [
                RouteLeg(id: "c1", mode: .walk, title: "Walk", detail: "10 min · 180 m",
                         description: "From your location to\nChennai Bus Station"),
                RouteLeg(id: "c2", mode: .bus, title: "Bus (MC13)", detail: "45 min · 5 stops",
                         description: "Chennai Metro Station →\nSt. Thomas Mount", fare: "₹ 25"),
                RouteLeg(id: "c3", mode: .walk, title: "Walk", detail: "25 min · 3.2 km",
                         description: "St. Thomas Mount →\nPhoenix Mall"),
                RouteLeg(id: "c4", mode: .bike, title: "Bike", detail: "7 min · 3.2 km",
                         description: "St. Thomas Mount →\nPhoenix Mall", fare: "₹ 30"),
                RouteLeg(id: "c5", mode: .train, title: "Train", detail: "5 min · 350 m",
                         description: "From drop-off to your destination", fare: "₹ 13")
            ],
            liveScreens: [.walk, .bus, .auto, .train]
        ),
        RouteOption(
            kind: .comfortable,
            minutes: 92,
            fare: 598,
            chain: [.walk, .cab],
            legs: [
                RouteLeg(id: "m1", mode: .walk, title: "Walk", detail: "2 min · 180 m",
                         description: "From your location to\nSRM Gate", lighting: .wellLit),
                RouteLeg(id: "m2", mode: .cab, title: "Cab", detail: "90 min · 35 km",
                         description: "From drop-off to your destination", fare: "₹ 598", lighting: .wellLit)
            ],
            liveScreens: [.walk, .auto]
        ),
        RouteOption(
            kind: .safest,
            minutes: 80,
            fare: 360,
            chain: [.walk, .auto, .metro],
            legs: [
                RouteLeg(id: "s1", mode: .walk, title: "Walk", detail: "10 min · 180 m",
                         description: "From your location to\nChennai Bus Station", lighting: .wellLit),
                RouteLeg(id: "s2", mode: .auto, title: "Auto", detail: "55 min · 6 km",
                         description: "St. Thomas Mount →\nPhoenix Mall", fare: "₹ 300", lighting: .wellLit),
                RouteLeg(id: "s3", mode: .metro, title: "Metro", detail: "15 min · 8 km",
                         description: "From drop-off to your destination", fare: "₹ 60", lighting: .wellLit)
            ],
            liveScreens: [.walk, .auto, .metro]
        )
    ]

    static func route(_ kind: RouteKind) -> RouteOption {
        routes.first { $0.kind == kind } ?? routes[0]
    }

    // MARK: Live journey screens

    static func live(_ screen: LiveScreen) -> LiveContent {
        switch screen {
        case .walk:
            return LiveContent(
                mode: .walk,
                title: "Walk",
                subtitle: "Chennai Central → Egmore",
                chips: ["20 min"],
                timeline: .walk(walkTimeline),
                showsMissedAlert: false,
                next: trainNext,
                tips: ["Use crosswalks and footpaths where available", "Keep your phone charged"]
            )
        case .walkEnd:
            return LiveContent(
                mode: .walk,
                title: "Walk",
                subtitle: "Chennai Central → Egmore",
                chips: ["18 min"],
                timeline: .walk(walkTimeline),
                showsMissedAlert: false,
                next: trainNext,
                tips: ["Use crosswalks and footpaths where available", "Keep your phone charged"]
            )
        case .metro:
            return LiveContent(
                mode: .metro,
                title: "Metro (Blue Line)",
                subtitle: "Chennai Airport → Alandur",
                chips: ["₹ 40", "10 min"],
                timeline: .stops(fullStops),
                showsMissedAlert: false,
                next: NextTransfer(
                    icon: .bus,
                    chip: "22 min",
                    headline: "Take the auto at Alandur",
                    lines: [
                        NextLine(text: "Route: 4 km"),
                        NextLine(text: "You will reach your destination by 10:45 AM")
                    ]
                ),
                tips: ["Check metro number & route", "Keep exact change / transit card", "Watch for your stop"]
            )
        case .auto:
            return LiveContent(
                mode: .auto,
                title: "Auto",
                subtitle: "Alandur → T. Nagar",
                chips: ["₹ 85", "10 min"],
                timeline: .pickupDrop(
                    PickupDrop(pickup: "Chennai Central", pickupTime: "9:41 AM",
                               drop: "Alandur", dropTime: "10:00 AM")
                ),
                showsMissedAlert: false,
                next: NextTransfer(
                    icon: .walk,
                    chip: "12 min",
                    headline: "Walking",
                    lines: [
                        NextLine(text: "Route: 500 m → Destination"),
                        NextLine(text: "You will reach your destination by 10:45 AM")
                    ]
                ),
                tips: ["Confirm fare before starting", "Share location for safety", "Keep small change handy"]
            )
        case .bus:
            return LiveContent(
                mode: .bus,
                title: "Bus",
                subtitle: "Chennai Airport → Alandur",
                chips: ["₹ 85", "22 min"],
                timeline: .stops(fullStops),
                showsMissedAlert: false,
                next: NextTransfer(
                    icon: .bus,
                    chip: "12 min",
                    headline: "Train",
                    lines: [
                        NextLine(text: "Board at: Chennai Central", trailing: "10:32 AM"),
                        NextLine(text: "Get down at: Egmore", trailing: "10:57 AM")
                    ]
                ),
                tips: ["Check bus number and route", "Same ticket/card for bus and metro", "Auto & bike options at the next stop"]
            )
        case .train:
            return LiveContent(
                mode: .train,
                title: "Train",
                subtitle: "Chennai Central → Egmore",
                chips: ["₹ 40", "22 min"],
                timeline: .stops(Array(fullStops.dropFirst())),
                showsMissedAlert: true,
                next: trainNext,
                tips: ["Check bus number and route", "Same ticket/card for bus and metro", "Auto & bike options at the next stop"]
            )
        }
    }

    private static let walkTimeline = WalkTimeline(
        startTitle: "T. Nagar",
        startCaption: "Start your walk from T. Nagar",
        walkTitle: "Walking",
        walkCaption: "2.4 km · 32 min",
        walkChip: "22 min",
        endTitle: "Marina Beach",
        endCaption: "You will reach your destination by 10:13 AM"
    )

    private static let fullStops: [StopItem] = [
        StopItem(name: "Chennai Airport", caption: "Boarded · 9:41 AM", state: .boarded),
        StopItem(name: "Meenambakkam", caption: "Next Stop · 3 min", state: .next),
        StopItem(name: "Guindy", caption: "8 min", state: .upcoming),
        StopItem(name: "Alandur", caption: "Arriving · 22 min", state: .arriving)
    ]

    private static let trainNext = NextTransfer(
        icon: .bus,
        chip: "12 min",
        headline: "Train",
        lines: [
            NextLine(text: "Route: 22A → Saidapet"),
            NextLine(text: "Board at: 10:32 AM, Alandur Station")
        ]
    )

    // MARK: Explore

    static let nearbySpots: [Place] = [
        Place(name: "Marina Beach", subtitle: "12 mins · Open now", imageName: "thumb_marina"),
        Place(name: "Besant Nagar Beach", subtitle: "18 mins · Open now", imageName: "thumb_besant")
    ]

    static let featuredPlaces: [Place] = [
        Place(name: "Marina Beach", subtitle: "World's 2nd longest beach · Mylapore coast", imageName: "thumb_marina"),
        Place(name: "Besant Nagar Beach", subtitle: "Elliot's Beach promenade · Evening cafes", imageName: "thumb_besant")
    ]

    // MARK: Trips

    // MARK: - Trips Hierarchy (Upcoming, Saved, Recent)

    static let upcomingTrips: [PlannedTrip] = [
        PlannedTrip(
            title: "Weekend Sunrise Walk",
            origin: "Chennai Central",
            destination: "Marina Beach",
            scheduledDate: "Tomorrow · 6:00 AM",
            countdownText: "In 18 hrs",
            primaryMode: .walk,
            estimatedDuration: "25 min",
            estimatedFare: "₹ 0"
        ),
        PlannedTrip(
            title: "Evening Shopping at Phoenix",
            origin: "Alandur Metro",
            destination: "Phoenix Mall, Velachery",
            scheduledDate: "Saturday · 5:30 PM",
            countdownText: "In 3 days",
            primaryMode: .metro,
            estimatedDuration: "22 min",
            estimatedFare: "₹ 40"
        )
    ]

    static let savedJourneys: [SavedJourney] = [
        SavedJourney(name: "Marina Beach", route: "Chennai Central → Marina Beach",
                     imageName: "trip_marina", isBookmarked: true),
        SavedJourney(name: "Besant Nagar Beach", route: "T. Nagar → Elliot's Beach",
                     imageName: "thumb_besant", isBookmarked: true),
        SavedJourney(name: "Phoenix Marketcity", route: "Guindy → Phoenix Mall",
                     imageName: "trip_mahabali", isBookmarked: false)
    ]

    static let recentTrips: [RecentTrip] = [
        RecentTrip(route: "Chennai Airport → Alandur", mode: "Metro (Blue Line)",
                   symbol: "tram.fill", customAsset: "icon_metro", day: "Today", time: "9:12 AM"),
        RecentTrip(route: "T. Nagar → Anna Nagar", mode: "Bus (Route 21C)",
                   symbol: "bus.fill", customAsset: nil, day: "Yesterday", time: "6:45 PM"),
        RecentTrip(route: "R.K. Salai → Adyar", mode: "Auto",
                   symbol: "car.fill", customAsset: "icon_auto", day: "Yesterday", time: "4:20 PM")
    ]

    // MARK: Missed train

    static let nextTrains: [MissedOption] = [
        MissedOption(line: "Metro (Green Line)", path: "Chennai Central Metro → Egmore Metro",
                     board: "Board at: 10:48 AM · Platform 1", duration: "17 min",
                     departs: "10:48 AM", arrives: "11:05 AM", isBest: true),
        MissedOption(line: "Metro (Green Line)", path: "Chennai Central Metro → Egmore Metro",
                     board: "Board at: 11:12 AM · Platform 1", duration: "41 min",
                     departs: "11:12 AM", arrives: "11:53 AM", isBest: false),
        MissedOption(line: "Metro (Green Line)", path: "Chennai Central Metro → Egmore Metro",
                     board: "Board at: 11:36 AM · Platform 1", duration: "1 hr 5 min",
                     departs: "11:36 AM", arrives: "12:41 PM", isBest: false)
    ]

    // MARK: Map

    static let origin = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2785)
    static let destination = CLLocationCoordinate2D(latitude: 12.9907, longitude: 80.2170)
    static let routeCoordinates: [CLLocationCoordinate2D] = [
        origin,
        CLLocationCoordinate2D(latitude: 13.0418, longitude: 80.2341),
        CLLocationCoordinate2D(latitude: 13.0067, longitude: 80.2206),
        destination
    ]
    static let mapCenter = CLLocationCoordinate2D(latitude: 12.985, longitude: 80.245)
}
