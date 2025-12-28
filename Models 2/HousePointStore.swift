import Foundation
import SwiftUI
import UserNotifications

class HousePointStore: ObservableObject {
    @Published var users: [User] = []
    @Published var chores: [Chore] = []
    @Published var rewards: [Reward] = []
    @Published var pendingRewardRequests: [PendingReward] = []
    @Published var currentUserId: UUID? = nil { didSet { saveData() } }

    // MARK: - Initialization
    init() {
        loadData()
        if !users.contains(where: { $0.isParent }) {
            let parent = User(
                id: UUID(),
                username: "parent",
                password: "1234",
                points: 0,
                isParent: true,
                familyId: UUID()
            )
            users.append(parent)
            saveData()
        }
    }

    // MARK: - Current User & Family
    var currentUser: User? {
        users.first { $0.id == currentUserId }
    }

    var currentFamilyId: UUID? {
        currentUser?.familyId
    }

    var childrenInFamily: [User] {
        guard let familyId = currentFamilyId else { return [] }
        return users.filter { $0.familyId == familyId && !$0.isParent }
    }

    var choresInFamily: [Chore] {
        guard let familyId = currentFamilyId else { return [] }
        return chores.filter { $0.familyId == familyId }
    }

    var rewardsInFamily: [Reward] {
        guard let familyId = currentFamilyId else { return [] }
        return rewards.filter { $0.familyId == familyId }
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

    func registerParent(username: String, password: String) -> String? {
        if users.contains(where: { $0.username.lowercased() == username.lowercased() }) {
            return "Username is already taken."
        }

        let familyId = UUID()
        let parent = User(
            id: UUID(),
            username: username,
            password: password,
            points: 0,
            isParent: true,
            familyId: familyId
        )

        users.append(parent)
        currentUserId = parent.id
        saveData()
        return nil
    }

    func addChild(username: String) -> Bool {
        guard let parent = currentUser, parent.isParent else { return false }

        let trimmed = username.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        if users.contains(where: { $0.username.lowercased() == trimmed.lowercased() }) { return false }

        let newChild = User(
            id: UUID(),
            username: trimmed,
            password: "",
            points: 0,
            isParent: false,
            familyId: parent.familyId
        )

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
        guard user.familyId == currentFamilyId else { return }
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].assignedTo = user.id
            chores[index].isCompleted = false
            chores[index].isMarkedDoneByChild = false
            chores[index].familyId = user.familyId
            saveData()
        }
    }

    func markChoreDoneByChild(_ chore: Chore) {
        guard let choreIndex = chores.firstIndex(where: { $0.id == chore.id }),
              let userId = chores[choreIndex].assignedTo,
              let userIndex = users.firstIndex(where: { $0.id == userId }) else { return }

        chores[choreIndex].isMarkedDoneByChild = true
        chores[choreIndex].isCompleted = false
        users[userIndex].pendingPoints += 10
        saveData()
    }

    func approveChore(_ chore: Chore) {
        guard let choreIndex = chores.firstIndex(where: { $0.id == chore.id }),
              let userId = chores[choreIndex].assignedTo,
              let userIndex = users.firstIndex(where: { $0.id == userId }) else { return }

        chores[choreIndex].isCompleted = true
        chores[choreIndex].isMarkedDoneByChild = false

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

    // MARK: - Chore Image Handling
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

    // MARK: - Rewards
    func requestReward(_ reward: Reward, by user: User) {
        guard user.familyId == currentFamilyId else { return }
        if !pendingRewardRequests.contains(where: { $0.userId == user.id && $0.reward.id == reward.id }) {
            var r = reward
            r.familyId = user.familyId
            let item = PendingReward(id: UUID(), userId: user.id, reward: r)
            pendingRewardRequests.append(item)
            saveData()
        }
    }

    func approveReward(_ request: PendingReward) {
        guard let rIndex = pendingRewardRequests.firstIndex(where: { $0.id == request.id }),
              let uIndex = users.firstIndex(where: { $0.id == request.userId }) else { return }
        let cost = pendingRewardRequests[rIndex].reward.cost
        users[uIndex].points = max(0, users[uIndex].points - cost)
        pendingRewardRequests.remove(at: rIndex)
        saveData()
    }

    func denyReward(_ request: PendingReward) {
        pendingRewardRequests.removeAll { $0.id == request.id }
        saveData()
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
