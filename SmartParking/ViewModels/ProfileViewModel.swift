import Foundation

@MainActor
@Observable
final class ProfileViewModel {
    var user: User?
    var favourites: [ParkingLot] = []
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Self.notificationsKey)
        }
    }
    var isLoading = false
    var errorMessage: String?

    private static let notificationsKey = "notificationsEnabled"
    private var didLoad = false
    private var loadedUserId: String?

    private let parkingRepository: ParkingRepository
    private let userRepository: UserRepository
    private let sessionService: SessionService

    init(
        parkingRepository: ParkingRepository? = nil,
        userRepository: UserRepository? = nil,
        sessionService: SessionService? = nil
    ) {
        let container = DIContainer.shared
        self.parkingRepository = parkingRepository ?? container.parkingRepository
        self.userRepository = userRepository ?? container.userRepository
        self.sessionService = sessionService ?? container.sessionService
        notificationsEnabled = Self.readNotificationsEnabled()
    }

    private static func readNotificationsEnabled() -> Bool {
        if UserDefaults.standard.object(forKey: notificationsKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: notificationsKey)
    }

    func applySessionUser(_ user: User?) {
        self.user = user
    }

    func exitGuest(appState: AppState) {
        sessionService.end(userId: appState.currentUser?.id)
        appState.signOut()
    }

    func load(user: User?) async {
        if user?.id != loadedUserId {
            didLoad = false
            loadedUserId = user?.id
        }
        self.user = user
        guard !didLoad else { return }
        didLoad = true
        notificationsEnabled = Self.readNotificationsEnabled()
        isLoading = true
        defer { isLoading = false }
        do {
            if let user, user.id != "guest-local" {
                self.user = try await userRepository.fetchUser(id: user.id)
            }
            favourites = try await parkingRepository.fetchFavourites()
        } catch {
            errorMessage = error.localizedDescription
            didLoad = false
        }
    }

    func refresh(user: User?) async {
        self.user = user
        isLoading = true
        defer { isLoading = false }
        do {
            if let user, user.id != "guest-local" {
                self.user = try await userRepository.fetchUser(id: user.id)
            }
            favourites = try await parkingRepository.fetchFavourites()
            didLoad = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
