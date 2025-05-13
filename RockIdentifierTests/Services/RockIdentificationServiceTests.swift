// Rock Identifier: Crystal ID
// Muoyo Okome
//

import XCTest
@testable import RockIdentifier

class RockIdentificationServiceTests: XCTestCase {
    var identificationService: RockIdentificationService!
    
    override func setUp() {
        super.setUp()
        identificationService = RockIdentificationService()
    }
    
    override func tearDown() {
        identificationService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Verify the service starts in idle state
        XCTAssertEqual(identificationService.state, .idle)
    }
    
    func testExtractJsonFromResponse() {
        // This test accesses a private method using the performSelector approach
        // Create sample responses with JSON embedded in different formats
        
        // JSON in markdown code block
        let markdownResponse = """
        Here is the identification result:
        ```json
        {"name": "Quartz", "category": "Mineral"}
        ```
        Additional information follows.
        """
        
        // JSON with surrounding text
        let surroundedResponse = """
        I've analyzed the image and here is the result:
        {"name": "Granite", "category": "Rock"}
        Let me know if you need any clarification.
        """
        
        // Clean JSON
        let cleanResponse = """
        {"name": "Amethyst", "category": "Mineral", "confidence": 0.98}
        """
        
        // HTML comments in response
        let htmlCommentResponse = """
        <!-- Debug information: processed in 1.2s -->
        {"name": "Basalt", "category": "Rock"}
        <!-- Additional notes: high confidence match -->
        """
        
        // Call the private method using selector
        let selector = Selector(("extractJsonFromResponse:"))
        
        // Test markdown extraction
        if let markdownResult = identificationService.perform(selector, with: markdownResponse)?.takeRetainedValue() as? String {
            XCTAssertEqual(markdownResult, "{\"name\": \"Quartz\", \"category\": \"Mineral\"}")
        } else {
            XCTFail("Failed to extract JSON from markdown")
        }
        
        // Test surrounded text extraction
        if let surroundedResult = identificationService.perform(selector, with: surroundedResponse)?.takeRetainedValue() as? String {
            XCTAssertEqual(surroundedResult, "{\"name\": \"Granite\", \"category\": \"Rock\"}")
        } else {
            XCTFail("Failed to extract JSON from surrounded text")
        }
        
        // Test clean JSON
        if let cleanResult = identificationService.perform(selector, with: cleanResponse)?.takeRetainedValue() as? String {
            XCTAssertEqual(cleanResult, "{\"name\": \"Amethyst\", \"category\": \"Mineral\", \"confidence\": 0.98}")
        } else {
            XCTFail("Failed to extract clean JSON")
        }
        
        // Test HTML comment removal
        if let htmlCommentResult = identificationService.perform(selector, with: htmlCommentResponse)?.takeRetainedValue() as? String {
            XCTAssertEqual(htmlCommentResult, "{\"name\": \"Basalt\", \"category\": \"Rock\"}")
        } else {
            XCTFail("Failed to extract JSON with HTML comments")
        }
    }
    
    func testCleanJsonString() {
        // Test the JSON cleaning functionality
        let dirtyJson = """
        {
          name: "Quartz",
          'category': "Mineral",
          "confidence": "0.95",
          specificGravity: "~2.65",
          environment: ": Forms in various settings",
          elements: [null],
          usees: {
            funFacts: ["Common mineral"]
          },
        }
        """
        
        // Call the private method using selector
        let selector = Selector(("cleanJsonString:"))
        
        if let cleanedJson = identificationService.perform(selector, with: dirtyJson)?.takeRetainedValue() as? String {
            // Verify quotes around property names
            XCTAssertTrue(cleanedJson.contains("\"name\""))
            XCTAssertTrue(cleanedJson.contains("\"category\""))
            
            // Verify single quotes converted to double quotes
            XCTAssertFalse(cleanedJson.contains("'category'"))
            
            // Verify string numbers converted for confidence
            XCTAssertTrue(cleanedJson.contains("\"confidence\":0.95") || cleanedJson.contains("\"confidence\": 0.95"))
            
            // Verify trailing commas removed
            XCTAssertFalse(cleanedJson.contains("},\n}"))
            
            // Verify typo fixed
            XCTAssertTrue(cleanedJson.contains("\"uses\""))
            XCTAssertFalse(cleanedJson.contains("\"usees\""))
            
            // Verify environment format fixed
            XCTAssertFalse(cleanedJson.contains("\"environment\":\": "))
            
            // Verify null arrays cleaned up
            XCTAssertFalse(cleanedJson.contains("[null]"))
        } else {
            XCTFail("Failed to clean JSON string")
        }
    }
    
    func testCreateHash() {
        // Test the MD5 hash creation
        let testString = "test message"
        let expectedHash = "c96da06954de52c57adece4e0cd05a76" // MD5 hash of "test message"
        
        // Call the private method using selector
        let selector = Selector(("createHash:"))
        
        if let hash = identificationService.perform(selector, with: testString)?.takeRetainedValue() as? String {
            XCTAssertEqual(hash, expectedHash)
        } else {
            XCTFail("Failed to create hash")
        }
    }
    
    func testEncodeToPercentEncodedString() {
        // Test the percent encoding functionality
        let testData = "test".data(using: .utf8)!
        let expectedEncoding = "%74%65%73%74" // Percent-encoded "test"
        
        // Call the private method using selector
        let selector = Selector(("encodeToPercentEncodedString:"))
        
        if let encoded = identificationService.perform(selector, with: testData)?.takeRetainedValue() as? String {
            XCTAssertEqual(encoded, expectedEncoding)
        } else {
            XCTFail("Failed to encode data")
        }
    }
    
    func testExtractRockData() {
        // Test the rock data extraction from malformed JSON
        let malformedJson = """
        {
          "name": "Amethyst",
          category: "Mineral",
          "confidence": 0.92,
          "color": "Purple",
          "funFacts": ["Variety of quartz", "Used for jewelry"]
        }
        """
        
        // Call the private method using selector
        let selector = Selector(("extractRockData:"))
        
        if let extractedData = identificationService.perform(selector, with: malformedJson)?.takeRetainedValue() as? [String: Any] {
            XCTAssertEqual(extractedData["name"] as? String, "Amethyst")
            XCTAssertEqual(extractedData["category"] as? String, "Mineral")
            XCTAssertEqual((extractedData["confidence"] as? Double).map { Int($0 * 100) }, 92)
            XCTAssertEqual(extractedData["color"] as? String, "Purple")
            XCTAssertEqual(extractedData["funFact"] as? String, "Variety of quartz")
        } else {
            XCTFail("Failed to extract rock data")
        }
    }
    
    func testIdentificationStateEquality() {
        // Test that IdentificationState equality works correctly
        let state1 = IdentificationState.idle
        let state2 = IdentificationState.idle
        XCTAssertEqual(state1, state2)
        
        let state3 = IdentificationState.processing
        XCTAssertNotEqual(state1, state3)
        
        let uuid1 = UUID()
        let result1 = RockIdentificationResult(
            id: uuid1,
            image: nil,
            name: "Test",
            category: "Rock",
            confidence: 0.9,
            physicalProperties: PhysicalProperties(
                color: "Test",
                hardness: "Test",
                luster: "Test",
                streak: nil,
                transparency: nil,
                crystalSystem: nil,
                cleavage: nil,
                fracture: nil,
                specificGravity: nil
            ),
            chemicalProperties: ChemicalProperties(
                formula: nil,
                composition: "Test",
                elements: nil
            ),
            formation: Formation(
                formationType: "Test",
                environment: "Test",
                geologicalAge: nil,
                commonLocations: nil,
                associatedMinerals: nil,
                formationProcess: "Test"
            ),
            uses: Uses(
                industrial: nil,
                historical: nil,
                modern: nil,
                metaphysical: nil,
                funFacts: ["Test"]
            )
        )
        
        let state4 = IdentificationState.success(result1)
        let state5 = IdentificationState.success(result1)
        XCTAssertEqual(state4, state5)
        
        let uuid2 = UUID()
        let result2 = RockIdentificationResult(
            id: uuid2, // Different ID
            image: nil,
            name: "Test",
            category: "Rock",
            confidence: 0.9,
            physicalProperties: result1.physicalProperties,
            chemicalProperties: result1.chemicalProperties,
            formation: result1.formation,
            uses: result1.uses
        )
        
        let state6 = IdentificationState.success(result2)
        XCTAssertNotEqual(state4, state6)
        
        let errorState1 = IdentificationState.error("Test error")
        let errorState2 = IdentificationState.error("Test error")
        let errorState3 = IdentificationState.error("Different error")
        
        XCTAssertEqual(errorState1, errorState2)
        XCTAssertNotEqual(errorState1, errorState3)
    }
}
