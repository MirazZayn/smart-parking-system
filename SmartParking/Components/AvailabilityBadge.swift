import SwiftUI

struct AvailabilityBadge: View {
    let status: AvailabilityStatus

    private var color: Color {
        switch status {
        case .available: return Theme.available
        case .limited: return Theme.limited
        case .full: return Theme.full
        }
    }

    var body: some View {
        Text(status.displayName)
            .font(Typography.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(color)
            .background(color.opacity(0.14))
            .clipShape(Capsule())
    }
}
