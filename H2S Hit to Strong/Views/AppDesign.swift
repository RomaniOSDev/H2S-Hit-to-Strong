//
//  AppDesign.swift
//  H2S Hit to Strong
//
//  Performant design tokens: gradients + borders on lists,
//  shadows only on featured/hero cards (max few per screen).
//

import SwiftUI

// MARK: - Theme

enum AppTheme {
    static let teal = Color(hex: "24CFA4")
    static let purple = Color(hex: "8B309C")
    static let bgDark = Color(hex: "0E0D12")
    
    static var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.10),
                Color.white.opacity(0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var surfaceGradientSubtle: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.07),
                Color.white.opacity(0.03)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static func borderGradient(accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                accent.opacity(0.45),
                accent.opacity(0.12),
                Color.white.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func accentFill(_ accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [accent, accent.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum SurfaceStyle {
  /// Gradient fill + border, no shadow — safe for long lists
    case glass
  /// Adds one composited shadow — use for hero cards only (2–3 per screen)
    case elevated
}

// MARK: - Surface Modifier

private struct AppSurfaceModifier: ViewModifier {
    let accent: Color
    let style: SurfaceStyle
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        
        Group {
            switch style {
            case .glass:
                content
                    .background(shape.fill(AppTheme.surfaceGradient))
                    .overlay(shape.stroke(AppTheme.borderGradient(accent: accent), lineWidth: 1))
            case .elevated:
                content
                    .background(shape.fill(AppTheme.surfaceGradient))
                    .overlay(shape.stroke(AppTheme.borderGradient(accent: accent), lineWidth: 1))
                    .compositingGroup()
                    .shadow(color: accent.opacity(0.22), radius: 10, x: 0, y: 5)
            }
        }
    }
}

extension View {
    func glassCard(accent: Color = AppTheme.teal, cornerRadius: CGFloat = 16) -> some View {
        modifier(AppSurfaceModifier(accent: accent, style: .glass, cornerRadius: cornerRadius))
    }
    
    func elevatedCard(accent: Color = AppTheme.teal, cornerRadius: CGFloat = 18) -> some View {
        modifier(AppSurfaceModifier(accent: accent, style: .elevated, cornerRadius: cornerRadius))
    }
}

// MARK: - Buttons

struct PrimaryGradientButtonStyle: ButtonStyle {
    var accent: Color = AppTheme.teal
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.accentFill(accent))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(configuration.isPressed ? 0.1 : 0.2), lineWidth: 1)
            )
            .compositingGroup()
            .shadow(color: accent.opacity(configuration.isPressed ? 0.1 : 0.3), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct FilterChipStyle: ButtonStyle {
    let isSelected: Bool
    var accent: Color = AppTheme.teal
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AppTheme.accentFill(accent))
                    } else {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AppTheme.surfaceGradientSubtle)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}

// MARK: - Icon Badge

struct GradientIconBadge: View {
    let icon: String
    let accent: Color
    var size: CGFloat = 36
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.44, weight: .semibold))
            .foregroundColor(accent)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [accent.opacity(0.22), accent.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .stroke(accent.opacity(0.35), lineWidth: 1)
            )
    }
}

// MARK: - Section Title

struct AppSectionTitle: View {
    let title: String
    var accent: Color = AppTheme.teal
    
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppTheme.accentFill(accent))
                .frame(width: 4, height: 18)
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Text Field

struct AppTextFieldStyle: TextFieldStyle {
    var accent: Color = AppTheme.teal
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .glassCard(accent: accent, cornerRadius: 10)
            .foregroundColor(.white)
    }
}

// MARK: - Progress Bar

struct GradientProgressBar: View {
    let progress: Double
    var accent: Color = AppTheme.teal
    var height: CGFloat = 6
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(AppTheme.accentFill(accent))
                    .frame(width: max(0, geo.size.width * min(1, progress)))
            }
        }
        .frame(height: height)
    }
}
