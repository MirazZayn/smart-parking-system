import Foundation

@MainActor
final class DIContainer {
    static let shared = DIContainer()

    let authRepository: AuthRepository
    let parkingRepository: ParkingRepository
    let vehicleRepository: VehicleRepository
    let bookingRepository: BookingRepository
    let userRepository: UserRepository
    let walletStore: WalletStore
    let sessionService: SessionService
    let bookingsSync: BookingsSync

    private init(
        store: MockDataStore = .shared,
        walletStore: WalletStore = .shared,
        sessionService: SessionService = .shared,
        bookingsSync: BookingsSync = .shared
    ) {
        authRepository = MockAuthRepository(store: store)
        parkingRepository = MockParkingRepository(store: store)
        vehicleRepository = MockVehicleRepository(store: store)
        bookingRepository = MockBookingRepository(store: store, sync: bookingsSync)
        userRepository = MockUserRepository(store: store)
        self.walletStore = walletStore
        self.sessionService = sessionService
        self.bookingsSync = bookingsSync
    }
}
