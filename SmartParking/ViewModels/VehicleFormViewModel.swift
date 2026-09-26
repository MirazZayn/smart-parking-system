import Foundation

@MainActor
@Observable
final class VehicleFormViewModel {
    var type: VehicleType = .car
    var registrationNumber = ""
    var brand = ""
    var model = ""
    var isLoading = false
    var errorMessage: String?
    var didSave = false

    private let vehicleRepository: VehicleRepository
    private let existing: Vehicle?
    private let userId: String

    init(
        userId: String,
        vehicle: Vehicle? = nil,
        vehicleRepository: VehicleRepository? = nil
    ) {
        self.userId = userId
        self.existing = vehicle
        self.vehicleRepository = vehicleRepository ?? DIContainer.shared.vehicleRepository
        if let vehicle {
            type = vehicle.type
            registrationNumber = vehicle.registrationNumber
            brand = vehicle.brand
            model = vehicle.model
        }
    }

    var title: String { existing == nil ? "Add Vehicle" : "Edit Vehicle" }

    func save() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let vehicle = Vehicle(
            id: existing?.id ?? UUID().uuidString,
            userId: userId,
            type: type,
            registrationNumber: registrationNumber.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
            brand: brand.trimmingCharacters(in: .whitespacesAndNewlines),
            model: model.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        do {
            if existing == nil {
                _ = try await vehicleRepository.addVehicle(vehicle)
            } else {
                _ = try await vehicleRepository.updateVehicle(vehicle)
            }
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
