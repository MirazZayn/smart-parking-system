import SwiftUI

struct VehicleListView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = VehicleListViewModel()
    @State private var showAdd = false
    @State private var editingVehicle: Vehicle?

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ScrollView {
                    LoadingView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                }
                .refreshable { await viewModel.refresh() }
            case .empty:
                ScrollView {
                    VStack(spacing: 20) {
                        EmptyStateView(
                            title: "No vehicles yet",
                            message: "Add one before you book.",
                            systemImage: "car"
                        )
                        PrimaryButton(title: "Add Vehicle", showsArrow: false) {
                            showAdd = true
                        }
                        .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
                .refreshable { await viewModel.refresh() }
            case .error(let message):
                ScrollView {
                    ErrorStateView(message: message) {
                        if let userId = appState.currentUser?.id {
                            Task { await viewModel.load(userId: userId) }
                        }
                    }
                    .padding(.top, 60)
                }
                .refreshable { await viewModel.refresh() }
            case .loaded(let vehicles):
                List {
                    ForEach(vehicles) { vehicle in
                        Button {
                            editingVehicle = vehicle
                        } label: {
                            VehicleRow(vehicle: vehicle)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        guard let index = indexSet.first else { return }
                        let id = vehicles[index].id
                        Task { await viewModel.delete(id: id) }
                    }
                }
                .listStyle(.plain)
                .refreshable { await viewModel.refresh() }
            }
        }
        .screenBackground()
        .navigationTitle("My Vehicles")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            if let userId = appState.currentUser?.id {
                await viewModel.load(userId: userId)
            }
        }
        .sheet(isPresented: $showAdd, onDismiss: reload) {
            if let userId = appState.currentUser?.id {
                VehicleFormView(userId: userId)
            }
        }
        .sheet(item: $editingVehicle, onDismiss: reload) { vehicle in
            VehicleFormView(userId: vehicle.userId, vehicle: vehicle)
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func reload() {
        if let userId = appState.currentUser?.id {
            Task { await viewModel.load(userId: userId) }
        }
    }
}
