import Foundation

@MainActor
@Observable
final class EditProfileViewModel {
    var name = ""
    var email = ""
    var phone = ""
    var isLoading = false
    var errorMessage: String?
    var didSave = false

    private let userRepository: UserRepository
    private let userId: String
    private let createdAt: Date

    init(
        user: User,
        userRepository: UserRepository? = nil
    ) {
        self.userId = user.id
        self.createdAt = user.createdAt
        self.userRepository = userRepository ?? DIContainer.shared.userRepository
        self.name = user.name
        self.email = user.email
        self.phone = user.phone
    }

    func save(appState: AppState) async {
        errorMessage = nil
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty, !trimmedPhone.isEmpty else {
            errorMessage = "Please fill in all personal details."
            return
        }

        isLoading = true
        defer { isLoading = false }

        let updated = User(
            id: userId,
            name: trimmedName,
            email: trimmedEmail,
            phone: trimmedPhone,
            createdAt: createdAt
        )

        do {
            let saved = try await userRepository.updateUser(updated)
            appState.updateCurrentUser(saved)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
