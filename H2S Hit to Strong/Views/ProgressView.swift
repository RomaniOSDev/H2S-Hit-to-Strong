//
//  ProgressView.swift
//  H2S: Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI
import Charts

struct TrainingProgressView: View {
    @StateObject private var sessionManager = SessionManager.shared
    @State private var selectedTimeframe: Timeframe = .month
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progress & Goals")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Picker("Timeframe", selection: $selectedTimeframe) {
                                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                                    Text(timeframe.rawValue).tag(timeframe)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // H2S Index Evolution Chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("H2S Index Evolution")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            if !filteredSessions.isEmpty {
                                Chart {
                                    ForEach(Array(filteredSessions.enumerated()), id: \.element.id) { index, session in
                                        LineMark(
                                            x: .value("Session", index + 1),
                                            y: .value("H2S Index", session.averageH2SIndex)
                                        )
                                        .foregroundStyle(Color(hex: "24CFA4"))
                                        .interpolationMethod(.catmullRom)
                                        
                                        PointMark(
                                            x: .value("Session", index + 1),
                                            y: .value("H2S Index", session.averageH2SIndex)
                                        )
                                        .foregroundStyle(Color(hex: "8B309C"))
                                        .symbolSize(60)
                                    }
                                }
                                .frame(height: 200)
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { value in
                                        AxisGridLine()
                                            .foregroundStyle(.white.opacity(0.2))
                                        AxisValueLabel()
                                            .foregroundStyle(.white.opacity(0.7))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(values: .automatic) { value in
                                        AxisGridLine()
                                            .foregroundStyle(.white.opacity(0.2))
                                        AxisValueLabel()
                                            .foregroundStyle(.white.opacity(0.7))
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.3))
                                    
                                    Text("No data yet")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    Text("Start training to see your progress")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Statistics Cards
                        HStack(spacing: 12) {
                            ProgressStatCard(
                                title: "Total Sessions",
                                value: "\(sessionManager.sessions.count)",
                                color: Color(hex: "8B309C")
                            )
                            
                            ProgressStatCard(
                                title: "Total Strikes",
                                value: "\(totalStrikes)",
                                color: Color(hex: "24CFA4")
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Goals Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Goals")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            GoalCard(
                                title: "Increase average strike force by 15%",
                                timeframe: "this month",
                                progress: 0.45,
                                color: Color(hex: "24CFA4")
                            )
                            
                            GoalCard(
                                title: "Improve H2S Index consistency",
                                timeframe: "this week",
                                progress: 0.72,
                                color: Color(hex: "8B309C")
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { sessionManager.loadSessions() }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color(hex: "24CFA4"))
                    }
                }
            }
        }
    }
    
    private var filteredSessions: [TrainingSession] {
        let calendar = Calendar.current
        let now = Date()
        let cutoffDate: Date
        
        switch selectedTimeframe {
        case .week:
            cutoffDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .month:
            cutoffDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return sessionManager.sessions.filter { $0.startTime >= cutoffDate }
    }
    
    private var totalStrikes: Int {
        sessionManager.sessions.reduce(0) { $0 + $1.strikes.count }
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct GoalCard: View {
    let title: String
    let timeframe: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(timeframe)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    TrainingProgressView()
}
