import SwiftUI

struct BookingFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: BookingFlowViewModel
    @State private var showConfirmation = false
    @State private var showAddVehicle = false
    @State private var showAddMoney = false

    init(parking: ParkingLot, userId: String) {
        _viewModel = State(initialValue: BookingFlowViewModel(parking: parking, userId: userId))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressHeader
                Divider()
                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                bottomBar
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Reserve Parking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task { await viewModel.load() }
            .sheet(isPresented: $showAddVehicle, onDismiss: {
                Task { await viewModel.reloadVehicles() }
            }) {
                VehicleFormView(userId: viewModel.userId)
            }
            .sheet(isPresented: $showAddMoney) {
                NavigationStack {
                    AddMoneyView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") { showAddMoney = false }
                            }
                        }
                }
            }
            .navigationDestination(isPresented: $showConfirmation) {
                if let booking = viewModel.confirmedBooking {
                    BookingConfirmationView(booking: booking) {
                        dismiss()
                    }
                }
            }
            .alert("Booking failed", isPresented: Binding(
                get: { viewModel.errorMessage != nil && viewModel.confirmedBooking == nil },
                set: { if !$0 { viewModel.clearError() } }
            )) {
                if viewModel.needsWalletTopUp {
                    Button("Add Money") {
                        viewModel.clearError()
                        showAddMoney = true
                    }
                }
                Button("OK", role: .cancel) {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.parking.name)
                .font(Typography.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
            Text(viewModel.step.title)
                .font(Typography.title3)
            ProgressView(value: Double(viewModel.step.rawValue + 1), total: Double(BookingStep.allCases.count))
                .tint(Theme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.surface)
    }

    @ViewBuilder
    private var stepContent: some View {
        if viewModel.isLoading {
            LoadingView()
        } else {
            ScrollView {
                Group {
                    switch viewModel.step {
                    case .vehicle:
                        vehicleStep
                    case .date:
                        dateStep
                    case .startTime:
                        timeStep
                    case .duration:
                        durationStep
                    case .slot:
                        slotStep
                    case .summary:
                        summaryStep
                    }
                }
                .padding(16)
            }
        }
    }

    private var vehicleStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.vehicles.isEmpty {
                EmptyStateView(
                    title: "No vehicles",
                    message: "Add one so we know what you’re parking.",
                    systemImage: "car"
                )
                PrimaryButton(title: "Add Vehicle", showsArrow: false) {
                    showAddVehicle = true
                }
            } else {
                ForEach(viewModel.vehicles) { vehicle in
                    Button {
                        viewModel.selectedVehicle = vehicle
                    } label: {
                        HStack {
                            VehicleRow(vehicle: vehicle)
                            if viewModel.selectedVehicle?.id == vehicle.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.primary)
                            }
                        }
                        .padding(12)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    viewModel.selectedVehicle?.id == vehicle.id ? Theme.primary : Theme.border,
                                    lineWidth: viewModel.selectedVehicle?.id == vehicle.id ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    showAddVehicle = true
                } label: {
                    Label("Add another vehicle", systemImage: "plus.circle")
                        .font(Typography.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
    }

    private var dateStep: some View {
        DatePicker(
            "Parking date",
            selection: $viewModel.selectedDate,
            in: Date()...,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .padding()
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var timeStep: some View {
        DatePicker(
            "Start time",
            selection: $viewModel.selectedStartTime,
            displayedComponents: .hourAndMinute
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var durationStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How long will you stay?")
                .font(Typography.headline)
                .foregroundStyle(Theme.textPrimary)
            Stepper(value: $viewModel.durationHours, in: 1...12) {
                Text("\(viewModel.durationHours) hour\(viewModel.durationHours == 1 ? "" : "s")")
                    .font(Typography.title3)
            }
            Text("Estimated total: \(DateFormatters.currencyString(from: viewModel.amount))")
                .font(Typography.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var slotStep: some View {
        let available = viewModel.slots.filter(\.isAvailable)
        return VStack(alignment: .leading, spacing: 12) {
            if available.isEmpty {
                EmptyStateView(title: "No slots available", systemImage: "xmark.circle")
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 10)], spacing: 10) {
                    ForEach(available) { slot in
                        Button {
                            viewModel.selectedSlot = slot
                        } label: {
                            VStack(spacing: 4) {
                                Text(slot.label)
                                    .font(Typography.headline)
                                Text(slot.level)
                                    .font(Typography.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                viewModel.selectedSlot?.id == slot.id
                                ? Theme.primary.opacity(0.15)
                                : Theme.surface
                            )
                            .foregroundStyle(Theme.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(
                                        viewModel.selectedSlot?.id == slot.id ? Theme.primary : Theme.border,
                                        lineWidth: viewModel.selectedSlot?.id == slot.id ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var summaryStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            summaryRow("Parking", viewModel.parking.name)
            summaryRow("Address", viewModel.parking.address)
            summaryRow("Vehicle", viewModel.selectedVehicle.map { "\($0.displayName) · \($0.registrationNumber)" } ?? "—")
            summaryRow("Date", DateFormatters.displayDate.string(from: viewModel.selectedDate))
            summaryRow("Start", DateFormatters.displayTime.string(from: viewModel.selectedStartTime))
            summaryRow("Duration", "\(viewModel.durationHours) hour(s)")
            summaryRow("Slot", viewModel.selectedSlot?.label ?? "—")
            summaryRow("Wallet balance", viewModel.walletBalanceLabel)
            Divider()
            HStack {
                Text("Total")
                    .font(Typography.headline)
                Spacer()
                Text(DateFormatters.currencyString(from: viewModel.amount))
                    .font(Typography.title3)
                    .foregroundStyle(Theme.primary)
            }
            Text("Amount will be deducted from your wallet on confirm.")
                .font(Typography.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Theme.textPrimary)
        }
        .font(Typography.subheadline)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if viewModel.step != .vehicle {
                SecondaryButton(title: "Back") {
                    viewModel.goBack()
                }
            }
            if viewModel.step == .summary {
                PrimaryButton(title: "Confirm Booking", isLoading: viewModel.isSubmitting, isDisabled: !viewModel.canContinue) {
                    Task {
                        await viewModel.confirm()
                        if viewModel.confirmedBooking != nil {
                            Haptics.success()
                            showConfirmation = true
                        }
                    }
                }
            } else {
                PrimaryButton(title: "Continue", isDisabled: !viewModel.canContinue) {
                    viewModel.goNext()
                }
            }
        }
        .padding(16)
        .background(Theme.surface)
    }
}
