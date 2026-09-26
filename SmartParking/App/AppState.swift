import Foundation

enum AppRoute: Equatable {
    case splash
    case onboarding
    case auth
    case main
}

enum AuthMode: Equatable {
    case login
    case register
}

enum MainTab: Hashable {
    case home
    case bookings
    case wallet
    case vehicles
    case profile
}

@MainActor
@Observable
final class AppState {
    var route: AppRoute = .splash
    var currentUser: User?
    var selectedTab: MainTab = .home
    var authMode: AuthMode = .login
    var isGuest = false

    private let sessionKey = "isAuthenticated"
    private let userKey = "currentUserJSON"
    private let guestKey = "isGuestSession"

    var isAuthenticated: Bool {
        currentUser != nil && !isGuest
    }

    init() {
        restoreSession()
    }

    func completeSplash() {
        route = isAuthenticated ? .main : .onboarding
    }

    func showLogin() {
        isGuest = false
        authMode = .login
        route = .auth
    }

    func showRegister() {
        isGuest = false
        authMode = .register
        route = .auth
    }

    func continueAsGuest() {
        isGuest = true
        currentUser = User(
            id: "guest-local",
            name: "Guest",
            email: "guest@smartparking.app",
            phone: ""
        )
        DIContainer.shared.sessionService.begin(userId: "guest-local")
        UserDefaults.standard.set(true, forKey: guestKey)
        UserDefaults.standard.set(false, forKey: sessionKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        selectedTab = .home
        route = .main
    }

    func signIn(user: User) {
        isGuest = false
        currentUser = user
        UserDefaults.standard.set(false, forKey: guestKey)
        persistSession(user: user)
        route = .main
    }

    func updateCurrentUser(_ user: User) {
        currentUser = user
        if !isGuest {
            persistSession(user: user)
        }
    }

    func signOut() {
        currentUser = nil
        isGuest = false
        UserDefaults.standard.set(false, forKey: sessionKey)
        UserDefaults.standard.set(false, forKey: guestKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        selectedTab = .home
        authMode = .login
        route = .onboarding
    }

    private func persistSession(user: User) {
        UserDefaults.standard.set(true, forKey: sessionKey)
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    private func restoreSession() {
        if UserDefaults.standard.bool(forKey: guestKey) {
            isGuest = true
            currentUser = User(
                id: "guest-local",
                name: "Guest",
                email: "guest@smartparking.app",
                phone: ""
            )
            DIContainer.shared.sessionService.begin(userId: "guest-local")
            return
        }

        guard UserDefaults.standard.bool(forKey: sessionKey),
              let data = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        currentUser = user
        isGuest = false
        DIContainer.shared.sessionService.begin(userId: user.id)
    }
}
