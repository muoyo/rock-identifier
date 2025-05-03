// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

struct PhysicalProperties: Codable {
    let color: String
    let hardness: String // Mohs scale
    let luster: String
    let streak: String?
    let transparency: String?
    let crystalSystem: String?
    let cleavage: String?
    let fracture: String?
    let specificGravity: String?
    let additionalProperties: [String: String]?
    
    init(
        color: String,
        hardness: String,
        luster: String,
        streak: String? = nil,
        transparency: String? = nil,
        crystalSystem: String? = nil,
        cleavage: String? = nil,
        fracture: String? = nil,
        specificGravity: String? = nil,
        additionalProperties: [String: String]? = nil
    ) {
        self.color = color
        self.hardness = hardness
        self.luster = luster
        self.streak = streak
        self.transparency = transparency
        self.crystalSystem = crystalSystem
        self.cleavage = cleavage
        self.fracture = fracture
        self.specificGravity = specificGravity
        self.additionalProperties = additionalProperties
    }
}
