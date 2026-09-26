import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var appear = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("OnboardingHero")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.45),
                        Color.black.opacity(0.12),
                        Color.black.opacity(0.65)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 0) {
                    headline
                        .padding(.top, 56)

                    Spacer()

                    actions
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 14)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appear = true
            }
        }
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: 12) {
            (
                Text("Skip the hunt.\n")
                    .foregroundColor(.white)
                + Text("Reserve a bay.")
                    .foregroundColor(Theme.mint)
            )
            .font(Typography.display)

            Text("See what’s free nearby and hold a spot before you arrive.")
                .font(Typography.body)
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                appState.showLogin()
            } label: {
                HStack(spacing: 8) {
                    Text("Log in")
                        .font(Typography.headline)
                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Theme.mint)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button {
                appState.showRegister()
            } label: {
                Text("Create account")
                    .font(Typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(Color.white.opacity(0.14))
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.9), lineWidth: 1.5)
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button {
                appState.continueAsGuest()
            } label: {
                (
                    Text("Continue as ")
                        .foregroundColor(.white.opacity(0.9))
                    + Text("Guest")
                        .underline()
                        .foregroundColor(Theme.mint)
                )
                .font(Typography.subheadline)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }
}
