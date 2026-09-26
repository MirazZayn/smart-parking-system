import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
    func register(name: String, email: String, phone: String, password: String) async throws -> User
    func logout() async throws
    func sendPasswordReset(email: String) async throws
    func deleteAccount(userId: String) async throws
}

protocol ParkingRepository {
    func fetchNearby(query: String?) async throws -> [ParkingLot]
    func fetchParking(id: String) async throws -> ParkingLot
    func fetchSlots(parkingId: String) async throws -> [ParkingSlot]
    func fetchFavourites() async throws -> [ParkingLot]
    func toggleFavourite(parkingId: String) async throws -> Bool
}

protocol VehicleRepository {
    func fetchVehicles(userId: String) async throws -> [Vehicle]
    func addVehicle(_ vehicle: Vehicle) async throws -> Vehicle
    func updateVehicle(_ vehicle: Vehicle) async throws -> Vehicle
    func deleteVehicle(id: String) async throws
}

protocol BookingRepository {
    func fetchBookings(userId: String, status: BookingStatus?) async throws -> [Booking]
    func createBooking(_ booking: Booking) async throws -> Booking
    func cancelBooking(id: String) async throws -> Booking
    func fetchBooking(id: String) async throws -> Booking
}

protocol UserRepository {
    func fetchUser(id: String) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws
}
