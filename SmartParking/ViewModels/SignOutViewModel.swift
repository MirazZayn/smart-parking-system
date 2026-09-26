import Foundation

@MainActor
@Observable
final class SignOutViewModel {
    var isLoading = false
    var errorMessage: String?
    var showDeleteConfirm = false

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

    func logout(appState: AppState) async {
        isLoading = true
        defer { isLoading = false }
        let userId = appState.currentUser?.id
        try? await authRepository.logout()
        sessionService.end(userId: userId)
        appState.signOut()
    }

    func deleteAccount(appState: AppState) async {
        guard let userId = appState.currentUser?.id else { return }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await authRepository.deleteAccount(userId: userId)
            sessionService.end(userId: userId)
            appState.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
