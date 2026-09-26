import SwiftUI

struct MyBookingsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = BookingsViewModel()
    private let bookingsSync = DIContainer.shared.bookingsSync

    var body: some View {
        VStack(spacing: 0) {
            Picker("Status", selection: Binding(
                get: { viewModel.selectedStatus },
                set: { status in
                    Task { await viewModel.select(status) }
                }
            )) {
                ForEach(BookingStatus.allCases) { status in
                    Text(status.displayName).tag(status)
                }
            }
            .pickerStyle(.segmented)
            .padding(16)

            content
        }
        .screenBackground()
        .navigationTitle("My Bookings")
        .task(id: appState.currentUser?.id) {
            if let userId = appState.currentUser?.id {
                await viewModel.load(userId: userId)
            }
        }
        .onChange(of: bookingsSync.revision) { _, _ in
            Task { await viewModel.refresh() }
        }
    }

    @ViewBuilder
    private var content: some View {
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
                EmptyStateView(
                    title: "No \(viewModel.selectedStatus.displayName.lowercased()) bookings",
                    systemImage: "calendar"
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
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
        case .loaded(let bookings):
            List {
                ForEach(bookings) { booking in
                    NavigationLink {
                        BookingDetailView(booking: booking) {
                            Task { await viewModel.cancel(id: booking.id) }
                        }
                    } label: {
                        BookingRow(booking: booking)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .refreshable { await viewModel.refresh() }
        }
    }
}
