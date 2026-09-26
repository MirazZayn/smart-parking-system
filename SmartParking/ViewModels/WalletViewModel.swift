import Foundation

@MainActor
@Observable
final class WalletViewModel {
    private let wallet: WalletStore

    init(wallet: WalletStore? = nil) {
        self.wallet = wallet ?? DIContainer.shared.walletStore
    }

    var balance: Double { wallet.balance }

    var balanceLabel: String {
        DateFormatters.currencyString(from: wallet.balance)
    }

    var transactions: [WalletTransaction] {
        wallet.transactions
    }

    func amountLabel(for transaction: WalletTransaction) -> String {
        let prefix = transaction.amount >= 0 ? "+" : ""
        return prefix + DateFormatters.currencyString(from: abs(transaction.amount))
    }

    func refresh() async {
        try? await Task.sleep(nanoseconds: 600_000_000)
    }
}
