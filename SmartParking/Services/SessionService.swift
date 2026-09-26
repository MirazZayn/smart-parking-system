import Foundation

@MainActor
final class SessionService {
    static let shared = SessionService()

    private static let lastUserKey = "lastSessionUserId"
    private static let notificationsKey = "notificationsEnabled"

    private let walletStore: WalletStore
    private let dataStore: MockDataStore

    private init(
        walletStore: WalletStore = .shared,
        dataStore: MockDataStore = .shared
    ) {
        self.walletStore = walletStore
        self.dataStore = dataStore
    }

    func begin(userId: String) {
        let previous = UserDefaults.standard.string(forKey: Self.lastUserKey)
        if previous != userId {
            resetLocalData(for: previous)
        }
        UserDefaults.standard.set(userId, forKey: Self.lastUserKey)
    }

    func end(userId: String?) {
        resetLocalData(for: userId)
        UserDefaults.standard.removeObject(forKey: Self.lastUserKey)
    }

    private func resetLocalData(for userId: String?) {
        walletStore.reset()
        if let userId, userId != "guest-local" {
            dataStore.clearUserOwnedData(userId: userId)
        } else {
            dataStore.clearFavourites()
        }
        UserDefaults.standard.removeObject(forKey: Self.notificationsKey)
    }
}
