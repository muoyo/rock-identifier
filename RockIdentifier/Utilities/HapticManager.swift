// Rock Identifier: Crystal ID
// Muoyo Okome
//

import UIKit

/// A singleton manager for providing consistent haptic feedback throughout the app
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Properties
    
    // Reuse generators for better performance
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    // MARK: - Haptic Feedback Methods
    
    /// Generates success feedback (e.g., for successful identification)
    func successFeedback() {
        if isHapticEnabled() {
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(.success)
        }
    }
    
    /// Generates error feedback (e.g., for error states)
    func errorFeedback() {
        if isHapticEnabled() {
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(.error)
        }
    }
    
    /// Generates warning feedback (e.g., for approaching limits)
    func warningFeedback() {
        if isHapticEnabled() {
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(.warning)
        }
    }
    
    /// Generates light impact feedback (e.g., for UI transitions)
    func lightImpact() {
        if isHapticEnabled() {
            lightImpactGenerator.prepare()
            lightImpactGenerator.impactOccurred()
        }
    }
    
    /// Generates medium impact feedback (e.g., for collection item deletion)
    func mediumImpact() {
        if isHapticEnabled() {
            mediumImpactGenerator.prepare()
            mediumImpactGenerator.impactOccurred()
        }
    }
    
    /// Generates heavy impact feedback (e.g., for significant actions)
    func heavyImpact() {
        if isHapticEnabled() {
            heavyImpactGenerator.prepare()
            heavyImpactGenerator.impactOccurred()
        }
    }
    
    /// Generates selection feedback (e.g., for scrolling through options)
    func selectionChanged() {
        if isHapticEnabled() {
            selectionGenerator.prepare()
            selectionGenerator.selectionChanged()
        }
    }
    
    // MARK: - Special Celebration Sequences
    
    /// Generates a celebratory haptic sequence for first identification
    func celebrationSequence() {
        if isHapticEnabled() {
            // Prepare all generators
            heavyImpactGenerator.prepare()
            mediumImpactGenerator.prepare()
            lightImpactGenerator.prepare()
            notificationGenerator.prepare()
            
            // First identification gets a special haptic celebration
            heavyImpact()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.mediumImpact()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.lightImpact()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.successFeedback()
            }
        }
    }
    
    /// Generates a gentle success celebration for regular identifications
    func identificationSuccess() {
        if isHapticEnabled() {
            mediumImpactGenerator.prepare()
            notificationGenerator.prepare()
            
            mediumImpact()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.successFeedback()
            }
        }
    }
    
    // MARK: - Accessibility Helper
    
    /// Checks if haptic feedback should be provided
    private func isHapticEnabled() -> Bool {
        // In a real app, we could check user preferences from UserDefaults here
        // For now, just return true to enable haptics by default
        return true
    }
}
