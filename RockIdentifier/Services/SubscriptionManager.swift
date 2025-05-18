// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import Combine
import StoreKit
import RevenueCat

class SubscriptionManager: NSObject, ObservableObject {
    @Published var status: SubscriptionStatus
    @Published var isLoading: Bool = false
    @Published var developerMode: Bool = false // In-memory only, resets on app restart
    
    private let defaults = UserDefaults.standard
    private let statusKey = "subscriptionStatus"
    private var cancellables = Set<AnyCancellable>()
    
    // Identification counter for free tier usage
    let identificationCounter = IdentificationCounter()
    
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
        
        // Configure RevenueCat listeners
        setupPurchasesListener()
    }
    
    private func setupPurchasesListener() {
        // Listen for changes in purchase status
        Purchases.shared.delegate = self
        
        // Check current subscription status
        Purchases.shared.getCustomerInfo { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching customer info: \(error.localizedDescription)")
                return
            }
            
            // Update subscription status based on customer info
            self.updateSubscriptionStatus(with: customerInfo)
        }
    }
    
    private func updateSubscriptionStatus(with customerInfo: CustomerInfo?) {
        guard let customerInfo = customerInfo else { return }
        
        // Check if user has active entitlement
        let hasActiveEntitlement = customerInfo.entitlements.active.keys.contains(RevenueCatConfig.premiumEntitlementID)
        
        // Determine which product they purchased
        var plan: SubscriptionPlan = .free
        var expirationDate: Date? = nil
        var isInTrial = false
        var trialEndDate: Date? = nil
        
        if hasActiveEntitlement {
            // Get the active subscription
            if let info = customerInfo.entitlements.active[RevenueCatConfig.premiumEntitlementID] {
                // Check which product they purchased
                if info.productIdentifier == RevenueCatConfig.weeklyWithTrialID {
                    plan = .weekly
                } else if info.productIdentifier == RevenueCatConfig.yearlyID {
                    plan = .yearly
                }
                
                // Get expiration date
                expirationDate = info.expirationDate
                
                // Check if in trial period
                if info.periodType == .trial {
                    isInTrial = true
                    // Trial end date (for RevenueCat, this would be the expiration date during trial)
                    trialEndDate = info.expirationDate
                }
            }
        }
        
        // Update the subscription status
        self.status = SubscriptionStatus(
            plan: plan,
            expirationDate: expirationDate,
            isInTrial: isInTrial,
            trialEndDate: trialEndDate
        )
        
        self.saveStatus()
    }
    
    // Checks if the user has access to a specific premium feature
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
    
    // Initiate a purchase
    func purchase(plan: SubscriptionPlan, isTrialEnabled: Bool = false) {
        isLoading = true
        
        // Make sure we have a valid product ID
        guard !plan.productIdentifier.isEmpty else {
            isLoading = false
            return
        }
        
        // First, get the available packages
        Purchases.shared.getOfferings { [weak self] (offerings, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching offerings: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            // Find the package based on the product identifier
            guard let offerings = offerings else {
                print("No offerings available")
                self.isLoading = false
                return
            }
            
            // Default to using the current offering
            guard let offering = offerings.current else {
                print("No current offering available")
                self.isLoading = false
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
                return
            }
            
            // Purchase the package
            Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                self.isLoading = false
                
                if let error = error {
                    print("Purchase error: \(error.localizedDescription)")
                    return
                }
                
                if userCancelled {
                    print("User cancelled purchase")
                    return
                }
                
                // Update subscription status
                self.updateSubscriptionStatus(with: customerInfo)
            }
        }
    }
    
    // Restore purchases
    func restorePurchases() {
        isLoading = true
        
        Purchases.shared.restorePurchases { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                print("Restore error: \(error.localizedDescription)")
                return
            }
            
            // Update subscription status
            self.updateSubscriptionStatus(with: customerInfo)
        }
    }
    
    // MARK: - For Development/Testing
    
    // Reset subscription status to free (for testing)
    func resetToFree() {
        status = SubscriptionStatus(plan: .free)
        saveStatus()
        // Signal that object has changed for UI updates
        objectWillChange.send()
        // Don't reset identification counter when a user downgrades
        // This ensures they still have their 3 total limit
    }
    
    // Set a mock premium subscription (for testing)
    func setMockPremium(plan: SubscriptionPlan = .yearly) {
        let expirationDate = Date().addingTimeInterval(365 * 24 * 60 * 60)
        status = SubscriptionStatus(plan: plan, expirationDate: expirationDate)
        saveStatus()
        // Signal that object has changed for UI updates
        objectWillChange.send()
    }
    
    // MARK: - Developer Mode Methods
    
    /// Toggles developer mode on/off
    func toggleDeveloperMode() {
        developerMode = !developerMode
        print("Developer mode: \(developerMode ? "ENABLED" : "DISABLED")")
        objectWillChange.send()
    }
}

// MARK: - RevenueCat Delegate
extension SubscriptionManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        // Update subscription status when we receive updates from RevenueCat
        updateSubscriptionStatus(with: customerInfo)
    }
}
