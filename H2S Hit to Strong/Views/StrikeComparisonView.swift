//
//  StrikeComparisonView.swift
//  H2S Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI
import Charts

struct StrikeComparisonView: View {
    @StateObject private var sessionManager = SessionManager.shared
    @State private var strike1: Strike?
    @State private var strike2: Strike?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                if strike1 == nil || strike2 == nil {
                    VStack(spacing: 20) {
                        Text("Select Two Strikes")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Choose strikes from your training history to compare")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(getAllStrikes()) { strike in
                                    StrikeSelectionRow(strike: strike) {
                                        if strike1 == nil {
                                            strike1 = strike
                                        } else if strike2 == nil {
                                            strike2 = strike
                                        } else {
                                            strike1 = strike
                                            strike2 = nil
                                        }
                                    }
                                }
                            }
                            .padding(20)
                        }
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Comparison Header
                            VStack(spacing: 12) {
                                Text("Strike Comparison")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 20) {
                                    ComparisonHeader(strike: strike1!, title: "Strike 1", color: Color(hex: "8B309C"))
                                    ComparisonHeader(strike: strike2!, title: "Strike 2", color: Color(hex: "24CFA4"))
                                }
                            }
                            .padding(.top, 20)
                            
                            // Acceleration Comparison
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Acceleration Comparison")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Chart {
                                    if let strike1 = strike1 {
                                        ForEach(Array(strike1.accelerationData.enumerated()), id: \.offset) { index, point in
                                            LineMark(
                                                x: .value("Time", point.time),
                                                y: .value("G-force", point.acceleration)
                                            )
                                            .foregroundStyle(Color(hex: "8B309C"))
                                            .interpolationMethod(.catmullRom)
                                        }
                                    }
                                    
                                    if let strike2 = strike2 {
                                        ForEach(Array(strike2.accelerationData.enumerated()), id: \.offset) { index, point in
                                            LineMark(
                                                x: .value("Time", point.time),
                                                y: .value("G-force", point.acceleration)
                                            )
                                            .foregroundStyle(Color(hex: "24CFA4"))
                                            .interpolationMethod(.catmullRom)
                                        }
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
                            
                            // Metrics Comparison
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Metrics")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                if let strike1 = strike1, let strike2 = strike2 {
                                    ComparisonMetric(title: "Peak Force", value1: String(format: "%.1f G", strike1.peakAcceleration), value2: String(format: "%.1f G", strike2.peakAcceleration), better: strike1.peakAcceleration > strike2.peakAcceleration ? 1 : 2)
                                    
                                    ComparisonMetric(title: "Time to Peak", value1: String(format: "%.3f s", strike1.timeToPeak), value2: String(format: "%.3f s", strike2.timeToPeak), better: strike1.timeToPeak < strike2.timeToPeak ? 1 : 2)
                                    
                                    ComparisonMetric(title: "H2S Index", value1: String(format: "%.0f", strike1.h2sIndex), value2: String(format: "%.0f", strike2.h2sIndex), better: strike1.h2sIndex > strike2.h2sIndex ? 1 : 2)
                                    
                                    ComparisonMetric(title: "Stability", value1: String(format: "%.0f%%", strike1.stability), value2: String(format: "%.0f%%", strike2.stability), better: strike1.stability > strike2.stability ? 1 : 2)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("Compare Strikes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if strike1 != nil && strike2 != nil {
                        Button("Reset") {
                            strike1 = nil
                            strike2 = nil
                        }
                        .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "24CFA4"))
                }
            }
        }
    }
    
    private func getAllStrikes() -> [Strike] {
        sessionManager.sessions.flatMap { $0.strikes }.sorted { $0.timestamp > $1.timestamp }
    }
}

struct StrikeSelectionRow: View {
    let strike: Strike
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: strike.strikeType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "24CFA4"))
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(strike.strikeType.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(formatDate(strike.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("H2S: \(Int(strike.h2sIndex))")
                        .font(.system(size: 14, weight: .bold))
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ComparisonHeader: View {
    let strike: Strike
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Text(strike.strikeType.rawValue)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            
            Text("H2S: \(Int(strike.h2sIndex))")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 2)
                )
        )
    }
}

struct ComparisonMetric: View {
    let title: String
    let value1: String
    let value2: String
    let better: Int // 1 or 2
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                
                HStack {
                    Text(value1)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(better == 1 ? Color(hex: "24CFA4") : .white)
                    
                    if better == 1 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "24CFA4"))
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                
                HStack {
                    if better == 2 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "24CFA4"))
                    }
                    
                    Text(value2)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(better == 2 ? Color(hex: "24CFA4") : .white)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    StrikeComparisonView()
}
