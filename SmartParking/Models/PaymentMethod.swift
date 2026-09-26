import Foundation

enum PaymentMethod: String, CaseIterable, Identifiable {
    case upi
    case card

    var id: String { rawValue }

    var title: String {
        switch self {
        case .upi: return "UPI"
        case .card: return "Card"
        }
    }

    var subtitle: String {
        switch self {
        case .upi: return "Pay with GPay, PhonePe, Paytm & more"
        case .card: return "Debit or credit card"
        }
    }

    var systemImage: String {
        switch self {
        case .upi: return "qrcode"
        case .card: return "creditcard"
        }
    }
}
