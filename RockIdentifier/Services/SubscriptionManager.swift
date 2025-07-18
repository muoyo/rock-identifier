// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import Combine
import StoreKit
import RevenueCat

/// Enhanced SubscriptionManager with full RevenueCat integration
class SubscriptionManager: NSObject, ObservableObject {
    // Shared instance for checking subscription status from anywhere
    static var shared: SubscriptionManager?
    
    // MARK: - Published Properties
    
    /// Current subscription status
    @Published var status: SubscriptionStatus
    
    /// Loading state for purchase operations
    @Published var isLoading: Bool = false
    
    /// Developer mode flag (in-memory only, resets on app restart)
    @Published var developerMode: Bool = false
    
    /// Error message from the last operation
    @Published var lastErrorMessage: String?
    
    // MARK: - Private Properties
    
    private let defaults = UserDefaults.standard
    private let statusKey = "subscriptionStatus"
    private let customerIDKey = "revenueCatCustomerID"
    private var cancellables = Set<AnyCancellable>()
    
    // Identification counter for free tier usage
    let identificationCounter = IdentificationCounter()
    
    // MARK: - Initialization
    
    override init() {
        // Load saved status or use default
        if let data = defaults.data(forKey: statusKey),
           let savedStatus = try? JSONDecoder().decode(SubscriptionStatus.self, from: data) {
            self.status = savedStatus
        } else {
            self.status = SubscriptionStatus(plan: .free)
        }
        
        // Developer mode always starts as false on app launch
        self.developerMode = false
        
        // Must call super.init() before using self in a subclass of NSObject
        super.init()
        
        // Set the shared instance for global access
        SubscriptionManager.shared = self
        
        // Configure RevenueCat listeners
        setupPurchasesListener()
    }
    
    // MARK: - RevenueCat Setup
    
    private func setupPurchasesListener() {
        // Set delegate to receive updates
        Purchases.shared.delegate = self
        
        // Restore custom user ID if available
        if let storedID = defaults.string(forKey: customerIDKey) {
            Purchases.shared.logIn(storedID) { (customerInfo, created, error) in
                if let error = error {
                    print("Error logging in with stored ID: \(error.localizedDescription)")
                    return
                }
                
                // Update subscription status with the restored customer info
                self.updateSubscriptionStatus(with: customerInfo)
            }
        }
        
        // Check current subscription status regardless of stored ID
        refreshSubscriptionStatus()
    }
    
    /// Refreshes subscription status from RevenueCat
    func refreshSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching customer info: \(error.localizedDescription)")
                self.lastErrorMessage = "Could not update subscription status: \(error.localizedDescription)"
                return
            }
            
            // Update subscription status based on customer info
            self.updateSubscriptionStatus(with: customerInfo)
        }
    }
    
    private func updateSubscriptionStatus(with customerInfo: CustomerInfo?) {
        guard let customerInfo = customerInfo else { 
            print("SubscriptionManager: updateSubscriptionStatus called with nil customerInfo")
            return 
        }
        
        print("SubscriptionManager: Updating subscription status from RevenueCat...")
        
        // Store customer ID for restoration
        let appUserID = Purchases.shared.appUserID
        defaults.set(appUserID, forKey: customerIDKey)
        print("SubscriptionManager: Stored customer ID: \(appUserID)")
        
        // Check if user has active entitlement
        let hasActiveEntitlement = customerInfo.entitlements.active.keys.contains(RevenueCatConfig.Identifiers.premiumAccess)
        print("SubscriptionManager: Has active entitlement: \(hasActiveEntitlement)")
        
        // Determine which product they purchased
        var plan: SubscriptionPlan = .free
        var expirationDate: Date? = nil
        var isInTrial = false
        var trialEndDate: Date? = nil
        
        if hasActiveEntitlement {
            // Get the active subscription
            if let info = customerInfo.entitlements.active[RevenueCatConfig.Identifiers.premiumAccess] {
                print("SubscriptionManager: Found active entitlement with product ID: \(info.productIdentifier)")
                
                // Check which product they purchased
                if info.productIdentifier == RevenueCatConfig.Identifiers.weeklySubscription {
                    plan = .weekly
                } else if info.productIdentifier == RevenueCatConfig.Identifiers.yearlySubscription {
                    plan = .yearly
                }
                
                // Get expiration date
                expirationDate = info.expirationDate
                print("SubscriptionManager: Plan: \(plan), Expiration: \(expirationDate?.description ?? "none")")
                
                // Check if in trial period
                if info.periodType == .trial {
                    isInTrial = true
                    // Trial end date (for RevenueCat, this would be the expiration date during trial)
                    trialEndDate = info.expirationDate
                    print("SubscriptionManager: User is in trial period, ends: \(trialEndDate?.description ?? "unknown")")
                }
            }
        }
        
        // Update the subscription status
        DispatchQueue.main.async {
            // Check if status is changing from inactive to active
            let wasActive = self.status.isActive
            print("SubscriptionManager: Previous status - isActive: \(wasActive), plan: \(self.status.plan)")
            
            self.status = SubscriptionStatus(
                plan: plan,
                expirationDate: expirationDate,
                isInTrial: isInTrial,
                trialEndDate: trialEndDate
            )
            
            // Check if subscription status changed
            let isNowActive = self.status.isActive
            print("SubscriptionManager: New status - isActive: \(isNowActive), plan: \(self.status.plan)")
            
            // If subscription became active, post notification
            if !wasActive && isNowActive {
                print("SubscriptionManager: Subscription activated! Posting notification.")
                NotificationCenter.default.post(name: NSNotification.Name("SubscriptionStatusChanged"), object: nil)
            }
            
            // Save the updated status
            self.saveStatus()
            print("SubscriptionManager: Status saved to UserDefaults")
        }
    }
    
    // MARK: - Feature Access Control
    
    /// Checks if the user has access to a specific premium feature
    /// - Parameter feature: The premium feature to check access for
    /// - Returns: Boolean indicating if the user can access the feature
    func canAccess(feature: PremiumFeature) -> Bool {
        // If user has an active premium subscription, they can access all features
        if status.isActive {
            return true
        }
        
        // For non-subscribers, check specific features
        switch feature {
        case .unlimitedIdentifications:
            return !identificationCounter.isLimitReached
        case .advancedPropertyDetails, .unlimitedCollectionSize, .exportCollection, .noAds:
            return false
        }
    }
    
    // Returns remaining identifications total (for free tier users)
    var remainingIdentifications: Int {
        if status.isActive {
            return Int.max // Unlimited for premium users
        }
        return identificationCounter.remainingTotal
    }
    
    // Increment identification counter and check if reached limit
    func recordIdentification() -> Bool {
        if status.isActive {
            return true // Premium users always succeed
        }
        
        let result = identificationCounter.increment()
        // Signal that object has changed for UI updates
        objectWillChange.send()
        return result
    }
    
    // Save subscription status to UserDefaults
    private func saveStatus() {
        if let data = try? JSONEncoder().encode(status) {
            defaults.set(data, forKey: statusKey)
        }
    }
    
    // MARK: - Purchase Methods
    
    /// Initiates a subscription purchase
    /// - Parameters:
    ///   - plan: The subscription plan to purchase
    ///   - isTrialEnabled: Whether to use the trial version of the plan if available
    ///   - completion: Optional callback with success/error information
    func purchase(plan: SubscriptionPlan, isTrialEnabled: Bool = false, completion: ((Bool, Error?) -> Void)? = nil) {
        isLoading = true
        lastErrorMessage = nil
        
        // Make sure we have a valid product ID
        guard !plan.productIdentifier.isEmpty else {
            isLoading = false
            let error = NSError(domain: "com.appmagic.rockidentifier", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid product identifier"])
            lastErrorMessage = "Invalid product identifier"
            completion?(false, error)
            return
        }
        
        // First, get the available packages
        Purchases.shared.getOfferings { [weak self] (offerings, error) in
            guard let self = self else {
                completion?(false, error)
                return
            }
            
            if let error = error {
                print("Error fetching offerings: \(error.localizedDescription)")
                self.isLoading = false
                self.lastErrorMessage = "Could not load subscription options: \(error.localizedDescription)"
                completion?(false, error)
                return
            }
            
            // Find the package based on the product identifier
            guard let offerings = offerings else {
                print("No offerings available")
                self.isLoading = false
                let noOfferingsError = NSError(domain: "com.appmagic.rockidentifier", code: 1002, userInfo: [NSLocalizedDescriptionKey: "No subscription options available"])
                self.lastErrorMessage = "No subscription options available"
                completion?(false, noOfferingsError)
                return
            }
            
            // Default to using the current offering
            guard let offering = offerings.current else {
                print("No current offering available")
                self.isLoading = false
                let noCurrentOfferingError = NSError(domain: "com.appmagic.rockidentifier", code: 1003, userInfo: [NSLocalizedDescriptionKey: "No subscription options available for your region"])
                self.lastErrorMessage = "No subscription options available for your region"
                completion?(false, noCurrentOfferingError)
                return
            }
            
            // Find the right package
            var packageToPurchase: Package?
            
            // Look for the specific product ID in the packages
            for package in offering.availablePackages {
                if package.storeProduct.productIdentifier == plan.productIdentifier {
                    packageToPurchase = package
                    break
                }
            }
            
            guard let package = packageToPurchase else {
                print("Could not find package for product ID: \(plan.productIdentifier)")
                self.isLoading = false
                let noPackageError = NSError(domain: "com.appmagic.rockidentifier", code: 1004, userInfo: [NSLocalizedDescriptionKey: "Subscription option not available"])
                self.lastErrorMessage = "Subscription option not available"
                completion?(false, noPackageError)
                return
            }
            
            // Purchase the package
            Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if userCancelled {
                        print("User cancelled purchase")
                        let cancelledError = NSError(domain: "com.appmagic.rockidentifier", code: 1005, userInfo: [NSLocalizedDescriptionKey: "Purchase cancelled"])
                        self.lastErrorMessage = nil // Don't show error for user cancellation
                        completion?(false, cancelledError)
                        return
                    }
                    
                    if let error = error {
                        print("Purchase error: \(error.localizedDescription)")
                        self.lastErrorMessage = "Purchase failed: \(error.localizedDescription)"
                        completion?(false, error)
                        return
                    }
                    
                    // Update subscription status
                    self.updateSubscriptionStatus(with: customerInfo)
                    
                    // Verify purchase success by checking if status is now active
                    let purchaseSucceeded = self.status.isActive
                    if !purchaseSucceeded {
                        // This should rarely happen, but just in case
                        let verificationError = NSError(domain: "com.appmagic.rockidentifier", code: 1006, userInfo: [NSLocalizedDescriptionKey: "Subscription verification failed"])
                        self.lastErrorMessage = "Subscription verification failed. Please try restoring purchases."
                        completion?(false, verificationError)
                        return
                    }
                    
                    // Success!
                    completion?(true, nil)
                }
            }
        }
    }
    
    /// Restores previously purchased subscriptions
    /// - Parameter completion: Optional callback with success/error information
    func restorePurchases(completion: ((Bool, Error?) -> Void)? = nil) {
        isLoading = true
        lastErrorMessage = nil
        
        Purchases.shared.restorePurchases { [weak self] (customerInfo, error) in
            guard let self = self else {
                completion?(false, error)
                return
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Restore error: \(error.localizedDescription)")
                    self.lastErrorMessage = "Restore failed: \(error.localizedDescription)"
                    completion?(false, error)
                    return
                }
                
                // Update subscription status
                self.updateSubscriptionStatus(with: customerInfo)
                
                // Check if restoration resulted in an active subscription
                let restoreSucceeded = self.status.isActive
                if !restoreSucceeded {
                    // User attempted to restore, but has no purchases
                    // This is not an error, just an information message
                    self.lastErrorMessage = "No active subscriptions found for your account"
                }
                
                // Return true even if no active subscriptions were found
                // The operation itself succeeded, even if it didn't find anything
                completion?(true, nil)
            }
        }
    }
    
    // MARK: - For Development/Testing
    
    /// Resets subscription status to free (for testing)
    func resetToFree() {
        status = SubscriptionStatus(plan: .free)
        saveStatus()
        // Signal that object has changed for UI updates
        objectWillChange.send()
        // Don't reset identification counter when a user downgrades
        // This ensures they still have their 3 total limit
        
        // Post notification about subscription status change
        // This will trigger the PaywallManager to update its state
        NotificationCenter.default.post(name: NSNotification.Name("SubscriptionStatusChanged"), object: nil)
    }
    
    /// Sets a mock premium subscription (for testing)
    /// - Parameter plan: The subscription plan to mock
    func setMockPremium(plan: SubscriptionPlan = .yearly) {
        let expirationDate = Date().addingTimeInterval(365 * 24 * 60 * 60)
        status = SubscriptionStatus(plan: plan, expirationDate: expirationDate)
        saveStatus()
        // Signal that object has changed for UI updates
        objectWillChange.send()
        
        // Post notification about subscription status change
        // This will trigger the PaywallManager to update its state
        NotificationCenter.default.post(name: NSNotification.Name("SubscriptionStatusChanged"), object: nil)
    }
    
    /// Toggles developer mode on/off
    func toggleDeveloperMode() {
        developerMode = !developerMode
        print("Developer mode: \(developerMode ? "ENABLED" : "DISABLED")")
        objectWillChange.send()
        
        // Post notification about subscription status change when developer mode changes
        // This will trigger the PaywallManager to update its state
        NotificationCenter.default.post(name: NSNotification.Name("SubscriptionStatusChanged"), object: nil)
    }
    
    /// Debug method to log current subscription state
    func debugSubscriptionState() {
        print("\n=== SUBSCRIPTION DEBUG INFO ===")
        print("Local Status:")
        print("  - isActive: \(status.isActive)")
        print("  - plan: \(status.plan)")
        print("  - expirationDate: \(status.expirationDate?.description ?? "none")")
        print("  - isInTrial: \(status.isInTrial)")
        print("  - developerMode: \(developerMode)")
        print("  - remainingIdentifications: \(remainingIdentifications)")
        
        print("\nRevenueCat Info:")
        let customerInfo = Purchases.shared.cachedCustomerInfo
        if let customerInfo = customerInfo {
            let hasEntitlement = customerInfo.entitlements.active.keys.contains(RevenueCatConfig.Identifiers.premiumAccess)
            print("  - hasActiveEntitlement: \(hasEntitlement)")
            print("  - appUserID: \(Purchases.shared.appUserID)")
            if let entitlement = customerInfo.entitlements.active[RevenueCatConfig.Identifiers.premiumAccess] {
                print("  - productIdentifier: \(entitlement.productIdentifier)")
                print("  - expirationDate: \(entitlement.expirationDate?.description ?? "none")")
                print("  - periodType: \(entitlement.periodType)")
            }
        } else {
            print("  - No cached customer info")
        }
        
        print("\nPaywallManager Check:")
        let paywallCheck = PaywallManager.shared
        print("  - Current PaywallManager believes user is subscribed: \(Purchases.shared.cachedCustomerInfo?.entitlements.active.keys.contains(RevenueCatConfig.Identifiers.premiumAccess) ?? false)")
        
        print("\nAppState:")
        print("  - showHardPaywall: \(AppState.shared.showHardPaywall)")
        print("  - showSoftPaywall: \(AppState.shared.showSoftPaywall)")
        print("================================\n")
    }
}

// MARK: - RevenueCat Delegate
extension SubscriptionManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        // Update subscription status when we receive updates from RevenueCat
        updateSubscriptionStatus(with: customerInfo)
    }
    
    // Handle other delegate methods as needed
    func purchases(_ purchases: Purchases, receivedUpdate purchaserInfo: CustomerInfo) {
        updateSubscriptionStatus(with: purchaserInfo)
    }
}
