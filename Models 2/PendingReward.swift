//
//  PendingReward.swift
//  HousePoint
//
//  Created by Fatom on 2025-12-07.
//

import Foundation

struct PendingReward: Identifiable, Codable {
    var id: UUID
    var userId: UUID
    var reward: Reward
}
