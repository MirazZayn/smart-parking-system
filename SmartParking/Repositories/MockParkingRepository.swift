import Foundation

@MainActor
final class MockParkingRepository: ParkingRepository {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
    }

    func fetchNearby(query: String?) async throws -> [ParkingLot] {
        await store.delay()
        var lots = store.parkingLots.sorted { $0.distance < $1.distance }
        if let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let q = query.lowercased()
            lots = lots.filter {
                $0.name.lowercased().contains(q) || $0.address.lowercased().contains(q)
            }
        }
        return lots.map { lot in
            var copy = lot
            copy.isFavourite = store.favouriteParkingIds.contains(lot.id)
            return copy
        }
    }

    func fetchParking(id: String) async throws -> ParkingLot {
        await store.delay(ms: 250)
        guard var lot = store.parkingLots.first(where: { $0.id == id }) else {
            throw AppError.notFound("Parking location not found.")
        }
        lot.isFavourite = store.favouriteParkingIds.contains(id)
        return lot
    }

    func fetchSlots(parkingId: String) async throws -> [ParkingSlot] {
        await store.delay(ms: 300)
        return store.parkingSlots.filter { $0.lotId == parkingId }
    }

    func fetchFavourites() async throws -> [ParkingLot] {
        await store.delay()
        return store.parkingLots
            .filter { store.favouriteParkingIds.contains($0.id) }
            .map { lot in
                var copy = lot
                copy.isFavourite = true
                return copy
            }
    }

    func toggleFavourite(parkingId: String) async throws -> Bool {
        await store.delay(ms: 150)
        if store.favouriteParkingIds.contains(parkingId) {
            store.favouriteParkingIds.remove(parkingId)
            return false
        } else {
            store.favouriteParkingIds.insert(parkingId)
            return true
        }
    }
}
