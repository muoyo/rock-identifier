// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import SwiftUI

/// Manages free tier limitations and prompts
class FreeTierManager {
    // Singleton instance
    static let shared = FreeTierManager()
    
    // Reference to app state
    private let appState = AppState.shared
    
    // Subscription manager
    private var subscriptionManager: SubscriptionManager?
    
    // Track when user has seen prompts to avoid spamming
    private var lastPromptDate: Date?
    private let minimumPromptInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    
    // UserDefaults keys
    private let lastPromptDateKey = "lastPaywallPromptDate"
    
    // Private init for singleton
    private init() {
        // Load last prompt date from storage
        if let savedDate = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date {
            lastPromptDate = savedDate
        }
    }
    
    /// Sets the subscription manager reference
    func setSubscriptionManager(_ manager: SubscriptionManager) {
        self.subscriptionManager = manager
    }
    
    /// Checks if identification should trigger a paywall prompt
    /// - Returns: True if successful (no paywall), false if limit reached and paywall shown
    func checkAndHandleIdentificationAttempt() -> Bool {
        guard let subscriptionManager = subscriptionManager else {
            // If no subscription manager, allow identification (fail safe)
            return true
        }
        
        // First check if user is premium - if so, allow identification
        if subscriptionManager.status.isActive {
            return true
        }
        
        // Get remaining count
        let remaining = subscriptionManager.remainingIdentifications
        
        // Check if they're already at the limit
        if remaining <= 0 {
            // They're at the limit, always show the paywall
            print("FreeTierManager: IDENTIFICATION LIMIT REACHED - showing soft paywall")
            PaywallManager.shared.showSoftPaywall()
            recordPromptShown()
            // Don't allow identification when limit reached
            return false
        }
        
        // Check if this is the last identification
        if remaining == 1 {
            // This is their last identification, show soft paywall
            // but still allow them to proceed
            if shouldShowPrompt() {
                print("FreeTierManager: ONE IDENTIFICATION LEFT - showing soft paywall")
                PaywallManager.shared.showSoftPaywall()
                recordPromptShown()
            }
            // Allow them to continue after seeing the paywall
            return subscriptionManager.recordIdentification()
        }
        
        // No paywall trigger, record the identification
        return subscriptionManager.recordIdentification()
    }
    
    /// Called after a successful identification to potentially show a paywall
    func handleSuccessfulIdentification() {
        guard let subscriptionManager = subscriptionManager else {
            return
        }
        
        // Only show for free tier users
        if subscriptionManager.status.isActive {
            return
        }
        
        // Get remaining count
        let remaining = subscriptionManager.remainingIdentifications
        
        // Show paywall if they just used their last free identification
        // or randomly (20% chance) if they have only 1 remaining
        if remaining == 0 || (remaining == 1 && shouldShowPrompt() && Double.random(in: 0...1) < 0.2) {
            // Delay slightly to allow them to see the result first
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                print("FreeTierManager: AFTER IDENTIFICATION - showing soft paywall")
                PaywallManager.shared.showSoftPaywall()
                self.recordPromptShown()
            }
        }
    }
    
    /// Determines if enough time has passed to show another prompt
    private func shouldShowPrompt() -> Bool {
        guard let lastPrompt = lastPromptDate else {
            return true // No previous prompt recorded
        }
        
        let timeElapsed = Date().timeIntervalSince(lastPrompt)
        return timeElapsed > minimumPromptInterval
    }
    
    /// Records that a prompt was shown
    private func recordPromptShown() {
        lastPromptDate = Date()
        UserDefaults.standard.set(lastPromptDate, forKey: lastPromptDateKey)
    }
    
    /// Reset prompt tracking (for testing)
    func resetPromptTracking() {
        lastPromptDate = nil
        UserDefaults.standard.removeObject(forKey: lastPromptDateKey)
    }
}
