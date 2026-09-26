import Foundation

struct Vehicle: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var userId: String
    var type: VehicleType
    var registrationNumber: String
    var brand: String
    var model: String

    init(
        id: String = UUID().uuidString,
        userId: String,
        type: VehicleType,
        registrationNumber: String,
        brand: String,
        model: String
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.registrationNumber = registrationNumber
        self.brand = brand
        self.model = model
    }

    var displayName: String {
        "\(brand) \(model)"
    }
}
