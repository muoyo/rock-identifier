// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import Combine

/// Global application state
class AppState: ObservableObject {
    // Singleton instance
    static let shared = AppState()
    
    // Paywall dismissal control
    @Published var paywallSwipeDismissable = false
    
    // Paywall presentation states - directly controlled
    @Published var showHardPaywall = false
    @Published var showSoftPaywall = false
    
    // Private init for singleton
    private init() {
        // Simple initialization
        print("AppState: Initialized")
    }
    
    // MARK: - Simple Interface
    
    // This is a simplified interface mostly for clarity in the code
    
    /// Shows a hard paywall (no dismiss option)
    func showHardPaywallModal() {
        print("AppState: Setting showHardPaywall = true")
        showHardPaywall = true
        paywallSwipeDismissable = false
    }
    
    /// Shows a soft paywall (can be dismissed after delay)
    func showSoftPaywallModal() {
        print("AppState: Setting showSoftPaywall = true")
        showSoftPaywall = true
        paywallSwipeDismissable = false // Will be set to true after timer elapses in PaywallView
    }
    
    /// Dismisses all paywalls
    func dismissPaywalls() {
        print("AppState: Dismissing all paywalls")
        showHardPaywall = false
        showSoftPaywall = false
    }
}
