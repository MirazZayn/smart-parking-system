import Foundation

@MainActor
@Observable
final class AuthViewModel {
    var name = ""
    var email = ""
    var phone = ""
    var password = ""
    var confirmPassword = ""
    var isLoading = false
    var errorMessage: String?
    var infoMessage: String?

    private let authRepository: AuthRepository
    private let sessionService: SessionService

    init(
        authRepository: AuthRepository? = nil,
        sessionService: SessionService? = nil
    ) {
        let container = DIContainer.shared
        self.authRepository = authRepository ?? container.authRepository
        self.sessionService = sessionService ?? container.sessionService
    }

    func login(appState: AppState) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await authRepository.login(email: email, password: password)
            sessionService.begin(userId: user.id)
            appState.signIn(user: user)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register(appState: AppState) async {
        errorMessage = nil
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await authRepository.register(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            sessionService.begin(userId: user.id)
            appState.signIn(user: user)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendPasswordReset() async {
        errorMessage = nil
        infoMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await authRepository.sendPasswordReset(email: email)
            infoMessage = "If an account exists for \(email), a reset link has been sent."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
