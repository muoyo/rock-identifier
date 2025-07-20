// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import RevenueCat

struct RevenueCatConfig {
    // API keys
    static let apiKey = "appl_vlfrSylKwVKeuFWbeAiQwHNeVua" // Production API key (use correct one for production)
    
    // String constants (to avoid duplicating strings throughout the app)
    // SINGLE SOURCE OF TRUTH: All product IDs are defined here and referenced elsewhere
    struct Identifiers {
        // Product identifiers - These MUST match exactly with App Store Connect
        static let weeklySubscription = "com.appmagic.rockidentifier.weekly__"
        static let yearlySubscription = "com.appmagic.rockidentifier.yearly__"
        static let lifetimeAccess = "com.appmagic.rockidentifier.lifetime"
        
        // Entitlement identifiers - These MUST match RevenueCat dashboard configuration
        static let premiumAccess = "premium_access"
        
        // Convenience method to get all product IDs
        static var allProductIDs: [String] {
            return [weeklySubscription, yearlySubscription, lifetimeAccess]
        }
    }
    
    // Configure RevenueCat with application settings
    static func configure() {
        // Simple configuration - less prone to errors
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        
        // Note: Entitlement mapping should be done in the RevenueCat dashboard
        // The older `entitlementMapping` property is no longer available
    }
}
