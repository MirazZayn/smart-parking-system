import SwiftUI

struct HelpSupportView: View {
    var body: some View {
        List {
            Section("Common questions") {
                faq(
                    q: "How do I reserve a slot?",
                    a: "Open a lot, tap Reserve, then pick your vehicle, time, and bay."
                )
                faq(
                    q: "How late can I cancel?",
                    a: "Upcoming bookings can be cancelled from My Bookings. The amount goes back to your wallet."
                )
                faq(
                    q: "Pass QR won’t scan — what now?",
                    a: "Show the booking ID on the pass screen. Attendants can check that if the QR fails."
                )
                faq(
                    q: "Why was I charged twice?",
                    a: "Usually a failed booking that still charged — check Recent activity in Wallet. Refunds show as a positive entry."
                )
            }
            Section("Contact") {
                Label("hello@smartparking.app", systemImage: "envelope")
                Label("WhatsApp +91 98765 00011", systemImage: "message")
            }
        }
        .navigationTitle("Help")
    }

    @ViewBuilder
    private func faq(q: String, a: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(q)
                .font(Typography.headline)
            Text(a)
                .font(Typography.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 2)
    }
}
