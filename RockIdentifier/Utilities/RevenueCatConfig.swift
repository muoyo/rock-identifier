// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import RevenueCat

struct RevenueCatConfig {
    // API keys
    #if DEBUG
    static let apiKey = "appl_vlfrSylKwVKeuFWbeAiQwHNeVua" // Replace with your actual Debug API key
    #else
    static let apiKey = "appl_vlfrSylKwVKeuFWbeAiQwHNeVua" // Replace with your actual Production API key
    #endif
    
    // Product identifiers
    static let weeklyWithTrialID = "com.appmagic.rockidentifier.weekly"
    static let yearlyID = "com.appmagic.rockidentifier.yearly"
    
    // Entitlement identifiers
    static let premiumEntitlementID = "premium_access"
    
    // Configuration
    static let debugLogs = true  // Set to false for production
    
    // Configure RevenueCat with application settings
    static func configure() {
        // Set up RevenueCat configuration
        let configuration = Configuration.builder(withAPIKey: apiKey)
            .with(apiKey: apiKey)
            .with(appUserID: nil) // Let RevenueCat generate a user ID
            // .with(purchasesAreCompletedBy: PurchasesAreCompletedBy, storeKitVersion: StoreKitVersion(rawValue: 2)!) // Not using observer mode - we want to handle transactions
            .with(usesStoreKit2IfAvailable: true) // Use StoreKit 2 if available for improved reliability
            .with(networkTimeout: 60) // Longer timeout for slower connections
            .with(storeKit1Timeout: 60) // Longer timeout for StoreKit 1
            .with(dangerousSettings: DangerousSettings(autoSyncPurchases: true)) // Auto-sync purchases for better reliability
            .build()
        
        // Configure with the builder
        Purchases.configure(with: configuration)
        
        // Set up logging level
        if debugLogs {
            Purchases.logLevel = .debug
        } else {
            Purchases.logLevel = .error  // Only log errors in production
        }
    }
}
