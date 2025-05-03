// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

struct ChemicalProperties: Codable {
    let formula: String?
    let composition: String
    let elements: [Element]?
    let mineralsPresent: [String]?
    let reactivity: String?
    let additionalProperties: [String: String]?
    
    init(
        formula: String? = nil,
        composition: String,
        elements: [Element]? = nil,
        mineralsPresent: [String]? = nil,
        reactivity: String? = nil,
        additionalProperties: [String: String]? = nil
    ) {
        self.formula = formula
        self.composition = composition
        self.elements = elements
        self.mineralsPresent = mineralsPresent
        self.reactivity = reactivity
        self.additionalProperties = additionalProperties
    }
}

struct Element: Codable {
    let name: String
    let symbol: String
    let percentage: Double?
    
    init(name: String, symbol: String, percentage: Double? = nil) {
        self.name = name
        self.symbol = symbol
        self.percentage = percentage
    }
}
