//
//  SettingsView.swift
//  H2S Hit to Strong
//
//  Created by Роман Главацкий on 19.01.2026.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0E0D12")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // App Info
                        VStack(spacing: 12) {
                            Text("H2S")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Hit to Strong")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "24CFA4"))
                            
                            Text("Version 1.0")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 4)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 40)
                        
                        // Settings Options
                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "star.fill",
                                title: "Rate Us",
                                color: Color(hex: "24CFA4")
                            ) {
                                rateApp()
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            SettingsRow(
                                icon: "lock.shield.fill",
                                title: "Privacy Policy",
                                color: Color(hex: "8B309C")
                            ) {
                                openPrivacyPolicy()
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            SettingsRow(
                                icon: "doc.text.fill",
                                title: "Terms of Service",
                                color: Color(hex: "24CFA4")
                            ) {
                                openTerms()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
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
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.termsfeed.com/live/0e8021bd-bb5d-4189-8eaa-21a02fe789a9") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTerms() {
        if let url = URL(string: "https://www.termsfeed.com/live/182d3e13-cb6a-4316-b87d-9759964e1511") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.05))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
