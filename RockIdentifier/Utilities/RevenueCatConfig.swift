// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import RevenueCat

struct RevenueCatConfig {
    // API keys
    #if DEBUG
    static let apiKey = "appl_vlfrSylKwVKeuFWbeAiQwHNeVua" // Debug API key
    #else
    static let apiKey = "appl_vlfrSylKwVKeuFWbeAiQwHNeVua" // Production API key (use correct one for production)
    #endif
    
    // String constants (to avoid duplicating strings throughout the app)
    struct Identifiers {
        // Product identifiers
        static let weeklySubscription = "com.appmagic.rockidentifier.weekly"
        static let yearlySubscription = "com.appmagic.rockidentifier.yearly"
        
        // Entitlement identifiers
        static let premiumAccess = "premium_access"
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
