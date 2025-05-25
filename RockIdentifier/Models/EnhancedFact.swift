// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

/// Enhanced fact model with intelligence ratings and user preferences
struct EnhancedFact: Codable, Identifiable, Equatable {
    let id: String
    let text: String
    let interestingnessRating: FactRating
    let confidenceLevel: ConfidenceLevel
    let category: FactCategory
    let rockName: String // Associated rock for personalization
    var isFavorited: Bool = false
    var displayCount: Int = 0
    var lastShown: Date?
    
    init(text: String, rockName: String, interestingnessRating: FactRating = .medium, confidenceLevel: ConfidenceLevel = .any, category: FactCategory = .general) {
        self.id = UUID().uuidString
        self.text = text
        self.rockName = rockName
        self.interestingnessRating = interestingnessRating
        self.confidenceLevel = confidenceLevel
        self.category = category
    }
    
    /// Create enhanced fact from simple string with intelligent analysis
    init(from simpleText: String, rockName: String) {
        self.id = UUID().uuidString
        self.text = simpleText
        self.rockName = rockName
        
        // Analyze the fact text to determine ratings automatically
        let analysis = FactAnalyzer.analyze(text: simpleText, rockName: rockName)
        self.interestingnessRating = analysis.interestingnessRating
        self.confidenceLevel = analysis.confidenceLevel
        self.category = analysis.category
    }
    
    // MARK: - Computed Properties
    
    /// Priority score for fact selection algorithm
    var priorityScore: Double {
        var score = interestingnessRating.rawValue
        
        // Boost score for favorites
        if isFavorited {
            score += 3.0
        }
        
        // Reduce score for recently or frequently shown facts
        if let lastShown = lastShown {
            let hoursSinceShown = Date().timeIntervalSince(lastShown) / 3600
            if hoursSinceShown < 24 {
                score -= 1.0 // Reduce priority for facts shown in last 24 hours
            }
        }
        
        // Reduce score based on display frequency
        if displayCount > 5 {
            score -= Double(displayCount - 5) * 0.2
        }
        
        return max(0, score)
    }
    
    /// Whether this fact is appropriate for the given confidence level
    func isAppropriate(for confidence: Double) -> Bool {
        switch confidenceLevel {
        case .high:
            return confidence >= 0.85
        case .medium:
            return confidence >= 0.70
        case .low:
            return confidence >= 0.50
        case .any:
            return true
        }
    }
    
    /// Visual styling hint for UI presentation
    var visualStyle: FactVisualStyle {
        if isFavorited {
            return .favorited
        }
        
        switch interestingnessRating {
        case .exceptional:
            return .exceptional
        case .high:
            return .high
        case .medium:
            return .medium
        case .low:
            return .low
        }
    }
}

// MARK: - Supporting Enums

enum FactRating: Double, Codable, CaseIterable {
    case low = 1.0
    case medium = 2.0
    case high = 4.0
    case exceptional = 6.0
    
    var description: String {
        switch self {
        case .low: return "Informative"
        case .medium: return "Interesting"
        case .high: return "Fascinating"
        case .exceptional: return "Mind-blowing"
        }
    }
}

enum ConfidenceLevel: String, Codable, CaseIterable {
    case high = "high"     // For facts that should only show with high confidence (>85%)
    case medium = "medium" // For facts that need moderate confidence (>70%)
    case low = "low"       // For facts that can show with low confidence (>50%)
    case any = "any"       // For facts appropriate at any confidence level
}

// Categories for facts to help with user preferences
enum FactCategory: String, CaseIterable, Codable {
    case historical = "historical"
    case scientific = "scientific"
    case cultural = "cultural"
    case formation = "formation"
    case unusual = "unusual"
    case practical = "practical"
    case general = "general"
    case economic = "economic"
    case geographical = "geographical"
    case mystical = "mystical"
    case record = "record"
    case discovery = "discovery"
    
    var displayName: String {
        switch self {
        case .historical: return "Historical"
        case .scientific: return "Scientific"
        case .cultural: return "Cultural"
        case .formation: return "Formation"
        case .unusual: return "Unusual"
        case .practical: return "Practical"
        case .general: return "General"
        case .economic: return "Economic"
        case .geographical: return "Geographical"
        case .mystical: return "Mystical"
        case .record: return "Records"
        case .discovery: return "Discovery"
        }
    }
    
    var icon: String {
        switch self {
        case .historical: return "scroll"
        case .scientific: return "atom"
        case .cultural: return "globe"
        case .formation: return "mountain.2"
        case .unusual: return "star.fill"
        case .practical: return "hammer"
        case .general: return "info.circle"
        case .economic: return "dollarsign.circle"
        case .geographical: return "map"
        case .mystical: return "sparkles"
        case .record: return "trophy"
        case .discovery: return "magnifyingglass"
        }
    }
}

enum FactVisualStyle {
    case favorited
    case exceptional
    case high
    case medium
    case low
    
    var backgroundColor: String {
        switch self {
        case .favorited: return "RoseQuartzPink"
        case .exceptional: return "AmethystPurple"
        case .high: return "SapphireBlue"
        case .medium: return "EmeraldGreen"
        case .low: return "AccentOrange"
        }
    }
    
    var glowIntensity: Double {
        switch self {
        case .favorited: return 0.8
        case .exceptional: return 0.7
        case .high: return 0.5
        case .medium: return 0.3
        case .low: return 0.1
        }
    }
}

// MARK: - Fact Analysis Engine

struct FactAnalyzer {
    /// Analyze a fact string to determine ratings and categories
    static func analyze(text: String, rockName: String) -> (interestingnessRating: FactRating, confidenceLevel: ConfidenceLevel, category: FactCategory) {
        let lowercaseText = text.lowercased()
        
        // Determine interestingness rating based on content
        let interestingnessRating = determineInterestingness(text: lowercaseText)
        
        // Determine confidence level requirement
        let confidenceLevel = determineConfidenceLevel(text: lowercaseText)
        
        // Determine category
        let category = determineCategory(text: lowercaseText)
        
        return (interestingnessRating, confidenceLevel, category)
    }
    
    private static func determineInterestingness(text: String) -> FactRating {
        let exceptionalKeywords = [
            "oldest", "largest", "rarest", "only", "unique", "discovered", "mystery", "ancient", 
            "legend", "myth", "cursed", "priceless", "treasure", "royal", "emperor", "pharaoh",
            "meteorite", "space", "alien", "impossible", "magical", "supernatural", "miracle"
        ]
        
        let highKeywords = [
            "famous", "incredible", "amazing", "fascinating", "remarkable", "extraordinary",
            "beautiful", "valuable", "precious", "historic", "centuries", "formation", "crystal",
            "healing", "power", "energy", "birthstone", "sacred", "temple", "crown"
        ]
        
        let mediumKeywords = [
            "used", "believed", "ancient", "traditional", "common", "found", "forms", "color",
            "originally", "known", "popular", "sometimes", "often", "typically"
        ]
        
        // Count keyword matches
        let exceptionalCount = exceptionalKeywords.filter { text.contains($0) }.count
        let highCount = highKeywords.filter { text.contains($0) }.count
        let mediumCount = mediumKeywords.filter { text.contains($0) }.count
        
        // Additional factors
        let hasNumbers = text.range(of: #"\d+"#, options: .regularExpression) != nil
        let hasSpecificDates = text.contains("century") || text.contains("year") || text.contains("BC") || text.contains("AD")
        let hasSuperlatives = text.contains("most") || text.contains("best") || text.contains("first") || text.contains("last")
        
        // Calculate score
        var score = 0
        score += exceptionalCount * 3
        score += highCount * 2
        score += mediumCount * 1
        
        if hasNumbers { score += 1 }
        if hasSpecificDates { score += 2 }
        if hasSuperlatives { score += 2 }
        
        // Determine rating based on score
        if score >= 6 || exceptionalCount > 0 {
            return .exceptional
        } else if score >= 4 || highCount > 1 {
            return .high
        } else if score >= 2 || mediumCount > 1 {
            return .medium
        } else {
            return .low
        }
    }
    
    private static func determineConfidenceLevel(text: String) -> ConfidenceLevel {
        // Facts with specific claims should require higher confidence
        let highConfidenceKeywords = ["exact", "precisely", "specifically", "measured", "calculated", "proven"]
        let mediumConfidenceKeywords = ["commonly", "typically", "usually", "often", "generally"]
        let lowConfidenceKeywords = ["believed", "thought", "said", "legend", "myth", "folklore"]
        
        if highConfidenceKeywords.contains(where: { text.contains($0) }) {
            return .high
        } else if mediumConfidenceKeywords.contains(where: { text.contains($0) }) {
            return .medium
        } else if lowConfidenceKeywords.contains(where: { text.contains($0) }) {
            return .low
        }
        
        return .any
    }
    
    private static func determineCategory(text: String) -> FactCategory {
        let historicalKeywords = ["ancient", "century", "BC", "AD", "historical", "originally", "traditional", "pharaoh", "emperor", "temple"]
        let scientificKeywords = ["chemical", "formula", "element", "crystal", "formation", "geological", "molecular", "atomic"]
        let culturalKeywords = ["believed", "legend", "myth", "sacred", "spiritual", "healing", "energy", "chakra", "meditation"]
        let formationKeywords = ["forms", "created", "pressure", "temperature", "volcanic", "metamorphic", "igneous", "sedimentary"]
        let unusualKeywords = ["strange", "unusual", "unique", "rare", "mystery", "impossible", "weird", "odd", "surprising"]
        let practicalKeywords = ["used", "jewelry", "tools", "building", "industry", "medical", "practical", "application"]
        
        if historicalKeywords.contains(where: { text.contains($0) }) {
            return .historical
        } else if scientificKeywords.contains(where: { text.contains($0) }) {
            return .scientific
        } else if culturalKeywords.contains(where: { text.contains($0) }) {
            return .cultural
        } else if formationKeywords.contains(where: { text.contains($0) }) {
            return .formation
        } else if unusualKeywords.contains(where: { text.contains($0) }) {
            return .unusual
        } else if practicalKeywords.contains(where: { text.contains($0) }) {
            return .practical
        }
        
        return .general
    }
}
