//
//  HomeView.swift
//  H2S Hit to Strong
//

import SwiftUI

struct HomeView: View {
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var recordsManager = RecordsManager.shared
    @StateObject private var programManager = ProgramManager.shared
    @StateObject private var workoutManager = WorkoutManager.shared
    
    @State private var selectedMode: TrainingMode?
    @State private var sessionLaunch: SessionLaunch?
    @State private var showProgress = false
    @State private var showHistory = false
    @State private var showRecords = false
    @State private var showPrograms = false
    @State private var showAchievements = false
    @State private var showTimer = false
    @State private var showComparison = false
    @State private var showSettings = false
    @State private var showCustomWorkouts = false
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    quickStartWidget
                    statsGridWidget
                    
                    if let program = programManager.activeProgram {
                        activeProgramWidget(program: program)
                    }
                    
                    lastSessionWidget
                    
                    if !workoutManager.workouts.isEmpty {
                        myWorkoutsWidget
                    }
                    
                    quickActionsWidget
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 32)
            }
        }
        .fullScreenCover(item: $selectedMode) { mode in
            LiveSessionView(mode: mode)
        }
        .fullScreenCover(item: $sessionLaunch) { launch in
            LiveSessionView(mode: launch.mode, goals: launch.goals)
        }
        .sheet(isPresented: $showProgress) { TrainingProgressView() }
        .sheet(isPresented: $showHistory) { SessionHistoryView() }
        .sheet(isPresented: $showRecords) { RecordsView() }
        .sheet(isPresented: $showPrograms) { TrainingProgramsView() }
        .sheet(isPresented: $showAchievements) { AchievementsView() }
        .sheet(isPresented: $showTimer) { TrainingTimerView() }
        .sheet(isPresented: $showComparison) { StrikeComparisonView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showCustomWorkouts) { CustomWorkoutsView() }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
                
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("H2S")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("Hit to Strong")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "24CFA4"))
                }
            }
            
            Spacer()
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.teal)
                    .frame(width: 44, height: 44)
                    .glassCard(accent: AppTheme.teal, cornerRadius: 22)
            }
        }
    }
    
    // MARK: - Quick Start
    
    private var quickStartWidget: some View {
        HomeWidgetCard(accent: AppTheme.teal, elevated: true) {
            VStack(alignment: .leading, spacing: 16) {
                HomeWidgetHeader(
                    title: "Start Training",
                    subtitle: "Choose your mode",
                    icon: "bolt.fill",
                    accent: Color(hex: "24CFA4")
                )
                
                HStack(spacing: 12) {
                    QuickStartButton(
                        title: "Shadow",
                        icon: "hand.raised.fill",
                        color: Color(hex: "8B309C")
                    ) {
                        selectedMode = .shadowBoxing
                    }
                    
                    QuickStartButton(
                        title: "Bag Work",
                        icon: "target",
                        color: Color(hex: "24CFA4")
                    ) {
                        selectedMode = .bagWork
                    }
                }
            }
        }
    }
    
    // MARK: - Stats Grid
    
    private var statsGridWidget: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            StatWidget(
                title: "Total Strikes",
                value: "\(recordsManager.records.totalStrikes)",
                icon: "hand.raised.fill",
                accent: Color(hex: "24CFA4")
            )
            
            StatWidget(
                title: "This Week",
                value: "\(sessionManager.strikesThisWeek)",
                icon: "calendar",
                accent: Color(hex: "8B309C")
            )
            
            StatWidget(
                title: "Max H2S",
                value: "\(Int(recordsManager.records.maxH2SIndex))",
                icon: "star.fill",
                accent: Color(hex: "24CFA4")
            )
            
            StatWidget(
                title: "Streak",
                value: "\(recordsManager.records.currentStreak)d",
                icon: "flame.fill",
                accent: Color(hex: "8B309C")
            )
        }
    }
    
    // MARK: - Active Program
    
    private func activeProgramWidget(program: TrainingProgram) -> some View {
        let session = programManager.getCurrentSession()
        let progress = Double(programManager.currentDay) / Double(program.duration)
        
        return HomeWidgetCard(accent: AppTheme.teal, elevated: true) {
            VStack(alignment: .leading, spacing: 14) {
                HomeWidgetHeader(
                    title: "Active Program",
                    subtitle: program.name,
                    icon: "list.bullet.rectangle",
                    accent: Color(hex: "24CFA4")
                )
                
                HStack {
                    Text("Day \(programManager.currentDay) of \(program.duration)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "24CFA4"))
                }
                
                GradientProgressBar(progress: progress, accent: AppTheme.teal)
                
                if let session {
                    HStack(spacing: 16) {
                        Label("\(session.targetStrikes) strikes", systemImage: "hand.raised.fill")
                        Label("H2S \(Int(session.targetH2SIndex))", systemImage: "star.fill")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                }
                
                Button("Continue Program") { showPrograms = true }
                    .buttonStyle(PrimaryGradientButtonStyle(accent: AppTheme.teal))
            }
        }
    }
    
    // MARK: - Last Session
    
    private var lastSessionWidget: some View {
        HomeWidgetCard(accent: AppTheme.purple) {
            VStack(alignment: .leading, spacing: 14) {
                HomeWidgetHeader(
                    title: sessionManager.todaySessions.isEmpty ? "Recent Activity" : "Today",
                    subtitle: sessionManager.todaySessions.isEmpty
                        ? "Your last session"
                        : "\(sessionManager.todaySessions.count) session\(sessionManager.todaySessions.count == 1 ? "" : "s") today",
                    icon: "clock.fill",
                    accent: Color(hex: "8B309C")
                )
                
                if let session = sessionManager.lastSession {
                    HStack(spacing: 0) {
                        SessionStatColumn(
                            value: "\(session.strikes.count)",
                            label: "Strikes"
                        )
                        Divider()
                            .frame(height: 36)
                            .background(Color.white.opacity(0.15))
                        SessionStatColumn(
                            value: String(format: "%.0f", session.averageH2SIndex),
                            label: "Avg H2S"
                        )
                        Divider()
                            .frame(height: 36)
                            .background(Color.white.opacity(0.15))
                        SessionStatColumn(
                            value: session.mode == .shadowBoxing ? "Shadow" : "Bag",
                            label: "Mode"
                        )
                    }
                    
                    Text(session.startTime, style: .relative)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "figure.boxing")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.2))
                        Text("No sessions yet — start your first training!")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.45))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                
                Button(action: { showHistory = true }) {
                    HStack {
                        Text("View History")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "8B309C"))
                }
            }
        }
    }
    
    // MARK: - My Workouts
    
    private var myWorkoutsWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Workouts")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button("See All") { showCustomWorkouts = true }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "24CFA4"))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: { showCustomWorkouts = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color(hex: "24CFA4"))
                            Text("New")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(width: 80, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "24CFA4").opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        )
                    }
                    
                    ForEach(workoutManager.workouts.prefix(5)) { workout in
                        WorkoutChip(workout: workout) {
                            sessionLaunch = SessionLaunch(
                                mode: workout.mode,
                                goals: WorkoutGoals(
                                    workoutName: workout.name,
                                    targetStrikes: workout.targetStrikes,
                                    targetH2SIndex: workout.targetH2SIndex
                                )
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(title: "Quick Actions", accent: AppTheme.teal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionTile(title: "Timer", icon: "timer", color: Color(hex: "24CFA4")) {
                    showTimer = true
                }
                QuickActionTile(title: "Progress", icon: "chart.line.uptrend.xyaxis", color: Color(hex: "8B309C")) {
                    showProgress = true
                }
                QuickActionTile(title: "Programs", icon: "list.bullet", color: Color(hex: "24CFA4")) {
                    showPrograms = true
                }
                QuickActionTile(title: "Records", icon: "trophy.fill", color: Color(hex: "8B309C")) {
                    showRecords = true
                }
                QuickActionTile(title: "Workouts", icon: "figure.boxing", color: Color(hex: "24CFA4")) {
                    showCustomWorkouts = true
                }
                QuickActionTile(title: "Compare", icon: "arrow.left.arrow.right", color: Color(hex: "8B309C")) {
                    showComparison = true
                }
                QuickActionTile(title: "Achieve", icon: "star.fill", color: Color(hex: "24CFA4")) {
                    showAchievements = true
                }
                QuickActionTile(title: "Settings", icon: "gearshape.fill", color: Color(hex: "8B309C")) {
                    showSettings = true
                }
            }
        }
    }
}

// MARK: - Reusable Widget Components

struct HomeWidgetCard<Content: View>: View {
    var accent: Color
    var elevated: Bool = false
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        Group {
            if elevated {
                content().padding(16).elevatedCard(accent: accent, cornerRadius: 18)
            } else {
                content().padding(16).glassCard(accent: accent, cornerRadius: 18)
            }
        }
    }
}

struct HomeWidgetHeader: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    
    var body: some View {
        HStack(spacing: 12) {
            GradientIconBadge(icon: icon, accent: accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
    }
}

struct StatWidget: View {
    let title: String
    let value: String
    let icon: String
    let accent: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(accent)
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassCard(accent: accent, cornerRadius: 16)
    }
}

struct QuickStartButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .glassCard(accent: color, cornerRadius: 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SessionStatColumn: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
    }
}

struct WorkoutChip: View {
    let workout: CustomWorkout
    let onStart: () -> Void
    
    var body: some View {
        Button(action: onStart) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: workout.mode == .shadowBoxing ? "hand.raised.fill" : "target")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "24CFA4"))
                
                Text(workout.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("\(workout.targetStrikes) · H2S \(Int(workout.targetH2SIndex))")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.45))
            }
            .frame(width: 120, height: 100, alignment: .topLeading)
            .padding(12)
            .glassCard(accent: AppTheme.teal, cornerRadius: 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionTile: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .glassCard(accent: color, cornerRadius: 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
