// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import StoreKit

/// Review prompt that appears after first identification celebration
struct ReviewPromptView: View {
    @Binding var isVisible: Bool
    let rockName: String
    
    @State private var cardScale: CGFloat = 0.3
    @State private var cardOpacity: Double = 0
    @State private var iconRotation: Double = 0
    @State private var backgroundOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(backgroundOpacity * 0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissWithoutReview()
                }
            
            // Main card
            VStack(spacing: 24) {
                // Celebratory header
                VStack(spacing: 12) {
                    // Rotating app icon or rock icon
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(StyleGuide.Colors.citrineGold)
                        .rotationEffect(.degrees(iconRotation))
                        .shadow(color: StyleGuide.Colors.citrineGold.opacity(0.4), radius: 8)
                    
                    Text("Loving Rock Identifier?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("You just identified your first \(rockName)! 🎉\nHelp other rockhounds discover the magic.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    // Rate button
                    Button(action: {
                        requestReview()
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Rate Rock Identifier")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    StyleGuide.Colors.citrineGold,
                                    StyleGuide.Colors.citrineGoldDark
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: StyleGuide.Colors.citrineGold.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Maybe later button
                    Button(action: {
                        dismissWithoutReview()
                    }) {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, 8)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
            )
            .padding(.horizontal, 40)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
        }
        .onAppear {
            showPrompt()
        }
    }
    
    private func showPrompt() {
        // Background fade in
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundOpacity = 1.0
        }
        
        // Card entrance
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
        
        // Icon rotation
        withAnimation(.easeOut(duration: 2.0).delay(0.3)) {
            iconRotation = 360
        }
    }
    
    private func requestReview() {
        // Use StoreKit to request review
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        
        // Mark that we've shown the review prompt
        UserDefaults.standard.set(true, forKey: "has_shown_review_prompt")
        
        // Dismiss the prompt
        dismiss()
    }
    
    private func dismissWithoutReview() {
        // Mark that we've shown the prompt (so we don't spam them)
        UserDefaults.standard.set(true, forKey: "has_shown_review_prompt")
        
        // Maybe show again later (after more identifications)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "review_prompt_dismissed_time")
        
        dismiss()
    }
    
    private func dismiss() {
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

// MARK: - Review Prompt Manager

class ReviewPromptManager {
    static let shared = ReviewPromptManager()
    private init() {}
    
    /// Determines if we should show the review prompt
    func shouldShowReviewPrompt() -> Bool {
        // Don't show if already shown
        if UserDefaults.standard.bool(forKey: "has_shown_review_prompt") {
            return false
        }
        
        // Don't show if user dismissed recently (within 7 days)
        if let dismissTime = UserDefaults.standard.object(forKey: "review_prompt_dismissed_time") as? TimeInterval {
            let daysSinceDismiss = (Date().timeIntervalSince1970 - dismissTime) / (24 * 60 * 60)
            if daysSinceDismiss < 7 {
                return false
            }
        }
        
        return true
    }
    
    /// Reset for testing purposes
    func resetForTesting() {
        UserDefaults.standard.removeObject(forKey: "has_shown_review_prompt")
        UserDefaults.standard.removeObject(forKey: "review_prompt_dismissed_time")
    }
}
