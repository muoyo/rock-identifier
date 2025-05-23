// Rock Identifier: Crystal ID
// Collection View Integration - Easy switching between original and enhanced views
// Muoyo Okome
//

import SwiftUI

/// Main collection view that can switch between original and enhanced implementations
/// Currently defaults to enhanced view for better aesthetics and user experience
struct CollectionViewSelector: View {
    @EnvironmentObject var collectionManager: CollectionManager
    
    // Toggle this to switch between original and enhanced views
    @AppStorage("useEnhancedCollectionView") private var useEnhancedView = true
    
    var body: some View {
        Group {
            if useEnhancedView {
                EnhancedCollectionView()
                    .environmentObject(collectionManager)
            } else {
                CollectionView()
                    .environmentObject(collectionManager)
            }
        }
    }
}

/// Developer settings toggle for switching between collection view implementations
struct CollectionViewToggleSettings: View {
    @AppStorage("useEnhancedCollectionView") private var useEnhancedView = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Collection View Settings")
                .font(.headline)
            
            Toggle("Use Enhanced Collection View", isOn: $useEnhancedView)
                .toggleStyle(SwitchToggleStyle())
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Enhanced View Features:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 4) {
                    FeatureItem(text: "Gradient card backgrounds with mineral theming")
                    FeatureItem(text: "Animated entrance animations for cards")
                    FeatureItem(text: "Shimmer effects and micro-interactions")
                    FeatureItem(text: "Enhanced typography with gradient text")
                    FeatureItem(text: "Improved empty state with floating animations")
                    FeatureItem(text: "Better visual hierarchy and spacing")
                    FeatureItem(text: "Confidence indicators and enhanced metadata")
                    FeatureItem(text: "Staggered animations and transitions")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            if !useEnhancedView {
                Text("Currently using the original collection view implementation.")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FeatureItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.green)
                .padding(.top, 1)
            
            Text("• \(text)")
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CollectionViewSelector_Previews: PreviewProvider {
    static var previews: some View {
        let collectionManager = CollectionManager()
        return Group {
            CollectionViewSelector()
                .environmentObject(collectionManager)
                .previewDisplayName("Collection View Selector")
            
            CollectionViewToggleSettings()
                .previewDisplayName("Settings Toggle")
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
