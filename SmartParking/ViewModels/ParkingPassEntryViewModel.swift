import Foundation

@MainActor
@Observable
final class ParkingPassEntryViewModel {
    var bookingId: String?
    var isLoading = false

    private let bookingRepository: BookingRepository

    init(bookingRepository: BookingRepository? = nil) {
        self.bookingRepository = bookingRepository ?? DIContainer.shared.bookingRepository
    }

    func load(userId: String?) async {
        isLoading = true
        defer { isLoading = false }

        guard let userId else {
            bookingId = nil
            return
        }

        do {
            let bookings = try await bookingRepository.fetchBookings(userId: userId, status: nil)
            bookingId = bookings.first(where: { $0.status == .active })?.id
                ?? bookings.first(where: { $0.status == .upcoming })?.id
        } catch {
            bookingId = nil
        }
    }
}
