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
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
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
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "24CFA4"))
                        .frame(width: geometry.size.width * (Double(currentDay) / Double(program.duration)), height: 8)
                }
            }
            .frame(height: 8)
            
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
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "24CFA4").opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "24CFA4"), lineWidth: 2)
                )
        )
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
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProgramDetailView: View {
    let program: TrainingProgram
    @StateObject private var programManager = ProgramManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
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
                        Button(action: {
                            programManager.startProgram(program)
                            dismiss()
                        }) {
                            Text(programManager.activeProgram?.id == program.id ? "Continue Program" : "Start Program")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "24CFA4"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
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
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct CreateProgramView: View {
    @StateObject private var programManager = ProgramManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var duration = 7
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Create Custom Program")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
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
                        
                        Button(action: {
                            let sessions = (1...duration).map { day in
                                TrainingProgram.ProgramSession(
                                    day: day,
                                    targetStrikes: 30,
                                    targetH2SIndex: 70.0,
                                    mode: day % 2 == 0 ? .bagWork : .shadowBoxing
                                )
                            }
                            
                            programManager.createCustomProgram(
                                name: name,
                                description: description,
                                duration: duration,
                                sessions: sessions
                            )
                            dismiss()
                        }) {
                            Text("Create Program")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(name.isEmpty ? Color.gray : Color(hex: "24CFA4"))
                                .cornerRadius(12)
                        }
                        .disabled(name.isEmpty)
                        .padding(.bottom, 40)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            .foregroundColor(.white)
    }
}

#Preview {
    TrainingProgramsView()
}
