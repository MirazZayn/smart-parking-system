import Foundation

enum BookingStep: Int, CaseIterable {
    case vehicle
    case date
    case startTime
    case duration
    case slot
    case summary

    var title: String {
        switch self {
        case .vehicle: return "Vehicle"
        case .date: return "Date"
        case .startTime: return "Start Time"
        case .duration: return "Duration"
        case .slot: return "Parking Slot"
        case .summary: return "Summary"
        }
    }
}
