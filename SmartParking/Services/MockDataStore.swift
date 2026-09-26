import Foundation

@MainActor
final class MockDataStore {
    static let shared = MockDataStore()

    var users: [User]
    var vehicles: [Vehicle]
    var parkingLots: [ParkingLot]
    var parkingSlots: [ParkingSlot]
    var bookings: [Booking]
    var favouriteParkingIds: Set<String>

    private init() {
        let userId = "user-demo-001"
        let demoUser = User(
            id: userId,
            name: "Alex Morgan",
            email: "alex@example.com",
            phone: "+91 98765 43210"
        )

        let vehicles: [Vehicle] = [
            Vehicle(id: "veh-1", userId: userId, type: .car, registrationNumber: "KA 03 AB 1234", brand: "Honda", model: "City"),
            Vehicle(id: "veh-2", userId: userId, type: .ev, registrationNumber: "KA 05 EV 7788", brand: "Tata", model: "Nexon EV"),
            Vehicle(id: "veh-3", userId: userId, type: .bike, registrationNumber: "KA 01 BK 5566", brand: "Yamaha", model: "MT-15")
        ]

        let lots: [ParkingLot] = [
            ParkingLot(
                id: "lot-1",
                name: "Downtown Central Garage",
                address: "12 MG Road, Bengaluru",
                latitude: 12.9716,
                longitude: 77.5946,
                distance: 0.4,
                rating: 4.7,
                totalSlots: 120,
                availableSlots: 42,
                pricePerHour: 60,
                openingHours: "24 hours",
                amenities: ["Covered", "CCTV", "EV Charging", "Washroom"],
                isFavourite: true,
                imageNames: ["ParkingGarage1", "ParkingGarage3", "ParkingGarage4", "ParkingGarage2"]
            ),
            ParkingLot(
                id: "lot-2",
                name: "City Mall Parking",
                address: "45 Brigade Road, Bengaluru",
                latitude: 12.9738,
                longitude: 77.6075,
                distance: 0.9,
                rating: 4.4,
                totalSlots: 200,
                availableSlots: 18,
                pricePerHour: 80,
                openingHours: "08:00 – 23:00",
                amenities: ["Covered", "Security", "Elevator"],
                isFavourite: false,
                imageNames: ["ParkingGarage2", "ParkingGarage1", "ParkingGarage4"]
            ),
            ParkingLot(
                id: "lot-3",
                name: "Tech Park Basement",
                address: "Manyata Embassy Business Park",
                latitude: 13.0475,
                longitude: 77.6190,
                distance: 2.1,
                rating: 4.6,
                totalSlots: 300,
                availableSlots: 0,
                pricePerHour: 50,
                openingHours: "06:00 – 22:00",
                amenities: ["Covered", "EV Charging", "Shuttle"],
                isFavourite: true,
                imageNames: ["ParkingGarage1", "ParkingGarage4", "ParkingGarage3"]
            ),
            ParkingLot(
                id: "lot-4",
                name: "Airport Express Lot",
                address: "KIAL Road, Devanahalli",
                latitude: 13.1989,
                longitude: 77.7069,
                distance: 28.0,
                rating: 4.2,
                totalSlots: 500,
                availableSlots: 210,
                pricePerHour: 40,
                openingHours: "24 hours",
                amenities: ["Open Air", "CCTV", "Shuttle"],
                isFavourite: false,
                imageNames: ["ParkingGarage2", "ParkingGarage3", "ParkingGarage1"]
            ),
            ParkingLot(
                id: "lot-5",
                name: "Lakeview Open Parking",
                address: "Ulsoor Lake Road",
                latitude: 12.9810,
                longitude: 77.6170,
                distance: 1.5,
                rating: 4.1,
                totalSlots: 80,
                availableSlots: 12,
                pricePerHour: 35,
                openingHours: "06:00 – 21:00",
                amenities: ["Open Air", "Security"],
                isFavourite: false,
                imageNames: ["ParkingGarage3", "ParkingGarage2", "ParkingGarage4"]
            ),
            ParkingLot(
                id: "lot-6",
                name: "Metro Hub Multi-Level",
                address: "Indiranagar Metro Station",
                latitude: 12.9784,
                longitude: 77.6408,
                distance: 1.2,
                rating: 4.5,
                totalSlots: 150,
                availableSlots: 55,
                pricePerHour: 45,
                openingHours: "05:00 – 23:30",
                amenities: ["Covered", "CCTV", "Bike Parking"],
                isFavourite: false,
                imageNames: ["ParkingGarage3", "ParkingGarage1", "ParkingGarage2", "ParkingGarage4"]
            ),
            ParkingLot(
                id: "lot-7",
                name: "Hospital Visitor Parking",
                address: "Manipal Hospital Road",
                latitude: 12.9580,
                longitude: 77.6480,
                distance: 3.4,
                rating: 3.6,
                totalSlots: 90,
                availableSlots: 8,
                pricePerHour: 30,
                openingHours: "24 hours",
                amenities: ["Covered", "Wheelchair Access"],
                isFavourite: false,
                imageNames: ["ParkingGarage1", "ParkingGarage2"]
            ),
            ParkingLot(
                id: "lot-8",
                name: "Harbour Side Parking",
                address: "Cubbon Park East Gate",
                latitude: 12.9763,
                longitude: 77.5929,
                distance: 0.7,
                rating: 4.8,
                totalSlots: 60,
                availableSlots: 22,
                pricePerHour: 70,
                openingHours: "07:00 – 20:00",
                amenities: ["Covered", "EV Charging", "Valet"],
                isFavourite: true,
                imageNames: ["ParkingGarage4", "ParkingGarage1", "ParkingGarage3"]
            )
        ]

        var slots: [ParkingSlot] = []
        for lot in lots {
            let count = min(lot.totalSlots, 12)
            for index in 1...count {
                let available = index <= lot.availableSlots || (lot.availableSlots > 0 && index % 3 != 0)
                slots.append(
                    ParkingSlot(
                        id: "\(lot.id)-slot-\(index)",
                        lotId: lot.id,
                        label: String(format: "%@-%02d", lot.id.suffix(1).uppercased(), index),
                        isAvailable: lot.availableSlots == 0 ? false : available,
                        level: index <= 6 ? "Ground" : "Level 1"
                    )
                )
            }
        }

        slots = slots.map { slot in
            var copy = slot
            if copy.lotId == "lot-3" {
                copy.isAvailable = false
            }
            return copy
        }

        let now = Date()
        let calendar = Calendar.current

        let bookings: [Booking] = [
            Booking(
                id: "book-1",
                userId: userId,
                parkingId: "lot-1",
                vehicleId: "veh-1",
                slotId: "lot-1-slot-1",
                startTime: calendar.date(byAdding: .hour, value: 2, to: now) ?? now,
                endTime: calendar.date(byAdding: .hour, value: 5, to: now) ?? now,
                durationHours: 3,
                amount: 180,
                status: .upcoming,
                parkingName: "Downtown Central Garage",
                parkingAddress: "12 MG Road, Bengaluru",
                vehicleLabel: "Honda City · MH 12 AB 1234",
                slotLabel: "A-01"
            ),
            Booking(
                id: "book-2",
                userId: userId,
                parkingId: "lot-8",
                vehicleId: "veh-2",
                slotId: "lot-8-slot-2",
                startTime: calendar.date(byAdding: .hour, value: -1, to: now) ?? now,
                endTime: calendar.date(byAdding: .hour, value: 2, to: now) ?? now,
                durationHours: 3,
                amount: 210,
                status: .active,
                parkingName: "Harbour Side Parking",
                parkingAddress: "Cubbon Park East Gate",
                vehicleLabel: "Tata Nexon EV · MH 14 EV 7788",
                slotLabel: "H-02"
            ),
            Booking(
                id: "book-3",
                userId: userId,
                parkingId: "lot-2",
                vehicleId: "veh-1",
                slotId: "lot-2-slot-3",
                startTime: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                endTime: calendar.date(byAdding: .day, value: -2, to: calendar.date(byAdding: .hour, value: 4, to: now) ?? now) ?? now,
                durationHours: 4,
                amount: 320,
                status: .completed,
                parkingName: "City Mall Parking",
                parkingAddress: "45 Brigade Road, Bengaluru",
                vehicleLabel: "Honda City · MH 12 AB 1234",
                slotLabel: "B-03"
            ),
            Booking(
                id: "book-4",
                userId: userId,
                parkingId: "lot-6",
                vehicleId: "veh-3",
                slotId: "lot-6-slot-1",
                startTime: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                endTime: calendar.date(byAdding: .day, value: -5, to: calendar.date(byAdding: .hour, value: 2, to: now) ?? now) ?? now,
                durationHours: 2,
                amount: 90,
                status: .cancelled,
                parkingName: "Metro Hub Multi-Level",
                parkingAddress: "Indiranagar Metro Station",
                vehicleLabel: "Yamaha MT-15 · MH 12 BK 5566",
                slotLabel: "M-01"
            )
        ]

        self.users = [demoUser]
        self.vehicles = vehicles
        self.parkingLots = lots
        self.parkingSlots = slots
        self.bookings = bookings
        self.favouriteParkingIds = Set(lots.filter(\.isFavourite).map(\.id))
    }

    func clearFavourites() {
        favouriteParkingIds = []
    }

    func clearUserOwnedData(userId: String) {
        vehicles.removeAll { $0.userId == userId }
        bookings.removeAll { $0.userId == userId }
        favouriteParkingIds = []
        BookingsSync.shared.notifyChanged()
    }

    func delay(ms: UInt64 = 400) async {
        try? await Task.sleep(nanoseconds: ms * 1_000_000)
    }
}
