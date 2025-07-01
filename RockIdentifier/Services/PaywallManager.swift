// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import SwiftUI
import RevenueCat

/// Simple, reliable manager for paywalls
class PaywallManager {
    // Singleton instance
    static let shared = PaywallManager()
    
    // MARK: - Properties
    
    // Current app version (cached for efficiency)
    private let currentAppVersion: String
    
    // UserDefaults keys
    private let lastVersionShownKey = "lastVersionShownPaywall"
    private let defaults = UserDefaults.standard
    
    // MARK: - Initialization
    
    private init() {
        // Get the current app version
        currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        
        print("PaywallManager: Initialized with app version \(currentAppVersion)")
        
        // Register for subscription change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionStatusChanged), name: NSNotification.Name("SubscriptionStatusChanged"), object: nil)
    }
    
    // Clean up observer when deallocated
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Handle subscription status changes
    @objc private func subscriptionStatusChanged() {
        // If user just subscribed, dismiss any paywalls
        if hasActiveSubscription() {
            print("PaywallManager: Subscription activated - dismissing paywalls")
            AppState.shared.dismissPaywalls()
        }
    }
    
    // MARK: - Public Methods
    
    /// Show hard paywall if this is the first launch of this version
    /// Returns true if paywall was shown
    @discardableResult
    func showHardPaywallIfNeeded() -> Bool {
        
        // HARD PAYWALLS DISABLED - always return false
        print("PaywallManager: Hard paywalls disabled - NOT showing hard paywall")
        return false
        
               
        // First check if user has an active subscription - never show paywall to subscribed users
        if hasActiveSubscription() {
            print("PaywallManager: User has active subscription - NOT showing hard paywall")
            return false
        }
        
        // Get the last version where we showed a paywall
        let lastVersionShown = defaults.string(forKey: lastVersionShownKey) ?? ""
        
        print("PaywallManager: Last version shown = \(lastVersionShown), Current version = \(currentAppVersion)")
        
        // If this is a new version, show the paywall
        if lastVersionShown != currentAppVersion {
            print("PaywallManager: SHOWING HARD PAYWALL for new version")
            
            // Show the paywall
            AppState.shared.showHardPaywall = true
            
            // Save this version as shown
            defaults.set(currentAppVersion, forKey: lastVersionShownKey)
            defaults.synchronize() // Force immediate save
            
            return true
        } else {
            print("PaywallManager: Not showing hard paywall - already shown for version \(currentAppVersion)")
            return false
        }
    }
    
    /// Show soft paywall
    func showSoftPaywall() {
        // First check if user has an active subscription - never show paywall to subscribed users
        if hasActiveSubscription() {
            print("PaywallManager: User has active subscription - NOT showing soft paywall")
            return
        }
        
        print("PaywallManager: SHOWING SOFT PAYWALL")
        AppState.shared.showSoftPaywall = true
    }
    
    /// Reset version tracking for testing
    func resetVersionForTesting() {
        print("PaywallManager: Resetting version tracking for testing")
        defaults.removeObject(forKey: lastVersionShownKey)
        defaults.synchronize() // Force immediate save
    }
    
    /// Log the current state (for debugging)
    func logState() {
        let lastVersionShown = defaults.string(forKey: lastVersionShownKey) ?? "none"
        let subscriptionActive = hasActiveSubscription()
        print("PaywallManager STATE: lastVersionShown=\(lastVersionShown), currentVersion=\(currentAppVersion)")
        print("PaywallManager STATE: showHardPaywall=\(AppState.shared.showHardPaywall), showSoftPaywall=\(AppState.shared.showSoftPaywall)")
        print("PaywallManager STATE: hasActiveSubscription=\(subscriptionActive)")
    }
    
    /// Check if user has an active subscription
    private func hasActiveSubscription() -> Bool {
        // Always use the local SubscriptionManager status as the source of truth
        // This ensures we're using the most up-to-date status after purchases
        if let subscriptionManager = SubscriptionManager.shared {
            print("PaywallManager: Checking subscription status - isActive: \(subscriptionManager.status.isActive), developerMode: \(subscriptionManager.developerMode)")
            return subscriptionManager.status.isActive
        }
        
        // Fallback to RevenueCat if SubscriptionManager isn't available (shouldn't happen)
        print("PaywallManager: WARNING - SubscriptionManager.shared is nil, falling back to RevenueCat")
        let customerInfo = Purchases.shared.cachedCustomerInfo
        return customerInfo?.entitlements.active.keys.contains(RevenueCatConfig.Identifiers.premiumAccess) ?? false
    }
}
