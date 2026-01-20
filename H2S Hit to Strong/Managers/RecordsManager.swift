//
//  RecordsManager.swift
//  H2S Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import Foundation
import Combine

class RecordsManager: ObservableObject {
    static let shared = RecordsManager()
    
    private let recordsKey = "userRecords"
    private let achievementsKey = "userAchievements"
    
    @Published var records = UserRecords()
    @Published var achievements: [Achievement] = []
    
    private init() {
        loadRecords()
        initializeAchievements()
        loadAchievements()
    }
    
    func updateRecords(with strike: Strike) {
        records.updateWith(strike: strike)
        records.totalStrikes += 1
        saveRecords()
        checkAchievements()
    }
    
    func updateSessionCount() {
        records.totalSessions += 1
        saveRecords()
        checkAchievements()
    }
    
    func updateStreak(isNewDay: Bool) {
        if isNewDay {
            records.currentStreak += 1
            if records.currentStreak > records.longestStreak {
                records.longestStreak = records.currentStreak
            }
        } else {
            records.currentStreak = 0
        }
        saveRecords()
        checkAchievements()
    }
    
    func setCalibration(max: Double) {
        records.calibrationMax = max
        saveRecords()
    }
    
    private func checkAchievements() {
        var updated = false
        for i in 0..<achievements.count {
            if !achievements[i].isUnlocked {
                let shouldUnlock = checkAchievementRequirement(achievements[i])
                if shouldUnlock {
                    achievements[i].isUnlocked = true
                    achievements[i].unlockedDate = Date()
                    updated = true
                }
            }
        }
        if updated {
            objectWillChange.send()
            saveAchievements()
        }
    }
    
    private func checkAchievementRequirement(_ achievement: Achievement) -> Bool {
        switch achievement.category {
        case .strikes:
            return records.totalStrikes >= achievement.requirement
        case .sessions:
            return records.totalSessions >= achievement.requirement
        case .power:
            return records.maxForce >= Double(achievement.requirement)
        case .consistency:
            return records.maxStability >= Double(achievement.requirement)
        case .streak:
            return records.currentStreak >= achievement.requirement
        }
    }
    
    private func initializeAchievements() {
        if achievements.isEmpty {
            achievements = [
                Achievement(id: UUID(), title: "First Strike", description: "Record your first strike", icon: "star.fill", category: .strikes, requirement: 1, isUnlocked: false, unlockedDate: nil),
                Achievement(id: UUID(), title: "Power Beginner", description: "Reach 10G force", icon: "bolt.fill", category: .power, requirement: 10, isUnlocked: false, unlockedDate: nil),
                Achievement(id: UUID(), title: "Power Master", description: "Reach 20G force", icon: "bolt.circle.fill", category: .power, requirement: 20, isUnlocked: false, unlockedDate: nil),
                Achievement(id: UUID(), title: "Consistent", description: "Achieve 80% stability", icon: "target", category: .consistency, requirement: 80, isUnlocked: false, unlockedDate: nil),
                Achievement(id: UUID(), title: "Century", description: "Record 100 strikes", icon: "100.circle.fill", category: .strikes, requirement: 100, isUnlocked: false, unlockedDate: nil),
                Achievement(id: UUID(), title: "Dedicated", description: "Complete 10 sessions", icon: "calendar", category: .sessions, requirement: 10, isUnlocked: false, unlockedDate: nil),
                Achievement(id: UUID(), title: "On Fire", description: "7 day streak", icon: "flame.fill", category: .streak, requirement: 7, isUnlocked: false, unlockedDate: nil),
                Achievement(id: UUID(), title: "Perfect Form", description: "Achieve 95% stability", icon: "star.circle.fill", category: .consistency, requirement: 95, isUnlocked: false, unlockedDate: nil)
            ]
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode(UserRecords.self, from: data) {
            records = decoded
        }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            saveAchievements()
        }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
}
