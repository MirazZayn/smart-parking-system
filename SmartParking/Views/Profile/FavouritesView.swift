import SwiftUI

struct FavouritesView: View {
    let lots: [ParkingLot]

    var body: some View {
        Group {
            if lots.isEmpty {
                EmptyStateView(
                    title: "Nothing saved",
                    message: "Tap the heart on a lot to keep it here.",
                    systemImage: "heart"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(lots) { lot in
                            NavigationLink {
                                ParkingDetailsView(parkingId: lot.id)
                            } label: {
                                ParkingCard(lot: lot)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Favourites")
    }
}
