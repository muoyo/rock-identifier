// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import Combine

class CollectionManager: ObservableObject {
    @Published var collection: [RockIdentificationResult] = []
    @Published var isLoading: Bool = false
    
    private let defaults = UserDefaults.standard
    private let collectionKey = "rockIdentifierCollection"
    
    init() {
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
        collection.insert(rock, at: 0) // Add to the beginning
        saveCollection()
    }
    
    // Remove a rock from the collection
    func removeRock(at index: Int) {
        guard index >= 0 && index < collection.count else { return }
        collection.remove(at: index)
        saveCollection()
    }
    
    // Remove a rock by ID
    func removeRock(withID id: UUID) {
        if let index = collection.firstIndex(where: { $0.id == id }) {
            collection.remove(at: index)
            saveCollection()
        }
    }
    
    // Toggle favorite status for a rock
    func toggleFavorite(for rockID: UUID) {
        if let index = collection.firstIndex(where: { $0.id == rockID }) {
            collection[index].isFavorite.toggle()
            saveCollection()
        }
    }
    
    // Update notes for a rock
    func updateNotes(for rockID: UUID, notes: String) {
        if let index = collection.firstIndex(where: { $0.id == rockID }) {
            collection[index].notes = notes
            saveCollection()
        }
    }
    
    // Get filtered collection
    func filteredCollection(filter: CollectionFilter, searchText: String = "") -> [RockIdentificationResult] {
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
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { rock in
                rock.name.lowercased().contains(searchText.lowercased()) ||
                rock.category.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // Get a rock by ID
    func getRock(by id: UUID) -> RockIdentificationResult? {
        return collection.first { $0.id == id }
    }
}

enum CollectionFilter {
    case all
    case favorites
    case rocks
    case minerals
    case crystals
    case gemstones
}
