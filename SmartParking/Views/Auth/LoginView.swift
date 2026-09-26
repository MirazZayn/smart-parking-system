import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AuthViewModel()
    @State private var showPassword = false
    @State private var showForgotPassword = false

    var body: some View {
        AuthShell(
            tagline: AuthCopy.tagline,
            title: "Log in",
            subtitle: "Email or phone works fine",
            onBack: { appState.route = .onboarding }
        ) {
            AuthTextField(
                placeholder: "Email or Phone Number",
                text: $viewModel.email,
                icon: "envelope",
                keyboard: .emailAddress
            )

            AuthSecureField(
                placeholder: "Password",
                text: $viewModel.password,
                showPassword: $showPassword
            )

            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .font(Typography.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primary)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(Typography.footnote)
                    .foregroundStyle(Theme.full)
            }

            AuthPrimaryButton(title: "Log In", isLoading: viewModel.isLoading) {
                Task {
                    await viewModel.login(appState: appState)
                    if appState.isAuthenticated { Haptics.success() }
                }
            }

            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundStyle(Theme.textSecondary)
                Button("Register") {
                    appState.authMode = .register
                }
                .fontWeight(.semibold)
                .foregroundStyle(Theme.primary)
            }
            .font(Typography.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(initialEmail: viewModel.email)
        }
    }
}
