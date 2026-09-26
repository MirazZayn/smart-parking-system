import SwiftUI

struct BookingDetailView: View {
    let booking: Booking
    var onCancel: () -> Void
    @State private var confirmCancel = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(booking.parkingName)
                    .font(Typography.title2)
                Text(booking.parkingAddress)
                    .font(Typography.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                group {
                    row("Status", booking.status.displayName)
                    row("Vehicle", booking.vehicleLabel)
                    row("Slot", booking.slotLabel)
                    row("When", booking.timeRangeLabel)
                    row("Duration", "\(booking.durationHours) hour(s)")
                    row("Amount", booking.amountLabel)
                    row("Booking ID", booking.id)
                }

                NavigationLink {
                    ParkingPassView(bookingId: booking.id)
                } label: {
                    Label("Open Parking Pass", systemImage: "qrcode")
                        .font(Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.primary.opacity(0.1))
                        .foregroundStyle(Theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                if booking.status == .upcoming || booking.status == .active {
                    Button(role: .destructive) {
                        confirmCancel = true
                    } label: {
                        Text("Cancel Booking")
                            .font(Typography.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
            }
            .padding(20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Booking")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Cancel this booking?", isPresented: $confirmCancel, titleVisibility: .visible) {
            Button("Cancel Booking", role: .destructive, action: onCancel)
            Button("Keep Booking", role: .cancel) {}
        }
    }

    private func group<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10, content: content)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .fontWeight(.medium)
        }
        .font(Typography.subheadline)
    }
}
