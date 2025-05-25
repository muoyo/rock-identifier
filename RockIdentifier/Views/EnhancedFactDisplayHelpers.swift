//  Enhanced Fact Display View Helper - Missing Functions
//
//  This file contains the helper functions and sections that are referenced but missing
//  from the main EnhancedFactDisplayView

import SwiftUI

// MARK: - Enhanced Uses Section Component

struct EnhancedUsesSection: View {
    let title: String
    let items: [String]
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section header
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
            }
            
            // Items list
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        // Bullet point with custom style
                        Circle()
                            .fill(Color.blue.opacity(0.6))
                            .frame(width: 6, height: 6)
                            .padding(.top, 8)
                        
                        Text(item)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 4)
        }
    }
}
