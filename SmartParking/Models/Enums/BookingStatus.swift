import Foundation

enum BookingStatus: String, Codable, CaseIterable, Identifiable {
    case upcoming
    case active
    case completed
    case cancelled

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .upcoming: return "Upcoming"
        case .active: return "Active"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}
