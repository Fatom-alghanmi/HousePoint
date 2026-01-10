//
//  HousePointStore.swift
//  HousePoint
//
//  Created by Fatom
//

import Foundation
import SwiftUI
import UserNotifications

class HousePointStore: ObservableObject {

    // MARK: - Published Data
    @Published var users: [User] = []
    @Published var chores: [Chore] = []
    @Published var rewards: [Reward] = []
    @Published var pendingRewardRequests: [PendingReward] = []
    @Published var currentUserId: UUID? = nil { didSet { saveData() } }

    // MARK: - Constants
    let minimumPointsToRedeem = 25

    // MARK: - Initialization
    init() {
        loadData()
        requestNotificationPermission()

        // Ensure a default parent exists
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

    // MARK: - Notifications Permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }

    private func isQuietHours() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 20 || hour < 8
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

    // MARK: - Login & Logout
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

    func logout() {
        currentUserId = nil
        saveData()
    }

    // MARK: - Parent Registration
    func registerParent(username: String, password: String) -> String? {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)

        guard !trimmedUsername.isEmpty else { return "Username cannot be empty" }
        guard !trimmedPassword.isEmpty else { return "Password cannot be empty" }

        if users.contains(where: { $0.username.lowercased() == trimmedUsername.lowercased() }) {
            return "Username already exists"
        }

        let newParent = User(
            id: UUID(),
            username: trimmedUsername,
            password: trimmedPassword,
            points: 0,
            isParent: true,
            familyId: UUID()
        )

        users.append(newParent)
        saveData()
        return nil
    }

    // MARK: - Rewards Deny
    func denyReward(_ request: PendingReward) {
        guard let index = pendingRewardRequests.firstIndex(where: { $0.id == request.id }) else { return }
        pendingRewardRequests.remove(at: index)
        saveData()
    }

    // MARK: - Child Management
    func addChild(username: String) -> Bool {
        guard let parent = currentUser, parent.isParent else { return false }

        let trimmed = username.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        if users.contains(where: { $0.username.lowercased() == trimmed.lowercased() }) {
            return false
        }

        let child = User(
            id: UUID(),
            username: trimmed,
            password: "",
            points: 0,
            isParent: false,
            familyId: parent.familyId
        )

        users.append(child)
        saveData()
        return true
    }
    
    // MARK: - Child Management

    func removeChild(_ child: User) {
        guard let parent = currentUser, parent.isParent else { return }
        guard !child.isParent else { return } // cannot remove parent
        guard let index = users.firstIndex(where: { $0.id == child.id }) else { return }

        // Optional: Remove child's chores
        chores.removeAll { $0.assignedTo == child.id }

        // Optional: Remove pending rewards by this child
        pendingRewardRequests.removeAll { $0.userId == child.id }

        // Remove child from users
        users.remove(at: index)

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

            sendChoreAssignedNotification(to: user, chore: chores[index])
            scheduleChoreReminder(for: chores[index], user: user)
            saveData()
        }
    }

    func toggleChoreDoneByChild(_ chore: Chore) {
        guard let cIndex = chores.firstIndex(where: { $0.id == chore.id }),
              let uId = chores[cIndex].assignedTo,
              let uIndex = users.firstIndex(where: { $0.id == uId }) else { return }

        if chores[cIndex].isMarkedDoneByChild {
            // Undo marking done
            chores[cIndex].isMarkedDoneByChild = false
            users[uIndex].pendingPoints -= chores[cIndex].basePoints
        } else {
            // Mark done
            chores[cIndex].isMarkedDoneByChild = true
            users[uIndex].pendingPoints += chores[cIndex].basePoints
        }
        saveData()
    }

    func approveChore(_ chore: Chore) {
        guard let cIndex = chores.firstIndex(where: { $0.id == chore.id }),
              let uId = chores[cIndex].assignedTo,
              let uIndex = users.firstIndex(where: { $0.id == uId }) else { return }

        chores[cIndex].isCompleted = true
        chores[cIndex].isMarkedDoneByChild = false

        let earned = min(chores[cIndex].basePoints, users[uIndex].pendingPoints)
        users[uIndex].pendingPoints -= earned
        users[uIndex].points += earned

        sendChoreApprovedNotification(to: users[uIndex], chore: chores[cIndex])
        saveData()
    }

    // MARK: - Add Image to Chore
    func addImage(_ image: UIImage, to chore: Chore) {
        guard let index = chores.firstIndex(where: { $0.id == chore.id }) else { return }
        chores[index].image = image
        saveData()
    }

    // MARK: - Rewards
    func requestReward(_ reward: Reward, by user: User) {
        // Only allow request if user has enough points
        guard user.points >= reward.cost else { return }

        if !pendingRewardRequests.contains(where: {
            $0.userId == user.id && $0.reward.id == reward.id
        }) {
            let item = PendingReward(
                id: UUID(),
                userId: user.id,
                reward: reward
            )
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

    // MARK: - Notifications
    private func sendChoreAssignedNotification(to user: User, chore: Chore) {
        if isQuietHours() { return }
        let content = UNMutableNotificationContent()
        content.title = "New Chore 🧹"
        content.body = "\(chore.title) was assigned to you!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        )
    }

    private func sendChoreApprovedNotification(to user: User, chore: Chore) {
        if isQuietHours() { return }
        let content = UNMutableNotificationContent()
        content.title = "Chore Approved 🎉"
        content.body = "Great job! \(chore.title) was approved!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        )
    }

    private func scheduleChoreReminder(for chore: Chore, user: User) {
        guard let dueDate = chore.dueDate else { return }
        if isQuietHours() { return }

        let content = UNMutableNotificationContent()
        content.title = "Chore Reminder ⏰"
        content.body = "Don't forget: \(chore.title)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate),
            repeats: false
        )

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: chore.id.uuidString, content: content, trigger: trigger)
        )
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
           let decoded = try? JSONDecoder().decode([User].self, from: data) {
            users = decoded
        }

        if let data = UserDefaults.standard.data(forKey: "chores"),
           let decoded = try? JSONDecoder().decode([Chore].self, from: data) {
            chores = decoded
        }

        if let data = UserDefaults.standard.data(forKey: "rewards"),
           let decoded = try? JSONDecoder().decode([Reward].self, from: data) {
            rewards = decoded
        }

        if let data = UserDefaults.standard.data(forKey: "pendingRewards"),
           let decoded = try? JSONDecoder().decode([PendingReward].self, from: data) {
            pendingRewardRequests = decoded
        }
    }

}
