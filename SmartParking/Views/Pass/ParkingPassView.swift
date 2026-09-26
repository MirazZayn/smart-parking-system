import SwiftUI

struct ParkingPassView: View {
    @State private var viewModel: ParkingPassViewModel

    init(bookingId: String) {
        _viewModel = State(initialValue: ParkingPassViewModel(bookingId: bookingId))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                LoadingView(message: "Loading pass…")
            case .empty:
                EmptyStateView(title: "Pass unavailable", systemImage: "qrcode")
            case .error(let message):
                ErrorStateView(message: message) {
                    Task { await viewModel.load() }
                }
            case .loaded(let booking):
                passContent(booking)
            }
        }
        .screenBackground()
        .navigationTitle("Parking Pass")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private func passContent(_ booking: Booking) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Parking pass")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.primary)
                    Text(booking.parkingName)
                        .font(Typography.title2)
                        .multilineTextAlignment(.center)
                    Text(booking.status.displayName.uppercased())
                        .font(Typography.caption)
                        .foregroundStyle(Theme.primary)
                }

                if let qr = QRCodeGenerator.image(from: viewModel.passPayload(for: booking)) {
                    Image(uiImage: qr)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 12) {
                    passRow("Booking ID", booking.id)
                    passRow("Parking ID", booking.parkingId)
                    passRow("Slot ID", booking.slotLabel)
                    passRow("Vehicle", booking.vehicleLabel)
                    passRow("Date / Time", booking.timeRangeLabel)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.border, lineWidth: 1)
                )
            }
            .padding(24)
        }
    }

    private func passRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(Typography.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .textSelection(.enabled)
        }
    }
}
