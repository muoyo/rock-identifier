// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import Combine

/// Global application state
class AppState: ObservableObject {
    // Singleton instance
    static let shared = AppState()
    
    // Paywall dismissal control
    @Published var paywallSwipeDismissable = false
    
    // Private init for singleton
    private init() {}
}
