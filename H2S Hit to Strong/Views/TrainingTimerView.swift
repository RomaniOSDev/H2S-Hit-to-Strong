//
//  TrainingTimerView.swift
//  H2S Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI
import AVFoundation
import Combine

struct TrainingTimerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var timer = TrainingTimer()
    
    var body: some View {
        ZStack {
            Color(hex: "0E0D12")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
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
                    
                    Text("Training Timer")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { timer.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Timer Display
                VStack(spacing: 20) {
                    Text(timer.isRest ? "REST" : "ROUND")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(timer.isRest ? Color(hex: "24CFA4") : Color(hex: "8B309C"))
                    
                    Text(timer.formattedTime)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    Text("Round \(timer.currentRound) of \(timer.totalRounds)")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Controls
                VStack(spacing: 16) {
                    // Main control button
                    Button(action: {
                        if timer.isRunning {
                            timer.pause()
                        } else {
                            timer.start()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 24))
                            Text(timer.isRunning ? "Pause" : "Start")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(timer.isRunning ? Color(hex: "8B309C") : Color(hex: "24CFA4"))
                        .cornerRadius(16)
                    }
                    
                    // Settings
                    HStack(spacing: 20) {
                        TimerSettingButton(title: "Round", value: "\(timer.roundDuration)s", color: Color(hex: "8B309C")) {
                            timer.showRoundSettings = true
                        }
                        
                        TimerSettingButton(title: "Rest", value: "\(timer.restDuration)s", color: Color(hex: "24CFA4")) {
                            timer.showRestSettings = true
                        }
                        
                        TimerSettingButton(title: "Rounds", value: "\(timer.totalRounds)", color: .white.opacity(0.7)) {
                            timer.showRoundsSettings = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $timer.showRoundSettings) {
            TimerSettingsView(title: "Round Duration", value: $timer.roundDuration, range: 30...600, step: 30)
        }
        .sheet(isPresented: $timer.showRestSettings) {
            TimerSettingsView(title: "Rest Duration", value: $timer.restDuration, range: 10...300, step: 10)
        }
        .sheet(isPresented: $timer.showRoundsSettings) {
            TimerSettingsView(title: "Total Rounds", value: $timer.totalRounds, range: 1...20, step: 1)
        }
    }
}

class TrainingTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval = 180 // 3 minutes default
    @Published var isRunning = false
    @Published var isRest = false
    @Published var currentRound = 1
    @Published var roundDuration: Int = 180
    @Published var restDuration: Int = 60
    @Published var totalRounds: Int = 3
    @Published var showRoundSettings = false
    @Published var showRestSettings = false
    @Published var showRoundsSettings = false
    
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 0.1
            } else {
                self.timeRemaining = 0
                self.completePeriod()
            }
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        isRest = false
        currentRound = 1
        timeRemaining = TimeInterval(roundDuration)
    }
    
    private func completePeriod() {
        playSound()
        pause()
        
        if isRest {
            // Rest finished, start next round
            isRest = false
            currentRound += 1
            if currentRound > totalRounds {
                // All rounds completed
                reset()
                return
            }
            timeRemaining = TimeInterval(roundDuration)
        } else {
            // Round finished, start rest
            isRest = true
            timeRemaining = TimeInterval(restDuration)
        }
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "bell", withExtension: "mp3") else {
            // Use system sound if custom sound not available
            AudioServicesPlaySystemSound(1057)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            AudioServicesPlaySystemSound(1057)
        }
    }
    
    init() {
        timeRemaining = TimeInterval(roundDuration)
    }
}

struct TimerSettingButton: View {
    let title: String
    let value: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct TimerSettingsView: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Text("\(value)")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(Color(hex: "24CFA4"))
                        .monospacedDigit()
                    
                    Stepper("", value: $value, in: range, step: step)
                        .labelsHidden()
                        .scaleEffect(1.5)
                    
                    Text("\(range.lowerBound) - \(range.upperBound)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                }
                .padding(40)
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
}

import AudioToolbox

#Preview {
    TrainingTimerView()
}
