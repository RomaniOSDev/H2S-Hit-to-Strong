//
//  OnboardingView.swift
//  H2S Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Track Your Strikes",
            description: "Record and analyze your strike power, speed, and technique with detailed metrics",
            icon: "hand.raised.fill",
            color: Color(hex: "8B309C")
        ),
        OnboardingPage(
            title: "Monitor Progress",
            description: "Track your improvement over time with comprehensive statistics and visual charts",
            icon: "chart.line.uptrend.xyaxis",
            color: Color(hex: "24CFA4")
        ),
        OnboardingPage(
            title: "Achieve Your Goals",
            description: "Set targets, complete training programs, and unlock achievements as you progress",
            icon: "star.fill",
            color: Color(hex: "24CFA4")
        )
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "0E0D12")
                .ignoresSafeArea()
            
            if hasCompletedOnboarding {
                TrainingDashboardView()
                    .preferredColorScheme(.dark)
            } else {
                VStack(spacing: 0) {
                    // Page Content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Bottom Section
                    VStack(spacing: 20) {
                        // Page Indicators
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? Color(hex: "24CFA4") : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .animation(.spring(), value: currentPage)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Action Button
                        Button(action: {
                            if currentPage < pages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                hasCompletedOnboarding = true
                            }
                        }) {
                            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "24CFA4"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 200, height: 200)
                
                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundColor(page.color)
            }
            .padding(.bottom, 20)
            
            // Text Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding(.vertical, 60)
    }
}

#Preview {
    OnboardingView()
}
