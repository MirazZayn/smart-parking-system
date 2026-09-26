import SwiftUI

struct EditProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditProfileViewModel
    @State private var showSavedToast = false

    init(user: User) {
        _viewModel = State(initialValue: EditProfileViewModel(user: user))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Name and contact used on bookings.")
                    .font(Typography.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                VStack(spacing: 14) {
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
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(Typography.footnote)
                        .foregroundStyle(Theme.full)
                }

                PrimaryButton(title: "Save Changes", isLoading: viewModel.isLoading) {
                    Task {
                        await viewModel.save(appState: appState)
                        if viewModel.didSave {
                            Haptics.success()
                            showSavedToast = true
                            try? await Task.sleep(nanoseconds: 700_000_000)
                            dismiss()
                        }
                    }
                }
            }
            .padding(24)
        }
        .screenBackground()
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .top) {
            if showSavedToast {
                SuccessToast(message: "Profile updated")
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.25), value: showSavedToast)
    }
}
