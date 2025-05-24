// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

struct IdentificationCounterView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var showLabel: Bool = true
    var showUnlimited: Bool = true
    var labelPosition: LabelPosition = .leading
    
    enum LabelPosition {
        case leading
        case trailing
    }
    
    var body: some View {
        HStack(spacing: 6) {
            if labelPosition == .leading && showLabel {
                Text("Remaining:")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            if subscriptionManager.status.isActive && showUnlimited {
                // Premium user with unlimited identifications
                HStack(spacing: 4) {
                    Image(systemName: "infinity")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text("Unlimited")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.blue)
                }
            } else {
                // Free tier user with limited identifications
                HStack(spacing: 4) {
                    Text("\(subscriptionManager.remainingIdentifications)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(getColor(for: subscriptionManager.remainingIdentifications))
                    
                    if showUnlimited {
                        Text("/ \(subscriptionManager.identificationCounter.maxTotalLimit)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if labelPosition == .trailing && showLabel {
                Text("Remaining")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    // Return appropriate color based on remaining count
    private func getColor(for remaining: Int) -> Color {
        switch remaining {
        case 0:
            return .red
        case 1:
            return .orange
        default:
            return .primary
        }
    }
}

// Preview provider
struct IdentificationCounterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Free tier preview
            VStack(spacing: 20) {
                IdentificationCounterView(showLabel: true)
                IdentificationCounterView(showLabel: true, labelPosition: .trailing)
                IdentificationCounterView(showLabel: false)
            }
            .environmentObject(createFreeSubscriptionManager())
            .previewDisplayName("Free Tier")
            .padding()
            
            // Premium tier preview
            VStack(spacing: 20) {
                IdentificationCounterView(showLabel: true)
                IdentificationCounterView(showLabel: true, labelPosition: .trailing)
                IdentificationCounterView(showUnlimited: false)
            }
            .environmentObject(createPremiumSubscriptionManager())
            .previewDisplayName("Premium Tier")
            .padding()
        }
    }
    
    // Helper to create mock subscription managers for previews
    static func createFreeSubscriptionManager() -> SubscriptionManager {
        let manager = SubscriptionManager()
        manager.resetToFree()
        return manager
    }
    
    static func createPremiumSubscriptionManager() -> SubscriptionManager {
        let manager = SubscriptionManager()
        manager.setMockPremium()
        return manager
    }
}
