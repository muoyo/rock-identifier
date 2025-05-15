// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

enum SubscriptionPlan: String, Codable {
    case free = "free"
    case weekly = "weekly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .weekly:
            return "Weekly"
        case .yearly:
            return "Yearly"
        }
    }
    
    var productIdentifier: String {
        switch self {
        case .free:
            return ""
        case .weekly:
            return "com.appmagic.rockidentifier.weekly"
        case .yearly:
            return "com.appmagic.rockidentifier.yearly"
        }
    }
    
    var price: String {
        switch self {
        case .free:
            return "Free"
        case .weekly:
            return "$7.99/week"
        case .yearly:
            return "$39.99/year"
        }
    }
    
    var savingsText: String? {
        switch self {
        case .yearly:
            return "SAVE 80%"
        default:
            return nil
        }
    }
}

struct SubscriptionStatus: Codable {
    var plan: SubscriptionPlan
    var expirationDate: Date?
    var isInTrial: Bool
    var trialEndDate: Date?
    
    var isActive: Bool {
        guard plan != .free else { return false }
        
        if isInTrial, let trialEndDate = trialEndDate, trialEndDate > Date() {
            return true
        }
        
        if let expirationDate = expirationDate, expirationDate > Date() {
            return true
        }
        
        return false
    }
    
    init(plan: SubscriptionPlan = .free, expirationDate: Date? = nil, isInTrial: Bool = false, trialEndDate: Date? = nil) {
        self.plan = plan
        self.expirationDate = expirationDate
        self.isInTrial = isInTrial
        self.trialEndDate = trialEndDate
    }
}

enum PremiumFeature: String, CaseIterable {
    case unlimitedIdentifications = "Unlimited Identifications"
    case advancedPropertyDetails = "Advanced Property Details"
    case unlimitedCollectionSize = "Unlimited Collection Size"
    case exportCollection = "Export Collection"
    case noAds = "No Advertisements"
    
    var description: String {
        switch self {
        case .unlimitedIdentifications:
            return "Identify as many rocks as you want, with no daily limits"
        case .advancedPropertyDetails:
            return "Access detailed chemical and physical properties of your specimens"
        case .unlimitedCollectionSize:
            return "Add unlimited rocks to your personal collection"
        case .exportCollection:
            return "Export your collection in various formats for sharing or backup"
        case .noAds:
            return "Enjoy a completely ad-free experience"
        }
    }
}
