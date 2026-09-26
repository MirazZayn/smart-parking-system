import Foundation

@MainActor
@Observable
final class HomeViewModel {
    var state: ViewState<[ParkingLot]> = .idle
    var searchText = ""
    var greetingName = "there"

    private var didLoad = false
    private let parkingRepository: ParkingRepository

    init(parkingRepository: ParkingRepository? = nil) {
        self.parkingRepository = parkingRepository ?? DIContainer.shared.parkingRepository
    }

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let part: String
        switch hour {
        case 5..<12: part = "Good Morning"
        case 12..<17: part = "Good Afternoon"
        default: part = "Good Evening"
        }
        return "\(part), \(greetingName)"
    }

    var filteredLots: [ParkingLot] {
        guard case .loaded(let lots) = state else { return [] }
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return lots }
        return lots.filter {
            $0.name.localizedCaseInsensitiveContains(q) ||
            $0.address.localizedCaseInsensitiveContains(q)
        }
    }

    func load(userName: String?) async {
        greetingName = userName?.components(separatedBy: " ").first ?? "there"
        guard !didLoad else { return }
        didLoad = true
        state = .loading
        do {
            let lots = try await parkingRepository.fetchNearby(query: nil)
            state = lots.isEmpty ? .empty : .loaded(Array(lots.prefix(5)))
        } catch {
            state = .error(error.localizedDescription)
            didLoad = false
        }
    }

    func refresh(userName: String?) async {
        greetingName = userName?.components(separatedBy: " ").first ?? "there"
        state = .loading
        do {
            let lots = try await parkingRepository.fetchNearby(query: nil)
            state = lots.isEmpty ? .empty : .loaded(Array(lots.prefix(5)))
            didLoad = true
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
