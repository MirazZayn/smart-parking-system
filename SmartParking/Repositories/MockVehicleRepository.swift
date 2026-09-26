import Foundation

@MainActor
final class MockVehicleRepository: VehicleRepository {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
    }

    func fetchVehicles(userId: String) async throws -> [Vehicle] {
        await store.delay()
        return store.vehicles.filter { $0.userId == userId }
    }

    func addVehicle(_ vehicle: Vehicle) async throws -> Vehicle {
        await store.delay()
        guard !vehicle.registrationNumber.isEmpty, !vehicle.brand.isEmpty, !vehicle.model.isEmpty else {
            throw AppError.validation("Please complete all vehicle fields.")
        }
        store.vehicles.append(vehicle)
        return vehicle
    }

    func updateVehicle(_ vehicle: Vehicle) async throws -> Vehicle {
        await store.delay()
        guard let index = store.vehicles.firstIndex(where: { $0.id == vehicle.id }) else {
            throw AppError.notFound("Vehicle not found.")
        }
        store.vehicles[index] = vehicle
        return vehicle
    }

    func deleteVehicle(id: String) async throws {
        await store.delay(ms: 250)
        store.vehicles.removeAll { $0.id == id }
    }
}
