// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import Combine

class CollectionManager: ObservableObject {
    @Published var collection: [RockIdentificationResult] = []
    @Published var isLoading: Bool = false
    @Published var selectedFilter: CollectionFilter = .all
    @Published var searchText: String = ""
    @Published var sortOrder: SortOrder = .dateDesc
    
    private let defaults = UserDefaults.standard
    private let collectionKey = "rockIdentifierCollection"
    private let sortOrderKey = "rockIdentifierSortOrder"
    
    init() {
        // Load user's preferred sort order
        if let savedSortOrder = defaults.string(forKey: sortOrderKey),
           let order = SortOrder(rawValue: savedSortOrder) {
            self.sortOrder = order
        }
        
        loadCollection()
    }
    
    // Load saved collection from UserDefaults
    func loadCollection() {
        isLoading = true
        defer { isLoading = false }
        
        guard let data = defaults.data(forKey: collectionKey) else {
            // No saved collection found
            collection = []
            return
        }
        
        do {
            collection = try JSONDecoder().decode([RockIdentificationResult].self, from: data)
        } catch {
            print("Error loading collection: \(error)")
            collection = []
        }
    }
    
    // Save collection to UserDefaults
    private func saveCollection() {
        do {
            let data = try JSONEncoder().encode(collection)
            defaults.set(data, forKey: collectionKey)
        } catch {
            print("Error saving collection: \(error)")
        }
    }
    
    // Add a new rock to the collection
    func addRock(_ rock: RockIdentificationResult) {
        // Create a new copy of the collection and insert the rock
        var updatedCollection = collection
        updatedCollection.insert(rock, at: 0) // Add to the beginning
        
        // Assign the new collection to trigger the @Published notification
        collection = updatedCollection
        
        // Save to UserDefaults
        saveCollection()
    }
    
    // Remove a rock from the collection
    func removeRock(at index: Int) {
        guard index >= 0 && index < collection.count else { return }
        
        var updatedCollection = collection
        updatedCollection.remove(at: index)
        collection = updatedCollection
        
        saveCollection()
    }
    
    // Remove a rock by ID
    func removeRock(withID id: UUID) {
        if let index = collection.firstIndex(where: { $0.id == id }) {
            var updatedCollection = collection
            updatedCollection.remove(at: index)
            collection = updatedCollection
            
            saveCollection()
        }
    }
    
    // Toggle favorite status for a rock
    func toggleFavorite(for rockID: UUID) {
        if let index = collection.firstIndex(where: { $0.id == rockID }) {
            var updatedCollection = collection
            updatedCollection[index].isFavorite.toggle()
            collection = updatedCollection
            
            saveCollection()
        }
    }
    
    // Update notes for a rock
    func updateNotes(for rockID: UUID, notes: String) {
        if let index = collection.firstIndex(where: { $0.id == rockID }) {
            var updatedCollection = collection
            updatedCollection[index].notes = notes
            collection = updatedCollection
            
            saveCollection()
        }
    }
    
    // Get filtered and sorted collection
    func filteredAndSortedCollection(filter: CollectionFilter = .all, searchText: String = "", sortOrder: SortOrder? = nil) -> [RockIdentificationResult] {
        let filtered: [RockIdentificationResult]
        
        // Apply category filter
        switch filter {
        case .all:
            filtered = collection
        case .favorites:
            filtered = collection.filter { $0.isFavorite }
        case .rocks:
            filtered = collection.filter { $0.category.lowercased() == "rock" }
        case .minerals:
            filtered = collection.filter { $0.category.lowercased() == "mineral" }
        case .crystals:
            filtered = collection.filter { $0.category.lowercased() == "crystal" }
        case .gemstones:
            filtered = collection.filter { $0.category.lowercased() == "gemstone" }
        }
        
        // Apply search text filter if provided
        let searchFiltered = searchText.isEmpty ? filtered : filtered.filter { rock in
            rock.name.lowercased().contains(searchText.lowercased()) ||
            rock.category.lowercased().contains(searchText.lowercased()) ||
            (rock.notes?.lowercased().contains(searchText.lowercased()) ?? false)
        }
        
        // Apply sorting
        let orderToUse = sortOrder ?? self.sortOrder
        return sortCollection(searchFiltered, by: orderToUse)
    }
    
    // Convenience method that uses the published properties
    var displayedCollection: [RockIdentificationResult] {
        return filteredAndSortedCollection(filter: selectedFilter, searchText: searchText, sortOrder: sortOrder)
    }
    
    // Sort collection based on the provided order
    private func sortCollection(_ rocks: [RockIdentificationResult], by order: SortOrder) -> [RockIdentificationResult] {
        switch order {
        case .dateDesc:
            return rocks.sorted { $0.identificationDate > $1.identificationDate }
        case .dateAsc:
            return rocks.sorted { $0.identificationDate < $1.identificationDate }
        case .nameAsc:
            return rocks.sorted { $0.name.lowercased() < $1.name.lowercased() }
        case .nameDesc:
            return rocks.sorted { $0.name.lowercased() > $1.name.lowercased() }
        case .category:
            return rocks.sorted { $0.category.lowercased() < $1.category.lowercased() }
        }
    }
    
    // Set and save the sort order
    func setSortOrder(_ order: SortOrder) {
        self.sortOrder = order
        defaults.set(order.rawValue, forKey: sortOrderKey)
    }
    
    // Get a rock by ID
    func getRock(by id: UUID) -> RockIdentificationResult? {
        return collection.first { $0.id == id }
    }
    
    // Update location for a rock
    func updateLocation(for rockID: UUID, location: String) {
        if let index = collection.firstIndex(where: { $0.id == rockID }) {
            var updatedCollection = collection
            updatedCollection[index].location = location
            collection = updatedCollection
            
            saveCollection()
        }
    }
}

enum CollectionFilter: String, CaseIterable {
    case all = "All"
    case favorites = "Favorites"
    case rocks = "Rocks"
    case minerals = "Minerals"
    case crystals = "Crystals"
    case gemstones = "Gemstones"
}

enum SortOrder: String, CaseIterable {
    case dateDesc = "Newest First"
    case dateAsc = "Oldest First"
    case nameAsc = "Name (A-Z)"
    case nameDesc = "Name (Z-A)"
    case category = "Category"
}
