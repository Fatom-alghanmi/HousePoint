


import Foundation

struct User: Identifiable, Codable, Equatable {
    var id: UUID
    var username: String
    var password: String
    var points: Int
    var isParent: Bool
}
