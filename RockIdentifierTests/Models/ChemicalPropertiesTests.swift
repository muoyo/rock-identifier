// Rock Identifier: Crystal ID
// Muoyo Okome
//

import XCTest
@testable import RockIdentifier

class ChemicalPropertiesTests: XCTestCase {
    
    func testInitialization() {
        // Create a sample chemical properties object
        let elements = [
            Element(name: "Calcium", symbol: "Ca", percentage: 40.0),
            Element(name: "Carbon", symbol: "C", percentage: 12.0),
            Element(name: "Oxygen", symbol: "O", percentage: 48.0)
        ]
        
        let properties = ChemicalProperties(
            formula: "CaCO3",
            composition: "Calcium Carbonate",
            elements: elements,
            mineralsPresent: ["Calcite", "Aragonite"],
            reactivity: "Reacts with acids"
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(properties.formula, "CaCO3")
        XCTAssertEqual(properties.composition, "Calcium Carbonate")
        XCTAssertEqual(properties.elements?.count, 3)
        XCTAssertEqual(properties.elements?[0].name, "Calcium")
        XCTAssertEqual(properties.elements?[1].symbol, "C")
        XCTAssertEqual(properties.elements?[2].percentage, 48.0)
        XCTAssertEqual(properties.mineralsPresent?.count, 2)
        XCTAssertEqual(properties.reactivity, "Reacts with acids")
        XCTAssertNil(properties.additionalProperties)
    }
    
    func testInitializationWithOptionalValues() {
        // Create a sample chemical properties object with nil values
        let properties = ChemicalProperties(
            formula: nil,
            composition: "Complex Silicate",
            elements: nil,
            mineralsPresent: nil,
            reactivity: nil
        )
        
        // Verify properties were set correctly
        XCTAssertNil(properties.formula)
        XCTAssertEqual(properties.composition, "Complex Silicate")
        XCTAssertNil(properties.elements)
        XCTAssertNil(properties.mineralsPresent)
        XCTAssertNil(properties.reactivity)
    }
    
    func testInitializationWithAdditionalProperties() {
        // Create a sample chemical properties object with additional properties
        let elements = [
            Element(name: "Iron", symbol: "Fe", percentage: 72.4),
            Element(name: "Oxygen", symbol: "O", percentage: 27.6)
        ]
        
        let additionalProps = ["radioactivity": "None", "toxicity": "Low"]
        
        let properties = ChemicalProperties(
            formula: "Fe2O3",
            composition: "Iron Oxide",
            elements: elements,
            mineralsPresent: ["Hematite"],
            reactivity: "Low reactivity",
            additionalProperties: additionalProps
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(properties.formula, "Fe2O3")
        XCTAssertEqual(properties.elements?.count, 2)
        XCTAssertEqual(properties.additionalProperties?["radioactivity"], "None")
        XCTAssertEqual(properties.additionalProperties?["toxicity"], "Low")
    }
    
    func testCodable() {
        // Create a sample chemical properties object
        let elements = [
            Element(name: "Silicon", symbol: "Si", percentage: 46.7),
            Element(name: "Oxygen", symbol: "O", percentage: 53.3)
        ]
        
        let additionalProps = ["solubility": "Insoluble in water", "melting_point": "1710°C"]
        
        let originalProperties = ChemicalProperties(
            formula: "SiO2",
            composition: "Silicon Dioxide",
            elements: elements,
            mineralsPresent: ["Quartz", "Agate", "Jasper"],
            reactivity: "Highly resistant to weathering",
            additionalProperties: additionalProps
        )
        
        // Encode the object
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(originalProperties)
            
            // Decode the object
            let decoder = JSONDecoder()
            let decodedProperties = try decoder.decode(ChemicalProperties.self, from: data)
            
            // Verify properties were preserved
            XCTAssertEqual(decodedProperties.formula, "SiO2")
            XCTAssertEqual(decodedProperties.composition, "Silicon Dioxide")
            XCTAssertEqual(decodedProperties.elements?.count, 2)
            XCTAssertEqual(decodedProperties.elements?[0].name, "Silicon")
            XCTAssertEqual(decodedProperties.elements?[0].symbol, "Si")
            XCTAssertEqual(decodedProperties.elements?[0].percentage, 46.7)
            XCTAssertEqual(decodedProperties.mineralsPresent?.count, 3)
            XCTAssertEqual(decodedProperties.reactivity, "Highly resistant to weathering")
            XCTAssertEqual(decodedProperties.additionalProperties?["solubility"], "Insoluble in water")
            XCTAssertEqual(decodedProperties.additionalProperties?["melting_point"], "1710°C")
            
        } catch {
            XCTFail("Failed to encode/decode ChemicalProperties: \(error)")
        }
    }
    
    func testElementInitialization() {
        // Test Element initialization and properties
        let element = Element(name: "Gold", symbol: "Au", percentage: 100.0)
        
        XCTAssertEqual(element.name, "Gold")
        XCTAssertEqual(element.symbol, "Au")
        XCTAssertEqual(element.percentage, 100.0)
    }
    
    func testElementCodable() {
        // Test Element encoding/decoding
        let originalElement = Element(name: "Silver", symbol: "Ag", percentage: 99.9)
        
        // Encode the element
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(originalElement)
            
            // Decode the element
            let decoder = JSONDecoder()
            let decodedElement = try decoder.decode(Element.self, from: data)
            
            // Verify properties were preserved
            XCTAssertEqual(decodedElement.name, "Silver")
            XCTAssertEqual(decodedElement.symbol, "Ag")
            XCTAssertEqual(decodedElement.percentage, 99.9)
            
        } catch {
            XCTFail("Failed to encode/decode Element: \(error)")
        }
    }
}
