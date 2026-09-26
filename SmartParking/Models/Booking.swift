import Foundation

struct Booking: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var userId: String
    var parkingId: String
    var vehicleId: String
    var slotId: String
    var startTime: Date
    var endTime: Date
    var durationHours: Int
    var amount: Double
    var status: BookingStatus
    var createdAt: Date

    var parkingName: String
    var parkingAddress: String
    var vehicleLabel: String
    var slotLabel: String

    init(
        id: String = UUID().uuidString,
        userId: String,
        parkingId: String,
        vehicleId: String,
        slotId: String,
        startTime: Date,
        endTime: Date,
        durationHours: Int,
        amount: Double,
        status: BookingStatus,
        createdAt: Date = Date(),
        parkingName: String,
        parkingAddress: String,
        vehicleLabel: String,
        slotLabel: String
    ) {
        self.id = id
        self.userId = userId
        self.parkingId = parkingId
        self.vehicleId = vehicleId
        self.slotId = slotId
        self.startTime = startTime
        self.endTime = endTime
        self.durationHours = durationHours
        self.amount = amount
        self.status = status
        self.createdAt = createdAt
        self.parkingName = parkingName
        self.parkingAddress = parkingAddress
        self.vehicleLabel = vehicleLabel
        self.slotLabel = slotLabel
    }

    var amountLabel: String {
        DateFormatters.currencyString(from: amount)
    }

    var timeRangeLabel: String {
        "\(DateFormatters.displayDateTime.string(from: startTime)) – \(DateFormatters.displayTime.string(from: endTime))"
    }
}
