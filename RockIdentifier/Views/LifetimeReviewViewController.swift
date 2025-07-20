//
//  LifetimeReviewViewController.swift
//  Rock Identifier
//
//  Hard review screen for users who get lifetime access for $0
//  Created following the Color Noir approach
//

import SwiftUI

struct LifetimeReviewViewController: View {
    @Environment(\.presentationMode) var presentationMode
    let onReviewCompleted: () -> Void
    
    @State private var animateElements = false
    
    var body: some View {
        ZStack {
            // Background similar to paywall style
            LinearGradient(
                gradient: Gradient(colors: [
                    StyleGuide.Colors.amethystBackground.opacity(0.3),
                    StyleGuide.Colors.emeraldBackground.opacity(0.3),
                    StyleGuide.Colors.citrineBackground.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Color(.systemBackground).opacity(0.85)
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 60)
                    
                    // Crystal celebration icon
                    crystalCelebrationView
                    
                    // Title section
                    VStack(spacing: 16) {
                        Text("You Got Lifetime Access! 🎉")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .scaleEffect(animateElements ? 1.0 : 0.9)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateElements)
                        
                        Text("Help others discover the fascinating world of geology by sharing your experience.\n\nYour support means everything to our community of rock enthusiasts! ✨")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .scaleEffect(animateElements ? 1.0 : 0.9)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: animateElements)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                        .frame(minHeight: 40)
                    
                    // Review button - the ONLY way to dismiss
                    reviewButton
                    
                    Spacer()
                        .frame(height: 60)
                }
            }
        }
        .onAppear {
            // Start animations
            withAnimation {
                animateElements = true
            }
            
            // Haptic feedback
            HapticManager.shared.successFeedback()
        }
        .interactiveDismissDisabled() // This prevents swipe-to-dismiss
    }
    
    // MARK: - Crystal Celebration View
    
    private var crystalCelebrationView: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            StyleGuide.Colors.roseQuartzPink.opacity(0.3),
                            StyleGuide.Colors.roseQuartzPink.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(animateElements ? 1.0 : 0.5)
                .opacity(animateElements ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1), value: animateElements)
            
            // Main crystal
            enhancedCrystalView
                .frame(width: 120, height: 100)
                .scaleEffect(animateElements ? 1.0 : 0.5)
                .rotationEffect(.degrees(animateElements ? 5 : 0))
                .opacity(animateElements ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: animateElements)
            
            // Sparkle effects
            ForEach(0..<8, id: \.self) { index in
                sparkleView(index: index)
            }
        }
    }
    
    private var enhancedCrystalView: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let centerX = width / 2
            let centerY = height / 2
            
            ZStack {
                // Top facet
                Path { path in
                    let topPoint = CGPoint(x: centerX, y: centerY - height * 0.45)
                    let topLeftPoint = CGPoint(x: centerX - width * 0.38, y: centerY - height * 0.15)
                    let topRightPoint = CGPoint(x: centerX + width * 0.38, y: centerY - height * 0.15)
                    let bottomLeftPoint = CGPoint(x: centerX - width * 0.28, y: centerY + height * 0.05)
                    let bottomRightPoint = CGPoint(x: centerX + width * 0.28, y: centerY + height * 0.05)
                    
                    path.move(to: topPoint)
                    path.addLine(to: topRightPoint)
                    path.addLine(to: bottomRightPoint)
                    path.addLine(to: bottomLeftPoint)
                    path.addLine(to: topLeftPoint)
                    path.closeSubpath()
                }
                .fill(StyleGuide.Colors.roseQuartzGradient)
                
                // Bottom facet
                Path { path in
                    let topLeftPoint = CGPoint(x: centerX - width * 0.28, y: centerY + height * 0.05)
                    let topRightPoint = CGPoint(x: centerX + width * 0.28, y: centerY + height * 0.05)
                    let bottomLeftPoint = CGPoint(x: centerX - width * 0.38, y: centerY + height * 0.35)
                    let bottomRightPoint = CGPoint(x: centerX + width * 0.38, y: centerY + height * 0.35)
                    let bottomPoint = CGPoint(x: centerX, y: centerY + height * 0.48)
                    
                    path.move(to: topLeftPoint)
                    path.addLine(to: topRightPoint)
                    path.addLine(to: bottomRightPoint)
                    path.addLine(to: bottomPoint)
                    path.addLine(to: bottomLeftPoint)
                    path.closeSubpath()
                }
                .fill(StyleGuide.Colors.roseQuartzPink.opacity(0.8))
                
                // Side facet for depth
                Path { path in
                    let points = [
                        CGPoint(x: centerX - width * 0.38, y: centerY - height * 0.15),
                        CGPoint(x: centerX - width * 0.28, y: centerY + height * 0.05),
                        CGPoint(x: centerX - width * 0.38, y: centerY + height * 0.35)
                    ]
                    
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                    path.closeSubpath()
                }
                .fill(StyleGuide.Colors.roseQuartzPink.opacity(0.6))
            }
        }
    }
    
    private func sparkleView(index: Int) -> some View {
        let angle = Double(index) * 45.0
        let radius: CGFloat = 70
        let size: CGFloat = CGFloat.random(in: 8...16)
        
        return Circle()
            .fill(StyleGuide.Colors.roseQuartzPink.opacity(0.8))
            .frame(width: size, height: size)
            .position(
                x: 80 + cos(angle * .pi / 180) * radius,
                y: 80 + sin(angle * .pi / 180) * radius
            )
            .scaleEffect(animateElements ? 1.0 : 0.3)
            .opacity(animateElements ? 1.0 : 0.0)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .delay(0.4 + Double(index) * 0.1),
                value: animateElements
            )
    }
    
    // MARK: - Review Button (Only Dismissal Option)
    
    private var reviewButton: some View {
        Button(action: {
            openAppStoreReview()
        }) {
            ZStack {
                // Gradient background
                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                StyleGuide.Colors.roseQuartzPink,
                                StyleGuide.Colors.roseQuartzPink.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 72)
                
                Text("Share the Love")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .mineralShadow(StyleGuide.Colors.roseQuartzPink, intensity: .large)
        .scaleEffect(animateElements ? 1.0 : 0.9)
        .opacity(animateElements ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: animateElements)
        .padding(.horizontal, 32)
    }
    
    // MARK: - Actions
    
    private func openAppStoreReview() {
        HapticManager.shared.lightImpact()
        
        // Rock Identifier App Store URL
        let appStoreURL = "https://apps.apple.com/app/rock-identifier-stone-scanner/id6745438668?action=write-review"
        
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url, options: [:]) { success in
                DispatchQueue.main.async {
                    if success {
                        // Only dismiss after successfully opening App Store
                        self.onReviewCompleted()
                    }
                }
            }
        }
    }
}
