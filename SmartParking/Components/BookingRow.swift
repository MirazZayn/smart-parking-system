import SwiftUI

struct BookingRow: View {
    let booking: Booking

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(booking.parkingName)
                    .font(Typography.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(booking.status.displayName)
                    .font(Typography.caption)
                    .foregroundStyle(statusColor)
            }
            Text(booking.parkingAddress)
                .font(Typography.caption)
                .foregroundStyle(Theme.textSecondary)
            Text(booking.timeRangeLabel)
                .font(Typography.subheadline)
                .foregroundStyle(Theme.textSecondary)
            HStack {
                Text(booking.slotLabel)
                Spacer()
                Text(booking.amountLabel)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.primary)
            }
            .font(Typography.subheadline)
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch booking.status {
        case .upcoming: return Theme.accent
        case .active: return Theme.available
        case .completed: return Theme.textSecondary
        case .cancelled: return Theme.full
        }
    }
}
