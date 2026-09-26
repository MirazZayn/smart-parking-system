import SwiftUI

struct StatChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(Typography.caption)
            Text(text)
                .font(Typography.caption)
        }
        .foregroundStyle(Theme.textSecondary)
    }
}
