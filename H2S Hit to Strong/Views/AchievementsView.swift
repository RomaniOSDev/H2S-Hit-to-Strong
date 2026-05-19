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
                AppBackgroundView(style: .sheet)
                
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
                            
                            GradientProgressBar(
                                progress: Double(unlockedAchievements.count) / Double(max(recordsManager.achievements.count, 1)),
                                accent: AppTheme.teal,
                                height: 8
                            )
                            .padding(.horizontal, 40)
                        }
                        .padding(.top, 20)
                        
                        // Unlocked Achievements
                        if !unlockedAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                AppSectionTitle(title: "Unlocked", accent: AppTheme.teal)
                                
                                ForEach(unlockedAchievements) { achievement in
                                    AchievementCard(achievement: achievement, isUnlocked: true)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Locked Achievements
                        if !lockedAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                AppSectionTitle(title: "Locked", accent: AppTheme.purple)
                                
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
                    .fill(
                        RadialGradient(
                            colors: [
                                (isUnlocked ? AppTheme.teal : AppTheme.purple).opacity(0.22),
                                Color.white.opacity(0.04)
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 32
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle().stroke((isUnlocked ? AppTheme.teal : AppTheme.purple).opacity(0.35), lineWidth: 1)
                    )
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? AppTheme.teal : .white.opacity(0.3))
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
        .glassCard(accent: isUnlocked ? AppTheme.teal : AppTheme.purple, cornerRadius: 14)
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
