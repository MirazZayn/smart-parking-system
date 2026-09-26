import SwiftUI

struct AuthShell<Content: View>: View {
    let tagline: String
    let title: String
    let subtitle: String
    let onBack: () -> Void
    @ViewBuilder var content: Content

    private let heroRatio: CGFloat = 0.5

    var body: some View {
        GeometryReader { geo in
            let heroHeight = max(180, geo.size.height * heroRatio)
            let bottomInset = geo.safeAreaInsets.bottom

            ZStack(alignment: .topLeading) {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    hero(width: geo.size.width, height: heroHeight)

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(title)
                                    .font(Typography.title2)
                                    .foregroundStyle(Theme.textPrimary)
                                Text(subtitle)
                                    .font(Typography.subheadline)
                                    .foregroundStyle(Theme.textSecondary)
                            }

                            content
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 28)
                        .padding(.bottom, max(40, bottomInset + 48))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color.white)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 28,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 28,
                            style: .continuous
                        )
                    )
                    .offset(y: -20)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)

                backButton
                    .padding(.top, 56)
                    .padding(.leading, 20)
                    .zIndex(10)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private func hero(width: CGFloat, height: CGFloat) -> some View {
        Image("AuthHero")
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.25),
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.55)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .bottom) {
                Text(tagline)
                    .font(Typography.tagline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 6, y: 2)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity)
            }
    }

    private var backButton: some View {
        Button(action: onBack) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Color.black.opacity(0.4))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}
