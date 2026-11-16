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
                VStack(alignment: .leading, spacing: 16) {
                    Text(event.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(EventInk.navy)
                        .fixedSize(horizontal: false, vertical: true)

                    EventStatusChips(event: event, showsFeatured: false)

                    Text(event.detail)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(EventInk.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Photograph of \(event.venue.name). It is not a photo of this event.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(EventInk.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    detailBlock(symbol: "calendar", title: "Date and time", value: event.scheduleText)
                    detailBlock(symbol: "tag", title: "Category", value: event.category.title)
                    detailBlock(symbol: "mappin.and.ellipse", title: "Venue", value: event.venue.name)
                    detailBlock(
                        symbol: "location",
                        title: "Address",
                        value: "\(event.venue.address), \(event.venue.locality)"
                    )
                    if let organiser = event.organiser {
                        detailBlock(symbol: "person", title: "Organiser", value: organiser)
                    }
                    detailBlock(symbol: "ticket", title: "Tickets", value: event.ticketLine)
                    if event.isSponsored {
                        detailBlock(
                            symbol: "megaphone",
                            title: "Sponsorship",
                            value: event.isSample
                                ? "Sample placement. This is not a paid campaign."
                                : "This listing is a sponsored placement."
                        )
                    }

                    VStack(spacing: 10) {
                        Button {
                            ticketPulse += 1
                            if let url = EventNavigationManager.ticketURL(for: event) {
                                openURL(url)
                            }
                        } label: {
                            Text(EventNavigationManager.ticketURL(for: event) == nil ? "No verified ticket link" : "View Tickets")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(EventInk.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(EventInk.deep.opacity(ticketLinkAvailable ? 1 : 0.45)))
                        }
                        .buttonStyle(EventDetailButtonStyle())
                        .disabled(!ticketLinkAvailable)
                        .sensoryFeedback(.impact(weight: .light), trigger: ticketPulse)

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
                                .foregroundStyle(EventInk.deep)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(EventInk.ice))
                                .overlay(Capsule().stroke(EventInk.soft, lineWidth: 1))
                        }
                        .buttonStyle(EventDetailButtonStyle())
                        .sensoryFeedback(.impact(weight: .medium), trigger: planPulse)
                    }
                    .padding(.top, 6)
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

    private var ticketLinkAvailable: Bool {
        EventNavigationManager.ticketURL(for: event) != nil
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
