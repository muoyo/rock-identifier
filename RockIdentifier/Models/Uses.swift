// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

struct Uses: Codable, Equatable {
    let industrial: [String]?
    let historical: [String]?
    let modern: [String]?
    let metaphysical: [String]?
    let funFacts: [String]
    let additionalUses: [String: String]?
    
    // Enhanced fact selection support
    var enhancedFacts: [EnhancedFact] {
        return funFacts.map { factText in
            EnhancedFact(from: factText, rockName: "Unknown")
        }
    }
    
    init(
        industrial: [String]? = nil,
        historical: [String]? = nil,
        modern: [String]? = nil,
        metaphysical: [String]? = nil,
        funFacts: [String],
        additionalUses: [String: String]? = nil
    ) {
        self.industrial = industrial
        self.historical = historical
        self.modern = modern
        self.metaphysical = metaphysical
        self.funFacts = funFacts
        self.additionalUses = additionalUses
    }
    
    /// Create enhanced facts for the given rock name and confidence level
    func enhancedFacts(for rockName: String, confidence: Double) -> [EnhancedFact] {
        return funFacts.map { factText in
            EnhancedFact(from: factText, rockName: rockName)
        }.filter { fact in
            fact.isAppropriate(for: confidence)
        }
    }
}
