import SwiftUI

struct SignOutView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = SignOutViewModel()

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)

            VStack(spacing: 18) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(Theme.primary.opacity(0.75))

                Text("Sign out?")
                    .font(Typography.title2)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("You’ll need to log in again to see bookings and wallet.")
                    .font(Typography.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 28)

            Spacer()

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(Typography.footnote)
                    .foregroundStyle(Theme.full)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }

            VStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.logout(appState: appState)
                    }
                } label: {
                    Text("LOG OUT")
                        .font(Typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.primary)
                        .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)

                Button {
                    viewModel.showDeleteConfirm = true
                } label: {
                    HStack(spacing: 8) {
                        Text("DELETE ACCOUNT")
                            .font(Typography.headline)
                        Image(systemName: "arrow.up.right.square")
                            .font(Typography.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .overlay(Rectangle().stroke(Theme.border, lineWidth: 1.5))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Sign out")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.08).ignoresSafeArea()
                ProgressView()
            }
        }
        .confirmationDialog(
            "Delete your account permanently?",
            isPresented: $viewModel.showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                Task { await viewModel.deleteAccount(appState: appState) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Deletes this account on this phone. You’ll have to register again.")
        }
    }
}
