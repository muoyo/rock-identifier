// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import SwiftUI

struct RockIdentificationResult: Identifiable, Codable, Equatable {
    let id: UUID
    let image: UIImage?
    let name: String
    let category: String
    let confidence: Double
    let identificationDate: Date
    let physicalProperties: PhysicalProperties
    let chemicalProperties: ChemicalProperties
    let formation: Formation
    let uses: Uses
    var isFavorite: Bool
    var notes: String?
    var location: String?
    
    // Computed property for thumbnail generation
    var thumbnail: UIImage? {
        guard let originalImage = image else { return nil }
        
        let size = CGSize(width: 200, height: 200)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let scaledImage = renderer.image { _ in
            originalImage.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return scaledImage
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageData
        case name
        case category
        case confidence
        case identificationDate
        case physicalProperties
        case chemicalProperties
        case formation
        case uses
        case isFavorite
        case notes
        case location
    }
    
    init(
        id: UUID = UUID(),
        image: UIImage? = nil,
        name: String,
        category: String,
        confidence: Double,
        physicalProperties: PhysicalProperties,
        chemicalProperties: ChemicalProperties,
        formation: Formation,
        uses: Uses,
        isFavorite: Bool = false,
        notes: String? = nil,
        location: String? = nil
    ) {
        self.id = id
        self.image = image
        self.name = name
        self.category = category
        self.confidence = confidence
        self.identificationDate = Date()
        self.physicalProperties = physicalProperties
        self.chemicalProperties = chemicalProperties
        self.formation = formation
        self.uses = uses
        self.isFavorite = isFavorite
        self.notes = notes
        self.location = location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        confidence = try container.decode(Double.self, forKey: .confidence)
        identificationDate = try container.decode(Date.self, forKey: .identificationDate)
        physicalProperties = try container.decode(PhysicalProperties.self, forKey: .physicalProperties)
        chemicalProperties = try container.decode(ChemicalProperties.self, forKey: .chemicalProperties)
        formation = try container.decode(Formation.self, forKey: .formation)
        uses = try container.decode(Uses.self, forKey: .uses)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        
        if let imageData = try container.decodeIfPresent(Data.self, forKey: .imageData) {
            self.image = UIImage(data: imageData)
        } else {
            self.image = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(confidence, forKey: .confidence)
        try container.encode(identificationDate, forKey: .identificationDate)
        try container.encode(physicalProperties, forKey: .physicalProperties)
        try container.encode(chemicalProperties, forKey: .chemicalProperties)
        try container.encode(formation, forKey: .formation)
        try container.encode(uses, forKey: .uses)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(location, forKey: .location)
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.7) {
            try container.encode(imageData, forKey: .imageData)
        }
    }
    
    // Implementation for Equatable
    static func == (lhs: RockIdentificationResult, rhs: RockIdentificationResult) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.confidence == rhs.confidence &&
               lhs.identificationDate == rhs.identificationDate &&
               lhs.isFavorite == rhs.isFavorite &&
               lhs.notes == rhs.notes
        // We're not comparing images, physicalProperties, chemicalProperties, etc. here
        // as they are complex objects and only ID is enough to determine equality
    }
}
