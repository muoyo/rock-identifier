// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import Combine

class FactManager: ObservableObject {
    @Published var userPreferences = FactPreferences.default
    @Published var allRatedFacts: [String: [RatedFact]] = [:] // Keyed by rock name
    
    private let userDefaults = UserDefaults.standard
    private let preferencesKey = "FactPreferences"
    private let ratedFactsKey = "RatedFacts"
    
    init() {
        loadUserData()
        setupFactDatabase()
    }
    
    // MARK: - Public Methods
    
    /// Select the best facts for a given rock based on user preferences and confidence
    func selectBestFacts(for uses: Uses, rockName: String, confidence: Double, maxFacts: Int = 3) -> [RatedFact] {
        // Convert plain string facts to rated facts if not already processed
        let ratedFacts = getRatedFacts(for: uses, rockName: rockName)
        
        // Score and sort facts
        let scoredFacts = ratedFacts.map { fact in
            (fact: fact, score: fact.calculateInterestScore(confidence: confidence, userPreferences: userPreferences))
        }.sorted { $0.score > $1.score }
        
        // Filter based on user preferences
        var selectedFacts = scoredFacts.compactMap { $0.fact }
        
        // Apply preference filters
        if userPreferences.showOnlyFavorites {
            selectedFacts = selectedFacts.filter { $0.isFavorite }
        }
        
        selectedFacts = selectedFacts.filter { 
            $0.baseRating.rawValue >= userPreferences.minimumRating.rawValue 
        }
        
        // Return the top facts, limited by maxFacts
        return Array(selectedFacts.prefix(maxFacts))
    }
    
    /// Mark a fact as shown (for rotation logic)
    func markFactAsShown(_ fact: RatedFact, for rockName: String) {
        if var facts = allRatedFacts[rockName],
           let index = facts.firstIndex(where: { $0.id == fact.id }) {
            facts[index].timesShown += 1
            facts[index].lastShown = Date()
            allRatedFacts[rockName] = facts
            saveUserData()
        }
    }
    
    /// Toggle favorite status for a fact
    func toggleFavorite(_ fact: RatedFact, for rockName: String) {
        if var facts = allRatedFacts[rockName],
           let index = facts.firstIndex(where: { $0.id == fact.id }) {
            facts[index].isFavorite.toggle()
            allRatedFacts[rockName] = facts
            saveUserData()
            
            // Trigger haptic feedback
            HapticManager.shared.selectionChanged()
        }
    }
    
    /// Rate a fact (user feedback)
    func rateFact(_ fact: RatedFact, rating: UserFactRating, for rockName: String) {
        if var facts = allRatedFacts[rockName],
           let index = facts.firstIndex(where: { $0.id == fact.id }) {
            facts[index].userRating = rating
            allRatedFacts[rockName] = facts
            saveUserData()
            
            // Trigger haptic feedback
            HapticManager.shared.lightImpact()
        }
    }
    
    /// Update user preferences
    func updatePreferences(_ newPreferences: FactPreferences) {
        userPreferences = newPreferences
        saveUserData()
    }
    
    /// Get intelligent rotation sequence for facts
    func getRotationSequence(facts: [RatedFact], confidence: Double) -> [RatedFact] {
        // Sort by interest score but add some randomness to avoid predictability
        let scoredFacts = facts.map { fact in
            (fact: fact, score: fact.calculateInterestScore(confidence: confidence, userPreferences: userPreferences))
        }
        
        // Group by score tiers for smart rotation
        let highScore = scoredFacts.filter { $0.score >= 0.7 }
        let mediumScore = scoredFacts.filter { $0.score >= 0.4 && $0.score < 0.7 }
        let lowScore = scoredFacts.filter { $0.score < 0.4 }
        
        // Interleave high and medium score facts, add low score at end
        var sequence: [RatedFact] = []
        let maxHigh = highScore.count
        let maxMedium = mediumScore.count
        
        for i in 0..<max(maxHigh, maxMedium) {
            if i < maxHigh {
                sequence.append(highScore[i].fact)
            }
            if i < maxMedium {
                sequence.append(mediumScore[i].fact)
            }
        }
        
        // Add remaining low score facts
        sequence.append(contentsOf: lowScore.map { $0.fact })
        
        return sequence
    }
    
    // MARK: - Private Methods
    
    private func getRatedFacts(for uses: Uses, rockName: String) -> [RatedFact] {
        // Check if we already have rated facts for this rock
        if let existingFacts = allRatedFacts[rockName] {
            return existingFacts
        }
        
        // Convert plain string facts to rated facts with intelligent categorization
        let ratedFacts = uses.funFacts.map { factText in
            let rating = determineFactRating(factText)
            let categories = categorizeFactText(factText)
            let confidenceThreshold = determineConfidenceThreshold(factText, categories: categories)
            
            return RatedFact(
                text: factText,
                baseRating: rating,
                categories: categories,
                confidenceThreshold: confidenceThreshold
            )
        }
        
        // Store for future use
        allRatedFacts[rockName] = ratedFacts
        saveUserData()
        
        return ratedFacts
    }
    
    /// Intelligently determine the interest rating for a fact based on content
    private func determineFactRating(_ factText: String) -> FactInterestRating {
        let text = factText.lowercased()
        
        // Very high interest indicators
        let veryHighKeywords = [
            "world's largest", "world's smallest", "only known", "most expensive",
            "ancient civilization", "thousands of years", "extinct", "discovered by accident",
            "worth millions", "rarer than diamond", "impossible to", "defies physics",
            "scientists baffled", "mystery", "unexplained", "legend", "curse"
        ]
        
        // High interest indicators  
        let highKeywords = [
            "birthstone", "ancient", "believed to", "protect", "healing",
            "royal", "crown jewels", "famous", "rare", "valuable",
            "forms only", "takes millions", "found only", "discovered",
            "named after", "hardest", "softest", "changes color"
        ]
        
        // Medium interest indicators
        let mediumKeywords = [
            "used in", "important", "common", "popular", "jewelry",
            "industrial", "construction", "formed when", "contains",
            "chemical formula", "composed of", "family", "variety"
        ]
        
        // Check for very high interest
        for keyword in veryHighKeywords {
            if text.contains(keyword) {
                return .veryHigh
            }
        }
        
        // Check for high interest
        for keyword in highKeywords {
            if text.contains(keyword) {
                return .high
            }
        }
        
        // Check for medium interest
        for keyword in mediumKeywords {
            if text.contains(keyword) {
                return .medium
            }
        }
        
        // Default to low interest
        return .low
    }
    
    /// Categorize a fact based on its content
    private func categorizeFactText(_ factText: String) -> [FactCategory] {
        let text = factText.lowercased()
        var categories: [FactCategory] = []
        
        // Historical indicators
        if text.contains("ancient") || text.contains("century") || text.contains("historical") ||
           text.contains("egyptian") || text.contains("roman") || text.contains("civilization") {
            categories.append(.historical)
        }
        
        // Scientific indicators
        if text.contains("chemical") || text.contains("formula") || text.contains("crystal") ||
           text.contains("atomic") || text.contains("research") || text.contains("study") {
            categories.append(.scientific)
        }
        
        // Cultural indicators
        if text.contains("culture") || text.contains("tradition") || text.contains("belief") ||
           text.contains("symbol") || text.contains("ritual") || text.contains("ceremony") {
            categories.append(.cultural)
        }
        
        // Economic indicators
        if text.contains("expensive") || text.contains("valuable") || text.contains("trade") ||
           text.contains("mining") || text.contains("industry") || text.contains("market") {
            categories.append(.economic)
        }
        
        // Geographical indicators
        if text.contains("found in") || text.contains("location") || text.contains("region") ||
           text.contains("country") || text.contains("deposits") || text.contains("mined") {
            categories.append(.geographical)
        }
        
        // Mystical indicators
        if text.contains("healing") || text.contains("spiritual") || text.contains("energy") ||
           text.contains("chakra") || text.contains("metaphysical") || text.contains("believed") {
            categories.append(.mystical)
        }
        
        // Unusual indicators
        if text.contains("unusual") || text.contains("strange") || text.contains("weird") ||
           text.contains("unique") || text.contains("only") || text.contains("impossible") {
            categories.append(.unusual)
        }
        
        // Record indicators  
        if text.contains("largest") || text.contains("smallest") || text.contains("hardest") ||
           text.contains("most") || text.contains("record") || text.contains("world's") {
            categories.append(.record)
        }
        
        // Discovery indicators
        if text.contains("discovered") || text.contains("found") || text.contains("identified") ||
           text.contains("named") || text.contains("first") || text.contains("new") {
            categories.append(.discovery)
        }
        
        // Practical indicators
        if text.contains("used for") || text.contains("application") || text.contains("tool") ||
           text.contains("construction") || text.contains("practical") || text.contains("everyday") {
            categories.append(.practical)
        }
        
        // Default to scientific if no categories found
        if categories.isEmpty {
            categories.append(.scientific)
        }
        
        return categories
    }
    
    /// Determine minimum confidence threshold for showing this fact
    private func determineConfidenceThreshold(_ factText: String, categories: [FactCategory]) -> Double {
        let text = factText.lowercased()
        
        // Facts that require high confidence
        if text.contains("exactly") || text.contains("precisely") || text.contains("specifically") ||
           categories.contains(.record) || categories.contains(.scientific) {
            return 0.8
        }
        
        // Facts that require medium confidence
        if categories.contains(.historical) || categories.contains(.geographical) ||
           categories.contains(.economic) {
            return 0.6
        }
        
        // General facts can be shown with any confidence
        return 0.0
    }
    
    /// Setup some enhanced facts database with better ratings
    private func setupFactDatabase() {
        // This could be expanded to include curated facts for common rocks
        // For now, the system will automatically rate facts from API responses
    }
    
    /// Load user preferences and rated facts from UserDefaults
    private func loadUserData() {
        // Load preferences
        if let preferencesData = userDefaults.data(forKey: preferencesKey),
           let preferences = try? JSONDecoder().decode(FactPreferences.self, from: preferencesData) {
            userPreferences = preferences
        }
        
        // Load rated facts
        if let factsData = userDefaults.data(forKey: ratedFactsKey),
           let facts = try? JSONDecoder().decode([String: [RatedFact]].self, from: factsData) {
            allRatedFacts = facts
        }
    }
    
    /// Save user preferences and rated facts to UserDefaults
    private func saveUserData() {
        // Save preferences
        if let preferencesData = try? JSONEncoder().encode(userPreferences) {
            userDefaults.set(preferencesData, forKey: preferencesKey)
        }
        
        // Save rated facts
        if let factsData = try? JSONEncoder().encode(allRatedFacts) {
            userDefaults.set(factsData, forKey: ratedFactsKey)
        }
    }
}

// MARK: - Extensions for easier access

extension FactManager {
    /// Get all favorite facts across all rocks
    func getAllFavoriteFacts() -> [(rockName: String, fact: RatedFact)] {
        var favorites: [(String, RatedFact)] = []
        
        for (rockName, facts) in allRatedFacts {
            let rockFavorites = facts.filter { $0.isFavorite }
            for fact in rockFavorites {
                favorites.append((rockName, fact))
            }
        }
        
        return favorites.sorted { $0.1.text < $1.1.text }
    }
    
    /// Get statistics about user's fact interactions
    func getFactStatistics() -> (totalFacts: Int, favorites: Int, rated: Int, categories: [FactCategory: Int]) {
        var totalFacts = 0
        var favorites = 0 
        var rated = 0
        var categoryCount: [FactCategory: Int] = [:]
        
        for facts in allRatedFacts.values {
            totalFacts += facts.count
            
            for fact in facts {
                if fact.isFavorite {
                    favorites += 1
                }
                
                if fact.userRating != nil {
                    rated += 1
                }
                
                for category in fact.categories {
                    categoryCount[category, default: 0] += 1
                }
            }
        }
        
        return (totalFacts, favorites, rated, categoryCount)
    }
}
