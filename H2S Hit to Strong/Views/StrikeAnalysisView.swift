//
//  StrikeAnalysisView.swift
//  H2S: Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI
import Charts

struct StrikeAnalysisView: View {
    let strike: Strike
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Strike Analysis")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(formatDate(strike.timestamp))
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        // Acceleration Plot
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Acceleration Plot")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Chart {
                                // Overall acceleration line
                                ForEach(Array(strike.accelerationData.enumerated()), id: \.offset) { index, point in
                                    LineMark(
                                        x: .value("Time", point.time),
                                        y: .value("G-force", point.acceleration)
                                    )
                                    .foregroundStyle(Color(hex: "8B309C"))
                                    .interpolationMethod(.catmullRom)
                                }
                                
                                // Technique zone (ideal curve area)
                                if let peakTime = strike.accelerationData.max(by: { $0.acceleration < $1.acceleration }) {
                                    let idealStart = max(0, peakTime.time - 0.1)
                                    let idealEnd = min(strike.accelerationData.last?.time ?? 0, peakTime.time + 0.1)
                                    
                                    RectangleMark(
                                        xStart: .value("Start", idealStart),
                                        xEnd: .value("End", idealEnd),
                                        yStart: .value("Min", 0),
                                        yEnd: .value("Max", peakTime.acceleration * 1.2)
                                    )
                                    .foregroundStyle(Color(hex: "24CFA4").opacity(0.2))
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
                        }
                        .padding(.horizontal, 20)
                        
                        // Metrics
                        VStack(spacing: 16) {
                            MetricCard(
                                title: "Peak Force",
                                value: String(format: "%.1f G", strike.peakAcceleration),
                                color: Color(hex: "8B309C")
                            )
                            
                            MetricCard(
                                title: "Time to Peak",
                                value: String(format: "%.3f s", strike.timeToPeak),
                                color: Color(hex: "24CFA4")
                            )
                            
                            MetricCard(
                                title: "Stability",
                                value: String(format: "%.0f%%", strike.stability),
                                color: Color(hex: "24CFA4").opacity(0.8)
                            )
                            
                            MetricCard(
                                title: "H2S Index",
                                value: String(format: "%.0f", strike.h2sIndex),
                                color: .white
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // AI Advice
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "24CFA4"))
                                
                                Text("AI Analysis")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(generateAdvice())
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "24CFA4").opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "24CFA4").opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func generateAdvice() -> String {
        var advice: [String] = []
        
        if strike.peakAcceleration > 15 {
            advice.append("Powerful strike detected!")
        } else if strike.peakAcceleration < 8 {
            advice.append("Focus on generating more power from your core.")
        }
        
        if strike.timeToPeak > 0.3 {
            advice.append("You're delaying leg engagement. Try starting the movement with a foot push.")
        } else if strike.timeToPeak < 0.15 {
            advice.append("Excellent speed! Your technique is sharp.")
        }
        
        if strike.stability < 60 {
            advice.append("Work on maintaining a smoother acceleration curve for better control.")
        }
        
        if advice.isEmpty {
            return "Good technique! Keep practicing to improve consistency."
        }
        
        return advice.joined(separator: " ")
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    StrikeAnalysisView(strike: Strike(
        id: UUID(),
        timestamp: Date(),
        peakAcceleration: 12.5,
        timeToPeak: 0.23,
        accelerationData: [],
        h2sIndex: 87,
        stability: 75,
        strikeType: .jab
    ))
}
