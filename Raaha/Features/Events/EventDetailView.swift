import SwiftUI

struct EventDetailView: View {
    let event: EventModel

    @Environment(AppRouter.self) private var router
    @Environment(AdImpressionTracker.self) private var tracker
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var ticketPulse = 0
    @State private var planPulse = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero
                VStack(alignment: .leading, spacing: 12) {
                    Text(event.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(EventInk.navy)
                        .fixedSize(horizontal: false, vertical: true)

                    if showsVerifiedSponsoredBadge {
                        Text("SPONSORED")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.6)
                            .foregroundStyle(EventInk.deep)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(EventInk.ice, in: Capsule())
                    }

                    if showsDescription {
                        Text(event.detail)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(EventInk.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        detailBlock(symbol: "calendar", title: "Date and time", value: event.scheduleText)
                        detailBlock(symbol: "tag", title: "Category", value: event.category.title)
                        detailBlock(symbol: "mappin.and.ellipse", title: "Venue", value: event.venue.name)
                        detailBlock(
                            symbol: "location",
                            title: "Address",
                            value: "\(event.venue.address), \(event.venue.locality)"
                        )
                        if let organiser = event.organiser, !event.isSample {
                            detailBlock(symbol: "person", title: "Organiser", value: organiser)
                        }
                        if let price = event.ticketPriceText, !price.isEmpty, !event.isSample {
                            detailBlock(symbol: "ticket", title: "Tickets", value: price)
                        }
                    }
                    .padding(.top, 2)

                    VStack(spacing: 10) {
                        Button {
                            planPulse += 1
                            EventNavigationManager.planJourney(
                                to: event,
                                placementID: "explore.events.detail",
                                router: router,
                                tracker: tracker
                            )
                        } label: {
                            Text("Plan Journey")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(EventInk.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(EventInk.deep))
                        }
                        .buttonStyle(EventDetailButtonStyle())
                        .sensoryFeedback(.impact(weight: .medium), trigger: planPulse)

                        if let ticketURL = EventNavigationManager.ticketURL(for: event) {
                            Button {
                                ticketPulse += 1
                                openURL(ticketURL)
                            } label: {
                                Text("View Tickets")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(EventInk.deep)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Capsule().fill(EventInk.ice))
                                    .overlay(Capsule().stroke(EventInk.soft, lineWidth: 1))
                            }
                            .buttonStyle(EventDetailButtonStyle())
                            .sensoryFeedback(.impact(weight: .light), trigger: ticketPulse)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(20)
                .padding(.bottom, 120)
            }
        }
        .background(EventInk.white)
        .pushedChrome(title: "Event")
        .ignoresSafeArea(edges: .top)
        .accessibilityElement(children: .contain)
    }

    private var showsVerifiedSponsoredBadge: Bool {
        event.isSponsored && !event.isSample && event.campaignID != nil
    }

    private var showsDescription: Bool {
        !event.isSample && !event.detail.isEmpty
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            EventPhoto(event: event, height: 280, pressed: false, reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipped()
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.45)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 280)
            .allowsHitTesting(false)
            Text(event.category.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(EventInk.deep.opacity(0.9)))
                .padding(16)
        }
    }

    private func detailBlock(symbol: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
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

private struct EventDetailButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.97 : 1)
            .animation(
                reduceMotion ? nil : .spring(response: 0.26, dampingFraction: 0.72),
                value: configuration.isPressed
            )
    }
}
