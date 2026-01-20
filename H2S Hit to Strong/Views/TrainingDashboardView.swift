//
//  TrainingDashboardView.swift
//  H2S: Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI

struct TrainingDashboardView: View {
    @State private var selectedMode: TrainingMode?
    @State private var showProgress = false
    @State private var showHistory = false
    @State private var showRecords = false
    @State private var showPrograms = false
    @State private var showAchievements = false
    @State private var showTimer = false
    @State private var showComparison = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            Color(hex: "0E0D12")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("H2S")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Hit to Strong")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "24CFA4"))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "24CFA4"))
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Menu {
                            Button(action: { showProgress = true }) {
                                Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                            }
                            Button(action: { showHistory = true }) {
                                Label("History", systemImage: "clock")
                            }
                            Button(action: { showRecords = true }) {
                                Label("Records", systemImage: "trophy")
                            }
                            Button(action: { showPrograms = true }) {
                                Label("Programs", systemImage: "list.bullet")
                            }
                            Button(action: { showAchievements = true }) {
                                Label("Achievements", systemImage: "star.fill")
                            }
                            Button(action: { showTimer = true }) {
                                Label("Timer", systemImage: "timer")
                            }
                            Button(action: { showComparison = true }) {
                                Label("Compare Strikes", systemImage: "arrow.left.arrow.right")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "24CFA4"))
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer()
                
                // Training Mode Cards
                VStack(spacing: 20) {
                    TrainingModeCard(
                        title: "Shadow Boxing",
                        subtitle: "Phone in hand",
                        description: "Analyze single strikes or combinations in the air",
                        color: Color(hex: "8B309C"),
                        icon: "hand.raised.fill"
                    ) {
                        selectedMode = .shadowBoxing
                    }
                    
                    TrainingModeCard(
                        title: "Bag Work",
                        subtitle: "Phone mounted",
                        description: "Analyze direct strike force on bag",
                        color: Color(hex: "24CFA4"),
                        icon: "target"
                    ) {
                        selectedMode = .bagWork
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .fullScreenCover(item: $selectedMode) { mode in
            LiveSessionView(mode: mode)
        }
        .sheet(isPresented: $showProgress) {
            TrainingProgressView()
        }
        .sheet(isPresented: $showHistory) {
            SessionHistoryView()
        }
        .sheet(isPresented: $showRecords) {
            RecordsView()
        }
        .sheet(isPresented: $showPrograms) {
            TrainingProgramsView()
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
        .sheet(isPresented: $showTimer) {
            TrainingTimerView()
        }
        .sheet(isPresented: $showComparison) {
            StrikeComparisonView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct TrainingModeCard: View {
    let title: String
    let subtitle: String
    let description: String
    let color: Color
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 4)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension TrainingMode: Identifiable {
    public var id: String { rawValue }
}

#Preview {
    TrainingDashboardView()
}
