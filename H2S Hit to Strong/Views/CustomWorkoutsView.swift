//
//  CustomWorkoutsView.swift
//  H2S Hit to Strong
//

import SwiftUI

struct CustomWorkoutsView: View {
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var showCreateWorkout = false
    @State private var editingWorkout: CustomWorkout?
    @State private var sessionLaunch: SessionLaunch?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackgroundView()
                
                if workoutManager.workouts.isEmpty {
                    emptyState
                } else {
                    workoutsList
                }
            }
            .navigationTitle("My Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "24CFA4"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateWorkout = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "24CFA4"))
                    }
                }
            }
            .sheet(isPresented: $showCreateWorkout) {
                WorkoutEditorView(workout: nil)
            }
            .sheet(item: $editingWorkout) { workout in
                WorkoutEditorView(workout: workout)
            }
            .fullScreenCover(item: $sessionLaunch) { launch in
                LiveSessionView(mode: launch.mode, goals: launch.goals)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.boxing")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: "24CFA4").opacity(0.5))
            
            Text("No Custom Workouts")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text("Create your own workouts with custom goals for strikes and H2S index")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showCreateWorkout = true }) {
                Label("Create Workout", systemImage: "plus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color(hex: "24CFA4"))
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
    }
    
    private var workoutsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(workoutManager.workouts) { workout in
                    CustomWorkoutCard(
                        workout: workout,
                        onStart: {
                            sessionLaunch = SessionLaunch(
                                mode: workout.mode,
                                goals: WorkoutGoals(
                                    workoutName: workout.name,
                                    targetStrikes: workout.targetStrikes,
                                    targetH2SIndex: workout.targetH2SIndex
                                )
                            )
                        },
                        onEdit: { editingWorkout = workout }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

struct CustomWorkoutCard: View {
    let workout: CustomWorkout
    let onStart: () -> Void
    let onEdit: () -> Void
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var showDeleteConfirm = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    if !workout.description.isEmpty {
                        Text(workout.description)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            HStack(spacing: 16) {
                Label("\(workout.targetStrikes) strikes", systemImage: "hand.raised.fill")
                Label("H2S \(Int(workout.targetH2SIndex))", systemImage: "star.fill")
                Label(workout.mode == .shadowBoxing ? "Shadow" : "Bag", systemImage: workout.mode == .shadowBoxing ? "hand.raised.fill" : "target")
            }
            .font(.system(size: 12))
            .foregroundColor(.white.opacity(0.5))
            
            HStack(spacing: 12) {
                Button(action: onStart) {
                    Text("Start")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "24CFA4"))
                        .cornerRadius(10)
                }
                
                Button(action: { showDeleteConfirm = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 15))
                        .foregroundColor(.red.opacity(0.8))
                        .frame(width: 44, height: 44)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .glassCard(accent: AppTheme.teal, cornerRadius: 14)
        .alert("Delete Workout?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                workoutManager.deleteWorkout(workout)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\"\(workout.name)\" will be permanently deleted.")
        }
    }
}

struct WorkoutEditorView: View {
    let workout: CustomWorkout?
    
    @StateObject private var workoutManager = WorkoutManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var mode: TrainingMode = .shadowBoxing
    @State private var targetStrikes = 30
    @State private var targetH2SIndex = 70.0
    @State private var selectedPreset: Int?
    
    private var isEditing: Bool { workout != nil }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if !isEditing {
                            presetsSection
                        }
                        
                        workoutForm
                        
                        saveButton
                    }
                    .padding(20)
                }
            }
            .navigationTitle(isEditing ? "Edit Workout" : "New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .onAppear { loadWorkout() }
        }
    }
    
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Templates")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(CustomWorkout.presets.enumerated()), id: \.offset) { index, preset in
                        Button(action: { applyPreset(preset, index: index) }) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(preset.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("\(preset.targetStrikes) strikes · H2S \(Int(preset.targetH2SIndex))")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedPreset == index
                                          ? Color(hex: "24CFA4").opacity(0.2)
                                          : Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedPreset == index ? Color(hex: "24CFA4") : Color.clear, lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var workoutForm: some View {
        VStack(spacing: 20) {
            formField(title: "Workout Name") {
                TextField("e.g. Morning Power", text: $name)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            formField(title: "Description (optional)") {
                TextField("What's the focus?", text: $description, axis: .vertical)
                    .textFieldStyle(CustomTextFieldStyle())
                    .lineLimit(2...4)
            }
            
            formField(title: "Training Mode") {
                Picker("Mode", selection: $mode) {
                    Text("Shadow Boxing").tag(TrainingMode.shadowBoxing)
                    Text("Bag Work").tag(TrainingMode.bagWork)
                }
                .pickerStyle(.segmented)
            }
            
            formField(title: "Target Strikes: \(targetStrikes)") {
                Slider(value: Binding(
                    get: { Double(targetStrikes) },
                    set: { targetStrikes = Int($0) }
                ), in: 10...100, step: 5)
                .tint(Color(hex: "24CFA4"))
            }
            
            formField(title: "Target H2S Index: \(Int(targetH2SIndex))") {
                Slider(value: $targetH2SIndex, in: 50...95, step: 5)
                    .tint(Color(hex: "8B309C"))
            }
        }
    }
    
    private var saveButton: some View {
                        Button(isEditing ? "Save Changes" : "Create Workout") { saveWorkout() }
                            .buttonStyle(PrimaryGradientButtonStyle())
                            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                            .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private func formField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            content()
        }
    }
    
    private func applyPreset(_ preset: CustomWorkout, index: Int) {
        selectedPreset = index
        name = preset.name
        description = preset.description
        mode = preset.mode
        targetStrikes = preset.targetStrikes
        targetH2SIndex = preset.targetH2SIndex
    }
    
    private func loadWorkout() {
        guard let workout else { return }
        name = workout.name
        description = workout.description
        mode = workout.mode
        targetStrikes = workout.targetStrikes
        targetH2SIndex = workout.targetH2SIndex
    }
    
    private func saveWorkout() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        if let existing = workout {
            var updated = existing
            updated.name = trimmedName
            updated.description = description
            updated.mode = mode
            updated.targetStrikes = targetStrikes
            updated.targetH2SIndex = targetH2SIndex
            workoutManager.updateWorkout(updated)
        } else {
            let newWorkout = CustomWorkout(
                id: UUID(),
                name: trimmedName,
                description: description,
                mode: mode,
                targetStrikes: targetStrikes,
                targetH2SIndex: targetH2SIndex,
                createdAt: Date()
            )
            workoutManager.addWorkout(newWorkout)
        }
        dismiss()
    }
}

struct SessionLaunch: Identifiable {
    let id = UUID()
    let mode: TrainingMode
    let goals: WorkoutGoals?
}

#Preview {
    CustomWorkoutsView()
}
