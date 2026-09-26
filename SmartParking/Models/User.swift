import Foundation

struct User: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var name: String
    var email: String
    var phone: String
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        phone: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.createdAt = createdAt
    }

    var firstName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }
}
