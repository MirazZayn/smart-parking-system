import SwiftUI

struct ParkingPassEntryView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ParkingPassEntryViewModel()

    var body: some View {
        Group {
            if let bookingId = viewModel.bookingId {
                ParkingPassView(bookingId: bookingId)
            } else if viewModel.isLoading {
                LoadingView(message: "Loading pass…")
            } else {
                EmptyStateView(
                    title: "No pass yet",
                    message: "Book a spot and it’ll show up here.",
                    systemImage: "qrcode"
                )
            }
        }
        .task {
            await viewModel.load(userId: appState.currentUser?.id)
        }
    }
}
