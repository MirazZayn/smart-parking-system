import SwiftUI

@main
struct SmartParkingApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .tint(Theme.primary)
                .font(Typography.body)
        }
    }
}
