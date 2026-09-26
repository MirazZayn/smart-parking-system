import SwiftUI

struct BookingConfirmationView: View {
    let booking: Booking
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Booked")
                .font(Typography.caption.weight(.semibold))
                .foregroundStyle(Theme.available)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Theme.available.opacity(0.12))
                .clipShape(Capsule())

            Text(booking.parkingName)
                .font(Typography.title2)
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)

            Text("\(booking.slotLabel) · \(booking.timeRangeLabel)")
                .font(Typography.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 10) {
                row("Booking ID", String(booking.id.prefix(8)).uppercased())
                row("Vehicle", booking.vehicleLabel)
                row("Amount", booking.amountLabel)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                NavigationLink {
                    ParkingPassView(bookingId: booking.id)
                } label: {
                    Text("View pass")
                        .font(Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                SecondaryButton(title: "Done") {
                    onDone()
                }
            }
            .padding(20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
        .font(Typography.subheadline)
    }
}
