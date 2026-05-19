//
//  SessionManager.swift
//  H2S: Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import Foundation
import Combine

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    private let sessionsKey = "savedTrainingSessions"
    
    @Published var sessions: [TrainingSession] = []
    
    private init() {
        loadSessions()
    }
    
    func saveSession(_ session: TrainingSession) {
        sessions.append(session)
        saveSessions()
        // Update records for all strikes in session
        for strike in session.strikes {
            RecordsManager.shared.updateRecords(with: strike)
        }
    }
    
    func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey),
              let decoded = try? JSONDecoder().decode([TrainingSession].self, from: data) else {
            sessions = []
            return
        }
        sessions = decoded
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }
    
    var lastSession: TrainingSession? {
        sessions.max(by: { $0.startTime < $1.startTime })
    }
    
    var todaySessions: [TrainingSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDateInToday($0.startTime) }
    }
    
    var sessionsThisWeek: [TrainingSession] {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return [] }
        return sessions.filter { $0.startTime >= weekStart }
    }
    
    var strikesThisWeek: Int {
        sessionsThisWeek.reduce(0) { $0 + $1.strikes.count }
    }
    
    var averageH2SThisWeek: Double {
        let allStrikes = sessionsThisWeek.flatMap(\.strikes)
        guard !allStrikes.isEmpty else { return 0 }
        return allStrikes.map(\.h2sIndex).reduce(0, +) / Double(allStrikes.count)
    }
}
