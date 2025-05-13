// Rock Identifier: Crystal ID
// Muoyo Okome
//

import XCTest
@testable import RockIdentifier

class CollectionManagerTests: XCTestCase {
    var collectionManager: CollectionManager!
    let testUserDefaultsKey = "testRockIdentifierCollection"
    let userDefaults = UserDefaults.standard
    
    // Create sample test data
    let sampleRock = RockIdentificationResult(
        image: nil,
        name: "Granite",
        category: "Rock",
        confidence: 0.98,
        physicalProperties: PhysicalProperties(
            color: "Gray to Pink",
            hardness: "6-7",
            luster: "Vitreous",
            streak: nil,
            transparency: "Opaque",
            crystalSystem: nil,
            cleavage: nil,
            fracture: "Irregular",
            specificGravity: "2.7"
        ),
        chemicalProperties: ChemicalProperties(
            formula: nil,
            composition: "Mixture of quartz, feldspar, and mica",
            elements: nil
        ),
        formation: Formation(
            formationType: "Igneous",
            environment: "Plutonic",
            geologicalAge: nil,
            commonLocations: ["Worldwide"],
            associatedMinerals: ["Quartz", "Feldspar", "Mica"],
            formationProcess: "Slow cooling of magma beneath Earth's surface"
        ),
        uses: Uses(
            industrial: ["Construction", "Countertops"],
            historical: ["Building material"],
            modern: ["Decorative", "Construction"],
            metaphysical: nil,
            funFacts: ["One of the most common rocks in the continental crust"]
        )
    )
    
    let sampleMineral = RockIdentificationResult(
        image: nil,
        name: "Quartz",
        category: "Mineral",
        confidence: 0.95,
        physicalProperties: PhysicalProperties(
            color: "Clear to White",
            hardness: "7",
            luster: "Vitreous",
            streak: "White",
            transparency: "Transparent to Translucent",
            crystalSystem: "Trigonal",
            cleavage: "None",
            fracture: "Conchoidal",
            specificGravity: "2.65"
        ),
        chemicalProperties: ChemicalProperties(
            formula: "SiO2",
            composition: "Silicon Dioxide",
            elements: nil
        ),
        formation: Formation(
            formationType: "Igneous, Metamorphic, Sedimentary",
            environment: "Various geological environments",
            geologicalAge: nil,
            commonLocations: ["Worldwide"],
            associatedMinerals: ["Feldspar", "Mica"],
            formationProcess: "Crystallizes from silica-rich solutions"
        ),
        uses: Uses(
            industrial: ["Electronics", "Glass"],
            historical: ["Tools", "Jewelry"],
            modern: ["Watches", "Electronics"],
            metaphysical: ["Energy amplification"],
            funFacts: ["One of the most common minerals on Earth"]
        ),
        isFavorite: true
    )
    
    override func setUp() {
        super.setUp()
        // Clear any existing collection data for testing
        userDefaults.removeObject(forKey: testUserDefaultsKey)
        
        // Create a custom subclass for testing to use a different key
        // This ensures we don't interfere with actual app data during tests
        class TestCollectionManager: CollectionManager {
            override init() {
                super.init()
                self.collectionKey = "testRockIdentifierCollection"
            }
        }
        
        collectionManager = TestCollectionManager()
    }
    
    override func tearDown() {
        // Clean up after each test
        userDefaults.removeObject(forKey: testUserDefaultsKey)
        collectionManager = nil
        super.tearDown()
    }
    
    func testAddRock() {
        // Verify collection starts empty
        XCTAssertEqual(collectionManager.collection.count, 0)
        
        // Add a rock
        collectionManager.addRock(sampleRock)
        
        // Verify rock was added
        XCTAssertEqual(collectionManager.collection.count, 1)
        XCTAssertEqual(collectionManager.collection[0].name, "Granite")
        XCTAssertEqual(collectionManager.collection[0].category, "Rock")
    }
    
    func testAddMultipleRocks() {
        // Add two different specimens
        collectionManager.addRock(sampleRock)
        collectionManager.addRock(sampleMineral)
        
        // Verify both were added with the most recent first
        XCTAssertEqual(collectionManager.collection.count, 2)
        XCTAssertEqual(collectionManager.collection[0].name, "Quartz")
        XCTAssertEqual(collectionManager.collection[1].name, "Granite")
    }
    
    func testRemoveRockByIndex() {
        // Add two specimens
        collectionManager.addRock(sampleRock)
        collectionManager.addRock(sampleMineral)
        
        // Verify both were added
        XCTAssertEqual(collectionManager.collection.count, 2)
        
        // Remove rock at index 0
        collectionManager.removeRock(at: 0)
        
        // Verify the correct rock was removed
        XCTAssertEqual(collectionManager.collection.count, 1)
        XCTAssertEqual(collectionManager.collection[0].name, "Granite")
    }
    
    func testRemoveRockByID() {
        // Add a specimen
        collectionManager.addRock(sampleRock)
        
        // Get the ID of the added rock
        let rockID = collectionManager.collection[0].id
        
        // Remove by ID
        collectionManager.removeRock(withID: rockID)
        
        // Verify the rock was removed
        XCTAssertEqual(collectionManager.collection.count, 0)
    }
    
    func testToggleFavorite() {
        // Add a rock that isn't favorited
        let unfavoritedRock = RockIdentificationResult(
            image: nil,
            name: "Granite",
            category: "Rock",
            confidence: 0.98,
            physicalProperties: sampleRock.physicalProperties,
            chemicalProperties: sampleRock.chemicalProperties,
            formation: sampleRock.formation,
            uses: sampleRock.uses,
            isFavorite: false
        )
        
        collectionManager.addRock(unfavoritedRock)
        
        // Verify initial state
        XCTAssertFalse(collectionManager.collection[0].isFavorite)
        
        // Toggle favorite
        collectionManager.toggleFavorite(for: collectionManager.collection[0].id)
        
        // Verify it was toggled
        XCTAssertTrue(collectionManager.collection[0].isFavorite)
        
        // Toggle again
        collectionManager.toggleFavorite(for: collectionManager.collection[0].id)
        
        // Verify it was toggled back
        XCTAssertFalse(collectionManager.collection[0].isFavorite)
    }
    
    func testUpdateNotes() {
        // Add a rock with no notes
        collectionManager.addRock(sampleRock)
        
        // Verify initial state
        XCTAssertNil(collectionManager.collection[0].notes)
        
        // Update notes
        let testNotes = "Found this in my backyard"
        collectionManager.updateNotes(for: collectionManager.collection[0].id, notes: testNotes)
        
        // Verify notes were updated
        XCTAssertEqual(collectionManager.collection[0].notes, testNotes)
    }
    
    func testFilteredCollection() {
        // Add multiple rocks and minerals
        collectionManager.addRock(sampleRock) // category: Rock
        collectionManager.addRock(sampleMineral) // category: Mineral, isFavorite: true
        
        // Test ALL filter
        let allItems = collectionManager.filteredCollection(filter: .all)
        XCTAssertEqual(allItems.count, 2)
        
        // Test FAVORITES filter
        let favorites = collectionManager.filteredCollection(filter: .favorites)
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites[0].name, "Quartz")
        
        // Test ROCKS filter
        let rocks = collectionManager.filteredCollection(filter: .rocks)
        XCTAssertEqual(rocks.count, 1)
        XCTAssertEqual(rocks[0].name, "Granite")
        
        // Test MINERALS filter
        let minerals = collectionManager.filteredCollection(filter: .minerals)
        XCTAssertEqual(minerals.count, 1)
        XCTAssertEqual(minerals[0].name, "Quartz")
    }
    
    func testSearchFiltering() {
        // Add samples
        collectionManager.addRock(sampleRock)
        collectionManager.addRock(sampleMineral)
        
        // Test search by name
        let quartzResults = collectionManager.filteredCollection(filter: .all, searchText: "quartz")
        XCTAssertEqual(quartzResults.count, 1)
        XCTAssertEqual(quartzResults[0].name, "Quartz")
        
        // Test search by category
        let mineralResults = collectionManager.filteredCollection(filter: .all, searchText: "mineral")
        XCTAssertEqual(mineralResults.count, 1)
        XCTAssertEqual(mineralResults[0].category, "Mineral")
        
        // Test case insensitivity
        let caseInsensitiveResults = collectionManager.filteredCollection(filter: .all, searchText: "GRANITE")
        XCTAssertEqual(caseInsensitiveResults.count, 1)
        XCTAssertEqual(caseInsensitiveResults[0].name, "Granite")
        
        // Test combined filter and search
        let favoriteMinerals = collectionManager.filteredCollection(filter: .favorites, searchText: "quartz")
        XCTAssertEqual(favoriteMinerals.count, 1)
        
        // Test no matches
        let noMatches = collectionManager.filteredCollection(filter: .all, searchText: "obsidian")
        XCTAssertEqual(noMatches.count, 0)
    }
    
    func testGetRockByID() {
        // Add a sample
        collectionManager.addRock(sampleRock)
        
        // Get the ID
        let rockID = collectionManager.collection[0].id
        
        // Retrieve by ID
        let retrievedRock = collectionManager.getRock(by: rockID)
        
        // Verify
        XCTAssertNotNil(retrievedRock)
        XCTAssertEqual(retrievedRock?.name, "Granite")
        
        // Test with invalid ID
        let invalidID = UUID()
        let shouldBeNil = collectionManager.getRock(by: invalidID)
        XCTAssertNil(shouldBeNil)
    }
    
    func testPersistence() {
        // Add rocks to collection
        collectionManager.addRock(sampleRock)
        collectionManager.addRock(sampleMineral)
        
        // Create a new instance to test loading from persistence
        class TestCollectionManager: CollectionManager {
            override init() {
                super.init()
                self.collectionKey = "testRockIdentifierCollection"
            }
        }
        
        let newCollectionManager = TestCollectionManager()
        
        // Verify data was loaded
        XCTAssertEqual(newCollectionManager.collection.count, 2)
        XCTAssertEqual(newCollectionManager.collection[0].name, "Quartz")
        XCTAssertEqual(newCollectionManager.collection[1].name, "Granite")
    }
}
