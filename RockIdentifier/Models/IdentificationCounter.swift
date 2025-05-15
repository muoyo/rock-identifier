// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

class IdentificationCounter {
    private let defaults = UserDefaults.standard
    private let countKey = "dailyIdentificationCount"
    private let dateKey = "lastIdentificationDate"
    private let maxFreeIdentifications = 5
    
    // Get the number of identifications remaining for today
    var remainingToday: Int {
        let count = todayCount
        return max(0, maxFreeIdentifications - count)
    }
    
    // Check if the user has reached their daily limit
    var isLimitReached: Bool {
        return remainingToday <= 0
    }
    
    // Get the current count for today
    private var todayCount: Int {
        // Reset counter if it's a new day
        if !isFromToday {
            resetCounter()
            return 0
        }
        
        return defaults.integer(forKey: countKey)
    }
    
    // Check if the last identification date is from today
    private var isFromToday: Bool {
        guard let lastDate = defaults.object(forKey: dateKey) as? Date else {
            return false
        }
        
        return Calendar.current.isDate(lastDate, inSameDayAs: Date())
    }
    
    // Increment the counter and return if successful (not reached limit)
    func increment() -> Bool {
        // Reset counter if it's a new day
        if !isFromToday {
            resetCounter()
        }
        
        let currentCount = defaults.integer(forKey: countKey)
        
        if currentCount < maxFreeIdentifications {
            defaults.set(currentCount + 1, forKey: countKey)
            defaults.set(Date(), forKey: dateKey)
            return true
        }
        
        return false
    }
    
    // Reset the counter (usually for a new day)
    private func resetCounter() {
        defaults.set(0, forKey: countKey)
        defaults.set(Date(), forKey: dateKey)
    }
    
    // Return the maximum number of free identifications
    var maxDailyLimit: Int {
        return maxFreeIdentifications
    }
}
