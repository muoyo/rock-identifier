// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

extension Animation {
    // Extension to make common animation patterns easier to access
    
    /// Premium slow animations for important UI elements
    static var premiumSlow: Animation {
        AnimationConstants.Curve.easeInOut(duration: 3.0)
    }
    
    /// Premium medium animations for most transitions
    static var premiumMedium: Animation {
        AnimationConstants.Curve.spring(duration: 1.2)
    }
    
    /// Premium quick animations for subtle effects
    static var premiumQuick: Animation {
        AnimationConstants.Curve.spring(duration: 0.6)
    }
}

