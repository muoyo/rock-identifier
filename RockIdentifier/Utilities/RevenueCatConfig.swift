// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

struct RevenueCatConfig {
    // API keys
    #if DEBUG
    static let apiKey = "appl_YOUR_DEBUG_API_KEY" // Replace with your actual Debug API key
    #else
    static let apiKey = "appl_YOUR_PRODUCTION_API_KEY" // Replace with your actual Production API key
    #endif
    
    // Product identifiers
    static let weeklyWithTrialID = "com.appmagic.rockidentifier.weekly"
    static let yearlyID = "com.appmagic.rockidentifier.yearly"
    
    // Entitlement identifiers
    static let premiumEntitlementID = "premium_access"
    
    // Configuration
    static let debugLogs = true  // Set to false for production
}
