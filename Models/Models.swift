import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var password: String
    var points: Int
    var isParent: Bool
}

struct Chore: Identifiable, Codable {
    let id: UUID
    var title: String
    var assignedTo: UUID?
    var isCompleted: Bool
}

struct Reward: Identifiable, Codable {
    let id: UUID
    var name: String
    var cost: Int
}
