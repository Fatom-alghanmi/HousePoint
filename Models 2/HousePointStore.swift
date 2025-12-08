import Foundation
import SwiftUI
import UserNotifications

class HousePointStore: ObservableObject {
    @Published var users: [User] = []
    @Published var chores: [Chore] = []
    @Published var rewards: [Reward] = []
    @Published var pendingRewardRequests: [PendingReward] = []
    @Published var currentUserId: UUID? = nil { didSet { saveData() } }
    
    init() {
        loadData()
        // Ensure at least one parent exists
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
    
    // MARK: - Login & Registration
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
        guard !username.isEmpty, !password.isEmpty else { return false }
        if users.contains(where: { $0.isParent }) { return false }
        let newUser = User(id: UUID(), username: username, password: password, points: 0, isParent: true)
        users.append(newUser)
        saveData()
        return true
    }
    
    func addChild(username: String) -> Bool {
        guard !username.isEmpty else { return false }
        if users.contains(where: { $0.username.lowercased() == username.lowercased() }) { return false }
        let newChild = User(id: UUID(), username: username, password: "", points: 0, isParent: false)
        users.append(newChild)
        saveData()
        return true
    }
    
    func logout() {
        currentUserId = nil
        saveData()
    }
    
    // MARK: - Chores
    func assignChore(_ chore: Chore, to user: User) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].assignedTo = user.id
            chores[index].isCompleted = false
            chores[index].isMarkedDoneByChild = false
            saveData()
            sendChoreNotification(to: user, choreTitle: chore.title)
        }
    }
    
    func markChoreDoneByChild(_ chore: Chore) {
        guard let choreIndex = chores.firstIndex(where: { $0.id == chore.id }),
              let userId = chores[choreIndex].assignedTo,
              let userIndex = users.firstIndex(where: { $0.id == userId }) else { return }
        
        chores[choreIndex].isMarkedDoneByChild = true
        chores[choreIndex].isCompleted = false
        
        // Add 10 pending points
        users[userIndex].pendingPoints += 10
        saveData()
    }
    
    func approveChore(_ chore: Chore) {
        guard let choreIndex = chores.firstIndex(where: { $0.id == chore.id }),
              let userId = chores[choreIndex].assignedTo,
              let userIndex = users.firstIndex(where: { $0.id == userId }) else { return }

        chores[choreIndex].isCompleted = true
        chores[choreIndex].isMarkedDoneByChild = false

        // Move 10 points from pending → points
        let earned = min(10, users[userIndex].pendingPoints)
        users[userIndex].pendingPoints -= earned
        users[userIndex].points += earned

        saveData()
    }
    
    func unapproveChore(_ chore: Chore) {
        guard let choreIndex = chores.firstIndex(where: { $0.id == chore.id }),
              let userId = chores[choreIndex].assignedTo,
              let userIndex = users.firstIndex(where: { $0.id == userId }) else { return }

        chores[choreIndex].isCompleted = false

        let removedPoints = min(10, users[userIndex].points)
        users[userIndex].points -= removedPoints
        users[userIndex].pendingPoints += removedPoints

        saveData()
    }
    
    // MARK: - Image
    func addImage(_ image: UIImage, to chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }),
           let data = image.jpegData(compressionQuality: 0.8) {
            chores[index].imageData = data
            saveData()
        }
    }
    
    func removeImage(from chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].imageData = nil
            saveData()
        }
    }
    
    // MARK: - Reward Requests
    func requestReward(_ reward: Reward, by user: User) {
        // Avoid duplicate pending requests
        if !pendingRewardRequests.contains(where: { $0.userId == user.id && $0.reward.id == reward.id }) {
            let item = PendingReward(id: UUID(), userId: user.id, reward: reward)
            pendingRewardRequests.append(item)
            saveData()
        }
    }
    
    func approveReward(_ request: PendingReward) {
        if let rIndex = pendingRewardRequests.firstIndex(where: { $0.id == request.id }),
           let uIndex = users.firstIndex(where: { $0.id == request.userId }) {
            let cost = pendingRewardRequests[rIndex].reward.cost
            users[uIndex].points = max(0, users[uIndex].points - cost)
            pendingRewardRequests.remove(at: rIndex)
            saveData()
        }
    }
    
    func denyReward(_ request: PendingReward) {
        pendingRewardRequests.removeAll { $0.id == request.id }
        saveData()
    }
    
    // MARK: - Notifications
    private func sendChoreNotification(to user: User, choreTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "New Chore Assigned!"
        content.body = "Hi \(user.username), you have a new chore: \(choreTitle)."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Save & Load
    func saveData() {
        UserDefaults.standard.set(try? JSONEncoder().encode(users), forKey: "users")
        UserDefaults.standard.set(try? JSONEncoder().encode(chores), forKey: "chores")
        UserDefaults.standard.set(try? JSONEncoder().encode(rewards), forKey: "rewards")
        UserDefaults.standard.set(try? JSONEncoder().encode(pendingRewardRequests), forKey: "pendingRewards")
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "users"),
           let decoded = try? JSONDecoder().decode([User].self, from: data) { users = decoded }
        if let data = UserDefaults.standard.data(forKey: "chores"),
           let decoded = try? JSONDecoder().decode([Chore].self, from: data) { chores = decoded }
        if let data = UserDefaults.standard.data(forKey: "rewards"),
           let decoded = try? JSONDecoder().decode([Reward].self, from: data) { rewards = decoded }
        if let data = UserDefaults.standard.data(forKey: "pendingRewards"),
           let decoded = try? JSONDecoder().decode([PendingReward].self, from: data) { pendingRewardRequests = decoded }
    }
}
