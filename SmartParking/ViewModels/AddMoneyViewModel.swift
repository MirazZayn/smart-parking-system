import Foundation

@MainActor
@Observable
final class AddMoneyViewModel {
    var amountText = "500"
    var selectedAmount: Double? = 500
    var method: PaymentMethod = .upi
    var upiId = ""
    var cardNumber = ""
    var cardExpiry = ""
    var cardCVV = ""
    var isProcessing = false
    var errorMessage: String?
    var didSucceed = false

    let presetAmounts: [Double] = [200, 500, 1000, 2000]

    private let wallet: WalletStore

    init(wallet: WalletStore? = nil) {
        self.wallet = wallet ?? DIContainer.shared.walletStore
    }

    var amount: Double {
        Double(amountText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    var payButtonTitle: String {
        let label = DateFormatters.currencyString(from: amount)
        switch method {
        case .upi: return "Pay \(label) with UPI"
        case .card: return "Pay \(label) with Card"
        }
    }

    func selectPreset(_ value: Double) {
        selectedAmount = value
        amountText = String(Int(value))
        errorMessage = nil
    }

    func updateAmountText(_ value: String) {
        let filtered = value.filter(\.isNumber)
        amountText = filtered
        selectedAmount = presetAmounts.first { Int($0) == Int(filtered) }
        errorMessage = nil
    }

    func selectMethod(_ method: PaymentMethod) {
        self.method = method
        errorMessage = nil
    }

    func pay() async {
        errorMessage = nil
        didSucceed = false

        guard amount >= 100 else {
            errorMessage = "Minimum top-up amount is ₹100."
            return
        }
        guard amount <= 50_000 else {
            errorMessage = "Maximum top-up amount is ₹50,000."
            return
        }

        switch method {
        case .upi:
            let id = upiId.trimmingCharacters(in: .whitespacesAndNewlines)
            guard id.contains("@"), id.count >= 5 else {
                errorMessage = "Enter a valid UPI ID (e.g. name@upi)."
                return
            }
        case .card:
            let digits = cardNumber.filter(\.isNumber)
            guard digits.count >= 12 else {
                errorMessage = "Enter a valid card number."
                return
            }
            guard cardExpiry.contains("/"), cardExpiry.count >= 4 else {
                errorMessage = "Enter expiry as MM/YY."
                return
            }
            guard cardCVV.filter(\.isNumber).count >= 3 else {
                errorMessage = "Enter a valid CVV."
                return
            }
        }

        isProcessing = true
        defer { isProcessing = false }

        try? await Task.sleep(nanoseconds: 1_200_000_000)

        let title: String
        switch method {
        case .upi:
            title = "UPI top-up · \(upiId.trimmingCharacters(in: .whitespacesAndNewlines))"
        case .card:
            let last4 = String(cardNumber.filter(\.isNumber).suffix(4))
            title = "Card top-up · •••• \(last4)"
        }

        wallet.topUp(amount: amount, title: title)
        didSucceed = true
    }
}
