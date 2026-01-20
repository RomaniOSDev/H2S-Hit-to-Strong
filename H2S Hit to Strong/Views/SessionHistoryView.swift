//
//  SessionHistoryView.swift
//  H2S Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI

struct SessionHistoryView: View {
    @StateObject private var sessionManager = SessionManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedSession: TrainingSession?
    @State private var filterMode: TrainingMode?
    
    var filteredSessions: [TrainingSession] {
        let sorted = sessionManager.sessions.sorted { $0.startTime > $1.startTime }
        if let mode = filterMode {
            return sorted.filter { $0.mode == mode }
        }
        return sorted
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                if filteredSessions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text("No Training History")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Start training to see your sessions here")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Filter buttons
                            HStack(spacing: 12) {
                                FilterButton(title: "All", isSelected: filterMode == nil) {
                                    filterMode = nil
                                }
                                
                                FilterButton(title: "Shadow Boxing", isSelected: filterMode == .shadowBoxing) {
                                    filterMode = .shadowBoxing
                                }
                                
                                FilterButton(title: "Bag Work", isSelected: filterMode == .bagWork) {
                                    filterMode = .bagWork
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Sessions list
                            ForEach(filteredSessions) { session in
                                SessionCard(session: session) {
                                    selectedSession = session
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Training History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "24CFA4"))
                }
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "24CFA4") : Color.white.opacity(0.1))
                )
        }
    }
}

struct SessionCard: View {
    let session: TrainingSession
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatDate(session.startTime))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(session.mode.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "24CFA4"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(session.strikes.count)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "8B309C"))
                        
                        Text("strikes")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                HStack(spacing: 20) {
                    StatItem(title: "H2S Index", value: String(format: "%.0f", session.averageH2SIndex), color: Color(hex: "24CFA4"))
                    
                    if let duration = session.duration {
                        StatItem(title: "Duration", value: formatDuration(duration), color: .white.opacity(0.7))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

struct SessionDetailView: View {
    let session: TrainingSession
    @Environment(\.dismiss) var dismiss
    @State private var selectedStrike: Strike?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Session info
                        VStack(spacing: 12) {
                            Text(formatDate(session.startTime))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(session.mode.rawValue)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "24CFA4"))
                            
                            if let duration = session.duration {
                                Text(formatDuration(duration))
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.top, 20)
                        
                        // Stats
                        HStack(spacing: 20) {
                            SessionStatCard(title: "Strikes", value: "\(session.strikes.count)", color: Color(hex: "8B309C"))
                            SessionStatCard(title: "Avg H2S", value: String(format: "%.0f", session.averageH2SIndex), color: Color(hex: "24CFA4"))
                        }
                        .padding(.horizontal, 20)
                        
                        // Strikes list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Strikes")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ForEach(session.strikes) { strike in
                                StrikeRow(strike: strike) {
                                    selectedStrike = strike
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "24CFA4"))
                }
            }
            .sheet(item: $selectedStrike) { strike in
                StrikeAnalysisView(strike: strike)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d min %d sec", minutes, seconds)
    }
}

struct SessionStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct StrikeRow: View {
    let strike: Strike
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(strike.strikeType.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(formatTime(strike.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("H2S: \(Int(strike.h2sIndex))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "24CFA4"))
                    
                    Text("\(String(format: "%.1f", strike.peakAcceleration)) G")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B309C"))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    SessionHistoryView()
}
