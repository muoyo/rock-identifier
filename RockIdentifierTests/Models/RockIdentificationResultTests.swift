// Rock Identifier: Crystal ID
// Muoyo Okome
//

import XCTest
@testable import RockIdentifier

class RockIdentificationResultTests: XCTestCase {
    
    // Sample objects for testing
    let samplePhysicalProperties = PhysicalProperties(
        color: "Gray to White",
        hardness: "7",
        luster: "Vitreous",
        streak: "White",
        transparency: "Translucent to Opaque",
        crystalSystem: "Trigonal",
        cleavage: "None",
        fracture: "Conchoidal",
        specificGravity: "2.65"
    )
    
    let sampleChemicalProperties = ChemicalProperties(
        formula: "SiO2",
        composition: "Silicon Dioxide",
        elements: [
            Element(name: "Silicon", symbol: "Si", percentage: 46.7),
            Element(name: "Oxygen", symbol: "O", percentage: 53.3)
        ]
    )
    
    let sampleFormation = Formation(
        formationType: "Igneous, Sedimentary, Metamorphic",
        environment: "Various geological environments",
        geologicalAge: "All geological periods",
        commonLocations: ["United States", "Brazil", "Madagascar"],
        associatedMinerals: ["Feldspar", "Mica", "Tourmaline"],
        formationProcess: "Crystallizes from silica-rich solutions"
    )
    
    let sampleUses = Uses(
        industrial: ["Electronics", "Glass manufacturing"],
        historical: ["Tools", "Fire-starting"],
        modern: ["Watches", "Computers"],
        metaphysical: ["Energy amplification", "Clarity"],
        funFacts: ["One of the most abundant minerals on Earth"]
    )
    
    func testInitialization() {
        // Create a sample rock identification result
        let result = RockIdentificationResult(
            image: nil,
            name: "Quartz",
            category: "Mineral",
            confidence: 0.95,
            physicalProperties: samplePhysicalProperties,
            chemicalProperties: sampleChemicalProperties,
            formation: sampleFormation,
            uses: sampleUses
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(result.name, "Quartz")
        XCTAssertEqual(result.category, "Mineral")
        XCTAssertEqual(result.confidence, 0.95)
        XCTAssertNil(result.image)
        XCTAssertFalse(result.isFavorite)
        XCTAssertNil(result.notes)
        
        // Verify nested objects
        XCTAssertEqual(result.physicalProperties.color, "Gray to White")
        XCTAssertEqual(result.chemicalProperties.formula, "SiO2")
        XCTAssertEqual(result.formation.formationType, "Igneous, Sedimentary, Metamorphic")
        XCTAssertEqual(result.uses.funFacts.first, "One of the most abundant minerals on Earth")
    }
    
    func testCodable() {
        // Create a sample rock identification result
        let originalResult = RockIdentificationResult(
            image: nil, // Skip image for Codable test
            name: "Quartz",
            category: "Mineral",
            confidence: 0.95,
            physicalProperties: samplePhysicalProperties,
            chemicalProperties: sampleChemicalProperties,
            formation: sampleFormation,
            uses: sampleUses,
            isFavorite: true,
            notes: "Found at the beach"
        )
        
        // Encode the result
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(originalResult)
            
            // Decode the result
            let decoder = JSONDecoder()
            let decodedResult = try decoder.decode(RockIdentificationResult.self, from: data)
            
            // Verify properties were preserved
            XCTAssertEqual(decodedResult.id, originalResult.id)
            XCTAssertEqual(decodedResult.name, "Quartz")
            XCTAssertEqual(decodedResult.category, "Mineral")
            XCTAssertEqual(decodedResult.confidence, 0.95)
            XCTAssertEqual(decodedResult.isFavorite, true)
            XCTAssertEqual(decodedResult.notes, "Found at the beach")
            
            // Verify nested objects
            XCTAssertEqual(decodedResult.physicalProperties.color, "Gray to White")
            XCTAssertEqual(decodedResult.chemicalProperties.formula, "SiO2")
            XCTAssertEqual(decodedResult.formation.formationType, "Igneous, Sedimentary, Metamorphic")
            XCTAssertEqual(decodedResult.uses.funFacts.first, "One of the most abundant minerals on Earth")
            
        } catch {
            XCTFail("Failed to encode/decode RockIdentificationResult: \(error)")
        }
    }
    
    func testImageEncoding() {
        // Create a simple test image
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rect)
        let testImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Create a sample rock with the test image
        let result = RockIdentificationResult(
            image: testImage,
            name: "Quartz",
            category: "Mineral",
            confidence: 0.95,
            physicalProperties: samplePhysicalProperties,
            chemicalProperties: sampleChemicalProperties,
            formation: sampleFormation,
            uses: sampleUses
        )
        
        // Encode the result
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(result)
            
            // Decode the result
            let decoder = JSONDecoder()
            let decodedResult = try decoder.decode(RockIdentificationResult.self, from: data)
            
            // Verify image was encoded and decoded
            XCTAssertNotNil(decodedResult.image, "Image should be decoded successfully")
            
        } catch {
            XCTFail("Failed to encode/decode RockIdentificationResult with image: \(error)")
        }
    }
}
