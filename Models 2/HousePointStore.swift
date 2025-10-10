import Foundation
import SwiftUI

class HousePointStore: ObservableObject {
    @Published var users: [User] = []
    @Published var chores: [Chore] = []
    @Published var rewards: [Reward] = []
    private let choresKey = "chores"
    private let rewardsKey = "rewards"
    
    @Published var currentUserId: UUID? = nil {
        didSet { saveData() }
    }
    
    init() {
        loadData()
        
        // If no parent account exists, create one for testing
        if !users.contains(where: { $0.isParent }) {
            let parent = User(id: UUID(), username: "parent", password: "1234", points: 0, isParent: true)
            users.append(parent)
            saveData()
        }
    }
    
    var currentUser: User? {
        users.first { $0.id == currentUserId }
    }
    
    var currentParent: User? {
        users.first { $0.isParent }
    }
    
    func login(username: String, password: String = "") -> Bool {
        if let user = users.first(where: {
            $0.username.lowercased() == username.lowercased() &&
            (($0.isParent && $0.password == password) || !$0.isParent)
        }) {
            currentUserId = user.id
            return true
        }
        return false
    }
    
    func registerParent(username: String, password: String) -> Bool {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else { return false }
        
        if users.contains(where: { $0.isParent }) {
            return false
        }
        
        let newUser = User(id: UUID(), username: username, password: password, points: 0, isParent: true)
        users.append(newUser)
        saveData()
        return true
    }
    
    func addChild(username: String) -> Bool {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if users.contains(where: { $0.username.lowercased() == username.lowercased() }) {
            return false
        }
        
        let newUser = User(id: UUID(), username: username, password: "", points: 0, isParent: false)
        users.append(newUser)
        saveData()
        return true
    }
    
    func logout() {
        currentUserId = nil
        saveData()
    }
    
    func assignChore(_ chore: Chore, to user: User) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].assignedTo = user.id
            saveData()
        }
    }
    
    func unassignChore(_ chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].assignedTo = nil
            saveData()
        }
    }

    
    func approveChore(_ chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].isCompleted = true
            
            if let userId = chores[index].assignedTo,
               let userIndex = users.firstIndex(where: { $0.id == userId }) {
                users[userIndex].points += 10
            }
            saveData()
        }
    }
    
    func unapproveChore(_ chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].isCompleted = false
            
            if let userId = chores[index].assignedTo,
               let userIndex = users.firstIndex(where: { $0.id == userId }) {
                users[userIndex].points -= 10
                if users[userIndex].points < 0 { users[userIndex].points = 0 }
            }
        }
    }
    
    
    func redeemReward(_ reward: Reward, for user: User) -> Bool {
        if let userIndex = users.firstIndex(where: { $0.id == user.id }) {
            if users[userIndex].points >= reward.cost {
                users[userIndex].points -= reward.cost
                saveData()
                return true
            }
        }
        return false
    }
    
    func saveData() {
        if let encodedUsers = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encodedUsers, forKey: "users")
        }
        if let encodedChores = try? JSONEncoder().encode(chores) {
            UserDefaults.standard.set(encodedChores, forKey: "chores")
        }
        if let encodedRewards = try? JSONEncoder().encode(rewards) {
            UserDefaults.standard.set(encodedRewards, forKey: "rewards")
        }
    }
    
    func loadData() {
        if let savedUsers = UserDefaults.standard.data(forKey: "users"),
           let decodedUsers = try? JSONDecoder().decode([User].self, from: savedUsers) {
            users = decodedUsers
        }
        
        if let savedChores = UserDefaults.standard.data(forKey: "chores"),
           let decodedChores = try? JSONDecoder().decode([Chore].self, from: savedChores) {
            chores = decodedChores
        }
        
        if let savedRewards = UserDefaults.standard.data(forKey: "rewards"),
           let decodedRewards = try? JSONDecoder().decode([Reward].self, from: savedRewards) {
            rewards = decodedRewards
        }
    }
}

