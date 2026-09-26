import SwiftUI

struct WalletView: View {
    @State private var viewModel = WalletViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                balanceCard
                NavigationLink {
                    AddMoneyView()
                } label: {
                    Text("Add Money")
                        .font(Typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.primary)
                        .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
                transactionsSection
            }
            .padding(20)
        }
        .screenBackground()
        .navigationTitle("Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Available balance")
                .font(Typography.subheadline)
                .foregroundStyle(.white.opacity(0.85))
            Text(viewModel.balanceLabel)
                .font(Typography.display)
                .foregroundStyle(.white)
            Text("Used when you book")
                .font(Typography.caption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Theme.primary.opacity(0.22), radius: 12, y: 6)
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent activity")
                .font(Typography.title3)
                .foregroundStyle(Theme.textPrimary)

            ForEach(viewModel.transactions) { tx in
                HStack {
                    Image(systemName: tx.type == .topUp ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .foregroundStyle(tx.type == .topUp ? Theme.available : Theme.primary)
                        .font(Typography.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tx.title)
                            .font(Typography.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Text(DateFormatters.displayDateTime.string(from: tx.date))
                            .font(Typography.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Text(viewModel.amountLabel(for: tx))
                        .font(Typography.subheadline.weight(.bold))
                        .foregroundStyle(tx.amount >= 0 ? Theme.available : Theme.textPrimary)
                }
                .padding(14)
                .elevatedCard(radius: 14)
            }
        }
    }
}
