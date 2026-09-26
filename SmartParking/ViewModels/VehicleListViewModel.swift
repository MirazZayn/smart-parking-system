import Foundation

@MainActor
@Observable
final class VehicleListViewModel {
    var state: ViewState<[Vehicle]> = .idle
    var errorMessage: String?

    private let vehicleRepository: VehicleRepository
    private var userId = ""

    init(vehicleRepository: VehicleRepository? = nil) {
        self.vehicleRepository = vehicleRepository ?? DIContainer.shared.vehicleRepository
    }

    func load(userId: String) async {
        if self.userId == userId {
            switch state {
            case .loaded, .empty: return
            default: break
            }
        }
        self.userId = userId
        state = .loading
        do {
            let vehicles = try await vehicleRepository.fetchVehicles(userId: userId)
            state = vehicles.isEmpty ? .empty : .loaded(vehicles)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func refresh() async {
        guard !userId.isEmpty else { return }
        state = .loading
        do {
            let vehicles = try await vehicleRepository.fetchVehicles(userId: userId)
            state = vehicles.isEmpty ? .empty : .loaded(vehicles)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func delete(id: String) async {
        do {
            try await vehicleRepository.deleteVehicle(id: id)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
