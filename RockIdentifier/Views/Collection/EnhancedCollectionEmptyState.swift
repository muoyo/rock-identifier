// Rock Identifier: Crystal ID
// Enhanced Collection Empty State with delightful aesthetics
// Muoyo Okome
//

import SwiftUI

struct EnhancedCollectionEmptyState: View {
    let onIdentifyAction: () -> Void
    
    @State private var isAnimating = false
    @State private var sparkleOffset1: CGFloat = 0
    @State private var sparkleOffset2: CGFloat = 0
    @State private var sparkleOpacity: Double = 0.5
    @State private var illustrationScale: CGFloat = 0.8
    @State private var textOffset: CGFloat = 20
    @State private var buttonScale: CGFloat = 0.9
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Animated illustration with floating sparkles
            ZStack {
                // Background glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                StyleGuide.Colors.amethystPurple.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .opacity(isAnimating ? 0.6 : 0.3)
                    .animation(
                        .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Main illustration
                ZStack {
                    Image("onboarding-collection")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .scaleEffect(illustrationScale)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: illustrationScale)
                    
                    // Floating sparkles
                    floatingSparkles
                }
            }
            .onAppear {
                animateEntrance()
            }
            
            // Enhanced text section
            VStack(spacing: 12) {
                Text("Your Collection Awaits")
                    .font(StyleGuide.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                StyleGuide.Colors.amethystPurple,
                                StyleGuide.Colors.roseQuartzPink
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(y: textOffset)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: textOffset)
                
                Text("Discover the hidden stories in rocks, minerals, crystals, and gemstones. Each identification becomes a treasured addition to your personal collection.")
                    .font(StyleGuide.Typography.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
                    .lineSpacing(2)
                    .offset(y: textOffset)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: textOffset)
            }
            
            // Enhanced action button
            Button(action: {
                HapticManager.shared.mediumImpact()
                onIdentifyAction()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Start Identifying")
                        .font(StyleGuide.Typography.buttonText)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    StyleGuide.Colors.amethystPurple,
                                    StyleGuide.Colors.roseQuartzPink
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(
                            color: StyleGuide.Colors.amethystPurple.opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                )
            }
            .scaleEffect(buttonScale)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: buttonScale)
            .buttonStyle(EnhancedScaleButtonStyle())
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Floating Sparkles
    private var floatingSparkles: some View {
        ZStack {
            // Sparkle 1
            Image(systemName: "sparkle")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(StyleGuide.Colors.citrineGold)
                .offset(x: sparkleOffset1, y: -40)
                .opacity(sparkleOpacity)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 4.0).repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Sparkle 2
            Image(systemName: "star.fill")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(StyleGuide.Colors.emeraldGreen)
                .offset(x: sparkleOffset2, y: 50)
                .opacity(sparkleOpacity)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .animation(
                    .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Sparkle 3
            Image(systemName: "diamond.fill")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(StyleGuide.Colors.sapphireBlue)
                .offset(x: -60, y: sparkleOffset1 * 0.5)
                .opacity(sparkleOpacity * 0.8)
                .rotationEffect(.degrees(isAnimating ? -180 : 0))
                .animation(
                    .linear(duration: 3.5).repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
    }
    
    // MARK: - Animation Functions
    private func animateEntrance() {
        // Start the floating animations
        withAnimation(.linear(duration: 0.1)) {
            isAnimating = true
        }
        
        // Animate sparkle positions
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            sparkleOffset1 = 30
            sparkleOffset2 = -25
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            sparkleOpacity = 1.0
        }
        
        // Animate entrance of elements
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
            illustrationScale = 1.0
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            textOffset = 0
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
            buttonScale = 1.0
        }
    }
}

struct EnhancedCollectionEmptyState_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EnhancedCollectionEmptyState {
                print("Identify tapped")
            }
            .previewDisplayName("Light Mode")
            
            EnhancedCollectionEmptyState {
                print("Identify tapped")
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
