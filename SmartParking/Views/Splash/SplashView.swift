import SwiftUI

struct SplashView: View {
    let onFinished: () -> Void

    @State private var imageOpacity: Double = 0
    @State private var brandOpacity: Double = 0
    @State private var exitOpacity: Double = 1

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("SplashHero")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(imageOpacity)

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.5),
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.55)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(imageOpacity)

                VStack(spacing: 16) {
                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Theme.primary)
                            .frame(width: 68, height: 68)

                        Text("P")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    Text("Smart Parking")
                        .font(Typography.display)
                        .foregroundStyle(.white)

                    Text("Park without circling")
                        .font(Typography.subheadline)
                        .foregroundStyle(.white.opacity(0.88))

                    Spacer()
                    Spacer()
                }
                .opacity(brandOpacity)
                .padding(.horizontal, 28)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .opacity(exitOpacity)
        .onAppear { runSplashSequence() }
    }

    private func runSplashSequence() {
        withAnimation(.easeOut(duration: 0.7)) {
            imageOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
            brandOpacity = 1
        }

        Task {
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            withAnimation(.easeIn(duration: 0.3)) {
                exitOpacity = 0
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
            onFinished()
        }
    }
}
