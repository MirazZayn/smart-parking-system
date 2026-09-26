import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AuthViewModel
    @State private var didSend = false

    init(initialEmail: String = "") {
        let vm = AuthViewModel()
        vm.email = initialEmail
        _viewModel = State(initialValue: vm)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Enter your account email and we’ll send a password reset link.")
                        .font(Typography.subheadline)
                        .foregroundStyle(Theme.textSecondary)

                    AuthTextField(
                        placeholder: "Email Address",
                        text: $viewModel.email,
                        icon: "envelope",
                        keyboard: .emailAddress
                    )

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(Typography.footnote)
                            .foregroundStyle(Theme.full)
                    }
                    if let info = viewModel.infoMessage {
                        Text(info)
                            .font(Typography.footnote)
                            .foregroundStyle(Theme.available)
                    }

                    PrimaryButton(
                        title: didSend ? "Done" : "Send Reset Link",
                        isLoading: viewModel.isLoading
                    ) {
                        if didSend {
                            dismiss()
                        } else {
                            Task {
                                await viewModel.sendPasswordReset()
                                if viewModel.infoMessage != nil {
                                    didSend = true
                                    Haptics.success()
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .screenBackground()
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
