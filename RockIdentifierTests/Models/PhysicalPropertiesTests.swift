// Rock Identifier: Crystal ID
// Muoyo Okome
//

import XCTest
@testable import RockIdentifier

class PhysicalPropertiesTests: XCTestCase {
    
    func testInitialization() {
        // Create a sample physical properties object
        let properties = PhysicalProperties(
            color: "Red to Pink",
            hardness: "6-6.5",
            luster: "Vitreous",
            streak: "White",
            transparency: "Translucent to Opaque",
            crystalSystem: "Triclinic",
            cleavage: "Perfect in two directions",
            fracture: "Uneven",
            specificGravity: "2.54-2.76"
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(properties.color, "Red to Pink")
        XCTAssertEqual(properties.hardness, "6-6.5")
        XCTAssertEqual(properties.luster, "Vitreous")
        XCTAssertEqual(properties.streak, "White")
        XCTAssertEqual(properties.transparency, "Translucent to Opaque")
        XCTAssertEqual(properties.crystalSystem, "Triclinic")
        XCTAssertEqual(properties.cleavage, "Perfect in two directions")
        XCTAssertEqual(properties.fracture, "Uneven")
        XCTAssertEqual(properties.specificGravity, "2.54-2.76")
        XCTAssertNil(properties.additionalProperties)
    }
    
    func testInitializationWithOptionalValues() {
        // Create a sample physical properties object with some nil values
        let properties = PhysicalProperties(
            color: "Blue",
            hardness: "7",
            luster: "Vitreous",
            streak: nil,
            transparency: nil,
            crystalSystem: nil,
            cleavage: nil,
            fracture: nil,
            specificGravity: nil
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(properties.color, "Blue")
        XCTAssertEqual(properties.hardness, "7")
        XCTAssertEqual(properties.luster, "Vitreous")
        XCTAssertNil(properties.streak)
        XCTAssertNil(properties.transparency)
        XCTAssertNil(properties.crystalSystem)
        XCTAssertNil(properties.cleavage)
        XCTAssertNil(properties.fracture)
        XCTAssertNil(properties.specificGravity)
    }
    
    func testInitializationWithAdditionalProperties() {
        // Create a sample physical properties object with additional properties
        let additionalProps = ["magnetism": "Strong", "fluorescence": "Blue under UV light"]
        let properties = PhysicalProperties(
            color: "Black",
            hardness: "5.5-6.5",
            luster: "Metallic",
            streak: "Black",
            transparency: "Opaque",
            crystalSystem: "Cubic",
            cleavage: "None",
            fracture: "Conchoidal",
            specificGravity: "5.2",
            additionalProperties: additionalProps
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(properties.color, "Black")
        XCTAssertEqual(properties.additionalProperties?["magnetism"], "Strong")
        XCTAssertEqual(properties.additionalProperties?["fluorescence"], "Blue under UV light")
    }
    
    func testCodable() {
        // Create a sample physical properties object
        let additionalProps = ["twinning": "Common", "fluorescence": "None"]
        let originalProperties = PhysicalProperties(
            color: "Yellow to Brown",
            hardness: "3.5-4",
            luster: "Adamantine",
            streak: "Brownish-yellow",
            transparency: "Transparent to Translucent",
            crystalSystem: "Tetragonal",
            cleavage: "Indistinct",
            fracture: "Conchoidal",
            specificGravity: "3.9-4.2",
            additionalProperties: additionalProps
        )
        
        // Encode the object
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(originalProperties)
            
            // Decode the object
            let decoder = JSONDecoder()
            let decodedProperties = try decoder.decode(PhysicalProperties.self, from: data)
            
            // Verify properties were preserved
            XCTAssertEqual(decodedProperties.color, "Yellow to Brown")
            XCTAssertEqual(decodedProperties.hardness, "3.5-4")
            XCTAssertEqual(decodedProperties.luster, "Adamantine")
            XCTAssertEqual(decodedProperties.streak, "Brownish-yellow")
            XCTAssertEqual(decodedProperties.transparency, "Transparent to Translucent")
            XCTAssertEqual(decodedProperties.crystalSystem, "Tetragonal")
            XCTAssertEqual(decodedProperties.cleavage, "Indistinct")
            XCTAssertEqual(decodedProperties.fracture, "Conchoidal")
            XCTAssertEqual(decodedProperties.specificGravity, "3.9-4.2")
            XCTAssertEqual(decodedProperties.additionalProperties?["twinning"], "Common")
            XCTAssertEqual(decodedProperties.additionalProperties?["fluorescence"], "None")
            
        } catch {
            XCTFail("Failed to encode/decode PhysicalProperties: \(error)")
        }
    }
}
