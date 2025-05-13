// Rock Identifier: Crystal ID
// Muoyo Okome
//

import XCTest
@testable import RockIdentifier

class UsesTests: XCTestCase {
    
    func testInitialization() {
        // Create a sample uses object
        let uses = Uses(
            industrial: ["Construction", "Electronics", "Glass manufacturing"],
            historical: ["Tools", "Jewelry", "Religious artifacts"],
            modern: ["Watches", "Computers", "Decorative items"],
            metaphysical: ["Energy amplification", "Healing", "Meditation"],
            funFacts: ["One of the most abundant minerals", "Found on every continent"]
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(uses.industrial?.count, 3)
        XCTAssertEqual(uses.industrial?[0], "Construction")
        XCTAssertEqual(uses.historical?.count, 3)
        XCTAssertEqual(uses.historical?[1], "Jewelry")
        XCTAssertEqual(uses.modern?.count, 3)
        XCTAssertEqual(uses.modern?[2], "Decorative items")
        XCTAssertEqual(uses.metaphysical?.count, 3)
        XCTAssertEqual(uses.metaphysical?[0], "Energy amplification")
        XCTAssertEqual(uses.funFacts.count, 2)
        XCTAssertEqual(uses.funFacts[1], "Found on every continent")
        XCTAssertNil(uses.additionalUses)
    }
    
    func testInitializationWithMinimalData() {
        // Create a sample uses object with only required funFacts
        let uses = Uses(
            industrial: nil,
            historical: nil,
            modern: nil,
            metaphysical: nil,
            funFacts: ["Used since prehistoric times"]
        )
        
        // Verify properties were set correctly
        XCTAssertNil(uses.industrial)
        XCTAssertNil(uses.historical)
        XCTAssertNil(uses.modern)
        XCTAssertNil(uses.metaphysical)
        XCTAssertEqual(uses.funFacts.count, 1)
        XCTAssertEqual(uses.funFacts[0], "Used since prehistoric times")
    }
    
    func testInitializationWithAdditionalUses() {
        // Create a sample uses object with additional uses
        let additionalUses = [
            "scientific": "Laboratory equipment",
            "educational": "Teaching geological concepts"
        ]
        
        let uses = Uses(
            industrial: ["Chemical processing"],
            historical: ["Currency"],
            modern: ["Smartphone components"],
            metaphysical: ["Protection"],
            funFacts: ["Can change color when exposed to sunlight"],
            additionalUses: additionalUses
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(uses.industrial?.count, 1)
        XCTAssertEqual(uses.additionalUses?["scientific"], "Laboratory equipment")
        XCTAssertEqual(uses.additionalUses?["educational"], "Teaching geological concepts")
    }
    
    func testCodable() {
        // Create a sample uses object
        let additionalUses = [
            "artistic": "Sculpture and decorative arts",
            "agricultural": "Soil enhancement"
        ]
        
        let originalUses = Uses(
            industrial: ["Abrasives", "Ceramics", "Metallurgy"],
            historical: ["Cave paintings", "Sculptures", "Monuments"],
            modern: ["Solar panels", "3D printing", "Fashion"],
            metaphysical: ["Grounding", "Balancing", "Protection"],
            funFacts: ["Changes color in different lighting", "Found in meteorites"],
            additionalUses: additionalUses
        )
        
        // Encode the object
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(originalUses)
            
            // Decode the object
            let decoder = JSONDecoder()
            let decodedUses = try decoder.decode(Uses.self, from: data)
            
            // Verify properties were preserved
            XCTAssertEqual(decodedUses.industrial?.count, 3)
            XCTAssertEqual(decodedUses.industrial?[1], "Ceramics")
            XCTAssertEqual(decodedUses.historical?.count, 3)
            XCTAssertEqual(decodedUses.historical?[0], "Cave paintings")
            XCTAssertEqual(decodedUses.modern?.count, 3)
            XCTAssertEqual(decodedUses.modern?[2], "Fashion")
            XCTAssertEqual(decodedUses.metaphysical?.count, 3)
            XCTAssertEqual(decodedUses.metaphysical?[1], "Balancing")
            XCTAssertEqual(decodedUses.funFacts.count, 2)
            XCTAssertEqual(decodedUses.funFacts[0], "Changes color in different lighting")
            XCTAssertEqual(decodedUses.additionalUses?["artistic"], "Sculpture and decorative arts")
            XCTAssertEqual(decodedUses.additionalUses?["agricultural"], "Soil enhancement")
            
        } catch {
            XCTFail("Failed to encode/decode Uses: \(error)")
        }
    }
    
    func testEmptyArrays() {
        // Create uses with empty arrays
        let uses = Uses(
            industrial: [],
            historical: [],
            modern: [],
            metaphysical: [],
            funFacts: ["No significant uses documented"]
        )
        
        // Encode the object
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(uses)
            
            // Decode the object
            let decoder = JSONDecoder()
            let decodedUses = try decoder.decode(Uses.self, from: data)
            
            // Verify empty arrays were preserved
            XCTAssertNotNil(decodedUses.industrial)
            XCTAssertEqual(decodedUses.industrial?.count, 0)
            XCTAssertNotNil(decodedUses.historical)
            XCTAssertEqual(decodedUses.historical?.count, 0)
            XCTAssertNotNil(decodedUses.modern)
            XCTAssertEqual(decodedUses.modern?.count, 0)
            XCTAssertNotNil(decodedUses.metaphysical)
            XCTAssertEqual(decodedUses.metaphysical?.count, 0)
            // Fun facts should have at least one entry
            XCTAssertEqual(decodedUses.funFacts.count, 1)
            
        } catch {
            XCTFail("Failed to encode/decode Uses with empty arrays: \(error)")
        }
    }
}
