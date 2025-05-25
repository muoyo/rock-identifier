// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import Combine

/// Intelligent fact selection and management system
class FactSelectionManager: ObservableObject {
    @Published private(set) var availableFacts: [EnhancedFact] = []
    @Published private(set) var currentFact: EnhancedFact?
    @Published private(set) var selectionHistory: [String] = [] // Fact IDs
    
    private let maxHistorySize = 50
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteFactIDs"
    private let displayCountsKey = "FactDisplayCounts"
    private let lastShownDatesKey = "FactLastShownDates"
    
    // MARK: - Initialization
    
    init() {
        loadUserPreferences()
    }
    
    // MARK: - Fact Management
    
    /// Set facts for a rock identification result
    func setFacts(_ facts: [String], for rockName: String, confidence: Double) {
        // Convert simple strings to enhanced facts
        var enhancedFacts = facts.map { factText in
            EnhancedFact(from: factText, rockName: rockName)
        }
        
        // Apply user preferences
        enhancedFacts = applyUserPreferences(to: enhancedFacts)
        
        // Filter facts appropriate for confidence level
        enhancedFacts = enhancedFacts.filter { $0.isAppropriate(for: confidence) }
        
        // Sort by priority
        enhancedFacts.sort { $0.priorityScore > $1.priorityScore }
        
        self.availableFacts = enhancedFacts
        
        // Select the best initial fact
        selectNextFact()
        
        print("FactSelectionManager: Set \(enhancedFacts.count) facts for \(rockName) (confidence: \(confidence))")
        logFactAnalysis(enhancedFacts)
    }
    
    /// Get the next best fact using intelligent selection
    func selectNextFact() {
        guard !availableFacts.isEmpty else {
            currentFact = nil
            return
        }
        
        // Use intelligent selection algorithm
        if let selectedFact = intelligentFactSelection() {
            // Update display tracking
            markFactAsShown(selectedFact)
            currentFact = selectedFact
            
            print("FactSelectionManager: Selected fact (rating: \(selectedFact.interestingnessRating.description), priority: \(String(format: "%.1f", selectedFact.priorityScore)))")
        }
    }
    
    /// Select the previous fact in the available facts list
    func selectPreviousFact() {
        guard availableFacts.count > 1 else { return }
        
        // Find current fact index and go to previous
        if let currentFact = currentFact,
           let currentIndex = availableFacts.firstIndex(where: { $0.id == currentFact.id }) {
            let previousIndex = currentIndex > 0 ? currentIndex - 1 : availableFacts.count - 1
            let previousFact = availableFacts[previousIndex]
            
            // Update display tracking
            markFactAsShown(previousFact)
            self.currentFact = previousFact
            
            print("FactSelectionManager: Selected previous fact (index: \(previousIndex))")
        }
    }
    
    /// Mark a fact as favorite/unfavorite
    func toggleFavorite(for factID: String) {
        // Update local facts
        if let index = availableFacts.firstIndex(where: { $0.id == factID }) {
            availableFacts[index].isFavorited.toggle()
            
            // Update current fact if it's the one being toggled
            if currentFact?.id == factID {
                currentFact?.isFavorited.toggle()
            }
            
            // Persist to UserDefaults
            saveFavoriteStatus(factID: factID, isFavorited: availableFacts[index].isFavorited)
            
            print("FactSelectionManager: Toggled favorite for fact: \(availableFacts[index].isFavorited ? "❤️" : "💔")")
            
            // Add haptic feedback
            HapticManager.shared.selectionChanged()
        }
    }
    
    // MARK: - Enhanced Intelligent Selection Algorithm
    
    private func intelligentFactSelection() -> EnhancedFact? {
        var candidateFacts = availableFacts
        
        // Step 1: Apply advanced filtering and scoring
        candidateFacts = applyAdvancedFiltering(to: candidateFacts)
        
        guard !candidateFacts.isEmpty else {
            // Fallback to any available fact if filtering is too restrictive
            return availableFacts.randomElement()
        }
        
        // Step 2: Calculate enhanced priority scores with temporal factors
        let scoredFacts = candidateFacts.map { fact in
            (fact: fact, score: calculateEnhancedPriorityScore(for: fact))
        }.sorted { $0.score > $1.score }
        
        // Step 3: Apply tiered selection with some randomness to avoid predictability
        return selectFromTieredCandidates(scoredFacts)
    }
    
    /// Apply advanced filtering based on recency, diversity, and user preferences
    private func applyAdvancedFiltering(to facts: [EnhancedFact]) -> [EnhancedFact] {
        var filtered = facts
        
        // Filter 1: Avoid recently shown facts (last 3 selections)
        let recentlyShownIDs = Set(selectionHistory.suffix(3))
        let notRecentlyShown = filtered.filter { !recentlyShownIDs.contains($0.id) }
        
        if !notRecentlyShown.isEmpty {
            filtered = notRecentlyShown
        }
        
        // Filter 2: Ensure category diversity if we have multiple categories
        let categoryDistribution = Dictionary(grouping: filtered, by: { $0.category })
        if categoryDistribution.count > 1 {
            // Prefer underrepresented categories in recent history
            filtered = prioritizeDiverseCategories(filtered)
        }
        
        // Filter 3: Apply confidence-based filtering
        // This was already handled in setFacts, but we can refine it here
        
        return filtered
    }
    
    /// Calculate an enhanced priority score considering multiple factors
    private func calculateEnhancedPriorityScore(for fact: EnhancedFact) -> Double {
        var score = fact.priorityScore // Base score from EnhancedFact
        
        // Factor 1: Boost for exceptional content
        if fact.interestingnessRating == .exceptional {
            score += 2.0
        } else if fact.interestingnessRating == .high {
            score += 1.0
        }
        
        // Factor 2: Freshness bonus (facts not shown recently get a boost)
        if let lastShown = fact.lastShown {
            let hoursSinceShown = Date().timeIntervalSince(lastShown) / 3600
            if hoursSinceShown > 24 {
                score += 0.5
            } else if hoursSinceShown > 4 {
                score += 0.2
            }
        } else {
            // Never shown before - significant boost
            score += 1.0
        }
        
        // Factor 3: Category variety bonus
        let recentCategories = getRecentCategoryHistory()
        if !recentCategories.contains(fact.category) {
            score += 0.3
        }
        
        // Factor 4: Display frequency penalty (diminishing returns for frequently shown facts)
        let displayPenalty = min(Double(fact.displayCount) * 0.1, 1.0)
        score -= displayPenalty
        
        // Factor 5: Special boost for user favorites
        if fact.isFavorited {
            score += 1.5
        }
        
        return max(0.1, score) // Ensure minimum score
    }
    
    /// Select from tiered candidates using weighted randomness
    private func selectFromTieredCandidates(_ scoredFacts: [(fact: EnhancedFact, score: Double)]) -> EnhancedFact? {
        guard !scoredFacts.isEmpty else { return nil }
        
        // Tier 1: Top 30% of facts (premium selection)
        let tier1Count = max(1, scoredFacts.count * 30 / 100)
        let tier1Facts = Array(scoredFacts.prefix(tier1Count))
        
        // Tier 2: Middle 50% of facts (good selection)
        let tier2Start = tier1Count
        let tier2Count = max(1, scoredFacts.count * 50 / 100)
        let tier2Facts = Array(scoredFacts.dropFirst(tier2Start).prefix(tier2Count))
        
        // Tier 3: Bottom 20% of facts (fallback selection)
        let tier3Facts = Array(scoredFacts.dropFirst(tier2Start + tier2Count))
        
        // Weighted selection: 70% chance tier 1, 25% chance tier 2, 5% chance tier 3
        let random = Double.random(in: 0...1)
        
        let selectedTier: [(fact: EnhancedFact, score: Double)]
        if random < 0.70 {
            selectedTier = tier1Facts
        } else if random < 0.95 {
            selectedTier = tier2Facts.isEmpty ? tier1Facts : tier2Facts
        } else {
            selectedTier = tier3Facts.isEmpty ? (tier2Facts.isEmpty ? tier1Facts : tier2Facts) : tier3Facts
        }
        
        // Within the selected tier, use weighted random selection
        let totalWeight = selectedTier.reduce(0) { $0 + $1.score }
        guard totalWeight > 0 else { return selectedTier.randomElement()?.fact }
        
        let randomValue = Double.random(in: 0...totalWeight)
        var currentWeight = 0.0
        
        for (fact, score) in selectedTier {
            currentWeight += score
            if randomValue <= currentWeight {
                return fact
            }
        }
        
        return selectedTier.first?.fact
    }
    
    /// Prioritize facts from categories that haven't been shown recently
    private func prioritizeDiverseCategories(_ facts: [EnhancedFact]) -> [EnhancedFact] {
        let recentCategories = getRecentCategoryHistory()
        
        // Separate facts into shown and unshown categories
        let unshownCategoryFacts = facts.filter { !recentCategories.contains($0.category) }
        let shownCategoryFacts = facts.filter { recentCategories.contains($0.category) }
        
        // Prefer facts from unshown categories, but don't exclude shown ones entirely
        if !unshownCategoryFacts.isEmpty {
            return unshownCategoryFacts + shownCategoryFacts
        }
        
        return facts
    }
    
    /// Get categories of recently shown facts for diversity analysis
    private func getRecentCategoryHistory() -> Set<FactCategory> {
        let recentFactIDs = Set(selectionHistory.suffix(5))
        let recentFacts = availableFacts.filter { recentFactIDs.contains($0.id) }
        return Set(recentFacts.map { $0.category })
    }
    
    private func markFactAsShown(_ fact: EnhancedFact) {
        // Update display count
        if let index = availableFacts.firstIndex(where: { $0.id == fact.id }) {
            availableFacts[index].displayCount += 1
            availableFacts[index].lastShown = Date()
            
            // Save to UserDefaults
            saveDisplayCount(factID: fact.id, count: availableFacts[index].displayCount)
            saveLastShownDate(factID: fact.id, date: Date())
        }
        
        // Update selection history
        selectionHistory.append(fact.id)
        if selectionHistory.count > maxHistorySize {
            selectionHistory.removeFirst()
        }
    }
    
    // MARK: - User Preferences Persistence
    
    private func loadUserPreferences() {
        let favoriteIDs = Set(userDefaults.stringArray(forKey: favoritesKey) ?? [])
        let displayCounts = userDefaults.dictionary(forKey: displayCountsKey) as? [String: Int] ?? [:]
        let lastShownDates = userDefaults.dictionary(forKey: lastShownDatesKey) as? [String: Date] ?? [:]
        
        print("FactSelectionManager: Loaded \(favoriteIDs.count) favorites, \(displayCounts.count) display counts")
    }
    
    private func applyUserPreferences(to facts: [EnhancedFact]) -> [EnhancedFact] {
        let favoriteIDs = Set(userDefaults.stringArray(forKey: favoritesKey) ?? [])
        let displayCounts = userDefaults.dictionary(forKey: displayCountsKey) as? [String: Int] ?? [:]
        let lastShownDates = userDefaults.dictionary(forKey: lastShownDatesKey) as? [String: Date] ?? [:]
        
        return facts.map { fact in
            var updatedFact = fact
            
            // Apply favorite status - match by text since IDs are regenerated
            updatedFact.isFavorited = favoriteIDs.contains(fact.text)
            
            // Apply display counts - match by text
            updatedFact.displayCount = displayCounts[fact.text] ?? 0
            
            // Apply last shown dates - match by text
            updatedFact.lastShown = lastShownDates[fact.text]
            
            return updatedFact
        }
    }
    
    private func saveFavoriteStatus(factID: String, isFavorited: Bool) {
        guard let fact = availableFacts.first(where: { $0.id == factID }) else { return }
        
        var favoriteTexts = Set(userDefaults.stringArray(forKey: favoritesKey) ?? [])
        
        if isFavorited {
            favoriteTexts.insert(fact.text)
        } else {
            favoriteTexts.remove(fact.text)
        }
        
        userDefaults.set(Array(favoriteTexts), forKey: favoritesKey)
    }
    
    private func saveDisplayCount(factID: String, count: Int) {
        guard let fact = availableFacts.first(where: { $0.id == factID }) else { return }
        
        var displayCounts = userDefaults.dictionary(forKey: displayCountsKey) as? [String: Int] ?? [:]
        displayCounts[fact.text] = count
        userDefaults.set(displayCounts, forKey: displayCountsKey)
    }
    
    private func saveLastShownDate(factID: String, date: Date) {
        guard let fact = availableFacts.first(where: { $0.id == factID }) else { return }
        
        var lastShownDates = userDefaults.dictionary(forKey: lastShownDatesKey) as? [String: Date] ?? [:]
        lastShownDates[fact.text] = date
        userDefaults.set(lastShownDates, forKey: lastShownDatesKey)
    }
    
    // MARK: - Analytics & Insights
    
    /// Get enhanced fact statistics for the current set
    func getFactStatistics() -> FactStatistics {
        let total = availableFacts.count
        let favorites = availableFacts.filter { $0.isFavorited }.count
        let exceptional = availableFacts.filter { $0.interestingnessRating == .exceptional }.count
        let high = availableFacts.filter { $0.interestingnessRating == .high }.count
        let neverShown = availableFacts.filter { $0.displayCount == 0 }.count
        
        let categoryDistribution = Dictionary(grouping: availableFacts, by: { $0.category })
            .mapValues { $0.count }
        
        // Calculate enhanced quality score based on multiple factors
        let enhancedQualityScore = calculateEnhancedQualityScore()
        
        return FactStatistics(
            totalFacts: total,
            favoriteFacts: favorites,
            exceptionalFacts: exceptional,
            highInterestFacts: high,
            neverShownFacts: neverShown,
            categoryDistribution: categoryDistribution,
            enhancedQualityScore: enhancedQualityScore
        )
    }
    
    /// Calculate an enhanced quality score based on content quality and diversity
    private func calculateEnhancedQualityScore() -> Double {
        guard !availableFacts.isEmpty else { return 0.0 }
        
        // Base quality from rating distribution
        let exceptionalWeight = Double(availableFacts.filter { $0.interestingnessRating == .exceptional }.count) * 4.0
        let highWeight = Double(availableFacts.filter { $0.interestingnessRating == .high }.count) * 3.0
        let mediumWeight = Double(availableFacts.filter { $0.interestingnessRating == .medium }.count) * 2.0
        let lowWeight = Double(availableFacts.filter { $0.interestingnessRating == .low }.count) * 1.0
        
        let baseQuality = (exceptionalWeight + highWeight + mediumWeight + lowWeight) / Double(availableFacts.count)
        
        // Diversity bonus (more categories = higher quality)
        let uniqueCategories = Set(availableFacts.map { $0.category }).count
        let diversityBonus = min(Double(uniqueCategories) * 0.2, 1.0)
        
        // Freshness bonus (more unshown facts = higher potential quality)
        let neverShownCount = availableFacts.filter { $0.displayCount == 0 }.count
        let freshnessBonus = Double(neverShownCount) / Double(availableFacts.count) * 0.5
        
        let finalScore = baseQuality + diversityBonus + freshnessBonus
        return min(5.0, max(1.0, finalScore)) // Normalize to 1-5 scale
    }
    
    /// Get all facts sorted by user preference (favorites first, then by rating)
    func getFactsForBrowsing() -> [EnhancedFact] {
        return availableFacts.sorted { lhs, rhs in
            // Favorites first
            if lhs.isFavorited != rhs.isFavorited {
                return lhs.isFavorited
            }
            
            // Then by interestingness rating
            if lhs.interestingnessRating != rhs.interestingnessRating {
                return lhs.interestingnessRating.rawValue > rhs.interestingnessRating.rawValue
            }
            
            // Finally by display count (less shown first)
            return lhs.displayCount < rhs.displayCount
        }
    }
    
    // MARK: - Debug Helpers
    
    private func logFactAnalysis(_ facts: [EnhancedFact]) {
        #if DEBUG
        print("=== FACT ANALYSIS ===")
        for (index, fact) in facts.enumerated() {
            let status = fact.isFavorited ? "❤️" : ""
            print("[\(index + 1)] \(fact.interestingnessRating.description) | \(fact.category.rawValue) | Score: \(String(format: "%.1f", fact.priorityScore)) \(status)")
            print("    \(fact.text.prefix(80))...")
        }
        print("=====================")
        #endif
    }
}

// MARK: - Supporting Types

struct FactStatistics {
    let totalFacts: Int
    let favoriteFacts: Int
    let exceptionalFacts: Int
    let highInterestFacts: Int
    let neverShownFacts: Int
    let categoryDistribution: [FactCategory: Int]
    let enhancedQualityScore: Double
    
    // Legacy quality score for backwards compatibility
    var qualityScore: Double {
        return enhancedQualityScore
    }
    
    // Additional computed properties for UI display
    var diversityScore: Double {
        let uniqueCategories = categoryDistribution.keys.count
        return min(5.0, Double(uniqueCategories) * 0.8)
    }
    
    var freshnessScore: Double {
        guard totalFacts > 0 else { return 0.0 }
        return (Double(neverShownFacts) / Double(totalFacts)) * 5.0
    }
    
    var engagementScore: Double {
        guard totalFacts > 0 else { return 0.0 }
        return (Double(favoriteFacts) / Double(totalFacts)) * 5.0
    }
}

// MARK: - Factory Methods

extension FactSelectionManager {
    /// Create a fact selection manager with mock data for testing
    static func withMockData() -> FactSelectionManager {
        let manager = FactSelectionManager()
        
        let mockFacts = [
            "Amethyst gets its purple color from iron impurities in the crystal structure",
            "The name 'amethyst' comes from ancient Greek meaning 'not intoxicated'",
            "Ancient Romans believed amethyst could prevent drunkenness when worn",
            "The largest amethyst geode ever found weighs over 13,000 pounds",
            "Amethyst is the birthstone for February and the 6th wedding anniversary gem",
            "Heat-treated amethyst turns yellow or orange, creating citrine",
            "The finest amethyst comes from Brazil, Uruguay, and Zambia"
        ]
        
        manager.setFacts(mockFacts, for: "Amethyst", confidence: 0.92)
        return manager
    }
}
