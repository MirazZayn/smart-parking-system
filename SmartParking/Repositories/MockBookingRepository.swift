import Foundation

@MainActor
final class MockBookingRepository: BookingRepository {
    private let store: MockDataStore
    private let sync: BookingsSync

    init(store: MockDataStore, sync: BookingsSync = .shared) {
        self.store = store
        self.sync = sync
    }

    func fetchBookings(userId: String, status: BookingStatus?) async throws -> [Booking] {
        await store.delay()
        let filtered = store.bookings.filter { $0.userId == userId }
        guard let status else { return filtered.sorted { $0.startTime > $1.startTime } }
        return filtered.filter { $0.status == status }.sorted { $0.startTime > $1.startTime }
    }

    func createBooking(_ booking: Booking) async throws -> Booking {
        await store.delay(ms: 600)
        if let slotIndex = store.parkingSlots.firstIndex(where: { $0.id == booking.slotId }) {
            guard store.parkingSlots[slotIndex].isAvailable else {
                throw AppError.bookingFailed("Selected slot is no longer available.")
            }
            store.parkingSlots[slotIndex].isAvailable = false
        }
        if let lotIndex = store.parkingLots.firstIndex(where: { $0.id == booking.parkingId }) {
            store.parkingLots[lotIndex].availableSlots = max(0, store.parkingLots[lotIndex].availableSlots - 1)
        }
        store.bookings.insert(booking, at: 0)
        sync.notifyChanged()
        return booking
    }

    func cancelBooking(id: String) async throws -> Booking {
        await store.delay()
        guard let index = store.bookings.firstIndex(where: { $0.id == id }) else {
            throw AppError.notFound("Booking not found.")
        }
        store.bookings[index].status = .cancelled
        let booking = store.bookings[index]
        if let slotIndex = store.parkingSlots.firstIndex(where: { $0.id == booking.slotId }) {
            store.parkingSlots[slotIndex].isAvailable = true
        }
        if let lotIndex = store.parkingLots.firstIndex(where: { $0.id == booking.parkingId }) {
            let lot = store.parkingLots[lotIndex]
            store.parkingLots[lotIndex].availableSlots = min(lot.totalSlots, lot.availableSlots + 1)
        }
        sync.notifyChanged()
        return booking
    }

    func fetchBooking(id: String) async throws -> Booking {
        await store.delay(ms: 200)
        guard let booking = store.bookings.first(where: { $0.id == id }) else {
            throw AppError.notFound("Booking not found.")
        }
        return booking
    }
}
