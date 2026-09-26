import SwiftUI

struct RegisterView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AuthViewModel()
    @State private var showPassword = false
    @State private var showConfirm = false

    var body: some View {
        AuthShell(
            tagline: AuthCopy.tagline,
            title: "Create account",
            subtitle: "Name, email, and phone",
            onBack: { appState.route = .onboarding }
        ) {
            AuthTextField(placeholder: "Full Name", text: $viewModel.name, icon: "person")
            AuthTextField(
                placeholder: "Email Address",
                text: $viewModel.email,
                icon: "envelope",
                keyboard: .emailAddress
            )
            AuthTextField(
                placeholder: "Phone Number",
                text: $viewModel.phone,
                icon: "phone",
                keyboard: .phonePad
            )
            AuthSecureField(
                placeholder: "Password",
                text: $viewModel.password,
                showPassword: $showPassword
            )
            AuthSecureField(
                placeholder: "Confirm Password",
                text: $viewModel.confirmPassword,
                showPassword: $showConfirm
            )

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(Typography.footnote)
                    .foregroundStyle(Theme.full)
            }

            AuthPrimaryButton(title: "Register", isLoading: viewModel.isLoading) {
                Task {
                    await viewModel.register(appState: appState)
                    if appState.isAuthenticated { Haptics.success() }
                }
            }
            .padding(.top, 8)

            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundStyle(Theme.textSecondary)
                Button("Log In") {
                    appState.authMode = .login
                }
                .fontWeight(.semibold)
                .foregroundStyle(Theme.primary)
            }
            .font(Typography.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
    }
}
