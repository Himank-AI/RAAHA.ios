import SwiftUI

/// Floating pill tab bar (Home · Trips · Explore · Profile) with fluid liquid glass sliding lens.
struct RaahaTabBar: View {
    @Binding var selection: AppTab
    @Namespace private var tabNamespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(5)
        .glassCapsule()
        .sensoryFeedback(.selection, trigger: selection)
        .accessibilityElement(children: .contain)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selection == tab
        return Button {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.70, blendDuration: 0.12)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.symbol(selected: isSelected))
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .frame(height: 24)
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
            }
            .foregroundStyle(isSelected ? Color.white : Color.royalBlue.opacity(0.65))
            .frame(maxWidth: .infinity, minHeight: 52)
            .background {
                if isSelected {
                    LiquidGlassLens(namespace: tabNamespace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Liquid Glass Sliding Indicator
/// A physics-driven glassmorphic sliding lens featuring dynamic material blur,
/// complete convex dome specular reflection, and multi-layer refractive rim highlights.
struct LiquidGlassLens: View {
    var namespace: Namespace.ID
    var id: String = "ACTIVE_TAB"

    var body: some View {
        ZStack {
            // 1. Base Liquid Glass Material (translucent optical backdrop blur)
            Capsule()
                .fill(.ultraThinMaterial)

            // 2. Liquid Tint Dispersion (Oceanic Gradient with Glass Vibrancy)
            Capsule()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.brightBlue.opacity(0.90), location: 0.0),
                            .init(color: Color.electricBlue.opacity(0.95), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // 3. Smooth Convex Specular Reflection (Hugs the entire capsule dome, fading organically with no cut-off)
            Capsule()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.38), location: 0.0),
                            .init(color: Color.white.opacity(0.10), location: 0.40),
                            .init(color: Color.clear, location: 0.70)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // 4. Complete Refractive Border (Specular Highlight on Full Rim)
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.90), location: 0.0),
                            .init(color: Color.white.opacity(0.45), location: 0.35),
                            .init(color: Color(hex: 0xBDD8E9).opacity(0.35), location: 0.70),
                            .init(color: Color.white.opacity(0.20), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        }
        // 5. Caustic Drop Shadow & Diffuse Glow
        .shadow(color: Color.electricBlue.opacity(0.45), radius: 8, x: 0, y: 3)
        .matchedGeometryEffect(id: id, in: namespace)
    }
}
