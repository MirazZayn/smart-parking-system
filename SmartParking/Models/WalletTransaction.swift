import Foundation

struct WalletTransaction: Identifiable, Equatable {
    enum Kind {
        case payment
        case topUp
    }

    let id: String
    let title: String
    let amount: Double
    let date: Date
    let type: Kind
}
