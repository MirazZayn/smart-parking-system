import Foundation

@MainActor
final class MockUserRepository: UserRepository {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
    }

    func fetchUser(id: String) async throws -> User {
        await store.delay(ms: 200)
        guard let user = store.users.first(where: { $0.id == id }) else {
            throw AppError.notFound("User not found.")
        }
        return user
    }

    func updateUser(_ user: User) async throws -> User {
        await store.delay()
        guard let index = store.users.firstIndex(where: { $0.id == user.id }) else {
            throw AppError.notFound("User not found.")
        }
        store.users[index] = user
        return user
    }

    func deleteUser(id: String) async throws {
        await store.delay(ms: 300)
        store.users.removeAll { $0.id == id }
    }
}
