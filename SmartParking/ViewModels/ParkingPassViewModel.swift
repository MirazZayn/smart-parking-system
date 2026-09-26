import Foundation

@MainActor
@Observable
final class ParkingPassViewModel {
    var state: ViewState<Booking> = .idle

    private let bookingId: String
    private let bookingRepository: BookingRepository

    init(
        bookingId: String,
        bookingRepository: BookingRepository? = nil
    ) {
        self.bookingId = bookingId
        self.bookingRepository = bookingRepository ?? DIContainer.shared.bookingRepository
    }

    func load() async {
        state = .loading
        do {
            let booking = try await bookingRepository.fetchBooking(id: bookingId)
            state = .loaded(booking)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func passPayload(for booking: Booking) -> String {
        "SMARTPARK|\(booking.id)|\(booking.parkingId)|\(booking.slotId)|\(booking.vehicleId)"
    }
}
