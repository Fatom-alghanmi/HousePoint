//
//  Reward.swift
//  HousePoint
//
//  Created by Fatom on 2025-10-10.
//

import Foundation

struct Reward: Identifiable, Codable {
    let id: UUID
    var name: String
    var cost: Int
}
