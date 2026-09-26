import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            switch appState.route {
            case .splash:
                SplashView {
                    appState.completeSplash()
                }
            case .onboarding:
                OnboardingView()
            case .auth:
                AuthContainerView()
            case .main:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.28), value: appState.route)
    }
}
