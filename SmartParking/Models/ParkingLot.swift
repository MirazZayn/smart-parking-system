import Foundation

struct ParkingLot: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var distance: Double
    var rating: Double
    var totalSlots: Int
    var availableSlots: Int
    var pricePerHour: Double
    var openingHours: String
    var amenities: [String]
    var isFavourite: Bool
    var imageNames: [String]

    var availabilityStatus: AvailabilityStatus {
        AvailabilityStatus.from(available: availableSlots, total: totalSlots)
    }

    var distanceLabel: String {
        if distance < 1 {
            return String(format: "%.0f m", distance * 1000)
        }
        return String(format: "%.1f km", distance)
    }

    var priceLabel: String {
        "\(DateFormatters.currencyString(from: pricePerHour))/hr"
    }

    var cityLabel: String {
        let parts = address.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return parts.last ?? address
    }

    var amenitiesLine: String {
        amenities.prefix(3).joined(separator: " · ")
    }

    var galleryImages: [String] {
        imageNames.isEmpty ? ["ParkingGarage1"] : imageNames
    }
}
