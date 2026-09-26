import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        List {
            Section {
                if let user = viewModel.user ?? appState.currentUser {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(Theme.primary.opacity(0.14))
                            .frame(width: 56, height: 56)
                            .overlay {
                                Text(String(user.firstName.prefix(1)).uppercased())
                                    .font(Typography.title2)
                                    .foregroundStyle(Theme.primary)
                            }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appState.isGuest ? "Guest" : user.name)
                                .font(Typography.headline)
                                .foregroundStyle(Theme.textPrimary)
                            if appState.isGuest {
                                Text("Browsing only — not signed in")
                                    .font(Typography.subheadline)
                                    .foregroundStyle(Theme.textSecondary)
                            } else {
                                Text(user.email)
                                    .font(Typography.subheadline)
                                    .foregroundStyle(Theme.textSecondary)
                                Text(user.phone)
                                    .font(Typography.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)

                    if !appState.isGuest {
                        NavigationLink {
                            EditProfileView(user: user)
                        } label: {
                            Label("Edit profile", systemImage: "pencil")
                                .font(Typography.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.primary)
                        }
                    }
                }
            } header: {
                Text("Personal details")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            if appState.isGuest {
                Section {
                    GuestRestrictionBanner()
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                }
            }

            if !appState.isGuest {
                Section {
                    NavigationLink {
                        WalletView()
                    } label: {
                        Label("Wallet", systemImage: "wallet.pass.fill")
                    }
                    NavigationLink {
                        VehicleListView()
                    } label: {
                        Label("My Vehicles", systemImage: "car.fill")
                    }
                    NavigationLink {
                        MyBookingsView()
                    } label: {
                        Label("My Bookings", systemImage: "calendar")
                    }
                    NavigationLink {
                        FavouritesView(lots: viewModel.favourites)
                    } label: {
                        Label("Favourites", systemImage: "heart.fill")
                    }
                } header: {
                    Text("Account")
                        .font(Typography.caption)
                }
            }

            Section {
                Toggle(isOn: $viewModel.notificationsEnabled) {
                    Label("Notifications", systemImage: "bell.fill")
                }
                .tint(Theme.primary)
                .disabled(appState.isGuest)

                NavigationLink {
                    HelpSupportView()
                } label: {
                    Label("Help & Support", systemImage: "questionmark.circle")
                }
            } header: {
                Text("Preferences")
                    .font(Typography.caption)
            }

            Section {
                if appState.isGuest {
                    Button {
                        appState.showLogin()
                    } label: {
                        Label("Log In", systemImage: "arrow.right.circle")
                            .foregroundStyle(Theme.primary)
                    }
                    Button {
                        appState.showRegister()
                    } label: {
                        Label("Register", systemImage: "person.badge.plus")
                            .foregroundStyle(Theme.primary)
                    }
                    Button(role: .destructive) {
                        viewModel.exitGuest(appState: appState)
                    } label: {
                        Label("Leave guest", systemImage: "xmark.circle")
                    }
                } else {
                    NavigationLink {
                        SignOutView()
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(Theme.full)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .screenBackground()
        .navigationTitle("Profile")
        .task {
            await viewModel.load(user: appState.currentUser)
        }
        .refreshable {
            await viewModel.refresh(user: appState.currentUser)
        }
        .onChange(of: appState.currentUser) { _, newValue in
            viewModel.applySessionUser(newValue)
        }
    }
}
