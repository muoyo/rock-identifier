// Rock Identifier: Crystal ID
// Muoyo Okome
//

import XCTest
@testable import RockIdentifier

class FormationTests: XCTestCase {
    
    func testInitialization() {
        // Create a sample formation object
        let formation = Formation(
            formationType: "Igneous",
            environment: "Plutonic",
            geologicalAge: "Precambrian to Recent",
            commonLocations: ["United States", "Brazil", "Italy"],
            associatedMinerals: ["Quartz", "Mica", "Feldspar"],
            formationProcess: "Slow cooling of magma beneath Earth's surface"
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(formation.formationType, "Igneous")
        XCTAssertEqual(formation.environment, "Plutonic")
        XCTAssertEqual(formation.geologicalAge, "Precambrian to Recent")
        XCTAssertEqual(formation.commonLocations?.count, 3)
        XCTAssertEqual(formation.commonLocations?[0], "United States")
        XCTAssertEqual(formation.associatedMinerals?.count, 3)
        XCTAssertEqual(formation.associatedMinerals?[2], "Feldspar")
        XCTAssertEqual(formation.formationProcess, "Slow cooling of magma beneath Earth's surface")
        XCTAssertNil(formation.additionalInfo)
    }
    
    func testInitializationWithOptionalValues() {
        // Create a sample formation object with nil values
        let formation = Formation(
            formationType: "Metamorphic",
            environment: "High pressure, medium temperature",
            geologicalAge: nil,
            commonLocations: nil,
            associatedMinerals: nil,
            formationProcess: "Transformation of existing rock due to heat and pressure"
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(formation.formationType, "Metamorphic")
        XCTAssertEqual(formation.environment, "High pressure, medium temperature")
        XCTAssertNil(formation.geologicalAge)
        XCTAssertNil(formation.commonLocations)
        XCTAssertNil(formation.associatedMinerals)
        XCTAssertEqual(formation.formationProcess, "Transformation of existing rock due to heat and pressure")
    }
    
    func testInitializationWithAdditionalInfo() {
        // Create a sample formation object with additional information
        let additionalInfo = [
            "tectonic_setting": "Convergent plate boundaries",
            "depth": "5-30km beneath surface"
        ]
        
        let formation = Formation(
            formationType: "Sedimentary",
            environment: "Marine",
            geologicalAge: "Jurassic",
            commonLocations: ["England", "France"],
            associatedMinerals: ["Calcite", "Dolomite"],
            formationProcess: "Deposition and lithification of sediments",
            additionalInfo: additionalInfo
        )
        
        // Verify properties were set correctly
        XCTAssertEqual(formation.formationType, "Sedimentary")
        XCTAssertEqual(formation.additionalInfo?["tectonic_setting"], "Convergent plate boundaries")
        XCTAssertEqual(formation.additionalInfo?["depth"], "5-30km beneath surface")
    }
    
    func testCodable() {
        // Create a sample formation object
        let additionalInfo = [
            "metamorphic_grade": "Medium to high",
            "parent_rock": "Limestone"
        ]
        
        let originalFormation = Formation(
            formationType: "Metamorphic",
            environment: "Contact metamorphism",
            geologicalAge: "Varies widely",
            commonLocations: ["Italy", "Greece", "United States"],
            associatedMinerals: ["Wollastonite", "Garnet", "Diopside"],
            formationProcess: "Recrystallization of limestone due to heat from nearby igneous intrusions",
            additionalInfo: additionalInfo
        )
        
        // Encode the object
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(originalFormation)
            
            // Decode the object
            let decoder = JSONDecoder()
            let decodedFormation = try decoder.decode(Formation.self, from: data)
            
            // Verify properties were preserved
            XCTAssertEqual(decodedFormation.formationType, "Metamorphic")
            XCTAssertEqual(decodedFormation.environment, "Contact metamorphism")
            XCTAssertEqual(decodedFormation.geologicalAge, "Varies widely")
            XCTAssertEqual(decodedFormation.commonLocations?.count, 3)
            XCTAssertEqual(decodedFormation.commonLocations?[1], "Greece")
            XCTAssertEqual(decodedFormation.associatedMinerals?.count, 3)
            XCTAssertEqual(decodedFormation.formationProcess, "Recrystallization of limestone due to heat from nearby igneous intrusions")
            XCTAssertEqual(decodedFormation.additionalInfo?["metamorphic_grade"], "Medium to high")
            XCTAssertEqual(decodedFormation.additionalInfo?["parent_rock"], "Limestone")
            
        } catch {
            XCTFail("Failed to encode/decode Formation: \(error)")
        }
    }
    
    func testEmptyArrays() {
        // Create a formation with empty arrays
        let formation = Formation(
            formationType: "Unknown",
            environment: "Various",
            geologicalAge: "Unknown",
            commonLocations: [],
            associatedMinerals: [],
            formationProcess: "Not well understood"
        )
        
        // Encode the object
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(formation)
            
            // Decode the object
            let decoder = JSONDecoder()
            let decodedFormation = try decoder.decode(Formation.self, from: data)
            
            // Verify empty arrays were preserved
            XCTAssertNotNil(decodedFormation.commonLocations)
            XCTAssertEqual(decodedFormation.commonLocations?.count, 0)
            XCTAssertNotNil(decodedFormation.associatedMinerals)
            XCTAssertEqual(decodedFormation.associatedMinerals?.count, 0)
            
        } catch {
            XCTFail("Failed to encode/decode Formation with empty arrays: \(error)")
        }
    }
}
