//
//  Chore.swift
//  HousePoint
//
//  Created by Fatom on 2025-10-10.
//

import Foundation

struct Chore: Identifiable, Codable {
    let id: UUID
    var title: String
    var assignedTo: UUID?
    var isCompleted: Bool
}
