import SwiftUI

// MARK: - Place Image Style

enum PlaceImageStyle {
    case thumbnail(size: CGFloat)
    case hero(height: CGFloat)
    case custom(width: CGFloat?, height: CGFloat, cornerRadius: CGFloat)

    var height: CGFloat {
        switch self {
        case .thumbnail(let size): return size
        case .hero(let height): return height
        case .custom(_, let height, _): return height
        }
    }

    var width: CGFloat? {
        switch self {
        case .thumbnail(let size): return size
        case .hero: return nil
        case .custom(let width, _, _): return width
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .thumbnail: return 14
        case .hero: return 0 // parent container clips
        case .custom(_, _, let radius): return radius
        }
    }
}

// MARK: - Pure SwiftUI Offline Place Image View

/// Zero-network, frontend-only SwiftUI place image component.
/// Renders bundled assets from Assets.xcassets when available, or a polished RAAHA design system placeholder.
struct PlaceImageView: View {
    let place: ExplorePlace
    let style: PlaceImageStyle

    init(place: ExplorePlace, style: PlaceImageStyle) {
        self.place = place
        self.style = style
    }

    var body: some View {
        ZStack {
            if let assetName = place.localAssetImageName {
                // 1. High-resolution local bundled asset
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: style.width, height: style.height)
                    .clipped()
            } else {
                // 2. Polished RAAHA design system placeholder
                placeholderView
            }
        }
        .frame(width: style.width, height: style.height)
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
    }

    // MARK: - Polished Placeholder

    private var placeholderView: some View {
        ZStack {
            switch style {
            case .thumbnail:
                Circle()
                    .fill(Color.steelBlue)
                    .overlay {
                        Image(systemName: place.symbolName)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color.honeydew)
                    }

            case .hero, .custom:
                LinearGradient.raahaHero
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: place.symbolName)
                                .font(.system(size: 52, weight: .light))
                                .foregroundStyle(Color.frostedBlue.opacity(0.6))

                            Text(place.name)
                                .font(.raahaHeadline)
                                .foregroundStyle(Color.honeydew.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .lineLimit(1)
                        }
                    }
            }
        }
        .frame(width: style.width, height: style.height)
    }
}
