import SwiftUI

struct ParkingCard: View {
    let lot: ParkingLot

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(lot.galleryImages.first ?? "ParkingGarage1")
                .resizable()
                .scaledToFill()
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lot.name)
                            .font(Typography.headline)
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(2)
                        Text(lot.address)
                            .font(Typography.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 8)
                    AvailabilityBadge(status: lot.availabilityStatus)
                }

                HStack(spacing: 12) {
                    StatChip(icon: "location", text: lot.distanceLabel)
                    StatChip(icon: "star.fill", text: String(format: "%.1f", lot.rating))
                    Spacer(minLength: 4)
                    Text(lot.priceLabel)
                        .font(Typography.caption.weight(.bold))
                        .foregroundStyle(Theme.primary)
                }
            }
        }
        .padding(14)
        .elevatedCard(radius: 16)
    }
}
