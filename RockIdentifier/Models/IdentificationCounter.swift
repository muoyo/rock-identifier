// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

class IdentificationCounter {
    private let defaults = UserDefaults.standard
    private let countKey = "totalIdentificationCount"
    private let maxFreeIdentifications = 3
    
    // Get the number of identifications remaining in total
    var remainingTotal: Int {
        let count = totalCount
        return max(0, maxFreeIdentifications - count)
    }
    
    // Check if the user has reached their total limit
    var isLimitReached: Bool {
        return remainingTotal <= 0
    }
    
    // Get the current total count
    private var totalCount: Int {
        return defaults.integer(forKey: countKey)
    }
    
    // Increment the counter and return if successful (not reached limit)
    func increment() -> Bool {
        let currentCount = defaults.integer(forKey: countKey)
        
        if currentCount < maxFreeIdentifications {
            defaults.set(currentCount + 1, forKey: countKey)
            return true
        }
        
        return false
    }
    
    // Reset the counter (only for testing or when user subscription status changes)
    func resetCounter() {
        defaults.set(0, forKey: countKey)
    }
    
    // Return the maximum number of free identifications
    var maxTotalLimit: Int {
        return maxFreeIdentifications
    }
}
