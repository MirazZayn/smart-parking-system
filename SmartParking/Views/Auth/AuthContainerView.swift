import SwiftUI

struct AuthContainerView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            switch appState.authMode {
            case .login:
                LoginView()
            case .register:
                RegisterView()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: appState.authMode)
    }
}
