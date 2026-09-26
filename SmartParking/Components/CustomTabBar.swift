import SwiftUI

struct CustomTabBar: View {
    @Binding var selection: MainTab
    @Namespace private var indicatorNamespace

    private let inactiveColor = Color(red: 0.18, green: 0.20, blue: 0.28)
    private let activeColor = Theme.primary

    private let tabs: [(MainTab, String, String)] = [
        (.home, "Home", "house"),
        (.bookings, "Bookings", "calendar"),
        (.wallet, "Wallet", "creditcard"),
        (.vehicles, "Vehicles", "car"),
        (.profile, "Profile", "person")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.0) { tab, title, icon in
                tabButton(tab: tab, title: title, icon: icon)
            }
        }
        .padding(.bottom, 2)
        .background {
            Color.white
                .shadow(color: Color.black.opacity(0.06), radius: 8, y: -1)
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 0.5)
        }
    }

    private func tabButton(tab: MainTab, title: String, icon: String) -> some View {
        let isSelected = selection == tab

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .regular))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(isSelected ? activeColor : inactiveColor)
                    .frame(height: 26)

                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? activeColor : inactiveColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .padding(.bottom, 6)
            .contentShape(Rectangle())
            .overlay(alignment: .top) {
                ZStack {
                    if isSelected {
                        Rectangle()
                            .fill(activeColor)
                            .frame(width: 28, height: 3)
                            .matchedGeometryEffect(id: "tabIndicator", in: indicatorNamespace)
                    }
                }
                .frame(height: 3)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
