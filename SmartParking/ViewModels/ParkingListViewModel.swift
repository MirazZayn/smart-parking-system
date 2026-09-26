import Foundation

@MainActor
@Observable
final class ParkingListViewModel {
    var state: ViewState<[ParkingLot]> = .idle
    var searchText = ""
    var selectedFilter: AvailabilityStatus?
    var sortOption: ParkingSortOption = .distance

    private let parkingRepository: ParkingRepository
    private var allLots: [ParkingLot] = []

    init(
        initialQuery: String = "",
        parkingRepository: ParkingRepository? = nil
    ) {
        self.searchText = initialQuery
        self.parkingRepository = parkingRepository ?? DIContainer.shared.parkingRepository
    }

    func load() async {
        state = .loading
        do {
            allLots = try await parkingRepository.fetchNearby(query: searchText.isEmpty ? nil : searchText)
            apply()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func refresh() async {
        await load()
    }

    func search() async {
        await load()
    }

    func setFilter(_ status: AvailabilityStatus?) async {
        selectedFilter = status
        apply()
    }

    func setSort(_ option: ParkingSortOption) {
        sortOption = option
        apply()
    }

    private func apply() {
        var result = allLots
        if let selectedFilter {
            result = result.filter { $0.availabilityStatus == selectedFilter }
        }
        switch sortOption {
        case .distance:
            result.sort { $0.distance < $1.distance }
        case .price:
            result.sort { $0.pricePerHour < $1.pricePerHour }
        case .rating:
            result.sort { $0.rating > $1.rating }
        }
        state = result.isEmpty ? .empty : .loaded(result)
    }
}
