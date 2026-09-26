import SwiftUI

struct ParkingDetailsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: ParkingDetailsViewModel
    @State private var showBooking = false
    @State private var imagePage = 0

    init(parkingId: String) {
        _viewModel = State(initialValue: ParkingDetailsViewModel(parkingId: parkingId))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                LoadingView()
            case .empty:
                EmptyStateView(title: "Parking not found")
            case .error(let message):
                ErrorStateView(message: message) {
                    Task { await viewModel.load() }
                }
            case .loaded(let lot):
                details(lot)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .sheet(isPresented: $showBooking) {
            if case .loaded(let lot) = viewModel.state,
               let userId = appState.currentUser?.id {
                BookingFlowView(parking: lot, userId: userId)
            }
        }
    }

    private func details(_ lot: ParkingLot) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard(lot)

                statsRow(lot)

                detailBlock(title: "Opening hours", icon: "clock") {
                    Text(lot.openingHours)
                        .font(Typography.body)
                        .foregroundStyle(Theme.textPrimary)
                }

                detailBlock(title: "Amenities", icon: "sparkles") {
                    FlowAmenities(items: lot.amenities)
                }

                detailBlock(title: "Location", icon: "mappin.and.ellipse") {
                    Text(lot.address)
                        .font(Typography.body)
                        .foregroundStyle(Theme.textPrimary)
                    Text(lot.distanceLabel + " away")
                        .font(Typography.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }

                if appState.isGuest {
                    GuestRestrictionBanner(message: "Sign in to reserve this spot.")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 28)
        }
    }

    private func heroCard(_ lot: ParkingLot) -> some View {
        let images = lot.galleryImages

        return VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                TabView(selection: $imagePage) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, name in
                        Image(name)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 240)
                            .clipped()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 240)

                LinearGradient(
                    colors: [.clear, .black.opacity(0.35)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 240)
                .allowsHitTesting(false)

                if !appState.isGuest {
                    Button {
                        Task { await viewModel.toggleFavourite() }
                    } label: {
                        Image(systemName: viewModel.isFavourite ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(viewModel.isFavourite ? Theme.full : Color.black.opacity(0.45))
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(14)
                    .accessibilityLabel(viewModel.isFavourite ? "Remove from favourites" : "Add to favourites")
                }

                if images.count > 1 {
                    HStack(spacing: 6) {
                        ForEach(0..<images.count, id: \.self) { index in
                            Capsule()
                                .fill(index == imagePage ? Color.white : Color.white.opacity(0.45))
                                .frame(width: index == imagePage ? 16 : 6, height: 6)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 12)
                    .allowsHitTesting(false)
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    featuredBadge(lot.availabilityStatus)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text(String(format: "%.1f", lot.rating))
                            .font(Typography.caption.weight(.bold))
                    }
                    .foregroundStyle(Theme.mint)
                }

                Text(lot.name)
                    .font(Typography.title2)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(lot.amenitiesLine)
                    .font(Typography.subheadline)
                    .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: 14) {
                    Label(lot.cityLabel, systemImage: "mappin")
                    Label(lot.distanceLabel, systemImage: "location")
                    Label(lot.priceLabel, systemImage: "tag")
                }
                .font(Typography.caption)
                .foregroundStyle(.white.opacity(0.9))
                .labelStyle(.titleAndIcon)

                if !appState.isGuest {
                    Button {
                        showBooking = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: lot.availabilityStatus == .full ? "xmark.circle" : "calendar")
                            Text(lot.availabilityStatus == .full ? "FULLY BOOKED" : "RESERVE PARKING")
                                .font(Typography.headline)
                        }
                        .foregroundStyle(lot.availabilityStatus == .full ? .white.opacity(0.7) : Theme.primaryDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(lot.availabilityStatus == .full ? Color.white.opacity(0.18) : Theme.mint)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(lot.availabilityStatus == .full)
                    .padding(.top, 4)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.primaryDark)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Theme.primaryDark.opacity(0.18), radius: 16, y: 8)
    }

    private func featuredBadge(_ status: AvailabilityStatus) -> some View {
        HStack(spacing: 0) {
            Capsule()
                .fill(Theme.mint)
                .frame(width: 4)
                .padding(.vertical, 2)

            Text(status.displayName)
                .font(Typography.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
        }
        .background(Theme.primary.opacity(0.95))
        .clipShape(Capsule())
    }

    private func statsRow(_ lot: ParkingLot) -> some View {
        HStack(spacing: 10) {
            miniStat(title: "Available", value: "\(lot.availableSlots)", tint: Theme.available)
            miniStat(title: "Total", value: "\(lot.totalSlots)", tint: Theme.primary)
            miniStat(title: "Price", value: DateFormatters.currencyString(from: lot.pricePerHour), tint: Theme.accent)
        }
    }

    private func miniStat(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(Typography.headline)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        )
    }

    private func detailBlock<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(Typography.headline)
                .foregroundStyle(Theme.textPrimary)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}
