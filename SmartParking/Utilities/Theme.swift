import SwiftUI

enum Theme {
    static let primary = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let primaryDark = Color(red: 0.05, green: 0.12, blue: 0.28)
    static let accent = Color(red: 0.30, green: 0.58, blue: 1.0)
    static let mint = Color(red: 0.55, green: 0.97, blue: 0.71)
    static let brandBlue = Color(red: 0.40, green: 0.65, blue: 1.0)

    static let background = Color(red: 0.953, green: 0.961, blue: 0.976)
    static let surface = Color.white
    static let textPrimary = Color(red: 0.10, green: 0.14, blue: 0.22)
    static let textSecondary = Color(red: 0.42, green: 0.46, blue: 0.54)
    static let available = Color(red: 0.20, green: 0.72, blue: 0.48)
    static let limited = Color(red: 0.95, green: 0.68, blue: 0.22)
    static let full = Color(red: 0.86, green: 0.28, blue: 0.32)
    static let border = Color(red: 0.88, green: 0.90, blue: 0.93)

    static let heroOverlay = LinearGradient(
        colors: [
            Color.black.opacity(0.48),
            Color.black.opacity(0.12),
            Color.black.opacity(0.62)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardGradient = LinearGradient(
        colors: [primaryDark, primary, brandBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum Typography {
    static let display = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let callout = Font.system(size: 15, weight: .medium, design: .default)
    static let subheadline = Font.system(size: 14, weight: .medium, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
    static let tagline = Font.system(size: 17, weight: .semibold, design: .rounded)
}

extension View {
    func screenBackground() -> some View {
        background(Theme.background.ignoresSafeArea())
    }

    func elevatedCard(radius: CGFloat = 16) -> some View {
        self
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Theme.border, lineWidth: 1)
            )
            .shadow(color: Theme.primaryDark.opacity(0.06), radius: 12, y: 4)
    }
}
