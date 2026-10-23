import SwiftUI

/// Floating pill tab bar (Home · Trips · Explore · Profile) with fluid spring motion.
struct RaahaTabBar: View {
    @Binding var selection: AppTab
    @Namespace private var tabNamespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(6)
        .glassCapsule()
        .sensoryFeedback(.selection, trigger: selection)
        .accessibilityElement(children: .contain)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selection == tab
        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.76)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.symbol(selected: isSelected))
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .frame(height: 24)
                Text(tab.title)
                    .font(.raahaCaption2.weight(isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? Color.honeydew : Color.deepSpace.opacity(0.85))
            .frame(maxWidth: .infinity, minHeight: 52)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.deepSpace)
                        .matchedGeometryEffect(id: "ACTIVE_TAB", in: tabNamespace)
                        .shadow(color: Color.deepSpace.opacity(0.2), radius: 6, x: 0, y: 3)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
