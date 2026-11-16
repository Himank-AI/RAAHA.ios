import SwiftUI

struct SponsoredDiscoverySection: View {
    let savedJourneyTexts: [String]

    @Environment(AppRouter.self) private var router
    @Environment(AdImpressionTracker.self) private var tracker
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared = false
    @State private var disclosure: SponsoredPlacement?

    private var currentFeed: SponsoredFeed {
        _ = tracker.revision
        return SponsoredContentService.development.feed(
            context: SponsoredContext(
                savedJourneyTexts: savedJourneyTexts,
                exploreFilter: router.lastExploreFilter,
                cycle: max(tracker.cycle - 1, 0)
            )
        )
    }

    private var liveJourneyIsActive: Bool {
        (router.homePath + router.tripsPath).contains { route in
            if case .live = route { return true }
            return false
        }
    }

    var body: some View {
        let feed = currentFeed
        if !liveJourneyIsActive, let featured = feed.featured {
            VStack(alignment: .leading, spacing: 12) {
                header

                if feed.usesSampleInventory {
                    Text("Development samples. These are not paid campaigns.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(SponsoredInk.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                FeaturedSponsoredCard(
                    placement: featured,
                    reduceMotion: reduceMotion,
                    onOpen: { open(featured, placementID: "trips.discover.featured") },
                    onDisclosure: { disclosure = featured }
                )
                .modifier(SponsoredImpressionMarker(
                    campaignID: featured.campaign.id,
                    advertiserID: featured.campaign.advertiserID,
                    placementID: "trips.discover.featured"
                ))

                if !feed.more.isEmpty {
                    SponsoredCarousel(
                        placements: feed.more,
                        reduceMotion: reduceMotion,
                        onOpen: { placement in
                            open(placement, placementID: "trips.discover.carousel")
                        },
                        onDisclosure: { disclosure = $0 }
                    )
                }
            }
            .opacity(appeared || reduceMotion ? 1 : 0)
            .offset(y: appeared || reduceMotion ? 0 : 12)
            .onAppear {
                tracker.noteVisit()
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(.spring(response: 0.48, dampingFraction: 0.86)) {
                        appeared = true
                    }
                }
            }
            .sheet(item: $disclosure) { placement in
                SponsoredDisclosureSheet(placement: placement)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Discover More")
                    .font(.raahaHeadline)
                    .foregroundStyle(Color.midnightBlue)
                Text("Places and experiences worth discovering around Chennai.")
                    .font(.raahaCaption)
                    .foregroundStyle(SponsoredInk.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            Button {
                AdNavigationManager.openExploreAll(router: router)
            } label: {
                HStack(spacing: 2) {
                    Text("Explore All")
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                }
                .font(.raahaSubheadline)
                .foregroundStyle(Color.royalBlue)
            }
            .buttonStyle(.plain)
        }
        .accessibilityElement(children: .contain)
    }

    private func open(_ placement: SponsoredPlacement, placementID: String) {
        AdNavigationManager.open(placement, placementID: placementID, router: router, tracker: tracker)
    }
}

// MARK: - Featured

struct FeaturedSponsoredCard: View {
    let placement: SponsoredPlacement
    let reduceMotion: Bool
    let onOpen: () -> Void
    let onDisclosure: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: 0) {
                    image
                    VStack(alignment: .leading, spacing: 6) {
                        Text(placement.place.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(SponsoredInk.navy)
                            .lineLimit(1)
                        Text(placement.place.category.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(SponsoredInk.deep)
                        Text(placement.campaign.summary)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(SponsoredInk.muted)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 6) {
                            Text("Explore in RAAHA")
                                .font(.system(size: 14, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(SponsoredInk.deep)
                        .padding(.top, 4)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(SponsoredPressStyle())

            disclosureButton
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
        }
        .background(SponsoredInk.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.95), lineWidth: 1)
        )
        .shadow(color: SponsoredInk.navy.opacity(0.10), radius: 14, y: 7)
        .accessibilityElement(children: .contain)
    }

    private var image: some View {
        GeometryReader { geo in
            PlaceImageView(
                place: placement.place,
                style: .custom(width: geo.size.width, height: 176, cornerRadius: 0)
            )
            .frame(width: geo.size.width, height: 176)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.18)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
            }
            .overlay(alignment: .topLeading) {
                SponsoredBadge(isSample: placement.isSample)
                    .padding(10)
            }
        }
        .frame(height: 176)
        .clipped()
    }

    private var disclosureButton: some View {
        Button(action: onDisclosure) {
            Label("Why this?", systemImage: "info.circle")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(SponsoredInk.muted)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Explains why this placement is shown")
    }
}

// MARK: - Carousel

struct SponsoredCarousel: View {
    let placements: [SponsoredPlacement]
    let reduceMotion: Bool
    let onOpen: (SponsoredPlacement) -> Void
    let onDisclosure: (SponsoredPlacement) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(placements) { placement in
                    SponsoredPlaceCard(
                        placement: placement,
                        onOpen: { onOpen(placement) },
                        onDisclosure: { onDisclosure(placement) }
                    )
                    .modifier(SponsoredImpressionMarker(
                        campaignID: placement.campaign.id,
                        advertiserID: placement.campaign.advertiserID,
                        placementID: "trips.discover.carousel"
                    ))
                    .modifier(SponsoredScrollEffect(enabled: !reduceMotion))
                }
            }
            .scrollTargetLayout()
            .padding(.vertical, 4)
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollClipDisabled()
    }
}

struct SponsoredPlaceCard: View {
    let placement: SponsoredPlacement
    let onOpen: () -> Void
    let onDisclosure: () -> Void

    private let width: CGFloat = 176

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: 0) {
                    GeometryReader { geo in
                        PlaceImageView(
                            place: placement.place,
                            style: .custom(width: geo.size.width, height: 112, cornerRadius: 0)
                        )
                        .overlay(alignment: .topLeading) {
                            SponsoredBadge(isSample: placement.isSample)
                                .padding(8)
                        }
                    }
                    .frame(width: width, height: 112)
                    .clipped()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(placement.place.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(SponsoredInk.navy)
                            .lineLimit(2)
                            .frame(minHeight: 36, alignment: .topLeading)
                        Text(placement.place.category.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(SponsoredInk.deep)
                        Text(placement.campaign.summary)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(SponsoredInk.muted)
                            .lineLimit(2)
                        Text("View Details")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(SponsoredInk.deep)
                            .padding(.top, 2)
                    }
                    .padding(10)
                    .frame(width: width, alignment: .leading)
                }
            }
            .buttonStyle(SponsoredPressStyle())

            Button(action: onDisclosure) {
                Text("Why this?")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SponsoredInk.muted)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
            .buttonStyle(.plain)
        }
        .frame(width: width)
        .background(SponsoredInk.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.95), lineWidth: 1)
        )
        .shadow(color: SponsoredInk.navy.opacity(0.08), radius: 10, y: 5)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(placement.place.name), \(placement.place.category.title), \(placement.isSample ? "sample placement" : "sponsored")")
    }
}

// MARK: - Badge and disclosure

struct SponsoredBadge: View {
    let isSample: Bool

    var body: some View {
        HStack(spacing: 4) {
            if isSample {
                chip("SAMPLE", foreground: SponsoredInk.deep, fill: SponsoredInk.ice)
            }
            chip("SPONSORED", foreground: SponsoredInk.navy, fill: Color.white.opacity(0.94))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isSample ? "Sample sponsored placement" : "Sponsored")
    }

    private func chip(_ title: String, foreground: Color, fill: Color) -> some View {
        Text(title)
            .font(.system(size: 9, weight: .bold))
            .tracking(0.6)
            .foregroundStyle(foreground)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(fill, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.9), lineWidth: 0.6))
    }
}

struct SponsoredDisclosureSheet: View {
    let placement: SponsoredPlacement
    @Environment(AdImpressionTracker.self) private var tracker
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Why am I seeing this?")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(SponsoredInk.navy)

            Text(placement.reason.explanation)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(SponsoredInk.navy)
                .fixedSize(horizontal: false, vertical: true)

            if placement.isSample {
                Text("This is sample inventory for development. It is not a paid campaign.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(SponsoredInk.deep)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 8) {
                disclosureAction("Hide this placement") {
                    tracker.hide(campaignID: placement.campaign.id)
                    dismiss()
                }
                disclosureAction("Report this placement") {
                    tracker.report(
                        campaignID: placement.campaign.id,
                        placementID: placement.campaign.placementID,
                        note: "Reported from Discover More"
                    )
                    dismiss()
                }
                disclosureAction(tracker.sponsoredDiscoveryEnabled ? "Turn off sponsored discovery" : "Sponsored discovery is off") {
                    tracker.sponsoredDiscoveryEnabled = false
                    dismiss()
                }
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SponsoredInk.white)
    }

    private func disclosureAction(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(SponsoredInk.navy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(SponsoredInk.ice, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Effects

private struct SponsoredImpressionMarker: ViewModifier {
    let campaignID: String
    let advertiserID: String
    let placementID: String
    @Environment(AdImpressionTracker.self) private var tracker

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.onScrollVisibilityChange(threshold: 0.6) { visible in
                guard visible else { return }
                tracker.recordImpression(
                    campaignID: campaignID,
                    advertiserID: advertiserID,
                    placementID: placementID
                )
            }
        } else {
            content
        }
    }
}

private struct SponsoredScrollEffect: ViewModifier {
    var enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.scrollTransition(.interactive, axis: .horizontal) { view, phase in
                view
                    .opacity(phase.isIdentity ? 1 : 0.86)
                    .scaleEffect(phase.isIdentity ? 1 : 0.97)
            }
        } else {
            content
        }
    }
}

struct SponsoredPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.98 : 1)
            .animation(
                reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.74),
                value: configuration.isPressed
            )
    }
}

private enum SponsoredInk {
    static let ice = Color(hex: 0xDCEFF5)
    static let deep = Color(hex: 0x176487)
    static let navy = Color(hex: 0x173D5C)
    static let muted = Color(hex: 0x326F89)
    static let white = Color(hex: 0xF5FAFC)
}
