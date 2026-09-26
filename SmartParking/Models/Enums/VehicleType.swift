import Foundation

enum VehicleType: String, Codable, CaseIterable, Identifiable {
    case car
    case suv
    case bike
    case ev

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .car: return "Car"
        case .suv: return "SUV"
        case .bike: return "Bike"
        case .ev: return "EV"
        }
    }

    var systemImage: String {
        switch self {
        case .car: return "car.fill"
        case .suv: return "car.side.fill"
        case .bike: return "bicycle"
        case .ev: return "bolt.car.fill"
        }
    }
}
