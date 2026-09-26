import SwiftUI

struct ParkingListView: View {
    @State private var viewModel: ParkingListViewModel

    init(initialQuery: String = "") {
        _viewModel = State(initialValue: ParkingListViewModel(initialQuery: initialQuery))
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            filterBar
            sortBar
            content
        }
        .screenBackground()
        .navigationTitle("Parking")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(ParkingSortOption.allCases) { option in
                        Button {
                            viewModel.setSort(option)
                        } label: {
                            HStack {
                                Text(option.displayName)
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.refresh() }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.textSecondary)
            TextField("Search by name or address", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit {
                    Task { await viewModel.search() }
                }
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    Task { await viewModel.search() }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .padding(12)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "All", selected: viewModel.selectedFilter == nil) {
                    Task { await viewModel.setFilter(nil) }
                }
                ForEach(AvailabilityStatus.allCases) { status in
                    filterChip(title: status.displayName, selected: viewModel.selectedFilter == status) {
                        Task { await viewModel.setFilter(status) }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private var sortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Text("Sort")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.textSecondary)
                ForEach(ParkingSortOption.allCases) { option in
                    filterChip(title: option.displayName, selected: viewModel.sortOption == option) {
                        viewModel.setSort(option)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
    }

    private func filterChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(selected ? Color.white : Theme.textPrimary)
                .background(selected ? Theme.primary : Theme.surface)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Theme.border, lineWidth: selected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()
        case .empty:
            EmptyStateView(
                title: "No parking found",
                message: "Try adjusting your search or filters.",
                systemImage: "parkingsign"
            )
        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        case .loaded(let lots):
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
}
