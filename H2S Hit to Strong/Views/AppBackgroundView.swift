//
//  AppBackgroundView.swift
//  H2S Hit to Strong
//

import SwiftUI

enum AppBackgroundStyle {
    case standard
    case session
    case sheet
}

struct AppBackgroundView: View {
    var style: AppBackgroundStyle = .standard
    
    private var tealOpacity: Double {
        switch style {
        case .standard: 0.14
        case .session: 0.18
        case .sheet: 0.10
        }
    }
    
    private var purpleOpacity: Double {
        switch style {
        case .standard: 0.16
        case .session: 0.20
        case .sheet: 0.12
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "0E0D12"),
                    Color(hex: "14121C"),
                    Color(hex: "0A0910")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            RadialGradient(
                colors: [
                    Color(hex: "24CFA4").opacity(tealOpacity),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 320
            )
            
            RadialGradient(
                colors: [
                    Color(hex: "8B309C").opacity(purpleOpacity),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 30,
                endRadius: 340
            )
            
            // Radial-only glows (no blur — GPU-friendly)
            if style == .standard {
                BackgroundGridPattern()
                    .opacity(0.28)
                    .drawingGroup()
            }
            
            LinearGradient(
                colors: [
                    Color.black.opacity(0.15),
                    Color.clear,
                    Color.black.opacity(0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

private struct BackgroundGridPattern: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 32
            var path = Path()
            
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
            
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            
            context.stroke(
                path,
                with: .color(Color.white.opacity(0.03)),
                lineWidth: 0.5
            )
        }
    }
}

extension View {
    func appBackground(_ style: AppBackgroundStyle = .standard) -> some View {
        background {
            AppBackgroundView(style: style)
        }
    }
}
