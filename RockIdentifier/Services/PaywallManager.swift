// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import SwiftUI

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
    }
    
    // MARK: - Public Methods
    
    /// Show hard paywall if this is the first launch of this version
    /// Returns true if paywall was shown
    @discardableResult
    func showHardPaywallIfNeeded() -> Bool {
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
        print("PaywallManager STATE: lastVersionShown=\(lastVersionShown), currentVersion=\(currentAppVersion)")
        print("PaywallManager STATE: showHardPaywall=\(AppState.shared.showHardPaywall), showSoftPaywall=\(AppState.shared.showSoftPaywall)")
    }
}
