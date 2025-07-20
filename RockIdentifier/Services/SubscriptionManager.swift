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
    
    // Receipt refresh request for handling receipt validation issues
    private var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    // Completion handler for receipt refresh
    private var receiptRefreshCompletion: ((Bool) -> Void)?
    
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
                } else if info.productIdentifier == RevenueCatConfig.Identifiers.lifetimeAccess {
                    plan = .lifetime
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
    
    /// Attempt lifetime purchase with receipt refresh for validation errors
    private func attemptLifetimePurchaseWithReceiptRefresh(package: Package, completion: ((Bool, Error?) -> Void)?) {
        print("🔄 SubscriptionManager: Attempting lifetime purchase with receipt refresh...")
        
        refreshReceiptIfNeeded { [weak self] refreshSuccess in
            guard let self = self else {
                completion?(false, NSError(domain: "com.appmagic.rockidentifier", code: 1011, userInfo: [NSLocalizedDescriptionKey: "Manager deallocated"]))
                return
            }
            
            if !refreshSuccess {
                print("⚠️ Receipt refresh failed, proceeding with retry anyway...")
            }
            
            // Try the purchase again after receipt refresh
            Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                DispatchQueue.main.async {
                    if userCancelled {
                        print("User cancelled lifetime purchase (retry)")
                        let cancelledError = NSError(domain: "com.appmagic.rockidentifier", code: 1009, userInfo: [NSLocalizedDescriptionKey: "Purchase cancelled"])
                        self.lastErrorMessage = nil
                        completion?(false, cancelledError)
                        return
                    }
                    
                    if let error = error {
                        print("❌ Lifetime purchase failed even after receipt refresh: \(error.localizedDescription)")
                        self.lastErrorMessage = "Lifetime purchase failed: \(error.localizedDescription)"
                        completion?(false, error)
                        return
                    }
                    
                    // Update subscription status
                    self.updateSubscriptionStatus(with: customerInfo)
                    
                    // Verify purchase success
                    let purchaseSucceeded = self.status.isActive
                    if !purchaseSucceeded {
                        let verificationError = NSError(domain: "com.appmagic.rockidentifier", code: 1010, userInfo: [NSLocalizedDescriptionKey: "Lifetime purchase verification failed"])
                        self.lastErrorMessage = "Lifetime purchase verification failed. Please try restoring purchases."
                        completion?(false, verificationError)
                        return
                    }
                    
                    // Success!
                    print("✅ Lifetime purchase succeeded after receipt refresh!")
                    completion?(true, nil)
                }
            }
        }
    }
    
    /// Gets the lifetime package for price checking
    /// - Parameter completion: Callback with package or error
    func getLifetimePackage(completion: @escaping (Package?, Error?) -> Void) {
        print("SubscriptionManager: Getting lifetime package...")
        
        Purchases.shared.getOfferings { (offerings, error) in
            if let error = error {
                print("SubscriptionManager: Error getting offerings: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let offerings = offerings, let offering = offerings.current else {
                print("SubscriptionManager: No offerings available")
                let noOfferingsError = NSError(domain: "com.appmagic.rockidentifier", code: 1007, userInfo: [NSLocalizedDescriptionKey: "Lifetime option not available"])
                completion(nil, noOfferingsError)
                return
            }
            
            print("SubscriptionManager: Available packages:")
            for package in offering.availablePackages {
                print("  - \(package.storeProduct.productIdentifier): \(package.localizedPriceString)")
            }
            
            // Find the lifetime package
            var lifetimePackage: Package?
            for package in offering.availablePackages {
                if package.storeProduct.productIdentifier == RevenueCatConfig.Identifiers.lifetimeAccess {
                    lifetimePackage = package
                    print("SubscriptionManager: Found lifetime package: \(package.storeProduct.productIdentifier) - \(package.localizedPriceString)")
                    break
                }
            }
            
            if let package = lifetimePackage {
                completion(package, nil)
            } else {
                print("SubscriptionManager: Lifetime package not found. Looking for: \(RevenueCatConfig.Identifiers.lifetimeAccess)")
                let noPackageError = NSError(domain: "com.appmagic.rockidentifier", code: 1008, userInfo: [NSLocalizedDescriptionKey: "Lifetime option not available"])
                completion(nil, noPackageError)
            }
        }
    }
    
    /// Purchases lifetime access
    /// - Parameter completion: Optional callback with success/error information
    func purchaseLifetime(completion: ((Bool, Error?) -> Void)? = nil) {
        print("🔍 SubscriptionManager: Starting lifetime purchase debug...")
        debugLifetimePurchaseConfiguration()
        
        isLoading = true
        lastErrorMessage = nil
        
        // Get the available packages and find lifetime access
        Purchases.shared.getOfferings { [weak self] (offerings, error) in
            guard let self = self else {
                completion?(false, error)
                return
            }
            
            if let error = error {
                print("Error fetching offerings for lifetime: \(error.localizedDescription)")
                self.isLoading = false
                self.lastErrorMessage = "Could not load lifetime option: \(error.localizedDescription)"
                completion?(false, error)
                return
            }
            
            guard let offerings = offerings, let offering = offerings.current else {
                print("No offerings available for lifetime")
                self.isLoading = false
                let noOfferingsError = NSError(domain: "com.appmagic.rockidentifier", code: 1007, userInfo: [NSLocalizedDescriptionKey: "Lifetime option not available"])
                self.lastErrorMessage = "Lifetime option not available"
                completion?(false, noOfferingsError)
                return
            }
            
            // Find the lifetime package
            var lifetimePackage: Package?
            for package in offering.availablePackages {
                if package.storeProduct.productIdentifier == RevenueCatConfig.Identifiers.lifetimeAccess {
                    lifetimePackage = package
                    break
                }
            }
            
            guard let package = lifetimePackage else {
                print("Could not find lifetime package")
                self.isLoading = false
                let noPackageError = NSError(domain: "com.appmagic.rockidentifier", code: 1008, userInfo: [NSLocalizedDescriptionKey: "Lifetime option not available"])
                self.lastErrorMessage = "Lifetime option not available"
                completion?(false, noPackageError)
                return
            }
            
            print("💰 SubscriptionManager: Attempting to purchase lifetime package: \(package.storeProduct.productIdentifier) for \(package.localizedPriceString)")
            
            // Purchase the lifetime package
            Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    // Enhanced logging for debugging
                    print("💰 Purchase callback received:")
                    print("  - User cancelled: \(userCancelled)")
                    print("  - Error: \(error?.localizedDescription ?? "none")")
                    print("  - Transaction: \(transaction?.productIdentifier ?? "none")")
                    if let customerInfo = customerInfo {
                        print("  - Customer has entitlements: \(Array(customerInfo.entitlements.active.keys))")
                        print("  - Customer purchased products: \(customerInfo.allPurchasedProductIdentifiers.sorted())")
                    }
                    
                    if userCancelled {
                        print("User cancelled lifetime purchase")
                        let cancelledError = NSError(domain: "com.appmagic.rockidentifier", code: 1009, userInfo: [NSLocalizedDescriptionKey: "Purchase cancelled"])
                        self.lastErrorMessage = nil
                        completion?(false, cancelledError)
                        return
                    }
                    
                    if let error = error {
                        print("Lifetime purchase error: \(error.localizedDescription)")
                        
                        // Enhanced error analysis for receipt validation issues
                        let nsError = error as NSError
                        print("   Error Code: \(nsError.code)")
                        print("   Error Domain: \(nsError.domain)")
                        
                        // Check for receipt validation error (code 7712)
                        if nsError.code == 7712 {
                            print("⚠️ Receipt validation error detected - attempting receipt refresh...")
                            self.attemptLifetimePurchaseWithReceiptRefresh(package: package, completion: completion)
                            return
                        }
                        
                        self.lastErrorMessage = "Lifetime purchase failed: \(error.localizedDescription)"
                        completion?(false, error)
                        return
                    }
                    
                    // Update subscription status
                    self.updateSubscriptionStatus(with: customerInfo)
                    
                    // Verify purchase success
                    let purchaseSucceeded = self.status.isActive
                    if !purchaseSucceeded {
                        let verificationError = NSError(domain: "com.appmagic.rockidentifier", code: 1010, userInfo: [NSLocalizedDescriptionKey: "Lifetime purchase verification failed"])
                        self.lastErrorMessage = "Lifetime purchase verification failed. Please try restoring purchases."
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
        
        // Use enhanced restore with receipt refresh
        restorePurchasesWithRefresh { [weak self] success, error in
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
    
    /// Debug method specifically for lifetime purchase configuration
    private func debugLifetimePurchaseConfiguration() {
        print("\n🔍 === LIFETIME PURCHASE DEBUG ===")
        print("Configuration Check:")
        print("  - App Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        print("  - RevenueCat API Key: \(RevenueCatConfig.apiKey.prefix(20))...")
        print("  - Lifetime Product ID: \(RevenueCatConfig.Identifiers.lifetimeAccess)")
        print("  - Premium Entitlement ID: \(RevenueCatConfig.Identifiers.premiumAccess)")
        print("  - RevenueCat User ID: \(Purchases.shared.appUserID)")
        print("  - Is Anonymous: \(Purchases.shared.isAnonymous)")
        
        // Check offerings synchronously if cached, otherwise note it
        let cachedCustomerInfo = Purchases.shared.cachedCustomerInfo
        if let customerInfo = cachedCustomerInfo {
            print("\nCached Customer Info:")
            print("  - Has active entitlements: \(!customerInfo.entitlements.active.isEmpty)")
            print("  - Active entitlement IDs: \(Array(customerInfo.entitlements.active.keys))")
            print("  - All product IDs: \(customerInfo.allPurchasedProductIdentifiers.sorted())")
        } else {
            print("\nCached Customer Info: None available")
        }
        
        print("\nEnvironment Check:")
        #if DEBUG
        print("  - Build Configuration: DEBUG (Sandbox)")
        #else
        print("  - Build Configuration: RELEASE (Production)")
        #endif
        
        print("====================================\n")
    }
    
    // MARK: - Receipt Refresh Methods
    
    /// Force refresh the App Store receipt to ensure latest transaction data
    func refreshReceiptIfNeeded(completion: @escaping (Bool) -> Void) {
        print("🗘️ SubscriptionManager: Refreshing receipt to ensure latest transaction data...")
        
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        receiptRefreshRequest = request
        
        // Store completion handler for delegate callback
        receiptRefreshCompletion = completion
        
        request.start()
    }
    
    /// Enhanced restore purchases with receipt refresh
    private func restorePurchasesWithRefresh(completion: @escaping (Bool, Error?) -> Void) {
        print("🔄 SubscriptionManager: Starting restore with receipt refresh...")
        
        refreshReceiptIfNeeded { [weak self] success in
            guard let self = self else {
                completion(false, NSError(domain: "com.appmagic.rockidentifier", code: 1011, userInfo: [NSLocalizedDescriptionKey: "Manager deallocated"]))
                return
            }
            
            if !success {
                print("⚠️ Receipt refresh failed, proceeding with restore anyway...")
            }
            
            // Proceed with RevenueCat restore
            Purchases.shared.restorePurchases { (customerInfo, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Restore after refresh failed: \(error.localizedDescription)")
                        completion(false, error)
                        return
                    }
                    
                    // Update subscription status
                    self.updateSubscriptionStatus(with: customerInfo)
                    
                    let restoreSucceeded = self.status.isActive
                    completion(true, nil)
                }
            }
        }
    }
    
    /// Test method to validate RevenueCat configuration
    func validateRevenueCatConfiguration(completion: @escaping (Bool, String) -> Void) {
        print("🔧 SubscriptionManager: Validating RevenueCat configuration...")
        
        // First get offerings to check if products are properly configured
        Purchases.shared.getOfferings { (offerings, error) in
            if let error = error {
                let message = "Failed to fetch offerings: \(error.localizedDescription)"
                print("❌ \(message)")
                completion(false, message)
                return
            }
            
            guard let offerings = offerings, let currentOffering = offerings.current else {
                let message = "No current offering available"
                print("❌ \(message)")
                completion(false, message)
                return
            }
            
            print("✅ Found current offering with \(currentOffering.availablePackages.count) packages")
            
            // Check if lifetime product exists
            let lifetimeProductID = RevenueCatConfig.Identifiers.lifetimeAccess
            var foundLifetimeProduct = false
            
            for package in currentOffering.availablePackages {
                let productID = package.storeProduct.productIdentifier
                let price = package.localizedPriceString
                print("  📱 Package: \(productID) - \(price)")
                
                if productID == lifetimeProductID {
                    foundLifetimeProduct = true
                    print("    ✅ Found lifetime product!")
                }
            }
            
            if !foundLifetimeProduct {
                let message = "Lifetime product '\(lifetimeProductID)' not found in offerings"
                print("❌ \(message)")
                completion(false, message)
                return
            }
            
            // Check customer info
            Purchases.shared.getCustomerInfo { (customerInfo, error) in
                if let error = error {
                    let message = "Failed to get customer info: \(error.localizedDescription)"
                    print("❌ \(message)")
                    completion(false, message)
                    return
                }
                
                print("✅ RevenueCat configuration appears valid!")
                
                if let customerInfo = customerInfo {
                    let hasActiveEntitlement = customerInfo.entitlements.active.keys.contains(RevenueCatConfig.Identifiers.premiumAccess)
                    print("  Current entitlement status: \(hasActiveEntitlement ? "Active" : "Inactive")")
                }
                
                completion(true, "Configuration validated successfully")
            }
        }
    }
    
    /// Clear RevenueCat's cached offerings and force fresh data
    func clearRevenueCatCache(completion: @escaping (Bool, String) -> Void) {
        print("🧹 SubscriptionManager: Clearing RevenueCat cache and forcing refresh...")
        
        // Step 1: Invalidate cached offerings by switching user temporarily
        let originalUserID = Purchases.shared.appUserID
        let tempUserID = "cache_clear_\(UUID().uuidString.prefix(8))"
        
        print("  🔄 Switching to temporary user ID to clear cache...")
        Purchases.shared.logIn(tempUserID) { (customerInfo, created, error) in
            if let error = error {
                print("  ❌ Failed to switch to temp user: \(error.localizedDescription)")
                completion(false, "Failed to clear cache: \(error.localizedDescription)")
                return
            }
            
            print("  ✅ Switched to temp user, now switching back...")
            
            // Step 2: Switch back to original user with fresh cache
            Purchases.shared.logIn(originalUserID) { (customerInfo, created, error) in
                if let error = error {
                    print("  ❌ Failed to switch back to original user: \(error.localizedDescription)")
                    completion(false, "Failed to restore original user: \(error.localizedDescription)")
                    return
                }
                
                print("  ✅ Restored original user, cache should be cleared")
                
                // Step 3: Force fetch fresh offerings
                print("  🔄 Fetching fresh offerings...")
                Purchases.shared.getOfferings { (offerings, error) in
                    if let error = error {
                        let message = "Failed to fetch fresh offerings: \(error.localizedDescription)"
                        print("  ❌ \(message)")
                        completion(false, message)
                        return
                    }
                    
                    print("  ✅ Fresh offerings loaded successfully!")
                    
                    // Update subscription status with fresh customer info
                    self.updateSubscriptionStatus(with: customerInfo)
                    
                    completion(true, "Cache cleared and fresh data loaded")
                }
            }
        }
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

// MARK: - SKRequestDelegate (for receipt refresh)
extension SubscriptionManager: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        print("✅ Receipt refresh completed successfully")
        DispatchQueue.main.async {
            self.receiptRefreshCompletion?(true)
            self.receiptRefreshCompletion = nil
            self.receiptRefreshRequest = nil
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("❌ Receipt refresh failed: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.receiptRefreshCompletion?(false)
            self.receiptRefreshCompletion = nil
            self.receiptRefreshRequest = nil
        }
    }
}
    
        
