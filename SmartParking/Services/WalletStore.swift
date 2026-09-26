import Foundation

@MainActor
@Observable
final class WalletStore {
    static let shared = WalletStore()

    private static let balanceKey = "walletBalance"
    private static let transactionsKey = "walletTransactions"

    var balance: Double
    var transactions: [WalletTransaction]

    private init() {
        if UserDefaults.standard.object(forKey: Self.balanceKey) != nil {
            balance = UserDefaults.standard.double(forKey: Self.balanceKey)
        } else {
            balance = 0
        }
        if let data = UserDefaults.standard.data(forKey: Self.transactionsKey),
           let decoded = try? JSONDecoder().decode([PersistedWalletTransaction].self, from: data) {
            transactions = decoded.map(\.asModel)
        } else {
            transactions = []
        }
    }

    func topUp(amount: Double, title: String = "Wallet top-up") {
        guard amount > 0 else { return }
        balance += amount
        transactions.insert(
            WalletTransaction(
                id: UUID().uuidString,
                title: title,
                amount: amount,
                date: Date(),
                type: .topUp
            ),
            at: 0
        )
        persist()
    }

    func charge(amount: Double, title: String) throws {
        guard amount > 0 else { return }
        guard balance >= amount else {
            throw AppError.validation("Insufficient wallet balance. Add money and try again.")
        }
        balance -= amount
        transactions.insert(
            WalletTransaction(
                id: UUID().uuidString,
                title: title,
                amount: -amount,
                date: Date(),
                type: .payment
            ),
            at: 0
        )
        persist()
    }

    func refund(amount: Double, title: String) {
        guard amount > 0 else { return }
        balance += amount
        transactions.insert(
            WalletTransaction(
                id: UUID().uuidString,
                title: title,
                amount: amount,
                date: Date(),
                type: .topUp
            ),
            at: 0
        )
        persist()
    }

    func reset() {
        balance = 0
        transactions = []
        persist()
    }

    private func persist() {
        UserDefaults.standard.set(balance, forKey: Self.balanceKey)
        let payload = transactions.map(PersistedWalletTransaction.init)
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: Self.transactionsKey)
        }
    }
}

private struct PersistedWalletTransaction: Codable {
    let id: String
    let title: String
    let amount: Double
    let date: Date
    let type: String

    init(_ tx: WalletTransaction) {
        id = tx.id
        title = tx.title
        amount = tx.amount
        date = tx.date
        type = tx.type == .topUp ? "topUp" : "payment"
    }

    var asModel: WalletTransaction {
        WalletTransaction(
            id: id,
            title: title,
            amount: amount,
            date: date,
            type: type == "topUp" ? .topUp : .payment
        )
    }
}
