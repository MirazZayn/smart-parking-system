import Foundation

@MainActor
@Observable
final class BookingFlowViewModel {
    let parking: ParkingLot
    let userId: String
    var step: BookingStep = .vehicle
    var vehicles: [Vehicle] = []
    var slots: [ParkingSlot] = []
    var selectedVehicle: Vehicle?
    var selectedDate = Date()
    var selectedStartTime = Date()
    var durationHours = 2
    var selectedSlot: ParkingSlot?
    var isLoading = false
    var isSubmitting = false
    var errorMessage: String?
    var needsWalletTopUp = false
    var confirmedBooking: Booking?

    private let vehicleRepository: VehicleRepository
    private let parkingRepository: ParkingRepository
    private let bookingRepository: BookingRepository
    private let walletStore: WalletStore

    init(
        parking: ParkingLot,
        userId: String,
        vehicleRepository: VehicleRepository? = nil,
        parkingRepository: ParkingRepository? = nil,
        bookingRepository: BookingRepository? = nil,
        walletStore: WalletStore? = nil
    ) {
        let container = DIContainer.shared
        self.parking = parking
        self.userId = userId
        self.vehicleRepository = vehicleRepository ?? container.vehicleRepository
        self.parkingRepository = parkingRepository ?? container.parkingRepository
        self.bookingRepository = bookingRepository ?? container.bookingRepository
        self.walletStore = walletStore ?? container.walletStore
    }

    var amount: Double {
        Double(durationHours) * parking.pricePerHour
    }

    var walletBalance: Double {
        walletStore.balance
    }

    var walletBalanceLabel: String {
        DateFormatters.currencyString(from: walletBalance)
    }

    var canContinue: Bool {
        switch step {
        case .vehicle: return selectedVehicle != nil
        case .date: return true
        case .startTime: return true
        case .duration: return durationHours > 0
        case .slot: return selectedSlot != nil
        case .summary: return selectedVehicle != nil && selectedSlot != nil
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let vehiclesTask = vehicleRepository.fetchVehicles(userId: userId)
            async let slotsTask = parkingRepository.fetchSlots(parkingId: parking.id)
            vehicles = try await vehiclesTask
            slots = try await slotsTask
            selectedVehicle = vehicles.first
            selectedSlot = slots.first(where: \.isAvailable)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reloadVehicles() async {
        do {
            vehicles = try await vehicleRepository.fetchVehicles(userId: userId)
            if selectedVehicle == nil || !vehicles.contains(where: { $0.id == selectedVehicle?.id }) {
                selectedVehicle = vehicles.first
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func goNext() {
        guard canContinue else { return }
        if let next = BookingStep(rawValue: step.rawValue + 1) {
            step = next
        }
    }

    func goBack() {
        if let prev = BookingStep(rawValue: step.rawValue - 1) {
            step = prev
        }
    }

    func confirm() async {
        guard let vehicle = selectedVehicle, let slot = selectedSlot else { return }
        errorMessage = nil
        needsWalletTopUp = false
        isSubmitting = true
        defer { isSubmitting = false }

        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedStartTime)
        startComponents.hour = timeComponents.hour
        startComponents.minute = timeComponents.minute
        let start = calendar.date(from: startComponents) ?? selectedStartTime
        let end = calendar.date(byAdding: .hour, value: durationHours, to: start) ?? start

        let booking = Booking(
            userId: userId,
            parkingId: parking.id,
            vehicleId: vehicle.id,
            slotId: slot.id,
            startTime: start,
            endTime: end,
            durationHours: durationHours,
            amount: amount,
            status: .upcoming,
            parkingName: parking.name,
            parkingAddress: parking.address,
            vehicleLabel: "\(vehicle.displayName) · \(vehicle.registrationNumber)",
            slotLabel: slot.label
        )

        do {
            try walletStore.charge(amount: amount, title: parking.name)
            do {
                confirmedBooking = try await bookingRepository.createBooking(booking)
            } catch {
                walletStore.refund(amount: amount, title: "Refund · \(parking.name)")
                throw error
            }
        } catch {
            errorMessage = error.localizedDescription
            needsWalletTopUp = error.localizedDescription.localizedCaseInsensitiveContains("insufficient wallet")
        }
    }

    func clearError() {
        errorMessage = nil
        needsWalletTopUp = false
    }
}
