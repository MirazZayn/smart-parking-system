import Foundation

enum AvailabilityStatus: String, Codable, CaseIterable, Identifiable {
    case available
    case limited
    case full

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .available: return "Available"
        case .limited: return "Limited"
        case .full: return "Full"
        }
    }

    static func from(available: Int, total: Int) -> AvailabilityStatus {
        guard total > 0 else { return .full }
        let ratio = Double(available) / Double(total)
        if available == 0 { return .full }
        if ratio <= 0.25 { return .limited }
        return .available
    }
}
