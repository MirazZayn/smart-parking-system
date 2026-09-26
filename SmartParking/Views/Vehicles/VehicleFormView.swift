import SwiftUI

struct VehicleFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: VehicleFormViewModel
    @State private var showSavedToast = false

    init(userId: String, vehicle: Vehicle? = nil) {
        _viewModel = State(initialValue: VehicleFormViewModel(userId: userId, vehicle: vehicle))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle type") {
                    Picker("Type", selection: $viewModel.type) {
                        ForEach(VehicleType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Details") {
                    TextField("Registration number", text: $viewModel.registrationNumber)
                        .textInputAutocapitalization(.characters)
                    TextField("Brand", text: $viewModel.brand)
                    TextField("Model", text: $viewModel.model)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .font(Typography.footnote)
                            .foregroundStyle(Theme.full)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                            if viewModel.didSave {
                                Haptics.success()
                                showSavedToast = true
                                try? await Task.sleep(nanoseconds: 650_000_000)
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .overlay(alignment: .top) {
                if showSavedToast {
                    SuccessToast(message: "Vehicle saved")
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeOut(duration: 0.25), value: showSavedToast)
        }
    }
}
