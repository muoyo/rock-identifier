// Rock Identifier: Crystal ID
// Thank You Celebration Modal
// Muoyo Okome
//

import SwiftUI

/// Celebration modal shown after user chooses to rate the app
struct ThankYouCelebrationView: View {
    @Binding var isVisible: Bool
    
    @State private var cardScale: CGFloat = 0.3
    @State private var cardOpacity: Double = 0
    @State private var sparkleRotation: Double = 0
    @State private var backgroundOpacity: Double = 0
    @State private var sparklesActive: Bool = false
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(backgroundOpacity * 0.5)
                .edgesIgnoringSafeArea(.all)
            
            // Golden sparkles effect (similar to results screen)
            if sparklesActive {
                GeometryReader { geometry in
                    ForEach(0..<12, id: \.self) { index in
                        Image(systemName: index % 3 == 0 ? "sparkle" : "star.fill")
                            .font(.system(size: CGFloat.random(in: 12...20), weight: .bold))
                            .foregroundColor(StyleGuide.Colors.citrineGold.opacity(Double.random(in: 0.7...1.0)))
                            .position(
                                x: CGFloat.random(in: 50...(geometry.size.width - 50)),
                                y: CGFloat.random(in: 100...(geometry.size.height - 100))
                            )
                            .opacity(sparklesActive ? 0.0 : 1.0)
                            .scaleEffect(sparklesActive ? 1.5 : 0.3)
                            .animation(
                                .easeOut(duration: 2.0)
                                .delay(Double(index) * 0.1)
                                .repeatCount(1, autoreverses: false),
                                value: sparklesActive
                            )
                            .shadow(color: StyleGuide.Colors.citrineGold.opacity(0.6), radius: 4)
                    }
                }
                .allowsHitTesting(false)
            }
            
            // Main celebration card
            VStack(spacing: 20) {
                // Header with animated heart
                VStack(spacing: 16) {
                    // Simple star icon (no pulsing)
                    Image(systemName: "sparkles")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(StyleGuide.Colors.roseQuartzPink)
                        .rotationEffect(.degrees(sparkleRotation))
                        .shadow(color: StyleGuide.Colors.roseQuartzPink.opacity(0.4), radius: 8)
                    
                    Text("Thank You!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Your support means the world to us and helps other rock enthusiasts discover the magic of geology!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Continue button
                Button(action: {
                    dismissCelebration()
                }) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                StyleGuide.Colors.roseQuartzPink,
                                StyleGuide.Colors.roseQuartzPink.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: StyleGuide.Colors.roseQuartzPink.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(EnhancedScaleButtonStyle(scaleAmount: 0.95))
                .padding(.horizontal, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 12)
            )
            .padding(.horizontal, 32)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
        }
        .onAppear {
            showCelebration()
        }
    }
    
    private func showCelebration() {
        // Haptic feedback for entrance
        HapticManager.shared.successFeedback()
        
        // Background fade in
        withAnimation(.easeOut(duration: 0.4)) {
            backgroundOpacity = 1.0
        }
        
        // Card entrance with bouncy spring
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
        
        // Start sparkles effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sparklesActive = true
        }
    }
    
    private func dismissCelebration() {
        // Haptic feedback for dismissal
        HapticManager.shared.lightImpact()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            cardOpacity = 0
            cardScale = 0.9
            backgroundOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isVisible = false
        }
    }
}
