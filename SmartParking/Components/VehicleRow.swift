import SwiftUI

struct VehicleRow: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: vehicle.type.systemImage)
                .font(Typography.title3)
                .foregroundStyle(Theme.primary)
                .frame(width: 44, height: 44)
                .background(Theme.primary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.displayName)
                    .font(Typography.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text(vehicle.registrationNumber)
                    .font(Typography.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                Text(vehicle.type.displayName)
                    .font(Typography.caption)
                    .foregroundStyle(Theme.primary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(Typography.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}
