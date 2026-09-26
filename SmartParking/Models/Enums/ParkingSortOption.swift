import Foundation

enum ParkingSortOption: String, CaseIterable, Identifiable {
    case distance
    case price
    case rating

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .distance: return "Distance"
        case .price: return "Price"
        case .rating: return "Rating"
        }
    }
}
