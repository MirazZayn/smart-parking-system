import Foundation

@MainActor
@Observable
final class ParkingDetailsViewModel {
    var state: ViewState<ParkingLot> = .idle
    var isFavourite = false

    private let parkingId: String
    private let parkingRepository: ParkingRepository

    init(
        parkingId: String,
        parkingRepository: ParkingRepository? = nil
    ) {
        self.parkingId = parkingId
        self.parkingRepository = parkingRepository ?? DIContainer.shared.parkingRepository
    }

    func load() async {
        state = .loading
        do {
            let lot = try await parkingRepository.fetchParking(id: parkingId)
            isFavourite = lot.isFavourite
            state = .loaded(lot)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func toggleFavourite() async {
        do {
            isFavourite = try await parkingRepository.toggleFavourite(parkingId: parkingId)
        } catch {
        }
    }
}
