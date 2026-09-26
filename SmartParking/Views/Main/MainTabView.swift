import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        VStack(spacing: 0) {
            ZStack {
                tab(.home) {
                    NavigationStack { HomeView() }
                }
                tab(.bookings) {
                    NavigationStack {
                        if appState.isGuest {
                            GuestLockedView(feature: "Bookings")
                        } else {
                            MyBookingsView()
                        }
                    }
                }
                tab(.wallet) {
                    NavigationStack {
                        if appState.isGuest {
                            GuestLockedView(feature: "Wallet")
                        } else {
                            WalletView()
                        }
                    }
                }
                tab(.vehicles) {
                    NavigationStack {
                        if appState.isGuest {
                            GuestLockedView(feature: "Vehicles")
                        } else {
                            VehicleListView()
                        }
                    }
                }
                tab(.profile) {
                    NavigationStack { ProfileView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(appState.currentUser?.id ?? "signed-out")

            CustomTabBar(selection: $appState.selectedTab)
        }
        .background(Theme.background.ignoresSafeArea())
        .tint(Theme.primary)
    }

    @ViewBuilder
    private func tab<Content: View>(
        _ item: MainTab,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let selected = appState.selectedTab == item
        content()
            .opacity(selected ? 1 : 0)
            .allowsHitTesting(selected)
            .accessibilityHidden(!selected)
            .zIndex(selected ? 1 : 0)
    }
}
