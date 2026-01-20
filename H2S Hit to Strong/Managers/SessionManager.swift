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
}
