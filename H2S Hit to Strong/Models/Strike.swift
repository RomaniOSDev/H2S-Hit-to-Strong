//
//  Strike.swift
//  H2S: Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import Foundation

struct Strike: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let peakAcceleration: Double // Peak acceleration in G
    let timeToPeak: TimeInterval // Time from start to peak in seconds
    let accelerationData: [AccelerationPoint] // Full acceleration curve
    let h2sIndex: Double // Calculated H2S index (0-100)
    let stability: Double // Stability score (0-100)
    let strikeType: StrikeType // Type of strike
    
    struct AccelerationPoint: Codable {
        let time: TimeInterval
        let acceleration: Double
    }
}

enum StrikeType: String, Codable, CaseIterable {
    case jab = "Jab"
    case cross = "Cross"
    case hook = "Hook"
    case uppercut = "Uppercut"
    case bodyShot = "Body Shot"
    case combination = "Combination"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .jab: return "arrow.right"
        case .cross: return "arrow.forward"
        case .hook: return "arrow.turn.up.right"
        case .uppercut: return "arrow.up"
        case .bodyShot: return "arrow.down"
        case .combination: return "arrow.triangle.2.circlepath"
        case .other: return "circle"
        }
    }
}

struct TrainingSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    let mode: TrainingMode
    let strikes: [Strike]
    
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    var averageH2SIndex: Double {
        guard !strikes.isEmpty else { return 0 }
        return strikes.map { $0.h2sIndex }.reduce(0, +) / Double(strikes.count)
    }
}

enum TrainingMode: String, Codable {
    case shadowBoxing = "Phone in hand"
    case bagWork = "Phone mounted"
}

// MARK: - Training Program
struct TrainingProgram: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let duration: Int // in days
    let sessions: [ProgramSession]
    let isCustom: Bool
    
    struct ProgramSession: Codable {
        let day: Int
        let targetStrikes: Int
        let targetH2SIndex: Double
        let mode: TrainingMode
    }
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    enum AchievementCategory: String, Codable {
        case strikes = "Strikes"
        case sessions = "Sessions"
        case power = "Power"
        case consistency = "Consistency"
        case streak = "Streak"
    }
}

// MARK: - User Records
struct UserRecords: Codable {
    var maxForce: Double = 0.0
    var maxH2SIndex: Double = 0.0
    var maxStability: Double = 0.0
    var fastestTimeToPeak: TimeInterval = Double.infinity
    var totalStrikes: Int = 0
    var totalSessions: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var calibrationMax: Double = 20.0 // Default calibration
    
    mutating func updateWith(strike: Strike) {
        if strike.peakAcceleration > maxForce {
            maxForce = strike.peakAcceleration
        }
        if strike.h2sIndex > maxH2SIndex {
            maxH2SIndex = strike.h2sIndex
        }
        if strike.stability > maxStability {
            maxStability = strike.stability
        }
        if strike.timeToPeak < fastestTimeToPeak {
            fastestTimeToPeak = strike.timeToPeak
        }
    }
}
