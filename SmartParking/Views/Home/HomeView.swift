import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = HomeViewModel()
    @State private var navigateToSearch = false

    var body: some View {
        GeometryReader { geo in
            let heroHeight = geo.size.height * 0.6

            ScrollView {
                VStack(spacing: 0) {
                    heroSection(width: geo.size.width, height: heroHeight)

                    VStack(alignment: .leading, spacing: 20) {
                        if appState.isGuest {
                            GuestRestrictionBanner()
                        }
                        quickActions
                        nearbySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.background)
                }
            }
            .refreshable {
                await viewModel.refresh(userName: appState.currentUser?.name)
            }
            .ignoresSafeArea(edges: .top)
            .screenBackground()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToSearch) {
            ParkingListView(initialQuery: viewModel.searchText)
        }
        .task {
            await viewModel.load(userName: appState.currentUser?.name)
        }
    }

    private func heroSection(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()

            Theme.heroOverlay

            VStack {
                HStack {
                    Text(viewModel.greetingText)
                        .font(Typography.tagline)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.35), radius: 4, y: 1)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                Text("Nearby spots, ready to book")
                    .font(Typography.tagline)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 4, y: 1)
                searchField
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .frame(width: width, height: height)
        .clipped()
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.9))
            TextField(
                "",
                text: $viewModel.searchText,
                prompt: Text("Search parking…").foregroundStyle(.white.opacity(0.75))
            )
            .font(Typography.callout)
            .foregroundStyle(.white)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .onSubmit { navigateToSearch = true }

            if !viewModel.searchText.isEmpty {
                Button {
                    navigateToSearch = true
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Search")
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.28), lineWidth: 1)
        )
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Shortcuts")
                .font(Typography.title3)
                .foregroundStyle(Theme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    NavigationLink {
                        ParkingListView()
                    } label: {
                        shortcutChip(title: "Find parking", icon: "parkingsign")
                    }
                    .buttonStyle(.plain)

                    Button {
                        appState.selectedTab = .bookings
                    } label: {
                        shortcutChip(title: "Bookings", icon: "calendar")
                    }
                    .buttonStyle(.plain)

                    Button {
                        appState.selectedTab = .vehicles
                    } label: {
                        shortcutChip(title: "Vehicles", icon: "car")
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ParkingPassEntryView()
                    } label: {
                        shortcutChip(title: "Show pass", icon: "qrcode")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func shortcutChip(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.primary)
            Text(title)
                .font(Typography.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Theme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nearby parking")
                    .font(Typography.title3)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                NavigationLink("See all") {
                    ParkingListView()
                }
                .font(Typography.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primary)
            }

            switch viewModel.state {
            case .idle, .loading:
                LoadingView(message: "Finding nearby parking…")
                    .frame(height: 160)
            case .empty:
                EmptyStateView(title: "No parking nearby", systemImage: "parkingsign")
                    .frame(height: 160)
            case .error(let message):
                ErrorStateView(message: message) {
                    Task { await viewModel.refresh(userName: appState.currentUser?.name) }
                }
                .frame(height: 160)
            case .loaded:
                ForEach(viewModel.filteredLots) { lot in
                    NavigationLink {
                        ParkingDetailsView(parkingId: lot.id)
                    } label: {
                        ParkingCard(lot: lot)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
