import Foundation

@MainActor
@Observable
final class BookingsViewModel {
    var selectedStatus: BookingStatus = .upcoming
    var state: ViewState<[Booking]> = .idle

    private let bookingRepository: BookingRepository
    private let walletStore: WalletStore
    private let bookingsSync: BookingsSync
    private var userId = ""
    private var lastSyncRevision = -1

    init(
        bookingRepository: BookingRepository? = nil,
        walletStore: WalletStore? = nil,
        bookingsSync: BookingsSync? = nil
    ) {
        let container = DIContainer.shared
        self.bookingRepository = bookingRepository ?? container.bookingRepository
        self.walletStore = walletStore ?? container.walletStore
        self.bookingsSync = bookingsSync ?? container.bookingsSync
    }

    func load(userId: String) async {
        let syncChanged = lastSyncRevision != bookingsSync.revision
        if self.userId == userId && !syncChanged {
            switch state {
            case .loaded, .empty: return
            default: break
            }
        }
        self.userId = userId
        await fetch()
    }

    func refresh() async {
        guard !userId.isEmpty else { return }
        await fetch()
    }

    func select(_ status: BookingStatus) async {
        selectedStatus = status
        guard !userId.isEmpty else { return }
        await fetch()
    }

    func cancel(id: String) async {
        do {
            let cancelled = try await bookingRepository.cancelBooking(id: id)
            walletStore.refund(
                amount: cancelled.amount,
                title: "Refund · \(cancelled.parkingName)"
            )
            await refresh()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func fetch() async {
        state = .loading
        do {
            let bookings = try await bookingRepository.fetchBookings(userId: userId, status: selectedStatus)
            state = bookings.isEmpty ? .empty : .loaded(bookings)
            lastSyncRevision = bookingsSync.revision
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
