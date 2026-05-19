//
//  WorkoutManager.swift
//  H2S Hit to Strong
//

import Foundation
import Combine

class WorkoutManager: ObservableObject {
    static let shared = WorkoutManager()
    
    private let workoutsKey = "customWorkouts"
    
    @Published var workouts: [CustomWorkout] = []
    
    private init() {
        loadWorkouts()
    }
    
    func addWorkout(_ workout: CustomWorkout) {
        workouts.append(workout)
        saveWorkouts()
    }
    
    func updateWorkout(_ workout: CustomWorkout) {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else { return }
        workouts[index] = workout
        saveWorkouts()
    }
    
    func deleteWorkout(_ workout: CustomWorkout) {
        workouts.removeAll { $0.id == workout.id }
        saveWorkouts()
    }
    
    private func loadWorkouts() {
        if let data = UserDefaults.standard.data(forKey: workoutsKey),
           let decoded = try? JSONDecoder().decode([CustomWorkout].self, from: data) {
            workouts = decoded
        }
    }
    
    private func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: workoutsKey)
        }
    }
}
