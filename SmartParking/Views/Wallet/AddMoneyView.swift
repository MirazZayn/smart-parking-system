import SwiftUI

struct AddMoneyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddMoneyViewModel()
    @State private var showSuccessToast = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                amountSection
                methodSection
                detailsSection

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(Typography.footnote)
                        .foregroundStyle(Theme.full)
                }

                Button {
                    Task {
                        await viewModel.pay()
                        if viewModel.didSucceed {
                            Haptics.success()
                            showSuccessToast = true
                            try? await Task.sleep(nanoseconds: 900_000_000)
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(viewModel.payButtonTitle)
                                .font(Typography.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.primary)
                    .foregroundStyle(.white)
                    .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isProcessing)
                .opacity(viewModel.isProcessing ? 0.7 : 1)

                Text("This is a mock payment for demo. No real money is charged.")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(20)
        }
        .screenBackground()
        .navigationTitle("Add Money")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .top) {
            if showSuccessToast {
                SuccessToast(message: "Payment successful")
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.25), value: showSuccessToast)
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(Typography.headline)
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 8) {
                Text("₹")
                    .font(Typography.title2)
                    .foregroundStyle(Theme.textSecondary)
                TextField("0", text: Binding(
                    get: { viewModel.amountText },
                    set: { viewModel.updateAmountText($0) }
                ))
                .font(Typography.title2)
                .keyboardType(.numberPad)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .overlay(Rectangle().stroke(Theme.border, lineWidth: 1))

            HStack(spacing: 8) {
                ForEach(viewModel.presetAmounts, id: \.self) { value in
                    let selected = viewModel.selectedAmount == value
                    Button {
                        viewModel.selectPreset(value)
                    } label: {
                        Text("₹\(Int(value))")
                            .font(Typography.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .foregroundStyle(selected ? Color.white : Theme.textPrimary)
                            .background(selected ? Theme.primary : Theme.surface)
                            .overlay(Rectangle().stroke(selected ? Theme.primary : Theme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var methodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment method")
                .font(Typography.headline)
                .foregroundStyle(Theme.textPrimary)

            ForEach(PaymentMethod.allCases) { method in
                let selected = viewModel.method == method
                Button {
                    viewModel.selectMethod(method)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: method.systemImage)
                            .font(Typography.title3)
                            .foregroundStyle(selected ? Theme.primary : Theme.textSecondary)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(method.title)
                                .font(Typography.headline)
                                .foregroundStyle(Theme.textPrimary)
                            Text(method.subtitle)
                                .font(Typography.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }

                        Spacer()

                        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selected ? Theme.primary : Theme.border)
                    }
                    .padding(14)
                    .background(Theme.surface)
                    .overlay(
                        Rectangle()
                            .stroke(selected ? Theme.primary : Theme.border, lineWidth: selected ? 2 : 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.method == .upi ? "UPI details" : "Card details")
                .font(Typography.headline)
                .foregroundStyle(Theme.textPrimary)

            switch viewModel.method {
            case .upi:
                paymentField(
                    title: "UPI ID",
                    placeholder: "yourname@upi",
                    text: $viewModel.upiId,
                    keyboard: .emailAddress
                )
            case .card:
                paymentField(
                    title: "Card number",
                    placeholder: "XXXX XXXX XXXX XXXX",
                    text: $viewModel.cardNumber,
                    keyboard: .numberPad
                )
                HStack(spacing: 12) {
                    paymentField(
                        title: "Expiry",
                        placeholder: "MM/YY",
                        text: $viewModel.cardExpiry,
                        keyboard: .numbersAndPunctuation
                    )
                    paymentField(
                        title: "CVV",
                        placeholder: "123",
                        text: $viewModel.cardCVV,
                        keyboard: .numberPad
                    )
                }
            }
        }
    }

    private func paymentField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(Theme.textSecondary)
            TextField(placeholder, text: text)
                .font(Typography.body)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(Theme.surface)
                .overlay(Rectangle().stroke(Theme.border, lineWidth: 1))
        }
    }
}
