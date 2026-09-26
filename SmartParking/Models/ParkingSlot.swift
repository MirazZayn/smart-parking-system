import Foundation

struct ParkingSlot: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var lotId: String
    var label: String
    var isAvailable: Bool
    var level: String

    init(
        id: String = UUID().uuidString,
        lotId: String,
        label: String,
        isAvailable: Bool,
        level: String = "Ground"
    ) {
        self.id = id
        self.lotId = lotId
        self.label = label
        self.isAvailable = isAvailable
        self.level = level
    }
}
