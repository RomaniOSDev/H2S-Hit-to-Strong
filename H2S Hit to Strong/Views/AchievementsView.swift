//
//  AchievementsView.swift
//  H2S Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var recordsManager = RecordsManager.shared
    @Environment(\.dismiss) var dismiss
    
    var unlockedAchievements: [Achievement] {
        recordsManager.achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        recordsManager.achievements.filter { !$0.isUnlocked }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Stats
                        VStack(spacing: 12) {
                            Text("\(unlockedAchievements.count)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(hex: "24CFA4"))
                            
                            Text("of \(recordsManager.achievements.count) Achievements Unlocked")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(hex: "24CFA4"))
                                        .frame(width: geometry.size.width * (Double(unlockedAchievements.count) / Double(recordsManager.achievements.count)), height: 8)
                                }
                            }
                            .frame(height: 8)
                            .padding(.horizontal, 40)
                        }
                        .padding(.top, 20)
                        
                        // Unlocked Achievements
                        if !unlockedAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Unlocked")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                ForEach(unlockedAchievements) { achievement in
                                    AchievementCard(achievement: achievement, isUnlocked: true)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Locked Achievements
                        if !lockedAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Locked")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                ForEach(lockedAchievements) { achievement in
                                    AchievementCard(achievement: achievement, isUnlocked: false)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "24CFA4"))
                }
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color(hex: "24CFA4").opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? Color(hex: "24CFA4") : .white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))
                
                Text(achievement.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                
                if !isUnlocked {
                    Text("Requirement: \(getRequirementText())")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                } else if let date = achievement.unlockedDate {
                    Text("Unlocked: \(formatDate(date))")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "24CFA4").opacity(0.7))
                }
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "24CFA4"))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color(hex: "24CFA4").opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isUnlocked ? Color(hex: "24CFA4").opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
    
    private func getRequirementText() -> String {
        switch achievement.category {
        case .strikes, .sessions:
            return "\(achievement.requirement) \(achievement.category.rawValue.lowercased())"
        case .power:
            return "\(achievement.requirement)G force"
        case .consistency:
            return "\(achievement.requirement)% stability"
        case .streak:
            return "\(achievement.requirement) day streak"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    AchievementsView()
}
