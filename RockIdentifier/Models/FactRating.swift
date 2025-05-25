// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

// Represents a rated fact with metadata
struct RatedFact: Codable, Identifiable, Equatable {
    let id = UUID()
    let text: String
    let baseRating: FactInterestRating
    let categories: [FactCategory]
    let confidenceThreshold: Double // Minimum confidence to show this fact
    var userRating: UserFactRating?
    var isFavorite: Bool = false
    var timesShown: Int = 0
    var lastShown: Date?
    
    init(text: String, baseRating: FactInterestRating, categories: [FactCategory], confidenceThreshold: Double = 0.0) {
        self.text = text
        self.baseRating = baseRating  
        self.categories = categories
        self.confidenceThreshold = confidenceThreshold
    }
    
    // Calculate the overall interest score for this fact
    func calculateInterestScore(confidence: Double, userPreferences: FactPreferences) -> Double {
        // Start with base rating
        var score = baseRating.rawValue
        
        // Apply user rating if available
        if let userRating = userRating {
            score = (score + userRating.rawValue) / 2.0
        }
        
        // Boost for favorites
        if isFavorite {
            score += 0.2
        }
        
        // Apply category preferences
        for category in categories {
            if userPreferences.preferredCategories.contains(category) {
                score += 0.1
            }
        }
        
        // Reduce score based on how recently/frequently shown
        let recencyPenalty = calculateRecencyPenalty()
        score -= recencyPenalty
        
        // Apply confidence-based filtering
        if confidence < confidenceThreshold {
            score *= 0.5 // Reduce score if confidence is too low
        }
        
        return max(0.0, min(1.0, score))
    }
    
    private func calculateRecencyPenalty() -> Double {
        guard let lastShown = lastShown else { return 0.0 }
        
        let timeSinceShown = Date().timeIntervalSinceReferenceDate - lastShown.timeIntervalSinceReferenceDate
        let hoursSince = timeSinceShown / 3600
        
        // More recent = higher penalty, but decay over time
        let recencyPenalty = max(0.0, 0.3 - (hoursSince * 0.01))
        
        // Frequency penalty - shown too many times
        let frequencyPenalty = Double(timesShown) * 0.05
        
        return recencyPenalty + frequencyPenalty
    }
    
    static func == (lhs: RatedFact, rhs: RatedFact) -> Bool {
        return lhs.id == rhs.id
    }
}

// Base interest rating for facts
enum FactInterestRating: Double, CaseIterable, Codable {
    case low = 0.3
    case medium = 0.5  
    case high = 0.7
    case veryHigh = 0.9
    
    var description: String {
        switch self {
        case .low: return "Informative"
        case .medium: return "Interesting"
        case .high: return "Fascinating"
        case .veryHigh: return "Mind-blowing"
        }
    }
}

// User's rating for facts they've seen
enum UserFactRating: Double, CaseIterable, Codable {
    case boring = 0.2
    case okay = 0.4
    case interesting = 0.6
    case amazing = 0.8
    case mindBlowing = 1.0
    
    var emoji: String {
        switch self {
        case .boring: return "😴"
        case .okay: return "👌"
        case .interesting: return "😊"
        case .amazing: return "🤩"
        case .mindBlowing: return "🤯"
        }
    }
}

// User preferences for fact selection
struct FactPreferences: Codable {
    var preferredCategories: Set<FactCategory> = Set(FactCategory.allCases)
    var minimumRating: FactInterestRating = .medium
    var showOnlyFavorites: Bool = false
    var rotationInterval: TimeInterval = 5.0
    var maxFactsPerSession: Int = 10
    
    static let `default` = FactPreferences()
}
