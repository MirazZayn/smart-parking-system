import Foundation

@MainActor
@Observable
final class BookingsSync {
    static let shared = BookingsSync()

    private(set) var revision = 0

    func notifyChanged() {
        revision += 1
    }
}
