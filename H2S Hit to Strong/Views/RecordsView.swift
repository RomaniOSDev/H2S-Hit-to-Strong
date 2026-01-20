//
//  RecordsView.swift
//  H2S Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI

struct RecordsView: View {
    @StateObject private var recordsManager = RecordsManager.shared
    @State private var showCalibration = false
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
                            Text("Records & Calibration")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Personal Records
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Personal Records")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                RecordCard(
                                    title: "Max Force",
                                    value: String(format: "%.1f G", recordsManager.records.maxForce),
                                    icon: "bolt.fill",
                                    color: Color(hex: "8B309C")
                                )
                                
                                RecordCard(
                                    title: "Max H2S Index",
                                    value: String(format: "%.0f", recordsManager.records.maxH2SIndex),
                                    icon: "star.fill",
                                    color: Color(hex: "24CFA4")
                                )
                                
                                RecordCard(
                                    title: "Max Stability",
                                    value: String(format: "%.0f%%", recordsManager.records.maxStability),
                                    icon: "target",
                                    color: Color(hex: "24CFA4")
                                )
                                
                                RecordCard(
                                    title: "Fastest Time to Peak",
                                    value: String(format: "%.3f s", recordsManager.records.fastestTimeToPeak == Double.infinity ? 0 : recordsManager.records.fastestTimeToPeak),
                                    icon: "timer",
                                    color: Color(hex: "24CFA4")
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Statistics
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Statistics")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                RecordsStatCard(
                                    title: "Total Strikes",
                                    value: "\(recordsManager.records.totalStrikes)",
                                    color: Color(hex: "8B309C")
                                )
                                
                                RecordsStatCard(
                                    title: "Total Sessions",
                                    value: "\(recordsManager.records.totalSessions)",
                                    color: Color(hex: "24CFA4")
                                )
                            }
                            
                            HStack(spacing: 12) {
                                RecordsStatCard(
                                    title: "Current Streak",
                                    value: "\(recordsManager.records.currentStreak) days",
                                    color: Color(hex: "24CFA4")
                                )
                                
                                RecordsStatCard(
                                    title: "Longest Streak",
                                    value: "\(recordsManager.records.longestStreak) days",
                                    color: Color(hex: "8B309C")
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Calibration
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Calibration")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Calibration Max")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text("Set your personal maximum force for accurate H2S Index calculation")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(String(format: "%.1f", recordsManager.records.calibrationMax)) G")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(hex: "24CFA4"))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                                
                                Button(action: { showCalibration = true }) {
                                    Text("Calibrate")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color(hex: "24CFA4"))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Records")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "24CFA4"))
                }
            }
            .sheet(isPresented: $showCalibration) {
                CalibrationView()
            }
        }
    }
}

struct RecordCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct RecordsStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 24, weight: .bold))
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

struct CalibrationView: View {
    @StateObject private var recordsManager = RecordsManager.shared
    @State private var calibrationValue: Double = 20.0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Set Calibration Max")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Text("Perform your maximum power strike and enter the force value")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text("\(String(format: "%.1f", calibrationValue)) G")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(Color(hex: "24CFA4"))
                        .monospacedDigit()
                    
                    VStack(spacing: 12) {
                        Slider(value: $calibrationValue, in: 5...50, step: 0.1)
                            .tint(Color(hex: "24CFA4"))
                            .padding(.horizontal, 40)
                        
                        HStack {
                            Text("5 G")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Spacer()
                            
                            Text("50 G")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    Button(action: {
                        recordsManager.setCalibration(max: calibrationValue)
                        dismiss()
                    }) {
                        Text("Save Calibration")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "24CFA4"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
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
            .onAppear {
                calibrationValue = recordsManager.records.calibrationMax
            }
        }
    }
}

#Preview {
    RecordsView()
}
