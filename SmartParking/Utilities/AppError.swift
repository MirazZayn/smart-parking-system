import Foundation

enum AppError: LocalizedError, Equatable {
    case invalidCredentials
    case validation(String)
    case notFound(String)
    case bookingFailed(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .validation(let message),
             .notFound(let message),
             .bookingFailed(let message),
             .unknown(let message):
            return message
        }
    }
}
