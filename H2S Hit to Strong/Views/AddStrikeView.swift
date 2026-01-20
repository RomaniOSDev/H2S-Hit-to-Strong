//
//  AddStrikeView.swift
//  H2S: Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI

struct AddStrikeView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (Strike) -> Void
    
    @State private var peakForce: Double = 10.0
    @State private var timeToPeak: Double = 0.25
    @State private var stability: Double = 75.0
    @State private var strikeType: StrikeType = .jab
    
    private var h2sIndex: Double {
        let forceScore = min(100, (peakForce / 20.0) * 100)
        let speedScore = timeToPeak > 0 ? min(100, (0.5 / timeToPeak) * 100) : 0
        return (forceScore * 0.6) + (speedScore * 0.4)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Add Strike")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Enter strike data manually")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        // H2S Index Preview
                        VStack(spacing: 8) {
                            Text("H2S Index")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("\(Int(h2sIndex))")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(hex: "24CFA4"))
                        }
                        .padding(.vertical, 20)
                        
                        // Strike Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Strike Type")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                                ForEach(StrikeType.allCases, id: \.self) { type in
                                    Button(action: { strikeType = type }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: type.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(strikeType == type ? Color(hex: "24CFA4") : .white.opacity(0.6))
                                            
                                            Text(type.rawValue)
                                                .font(.system(size: 12, weight: strikeType == type ? .semibold : .regular))
                                                .foregroundColor(strikeType == type ? Color(hex: "24CFA4") : .white.opacity(0.7))
                                        }
                                        .frame(height: 80)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(strikeType == type ? Color(hex: "24CFA4").opacity(0.2) : Color.white.opacity(0.05))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(strikeType == type ? Color(hex: "24CFA4") : Color.clear, lineWidth: 2)
                                                )
                                        )
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Peak Force Input
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Peak Force")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(String(format: "%.1f", peakForce)) G")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "8B309C"))
                            }
                            
                            Slider(value: $peakForce, in: 1...30, step: 0.1)
                                .tint(Color(hex: "8B309C"))
                            
                            HStack {
                                Text("1 G")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Spacer()
                                
                                Text("30 G")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Time to Peak Input
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Time to Peak")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(String(format: "%.3f", timeToPeak)) s")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "24CFA4"))
                            }
                            
                            Slider(value: $timeToPeak, in: 0.1...1.0, step: 0.01)
                                .tint(Color(hex: "24CFA4"))
                            
                            HStack {
                                Text("0.1 s")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Spacer()
                                
                                Text("1.0 s")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Stability Input
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Stability")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(Int(stability))%")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "24CFA4"))
                            }
                            
                            Slider(value: $stability, in: 0...100, step: 1)
                                .tint(Color(hex: "24CFA4"))
                            
                            HStack {
                                Text("0%")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Spacer()
                                
                                Text("100%")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Save Button
                        Button(action: saveStrike) {
                            Text("Add Strike")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "8B309C"))
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    private func saveStrike() {
        // Generate sample acceleration data for visualization
        let accelerationData = generateAccelerationData(
            peak: peakForce,
            timeToPeak: timeToPeak
        )
        
        let strike = Strike(
            id: UUID(),
            timestamp: Date(),
            peakAcceleration: peakForce,
            timeToPeak: timeToPeak,
            accelerationData: accelerationData,
            h2sIndex: h2sIndex,
            stability: stability,
            strikeType: strikeType
        )
        
        onSave(strike)
        dismiss()
    }
    
    private func generateAccelerationData(peak: Double, timeToPeak: TimeInterval) -> [Strike.AccelerationPoint] {
        var data: [Strike.AccelerationPoint] = []
        let duration = timeToPeak * 2.5 // Total duration
        let steps = 50
        let stepSize = duration / Double(steps)
        
        for i in 0...steps {
            let time = Double(i) * stepSize
            let normalizedTime = time / duration
            
            // Create a smooth curve: rise to peak, then fall
            let acceleration: Double
            if normalizedTime < (timeToPeak / duration) {
                // Rising phase
                let progress = normalizedTime / (timeToPeak / duration)
                acceleration = peak * (1 - cos(progress * .pi / 2))
            } else {
                // Falling phase
                let progress = (normalizedTime - (timeToPeak / duration)) / (1 - (timeToPeak / duration))
                acceleration = peak * (1 - progress) * 0.3
            }
            
            data.append(Strike.AccelerationPoint(time: time, acceleration: max(0, acceleration)))
        }
        
        return data
    }
}

#Preview {
    AddStrikeView { _ in }
}
