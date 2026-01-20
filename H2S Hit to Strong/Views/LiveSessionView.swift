//
//  LiveSessionView.swift
//  H2S: Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI
import Charts

struct LiveSessionView: View {
    let mode: TrainingMode
    @Environment(\.dismiss) var dismiss
    
    @State private var sessionStartTime = Date()
    @State private var session: TrainingSession?
    @State private var strikes: [Strike] = []
    @State private var sessionTimer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var showAnalysis = false
    @State private var showAddStrike = false
    @State private var selectedStrike: Strike?
    
    var body: some View {
        ZStack {
            Color(hex: "0E0D12")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(mode.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button(action: { showAddStrike = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "24CFA4"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Main Indicators
                HStack(spacing: 40) {
                    // Force Indicator
                    CircularIndicator(
                        title: "FORCE",
                        value: forcePercentage,
                        displayValue: "PK: \(Int(latestStrike?.peakAcceleration ?? 0))",
                        color: Color(hex: "8B309C")
                    )
                    
                    // Speed Indicator
                    CircularIndicator(
                        title: "SPEED",
                        value: speedPercentage,
                        displayValue: "SPD: \(String(format: "%.2f", latestStrike?.timeToPeak ?? 0.0))s",
                        color: Color(hex: "24CFA4")
                    )
                }
                .padding(.top, 40)
                
                // H2S Index
                VStack(spacing: 12) {
                    Text("H2S INDEX")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(Int(currentH2SIndex))")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Last 5 strikes chart
                    if !strikes.isEmpty {
                        Chart {
                            ForEach(Array(strikes.suffix(5).enumerated()), id: \.element.id) { index, strike in
                                LineMark(
                                    x: .value("Strike", index + 1),
                                    y: .value("H2S", strike.h2sIndex)
                                )
                                .foregroundStyle(Color(hex: "24CFA4"))
                                .interpolationMethod(.catmullRom)
                                
                                PointMark(
                                    x: .value("Strike", index + 1),
                                    y: .value("H2S", strike.h2sIndex)
                                )
                                .foregroundStyle(Color(hex: "8B309C"))
                                .symbolSize(40)
                            }
                        }
                        .frame(height: 80)
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Bottom Panel
                VStack(spacing: 16) {
                    Button(action: {
                        if let strike = latestStrike {
                            selectedStrike = strike
                            showAnalysis = true
                        }
                    }) {
                        Text("Analyze Last Strike")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "8B309C"))
                            .cornerRadius(12)
                    }
                    .disabled(latestStrike == nil)
                    .opacity(latestStrike == nil ? 0.5 : 1.0)
                    
                    HStack(spacing: 30) {
                        VStack(spacing: 4) {
                            Text("TIME")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                            Text(formatTime(elapsedTime))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("STRIKES")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                            Text("\(strikes.count)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startSession()
        }
        .onDisappear {
            stopSession()
        }
        .sheet(isPresented: $showAddStrike) {
            AddStrikeView { strike in
                strikes.append(strike)
                RecordsManager.shared.updateRecords(with: strike)
            }
        }
        .sheet(isPresented: $showAnalysis) {
            if let strike = selectedStrike {
                StrikeAnalysisView(strike: strike)
            }
        }
    }
    
    private var latestStrike: Strike? {
        strikes.last
    }
    
    private var currentH2SIndex: Double {
        latestStrike?.h2sIndex ?? 0
    }
    
    private var forcePercentage: Double {
        guard let latest = latestStrike else { return 0 }
        // Normalize to 0-100 based on calibration
        return min(100, (latest.peakAcceleration / 20.0) * 100)
    }
    
    private var speedPercentage: Double {
        guard let latest = latestStrike else { return 0 }
        // Faster = higher percentage (inverse of time)
        let maxTime: TimeInterval = 1.0
        return min(100, ((maxTime - latest.timeToPeak) / maxTime) * 100)
    }
    
    private func startSession() {
        sessionStartTime = Date()
        let newSession = TrainingSession(
            id: UUID(),
            startTime: sessionStartTime,
            endTime: nil,
            mode: mode,
            strikes: []
        )
        session = newSession
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(sessionStartTime)
        }
    }
    
    private func stopSession() {
        sessionTimer?.invalidate()
        
        // Save session
        if let currentSession = session {
            let savedSession = TrainingSession(
                id: currentSession.id,
                startTime: currentSession.startTime,
                endTime: Date(),
                mode: currentSession.mode,
                strikes: strikes
            )
            SessionManager.shared.saveSession(savedSession)
            RecordsManager.shared.updateSessionCount()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CircularIndicator: View {
    let title: String
    let value: Double
    let displayValue: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 140, height: 140)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: value / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.3), value: value)
                
                // Value text
                Text(displayValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    LiveSessionView(mode: .shadowBoxing)
}
