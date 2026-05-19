//
//  TrainingProgramsView.swift
//  H2S Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI

struct TrainingProgramsView: View {
    @StateObject private var programManager = ProgramManager.shared
    @State private var selectedProgram: TrainingProgram?
    @State private var showCreateProgram = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackgroundView(style: .sheet)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Active Program
                        if let activeProgram = programManager.activeProgram {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Active Program")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                ActiveProgramCard(program: activeProgram, currentDay: programManager.currentDay)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        
                        // Available Programs
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Available Programs")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { showCreateProgram = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "24CFA4"))
                                }
                            }
                            
                            ForEach(programManager.programs) { program in
                                ProgramCard(program: program) {
                                    selectedProgram = program
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Training Programs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "24CFA4"))
                }
            }
            .sheet(item: $selectedProgram) { program in
                ProgramDetailView(program: program)
            }
            .sheet(isPresented: $showCreateProgram) {
                CreateProgramView()
            }
        }
    }
}

struct ActiveProgramCard: View {
    let program: TrainingProgram
    let currentDay: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(program.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(program.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Day \(currentDay)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "24CFA4"))
                    
                    Text("of \(program.duration)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Progress bar
            GradientProgressBar(
                progress: Double(currentDay) / Double(program.duration),
                accent: AppTheme.teal
            )
            
            if let session = program.sessions.first(where: { $0.day == currentDay }) {
                HStack {
                    Label("\(session.targetStrikes) strikes", systemImage: "hand.raised.fill")
                    Label("H2S: \(Int(session.targetH2SIndex))", systemImage: "star.fill")
                }
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(20)
        .elevatedCard(accent: AppTheme.teal, cornerRadius: 16)
    }
}

struct ProgramCard: View {
    let program: TrainingProgram
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(program.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(program.description)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    if program.isCustom {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(Color(hex: "24CFA4"))
                    }
                }
                
                HStack {
                    Label("\(program.duration) days", systemImage: "calendar")
                    Label("\(program.sessions.count) sessions", systemImage: "clock")
                }
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
            }
            .padding(16)
            .glassCard(accent: AppTheme.teal, cornerRadius: 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProgramDetailView: View {
    let program: TrainingProgram
    @StateObject private var programManager = ProgramManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showEditProgram = false
    @State private var showDeleteConfirm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackgroundView(style: .sheet)
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(program.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(program.description)
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack {
                                Label("\(program.duration) days", systemImage: "calendar")
                                Label("\(program.sessions.count) sessions", systemImage: "clock")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        
                        // Program sessions preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Program Overview")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            ForEach(Array(program.sessions.prefix(7).enumerated()), id: \.element.day) { index, session in
                                ProgramSessionRow(session: session, day: index + 1)
                            }
                            
                            if program.sessions.count > 7 {
                                Text("... and \(program.sessions.count - 7) more sessions")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.leading, 16)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Start button
                        Button(programManager.activeProgram?.id == program.id ? "Continue Program" : "Start Program") {
                            programManager.startProgram(program)
                            dismiss()
                        }
                        .buttonStyle(PrimaryGradientButtonStyle())
                        .padding(.horizontal, 20)
                        
                        if program.isCustom {
                            HStack(spacing: 12) {
                                Button(action: { showEditProgram = true }) {
                                    Label("Edit", systemImage: "pencil")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(hex: "24CFA4"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color(hex: "24CFA4").opacity(0.15))
                                        .cornerRadius(12)
                                }
                                
                                Button(action: { showDeleteConfirm = true }) {
                                    Label("Delete", systemImage: "trash")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.red.opacity(0.15))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Program Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "24CFA4"))
                }
            }
            .sheet(isPresented: $showEditProgram) {
                CreateProgramView(editingProgram: program)
            }
            .alert("Delete Program?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    programManager.deleteProgram(program)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("\"\(program.name)\" will be permanently deleted.")
            }
        }
    }
}

struct ProgramSessionRow: View {
    let session: TrainingProgram.ProgramSession
    let day: Int
    
    var body: some View {
        HStack {
            Text("Day \(day)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 60, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(session.targetStrikes) strikes")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Target H2S: \(Int(session.targetH2SIndex))")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Text(session.mode.rawValue)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "24CFA4"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "24CFA4").opacity(0.2))
                .cornerRadius(6)
        }
        .padding(12)
        .glassCard(accent: AppTheme.teal, cornerRadius: 10)
    }
}

enum ProgramDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var baseStrikes: Int {
        switch self {
        case .beginner: return 20
        case .intermediate: return 35
        case .advanced: return 50
        }
    }
    
    var baseH2S: Double {
        switch self {
        case .beginner: return 60
        case .intermediate: return 72
        case .advanced: return 82
        }
    }
}

struct CreateProgramView: View {
    var editingProgram: TrainingProgram? = nil
    
    @StateObject private var programManager = ProgramManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var duration = 7
    @State private var difficulty: ProgramDifficulty = .intermediate
    @State private var defaultMode: TrainingMode = .shadowBoxing
    @State private var useProgressive = true
    @State private var alternateModes = true
    
    private var isEditing: Bool { editingProgram != nil }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackgroundView(style: .sheet)
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Program Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Enter name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Enter description", text: $description, axis: .vertical)
                                .textFieldStyle(CustomTextFieldStyle())
                                .lineLimit(3...6)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duration: \(duration) days")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Stepper("", value: $duration, in: 3...30)
                                .labelsHidden()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Difficulty")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Picker("Difficulty", selection: $difficulty) {
                                ForEach(ProgramDifficulty.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Default Mode")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Picker("Mode", selection: $defaultMode) {
                                Text("Shadow Boxing").tag(TrainingMode.shadowBoxing)
                                Text("Bag Work").tag(TrainingMode.bagWork)
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        Toggle(isOn: $useProgressive) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Progressive Goals")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                Text("Increase targets each day")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .tint(Color(hex: "24CFA4"))
                        
                        Toggle(isOn: $alternateModes) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Alternate Modes")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                Text("Switch between shadow and bag")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .tint(Color(hex: "24CFA4"))
                        
                        sessionPreview
                        
                        Button(isEditing ? "Save Changes" : "Create Program") { saveProgram() }
                            .buttonStyle(PrimaryGradientButtonStyle())
                            .disabled(name.isEmpty)
                            .opacity(name.isEmpty ? 0.5 : 1)
                        .padding(.bottom, 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(isEditing ? "Edit Program" : "New Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
            .onAppear { loadProgram() }
        }
    }
    
    private var sessionPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preview (Day 1 → Day \(duration))")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            
            let sessions = buildSessions()
            if let first = sessions.first, let last = sessions.last {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Day 1")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "24CFA4"))
                        Text("\(first.targetStrikes) strikes · H2S \(Int(first.targetH2SIndex))")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white.opacity(0.3))
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Day \(duration)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "8B309C"))
                        Text("\(last.targetStrikes) strikes · H2S \(Int(last.targetH2SIndex))")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(14)
                .glassCard(accent: AppTheme.purple, cornerRadius: 10)
            }
        }
    }
    
    private func buildSessions() -> [TrainingProgram.ProgramSession] {
        (1...duration).map { day in
            let progress = useProgressive ? Double(day - 1) / Double(max(duration - 1, 1)) : 0
            let strikes = difficulty.baseStrikes + Int(progress * Double(difficulty.baseStrikes))
            let h2s = difficulty.baseH2S + progress * 15
            
            let mode: TrainingMode
            if alternateModes {
                mode = day % 2 == 0 ? .bagWork : .shadowBoxing
            } else {
                mode = defaultMode
            }
            
            return TrainingProgram.ProgramSession(
                day: day,
                targetStrikes: strikes,
                targetH2SIndex: min(h2s, 95),
                mode: mode
            )
        }
    }
    
    private func loadProgram() {
        guard let program = editingProgram else { return }
        name = program.name
        description = program.description
        duration = program.duration
        if let first = program.sessions.first {
            defaultMode = first.mode
        }
    }
    
    private func saveProgram() {
        let sessions = buildSessions()
        
        if let existing = editingProgram {
            let updated = TrainingProgram(
                id: existing.id,
                name: name,
                description: description,
                duration: duration,
                sessions: sessions,
                isCustom: true
            )
            programManager.updateProgram(updated)
        } else {
            programManager.createCustomProgram(
                name: name,
                description: description,
                duration: duration,
                sessions: sessions
            )
        }
        dismiss()
    }
}

typealias CustomTextFieldStyle = AppTextFieldStyle

#Preview {
    TrainingProgramsView()
}
