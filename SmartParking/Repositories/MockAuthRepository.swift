import Foundation

@MainActor
final class MockAuthRepository: AuthRepository {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
    }

    func login(email: String, password: String) async throws -> User {
        await store.delay()
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            throw AppError.invalidCredentials
        }

        if let existing = store.users.first(where: { $0.email.lowercased() == trimmedEmail.lowercased() }) {
            return existing
        }

        let user = User(name: trimmedEmail.components(separatedBy: "@").first?.capitalized ?? "Driver", email: trimmedEmail, phone: "+91 90000 00000")
        store.users.append(user)
        return user
    }

    func register(name: String, email: String, phone: String, password: String) async throws -> User {
        await store.delay()
        guard !name.isEmpty, !email.isEmpty, !phone.isEmpty, password.count >= 6 else {
            throw AppError.validation("Please fill all fields. Password must be at least 6 characters.")
        }
        if store.users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            throw AppError.validation("An account with this email already exists.")
        }
        let user = User(name: name, email: email, phone: phone)
        store.users.append(user)
        return user
    }

    func logout() async throws {
        await store.delay(ms: 200)
    }

    func sendPasswordReset(email: String) async throws {
        await store.delay(ms: 500)
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.contains("@") else {
            throw AppError.validation("Enter a valid email address.")
        }
    }

    func deleteAccount(userId: String) async throws {
        await store.delay(ms: 400)
        store.users.removeAll { $0.id == userId }
        store.vehicles.removeAll { $0.userId == userId }
        store.bookings.removeAll { $0.userId == userId }
    }
}
