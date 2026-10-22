import SwiftUI

/// Floating pill tab bar (Home · Trips · Explore · Profile).
struct RaahaTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(6)
        .glassCapsule()
        .accessibilityElement(children: .contain)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selection == tab
        return Button {
            withAnimation(.snappy(duration: 0.25)) { selection = tab }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.symbol(selected: isSelected))
                    .font(.raahaTitle2)
                    .frame(height: 26)
                Text(tab.title)
                    .font(.raahaCaption2.weight(.semibold))
            }
            .foregroundStyle(isSelected ? Color.honeydew : Color.deepSpace)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background {
                if isSelected {
                    Capsule().fill(Color.deepSpace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
