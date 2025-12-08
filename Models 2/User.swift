


import Foundation

struct User: Identifiable, Codable, Equatable {
    var id: UUID
    var username: String
    var password: String
    var points: Int = 0
    var pendingPoints: Int = 0
    var isParent: Bool
    var pendingRewardRequest: Bool = false 
}
