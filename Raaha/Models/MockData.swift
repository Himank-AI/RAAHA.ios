import Foundation
import CoreLocation

/// All prototype content lives here. No backend, no network.
enum MockData {

    // MARK: Route options

    static let routes: [RouteOption] = [
        RouteOption(
            kind: .fastest,
            minutes: 52,
            fare: 90,
            chain: [.walk, .train, .auto],
            legs: [
                RouteLeg(id: "f1", mode: .walk, title: "Walk", detail: "2 min · 180 m",
                         description: "From your location to\nPotheri Railway Station"),
                RouteLeg(id: "f2", mode: .train, title: "Train", detail: "40 min · 8 stops",
                         description: "Potheri Railway Station →\nGuindy Railway Station", fare: "₹ 10"),
                RouteLeg(id: "f3", mode: .auto, title: "Auto", detail: "10 min · 3.2 km",
                         description: "Guindy Railway Station →\nPhoenix Mall", fare: "₹ 80")
            ],
            liveScreens: [.walk, .train, .auto],
            modeCountOverride: 3
        ),
        RouteOption(
            kind: .cheapest,
            minutes: 66,
            fare: 25,
            chain: [.walk, .train, .bus, .walk],
            legs: [
                RouteLeg(id: "c1", mode: .walk, title: "Walk", detail: "2 min · 200 m",
                         description: "From your location to\nPotheri Railway Station"),
                RouteLeg(id: "c2", mode: .train, title: "Train", detail: "40 min · 8 stops",
                         description: "Potheri Railway Station →\nGuindy Railway Station", fare: "₹ 10"),
                RouteLeg(id: "c3", mode: .bus, title: "Bus (M31)", detail: "18 min · 4 stops",
                         description: "Guindy Bus Terminal →\nGuru Nanak College", fare: "₹ 15"),
                RouteLeg(id: "c4", mode: .walk, title: "Walk", detail: "6 min · 400 m",
                         description: "From Guru Nanak College to\nyour destination")
            ],
            liveScreens: [.walk, .train, .bus],
            modeCountOverride: 3
        ),
        RouteOption(
            kind: .comfortable,
            minutes: 92,
            fare: 360,
            chain: [.auto, .metro, .auto],
            legs: [
                RouteLeg(id: "m1", mode: .auto, title: "Auto", detail: "52 min · 29 km",
                         description: "From Your Location to\nTirusulam Metro Station", fare: "₹ 200"),
                RouteLeg(id: "m2", mode: .metro, title: "Metro", detail: "26 min · 5 stops",
                         description: "Tirusulam →\nGuindy", fare: "₹ 50"),
                RouteLeg(id: "m3", mode: .auto, title: "Auto", detail: "14 min · 6 km",
                         description: "From Guindy Metro Station to\nyour destination", fare: "₹ 110")
            ],
            liveScreens: [.autoToMetro, .metro, .autoEnd],
            modeCountOverride: 2
        ),
        RouteOption(
            kind: .safest,
            minutes: 80,
            fare: 480,
            chain: [.cab],
            legs: [
                RouteLeg(id: "s1", mode: .cab, title: "Cab", detail: "80 min · 32 km",
                         description: "Direct cab from your location\nto your destination", fare: "₹ 480")
            ],
            liveScreens: [.cab],
            modeCountOverride: 1
        )
    ]

    static func route(_ kind: RouteKind) -> RouteOption {
        routes.first { $0.kind == kind } ?? routes[0]
    }

    // MARK: Live journey screens

    static func live(_ screen: LiveScreen, kind: RouteKind = .fastest) -> LiveContent {
        switch screen {
        case .walk:
            return LiveContent(
                mode: .walk,
                title: "Walk",
                subtitle: "Your Location to Potheri Railway Station",
                chips: ["2 min"],
                timeline: .walk(walkTimeline),
                showsMissedAlert: false,
                next: trainNext,
                tips: ["Use crosswalks and footpaths where available", "Keep your phone charged"],
                direction: WalkDirection(turn: .straight, distance: "80 m")
            )
        case .walkEnd:
            return LiveContent(
                mode: .walk,
                title: "Walk",
                subtitle: "Guru Nanak College to your destination",
                chips: ["6 min"],
                timeline: .walk(walkTimeline),
                showsMissedAlert: false,
                next: trainNext,
                tips: ["Use crosswalks and footpaths where available", "Keep your phone charged"],
                direction: WalkDirection(turn: .straight, distance: "80 m"),
                arrival: "10:45 AM"
            )
        case .metro:
            return LiveContent(
                mode: .metro,
                title: "Metro (Blue Line)",
                subtitle: "Tirusulam → Guindy",
                chips: ["26 min"],
                timeline: .rideStops(
                    RideStopsTimeline(
                        previous: .init(name: "Tirusulam", caption: "Departed 10:58 AM"),
                        current: .init(name: "Meenambakkam", caption: "Arriving now"),
                        next: .init(name: "Nanganallur Road", caption: "in 4 min")
                    )
                ),
                showsMissedAlert: false,
                next: NextTransfer(
                    icon: .auto,
                    chip: "14 min",
                    headline: "Auto",
                    lines: [
                        NextLine(text: "Board at: 11:20 AM, Guindy"),
                        NextLine(text: "Reach your destination by 11:34 AM")
                    ]
                ),
                tips: ["Check metro number & route", "Keep exact change / transit card", "Watch for your stop"],
                ride: RideProgress(
                    lines: ["Tirusulam to Guindy"],
                    totalStops: 5,
                    currentStopIndex: 1
                )
            )
        case .auto:
            return LiveContent(
                mode: .auto,
                title: "Auto",
                subtitle: "Guindy → Anna Nagar",
                chips: ["10 min"],
                timeline: .pickupDrop(
                    PickupDrop(pickup: "Guindy Railway Station", drop: "Phoenix mall, Velachery")
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
                tips: ["Confirm fare before starting", "Share location for safety", "Keep small change handy"],
                ride: RideProgress(
                    lines: ["Guindy Station to Phoenix Mall"],
                    totalStops: 4,
                    currentStopIndex: 1
                ),
                arrival: "1:38 PM"
            )
        case .autoEnd:
            return LiveContent(
                mode: .auto,
                title: "Auto",
                subtitle: "Guindy → Anna Nagar",
                chips: ["14 min"],
                timeline: .pickupDrop(
                    PickupDrop(pickup: "Guindy Railway Station", drop: "Phoenix mall, Velachery")
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
                tips: ["Confirm fare before starting", "Share location for safety", "Keep small change handy"],
                ride: RideProgress(
                    lines: ["Guindy Station to Phoenix Mall"],
                    totalStops: 4,
                    currentStopIndex: 1,
                    remaining: "4.1 km"
                ),
                arrival: "1:38 PM"
            )
        case .autoToMetro:
            return LiveContent(
                mode: .auto,
                title: "Auto",
                subtitle: "Your Location → Tirusulam Metro",
                chips: ["52 min"],
                timeline: .pickupDrop(
                    PickupDrop(pickup: "Your Location", drop: "Tirusulam Metro Station")
                ),
                showsMissedAlert: false,
                next: NextTransfer(
                    icon: .metro,
                    chip: "26 min",
                    headline: "Metro",
                    lines: [
                        NextLine(text: "Route: Tirusulam → Guindy"),
                        NextLine(text: "Board at: 10:58 AM, Towards LIC")
                    ]
                ),
                tips: ["Confirm fare before starting", "Share location for safety", "Keep small change handy"],
                ride: RideProgress(
                    lines: ["Your Location to Tirusulam Metro"],
                    totalStops: 4,
                    currentStopIndex: 1,
                    remaining: "21.2 km"
                )
            )
        case .bus:
            return LiveContent(
                mode: .bus,
                title: "Bus (M31)",
                subtitle: "Guindy Bus Terminal → Guru Nanak College",
                chips: ["18 min"],
                timeline: .rideStops(
                    RideStopsTimeline(
                        previous: .init(name: "Guindy Bus Terminal", caption: "Departed 11:18 AM"),
                        current: .init(name: "Saidapet", caption: "Arriving now"),
                        next: .init(name: "Velachery", caption: "in 6 min")
                    )
                ),
                showsMissedAlert: false,
                next: NextTransfer(
                    icon: .walk,
                    chip: "6 min",
                    headline: "Walk to your destination",
                    lines: [
                        NextLine(text: "From Guru Nanak College"),
                        NextLine(text: "400 m to your destination")
                    ]
                ),
                tips: ["Check bus number and route", "Same ticket/card for bus and metro", "Auto & bike options at the next stop"],
                ride: RideProgress(
                    lines: ["Guindy Bus Terminal to Guru Nanak College"],
                    totalStops: 4,
                    currentStopIndex: 1
                ),
                arrival: "1:38 PM"
            )
        case .train:
            return LiveContent(
                mode: .train,
                title: "Train",
                subtitle: "Potheri → Guindy",
                chips: ["40 min"],
                timeline: .rideStops(
                    RideStopsTimeline(
                        previous: .init(name: "Potheri", caption: "Departed 10:32 AM"),
                        current: .init(name: "Gudduvancheri", caption: "Arriving now"),
                        next: .init(name: "Urappakkam", caption: "in 4 min")
                    )
                ),
                showsMissedAlert: false,
                next: kind == .cheapest ? busNext : autoNext,
                tips: ["Check bus number and route", "Same ticket/card for bus and metro", "Auto & bike options at the next stop"],
                ride: RideProgress(
                    lines: ["Potheri Station to Guindy Station"],
                    totalStops: 8,
                    currentStopIndex: 1
                )
            )
        case .cab:
            return LiveContent(
                mode: .cab,
                title: "Cab",
                subtitle: "Your location → Destination",
                chips: ["80 min"],
                timeline: .pickupDrop(
                    PickupDrop(pickup: "Your Location", drop: "Phoenix Mall, Velachery")
                ),
                showsMissedAlert: false,
                next: NextTransfer(
                    icon: .cab,
                    chip: "80 min",
                    headline: "Direct cab",
                    lines: [
                        NextLine(text: "Door to door, no transfers"),
                        NextLine(text: "You will reach your destination by 11:00 AM")
                    ]
                ),
                tips: ["Confirm the cab and fare before starting", "Share your live location", "Sit in the back and keep the doors locked"],
                ride: RideProgress(
                    lines: ["Your location to Destination"],
                    totalStops: 4,
                    currentStopIndex: 1,
                    remaining: "20.8 km"
                ),
                arrival: "11:00 AM"
            )
        }
    }

    private static let walkTimeline = WalkTimeline(
        startTitle: "Current Location",
        startCaption: "Start your walk from Your Location",
        walkTitle: "Walking",
        walkCaption: "180 m · 2 min",
        walkChip: "2 min",
        endTitle: "Potheri Railway Station",
        endCaption: "You will reach your destination by 10:13 AM"
    )

    private static let fullStops: [StopItem] = [
        StopItem(name: "Chennai Airport", caption: "Boarded · 9:41 AM", state: .boarded),
        StopItem(name: "Meenambakkam", caption: "Next Stop · 3 min", state: .next),
        StopItem(name: "Guindy", caption: "8 min", state: .upcoming),
        StopItem(name: "Alandur", caption: "Arriving · 22 min", state: .arriving)
    ]

    private static let busNext = NextTransfer(
        icon: .bus,
        chip: "18 min",
        headline: "Bus (M31)",
        lines: [
            NextLine(text: "Board at: 11:18 AM"),
            NextLine(text: "Guindy Bus Terminal")
        ]
    )

    private static let autoNext = NextTransfer(
        icon: .auto,
        chip: "10 min",
        headline: "Auto",
        lines: [
            NextLine(text: "Board at: 10:37 AM, Guindy"),
            NextLine(text: "Towards: Anna Nagar")
        ]
    )

    private static let trainNext = NextTransfer(
        icon: .train,
        chip: "40 min",
        headline: "Train",
        lines: [
            NextLine(text: "Route: Potheri → Guindy"),
            NextLine(text: "Board at: 10:32 AM, Potheri Station")
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
                   symbol: "train.side.front.car", customAsset: "icon_metro", day: "Today", time: "9:12 AM"),
        RecentTrip(route: "T. Nagar → Anna Nagar", mode: "Bus (Route 21C)",
                   symbol: "bus.fill", customAsset: nil, day: "Yesterday", time: "6:45 PM"),
        RecentTrip(route: "R.K. Salai → Adyar", mode: "Auto",
                   symbol: "car.fill", customAsset: "icon_auto", day: "Yesterday", time: "4:20 PM")
    ]

    // MARK: Missed train

    static let nextTrains: [MissedOption] = [
        MissedOption(name: "Chennai Local", destination: "To Guindy Station", minutesAway: 3, platform: 2),
        MissedOption(name: "Chennai Local", destination: "To Tambaram", minutesAway: 7, platform: 1),
        MissedOption(name: "Express Train", destination: "To Central Station", minutesAway: 12, platform: 3)
    ]

    static let nearbyStations = ["Potheri Station", "Guduvancheri Station", "Tambaram Station"]

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
