import SwiftUI

/// Floating translucent capsule shared by Home, Trips, Explore, and Profile.
struct RaahaTabBar: View {
    @Binding var selection: AppTab
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var selectionSpace

    var body: some View {
        HStack(spacing: 2) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(5)
        .background { TabBarGlass() }
        .overlay {
            Capsule().stroke(Color.white.opacity(0.62), lineWidth: 0.8)
        }
        .shadow(color: Color(hex: 0x173D5C).opacity(0.14), radius: 16, y: 8)
        .sensoryFeedback(.selection, trigger: selection)
        .accessibilityElement(children: .contain)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selection == tab
        return Button {
            guard selection != tab else { return }
            if reduceMotion {
                selection = tab
            } else {
                withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) {
                    selection = tab
                }
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.symbol(selected: isSelected))
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .scaleEffect(isSelected ? 1.08 : 1)
                    .frame(height: 24)
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
            }
            .foregroundStyle(isSelected ? Color(hex: 0x173D5C) : Color(hex: 0x326F89))
            .frame(maxWidth: .infinity, minHeight: 52)
            .background {
                if isSelected {
                    SelectedTabGlass()
                        .matchedGeometryEffect(id: "raaha-tab", in: selectionSpace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.34, dampingFraction: 0.72), value: isSelected)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct TabBarGlass: View {
    var body: some View {
        ZStack {
            Capsule().fill(.ultraThinMaterial)
            Capsule().fill(Color.white.opacity(0.38))
            if #available(iOS 26, *) {
                Capsule()
                    .fill(Color.clear)
                    .glassEffect(.regular.tint(Color.white.opacity(0.28)), in: Capsule())
            }
        }
    }
}

private struct SelectedTabGlass: View {
    var body: some View {
        ZStack {
            if #available(iOS 26, *) {
                Capsule()
                    .fill(Color.clear)
                    .glassEffect(.regular.tint(Color.white.opacity(0.46)), in: Capsule())
            } else {
                Capsule().fill(.ultraThinMaterial)
                Capsule().fill(Color.white.opacity(0.42))
            }
            Capsule().stroke(Color.white.opacity(0.85), lineWidth: 0.8)
        }
        .shadow(color: Color(hex: 0x75BBD0).opacity(0.22), radius: 6, y: 2)
    }
}
