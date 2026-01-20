//
//  ProgramManager.swift
//  H2S Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import Foundation
import Combine

class ProgramManager: ObservableObject {
    static let shared = ProgramManager()
    
    private let programsKey = "trainingPrograms"
    private let activeProgramKey = "activeProgram"
    
    @Published var programs: [TrainingProgram] = []
    @Published var activeProgram: TrainingProgram?
    @Published var currentDay: Int = 1
    
    private init() {
        loadPrograms()
        loadActiveProgram()
        initializeDefaultPrograms()
    }
    
    func startProgram(_ program: TrainingProgram) {
        activeProgram = program
        currentDay = 1
        saveActiveProgram()
    }
    
    func completeDay() {
        guard let program = activeProgram else { return }
        if currentDay < program.duration {
            currentDay += 1
        } else {
            // Program completed
            activeProgram = nil
            currentDay = 1
        }
        saveActiveProgram()
    }
    
    func createCustomProgram(name: String, description: String, duration: Int, sessions: [TrainingProgram.ProgramSession]) {
        let program = TrainingProgram(
            id: UUID(),
            name: name,
            description: description,
            duration: duration,
            sessions: sessions,
            isCustom: true
        )
        programs.append(program)
        savePrograms()
    }
    
    func getCurrentSession() -> TrainingProgram.ProgramSession? {
        guard let program = activeProgram,
              currentDay <= program.sessions.count else { return nil }
        return program.sessions[currentDay - 1]
    }
    
    private func initializeDefaultPrograms() {
        if programs.isEmpty {
            programs = [
                TrainingProgram(
                    id: UUID(),
                    name: "Beginner's Path",
                    description: "4-week program for beginners",
                    duration: 28,
                    sessions: (1...28).map { day in
                        TrainingProgram.ProgramSession(
                            day: day,
                            targetStrikes: min(20 + (day * 2), 100),
                            targetH2SIndex: min(50.0 + (Double(day) * 1.5), 85.0),
                            mode: day % 2 == 0 ? .bagWork : .shadowBoxing
                        )
                    },
                    isCustom: false
                ),
                TrainingProgram(
                    id: UUID(),
                    name: "Power Builder",
                    description: "Focus on increasing strike power",
                    duration: 21,
                    sessions: (1...21).map { day in
                        TrainingProgram.ProgramSession(
                            day: day,
                            targetStrikes: 50,
                            targetH2SIndex: 70.0 + (Double(day) * 0.5),
                            mode: .bagWork
                        )
                    },
                    isCustom: false
                ),
                TrainingProgram(
                    id: UUID(),
                    name: "Speed & Technique",
                    description: "Improve speed and form",
                    duration: 14,
                    sessions: (1...14).map { day in
                        TrainingProgram.ProgramSession(
                            day: day,
                            targetStrikes: 30,
                            targetH2SIndex: 75.0,
                            mode: .shadowBoxing
                        )
                    },
                    isCustom: false
                )
            ]
            savePrograms()
        }
    }
    
    private func loadPrograms() {
        if let data = UserDefaults.standard.data(forKey: programsKey),
           let decoded = try? JSONDecoder().decode([TrainingProgram].self, from: data) {
            programs = decoded
        }
    }
    
    private func savePrograms() {
        if let encoded = try? JSONEncoder().encode(programs) {
            UserDefaults.standard.set(encoded, forKey: programsKey)
        }
    }
    
    private func loadActiveProgram() {
        if let programIdData = UserDefaults.standard.data(forKey: activeProgramKey),
           let programId = try? JSONDecoder().decode(UUID.self, from: programIdData),
           let program = programs.first(where: { $0.id == programId }) {
            activeProgram = program
        }
        currentDay = UserDefaults.standard.integer(forKey: "currentProgramDay")
        if currentDay == 0 { currentDay = 1 }
    }
    
    private func saveActiveProgram() {
        if let program = activeProgram,
           let encoded = try? JSONEncoder().encode(program.id) {
            UserDefaults.standard.set(encoded, forKey: activeProgramKey)
            UserDefaults.standard.set(currentDay, forKey: "currentProgramDay")
        } else {
            UserDefaults.standard.removeObject(forKey: activeProgramKey)
            UserDefaults.standard.removeObject(forKey: "currentProgramDay")
        }
    }
}
