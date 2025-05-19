// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

/// Tracks app version launches to determine when to show paywalls
class VersionManager {
    // Singleton instance
    static let shared = VersionManager()
    
    // UserDefaults keys
    private let lastVersionKey = "lastLaunchedAppVersion"
    private let firstLaunchThisVersionKey = "isFirstLaunchOfThisVersion"
    
    // Private init for singleton
    private init() {
        checkAppVersion()
    }
    
    /// Returns if this is the first launch of the current app version
    var isFirstLaunchOfCurrentVersion: Bool {
        return UserDefaults.standard.bool(forKey: firstLaunchThisVersionKey)
    }
    
    /// Marks the current version as seen (no longer first launch)
    func markCurrentVersionAsSeen() {
        UserDefaults.standard.set(false, forKey: firstLaunchThisVersionKey)
    }
    
    /// Compares the current app version with the last launched version
    private func checkAppVersion() {
        // Get current app version
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return
        }
        
        // Get last launched version
        let lastVersion = UserDefaults.standard.string(forKey: lastVersionKey) ?? ""
        
        if currentVersion != lastVersion {
            // This is a new version launch
            UserDefaults.standard.set(currentVersion, forKey: lastVersionKey)
            UserDefaults.standard.set(true, forKey: firstLaunchThisVersionKey)
        }
    }
    
    /// Resets version tracking (for testing)
    func resetVersionTracking() {
        UserDefaults.standard.removeObject(forKey: lastVersionKey)
        UserDefaults.standard.set(true, forKey: firstLaunchThisVersionKey)
    }
}
