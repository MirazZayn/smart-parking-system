import SwiftUI

struct GuestRestrictionBanner: View {
    @Environment(AppState.self) private var appState

    var message: String = "You’re browsing as a guest. Sign in to book, pay, and save vehicles."

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(Typography.title3)
                    .foregroundStyle(Theme.primary)
                Text(message)
                    .font(Typography.footnote)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                Button("Log In") { appState.showLogin() }
                    .font(Typography.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Theme.primary)
                    .clipShape(Capsule())

                Button("Register") { appState.showRegister() }
                    .font(Typography.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Theme.primary.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.primary.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Theme.primary.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct GuestLockedView: View {
    let feature: String

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "lock.fill")
                .font(.system(size: 36))
                .foregroundStyle(Theme.primary)

            Text("Sign in to see \(feature.lowercased())")
                .font(Typography.title3)
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)

            Text("Guest mode is browse-only for now.")
                .font(Typography.subheadline)
                .foregroundStyle(Theme.textSecondary)

            GuestRestrictionBanner(message: "Log in or create an account to continue.")
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
    }
}
