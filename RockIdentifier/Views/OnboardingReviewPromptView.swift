// Rock Identifier: Crystal ID
// Post-Onboarding Review Prompt
// Muoyo Okome
//

import SwiftUI
import StoreKit

/// Review prompt that appears right after onboarding completion
struct OnboardingReviewPromptView: View {
    @Binding var isVisible: Bool
    
    @State private var cardScale: CGFloat = 0.3
    @State private var cardOpacity: Double = 0
    @State private var sparkleRotation: Double = 0
    @State private var backgroundOpacity: Double = 0
    
    // State for celebration modal
    @State private var showCelebration: Bool = false
    
    var body: some View {
        ZStack {
            // Backdrop with subtle blur
            Color.black.opacity(backgroundOpacity * 0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissWithoutReview()
                }
            
            // Main card
            VStack(spacing: 20) {
                // Header with sparkling crystal
                VStack(spacing: 16) {
                    // Rotating sparkle icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(StyleGuide.Colors.roseQuartzPink)
                        .rotationEffect(.degrees(sparkleRotation))
                        .shadow(color: StyleGuide.Colors.amethystPurple.opacity(0.4), radius: 8)
                    
                    Text("Loving what you see so far?")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("A quick rating helps other rock lovers find us!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    // Rate button - matches app's crystal theme
                    Button(action: {
                        requestReview()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Rate App")
                                .font(.system(size: 17, weight: .semibold))
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
                    
                    // Maybe later button
                    Button(action: {
                        dismissWithoutReview()
                    }) {
                        Text("Maybe Later")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(EnhancedScaleButtonStyle(scaleAmount: 0.98))
                }
                .padding(.horizontal, 8)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            
            // Celebration modal overlay
            if showCelebration {
                ThankYouCelebrationView(isVisible: $showCelebration)
                    .onDisappear {
                        // When celebration dismisses, dismiss the review prompt
                        dismiss()
                    }
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            showPrompt()
        }
    }
    
    private func showPrompt() {
        // Haptic feedback for entrance
        HapticManager.shared.lightImpact()
        
        // Background fade in
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundOpacity = 1.0
        }
        
        // Card entrance with spring animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
        
        // Sparkle rotation
        withAnimation(.easeInOut(duration: 3.0).delay(0.3).repeatForever(autoreverses: true)) {
            sparkleRotation = 15
        }
    }
    
    private func requestReview() {
        // Haptic feedback for action
        HapticManager.shared.successFeedback()
        
        // Use StoreKit to request review
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        
        // Mark that we've shown the onboarding review prompt
        UserDefaults.standard.set(true, forKey: "has_shown_onboarding_review_prompt")
        
        // Show celebration modal instead of immediately dismissing
        showCelebration = true
    }
    
    private func dismissWithoutReview() {
        // Haptic feedback for dismissal
        HapticManager.shared.lightImpact()
        
        // Mark that we've shown the prompt (so we don't spam them)
        UserDefaults.standard.set(true, forKey: "has_shown_onboarding_review_prompt")
        
        // Set dismissal time for potential future prompts
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "onboarding_review_prompt_dismissed_time")
        
        dismiss()
    }
    
    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.25)) {
            cardOpacity = 0
            cardScale = 0.9
            backgroundOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isVisible = false
        }
    }
}

// MARK: - Onboarding Review Prompt Manager

extension ReviewPromptManager {
    /// Determines if we should show the onboarding review prompt
    func shouldShowOnboardingReviewPrompt() -> Bool {
        // Don't show if already shown
        if UserDefaults.standard.bool(forKey: "has_shown_onboarding_review_prompt") {
            return false
        }
        
        // Don't show if user dismissed recently (within 30 days)
        if let dismissTime = UserDefaults.standard.object(forKey: "onboarding_review_prompt_dismissed_time") as? TimeInterval {
            let daysSinceDismiss = (Date().timeIntervalSince1970 - dismissTime) / (24 * 60 * 60)
            if daysSinceDismiss < 30 {
                return false
            }
        }
        
        return true
    }
    
    /// Reset onboarding review prompt for testing
    func resetOnboardingReviewPrompt() {
        UserDefaults.standard.removeObject(forKey: "has_shown_onboarding_review_prompt")
        UserDefaults.standard.removeObject(forKey: "onboarding_review_prompt_dismissed_time")
    }
}
