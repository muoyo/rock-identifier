// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

struct Uses: Codable {
    let industrial: [String]?
    let historical: [String]?
    let modern: [String]?
    let metaphysical: [String]?
    let funFacts: [String]
    let additionalUses: [String: String]?
    
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
}
