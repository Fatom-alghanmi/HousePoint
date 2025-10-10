//
//  HousePointStore.swift
//  HousePoint
//
//  Created by Fatom on 2025-10-09.
//


import Foundation
import SwiftUI

class HousePointStore: ObservableObject {
    @Published var users: [User] = [
        User(id: UUID(), username: "parent", password: "1234", points: 0, isParent: true),
        User(id: UUID(), username: "child", password: "1234", points: 0, isParent: false)
    ]
    
    @Published var chores: [Chore] = [
        Chore(id: UUID(), title: "Clean your room", assignedTo: nil, isCompleted: false),
        Chore(id: UUID(), title: "Wash the dishes", assignedTo: nil, isCompleted: false)
    ]
    
    @Published var rewards: [Reward] = [
        Reward(id: UUID(), name: "Movie Night", cost: 50),
        Reward(id: UUID(), name: "Ice Cream", cost: 20)
    ]
    
    @Published var currentUserId: UUID? = nil
    
    var currentUser: User? {
        users.first { $0.id == currentUserId }
    }
    
    func login(username: String, password: String) -> Bool {
        if let user = users.first(where: { $0.username == username && $0.password == password }) {
            currentUserId = user.id
            return true
        }
        return false
    }
    
    func logout() {
        currentUserId = nil
    }
    
    func assignChore(_ chore: Chore, to user: User) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].assignedTo = user.id
        }
    }
    
    func completeChore(_ chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].isCompleted = true
            
            if let userId = chores[index].assignedTo,
               let userIndex = users.firstIndex(where: { $0.id == userId }) {
                users[userIndex].points += 10
            }
        }
    }
    
    func redeemReward(_ reward: Reward) -> Bool {
        guard let userId = currentUserId,
              let userIndex = users.firstIndex(where: { $0.id == userId }) else { return false }
        
        if users[userIndex].points >= reward.cost {
            users[userIndex].points -= reward.cost
            return true
        } else {
            return false
        }
    }
}
