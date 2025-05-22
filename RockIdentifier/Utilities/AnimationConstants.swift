// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

/// Centralized animation constants for consistent UI animations throughout the app
struct AnimationConstants {
    // MARK: - Duration Constants
    
    /// Very short animations (button feedback, small UI changes)
    struct Quick {
        /// Ultra-fast animations (0.1s) for immediate visual feedback
        static let ultraFast: Double = 0.1
        /// Fast animations (0.2s) for button presses and simple state changes
        static let fast: Double = 0.2
        /// Standard quick animations (0.3s) for most interface elements
        static let standard: Double = 0.3
    }
    
    /// Medium duration animations (transitions, reveals)
    struct Medium {
        /// Shorter medium animations (0.4s)
        static let short: Double = 0.4
        /// Standard medium animations (0.5s) for most transitions
        static let standard: Double = 0.5
        /// Longer medium animations (0.6s) for more dramatic effects
        static let long: Double = 0.6
    }
    
    /// Longer animations for emphasis and dramatic effect
    struct Slow {
        /// Standard slow animations (0.8s)
        static let standard: Double = 0.8
        /// Longer slow animations (1.0s) for key moments
        static let long: Double = 1.0
        /// Very slow animations (1.5s) for special effects
        static let extraLong: Double = 1.5
    }
    
    // MARK: - Animation Curves
    
    /// SwiftUI animation curve presets
    struct Curve {
        /// Standard easing for most animations
        static func easeInOut(duration: Double) -> Animation {
            .easeInOut(duration: duration)
        }
        
        /// Smooth spring animation with default parameters
        static func spring(duration: Double) -> Animation {
            .spring(response: duration, dampingFraction: 0.7, blendDuration: duration * 0.5)
        }
        
        /// Bouncy spring animation for playful interactions
        static func bouncySpring(duration: Double) -> Animation {
            .spring(response: duration, dampingFraction: 0.6, blendDuration: duration * 0.4)
        }
        
        /// Tight spring animation for precise movements
        static func tightSpring(duration: Double) -> Animation {
            .spring(response: duration, dampingFraction: 0.8, blendDuration: duration * 0.3)
        }
        
        /// Linear animation for constant speed effects (rotation, scanning)
        static func linear(duration: Double) -> Animation {
            .linear(duration: duration)
        }
    }
    
    // MARK: - Animation Delays
    
    /// Common animation delay intervals for sequenced animations
    struct Delay {
        /// Very short delay (0.05s) for closely sequenced elements
        static let tiny: Double = 0.05
        /// Short delay (0.1s) for staggered animations
        static let short: Double = 0.1
        /// Medium delay (0.2s) for standard sequencing
        static let medium: Double = 0.2
        /// Long delay (0.3s) for more pronounced sequencing
        static let long: Double = 0.3
        /// Extra long delay (0.5s) for distinct sequential steps
        static let extraLong: Double = 0.5
    }
    
    // MARK: - Accessibility
    
    /// Adjusts animation duration based on user's reduced motion preference
    static func adjustedDuration(_ standardDuration: Double) -> Double {
        #if os(iOS)
        let prefersReducedMotion = UIAccessibility.isReduceMotionEnabled
        #else
        let prefersReducedMotion = false
        #endif
        
        // If reduced motion is enabled, make animations quicker and simpler
        if prefersReducedMotion {
            return min(standardDuration * 0.7, 0.3) // Cap at 0.3 seconds for reduced motion
        }
        return standardDuration
    }
    
    /// Returns the most appropriate animation based on reduced motion settings
    static func accessibleAnimation(_ animation: Animation) -> Animation {
        #if os(iOS)
        let prefersReducedMotion = UIAccessibility.isReduceMotionEnabled
        #else
        let prefersReducedMotion = false
        #endif
        
        if prefersReducedMotion {
            // Use simpler animations when reduced motion is enabled
            return .easeInOut(duration: 0.3)
        }
        return animation
    }
    
    // MARK: - Common Animation Presets
    
    /// Standard button press animation
    static let buttonPress = Curve.spring(duration: Quick.standard)
    
    /// Standard transition animation between views
    static let viewTransition = Curve.easeInOut(duration: Medium.standard)
    
    /// Animation for elements appearing on screen
    static let appear = Curve.spring(duration: Medium.short)
    
    /// Animation for elements fading away
    static let disappear = Curve.easeInOut(duration: Quick.standard)
    
    /// Animation for success/completion actions
    static let success = Curve.bouncySpring(duration: Medium.standard)
    
    /// Animation for loading/processing states
    static let loading = Curve.linear(duration: Slow.standard).repeatForever(autoreverses: true)
    
    /// Animation for emphasis/attention
    static let emphasis = Curve.bouncySpring(duration: Medium.long)
}
