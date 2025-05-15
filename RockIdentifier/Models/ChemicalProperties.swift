// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

struct ChemicalProperties: Codable, Equatable {
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

struct Element: Codable, Equatable {
    let name: String
    let symbol: String
    let percentage: Double?
    
    init(name: String, symbol: String, percentage: Double? = nil) {
        self.name = name
        self.symbol = symbol
        self.percentage = percentage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle name and symbol
        if let nameString = try container.decodeIfPresent(String.self, forKey: .name) {
            name = nameString
        } else {
            name = "Unknown"
        }
        
        if let symbolString = try container.decodeIfPresent(String.self, forKey: .symbol) {
            symbol = symbolString
        } else {
            symbol = "?"
        }
        
        // Handle percentage that might be a string
        if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: .percentage) {
            percentage = doubleValue
        } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .percentage),
                  let doubleFromString = Double(stringValue.replacingOccurrences(of: "~", with: "").trimmingCharacters(in: .whitespacesAndNewlines)) {
            percentage = doubleFromString
        } else {
            percentage = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name, symbol, percentage
    }
}
