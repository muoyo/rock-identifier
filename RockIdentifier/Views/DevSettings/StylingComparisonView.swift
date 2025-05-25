// Rock Identifier: Crystal ID
// Comparison Views for Grey vs Colorful Styling
// This file shows both approaches for comparison

import SwiftUI

// MARK: - Grey Alternative Styling

/// Grey version of EnhancedPropertyRow for comparison
struct GreyEnhancedPropertyRow: View {
    let label: String
    let value: String
    let iconName: String
    let showDivider: Bool
    
    @State private var hasAnimated = false
    @State private var shine = false
    @State private var opacity: Double = 0
    
    // Consistent grey theming
    private let iconColor = Color.gray
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Property content
            HStack(alignment: .top, spacing: 14) {
                // Enhanced icon with subtle animation (grey themed)
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    
                    // Subtle pulse ring
                    Circle()
                        .stroke(iconColor.opacity(hasAnimated ? 0.0 : 0.3), lineWidth: 2)
                        .frame(width: 34, height: 34)
                        .scaleEffect(hasAnimated ? 1.2 : 1.0)
                        .opacity(hasAnimated ? 0.0 : 1.0)
                        .animation(
                            Animation.easeOut(duration: 1.0).delay(0.3),
                            value: hasAnimated
                        )
                    
                    // Shine effect overlay
                    Circle()
                        .trim(from: 0.0, to: 0.2)
                        .stroke(Color.white.opacity(shine ? 0.0 : 0.6), lineWidth: 2)
                        .frame(width: 30, height: 30)
                        .rotationEffect(Angle(degrees: shine ? 360 : 0))
                        .animation(Animation.linear(duration: 1.2).delay(0.5).repeatCount(1, autoreverses: false),
                                   value: shine)
                    
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.system(size: 16, weight: .medium))
                }
                
                // Label and value with improved typography
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                    
                    Text(value)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.6), value: opacity)
            .onAppear {
                // Fade in with slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    opacity = 1.0
                    hasAnimated = true
                    shine = true
                }
            }
            
            // Enhanced divider with grey gradient
            if showDivider {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        iconColor.opacity(0.3),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .padding(.leading, 44)
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Colorful Property Row (using current system)

struct ColorfulPropertyRowDemo: View {
    let label: String
    let value: String
    let iconName: String
    let showDivider: Bool
    
    var body: some View {
        // Use the existing EnhancedPropertyRow from EnhancedRockResultView
        EnhancedPropertyRow(
            label: label,
            value: value,
            iconName: iconName,
            showDivider: showDivider
        )
    }
}

// MARK: - Comparison Preview

struct StylingComparisonView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🎨 Icon Styling Comparison")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Compare colorful vs grey approaches for property icons")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Colorful approach
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("🌈 Colorful Approach")
                                .font(.headline)
                            Text("(Current)")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            ColorfulPropertyRowDemo(
                                label: "Color",
                                value: "Deep purple with violet hues",
                                iconName: "circle.fill",
                                showDivider: true
                            )
                            
                            ColorfulPropertyRowDemo(
                                label: "Hardness",
                                value: "7 (Mohs scale)",
                                iconName: "hammer",
                                showDivider: true
                            )
                            
                            ColorfulPropertyRowDemo(
                                label: "Composition",
                                value: "Silicon dioxide (SiO₂)",
                                iconName: "doc.plaintext",
                                showDivider: false
                            )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Grey approach
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("⚪ Grey Approach")
                                .font(.headline)
                            Text("(Alternative)")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            GreyEnhancedPropertyRow(
                                label: "Color",
                                value: "Deep purple with violet hues",
                                iconName: "circle.fill",
                                showDivider: true
                            )
                            
                            GreyEnhancedPropertyRow(
                                label: "Hardness",
                                value: "7 (Mohs scale)",
                                iconName: "hammer",
                                showDivider: true
                            )
                            
                            GreyEnhancedPropertyRow(
                                label: "Composition",
                                value: "Silicon dioxide (SiO₂)",
                                iconName: "doc.plaintext",
                                showDivider: false
                            )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Analysis
                    VStack(alignment: .leading, spacing: 16) {
                        Text("📊 Analysis")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🌈 Colorful Approach")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("✅ More vibrant and engaging")
                                    Text("✅ Fits mineral-inspired theme perfectly")
                                    Text("✅ Creates clear visual hierarchy")
                                    Text("✅ More premium, delightful feel")
                                    Text("✅ Each property type is instantly recognizable")
                                    Text("❌ Could potentially feel overwhelming")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("⚪ Grey Approach")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("✅ More subtle and professional")
                                    Text("✅ Unified, consistent appearance")
                                    Text("✅ Content-focused design")
                                    Text("✅ Still has beautiful animations")
                                    Text("❌ Less engaging for discovery experience")
                                    Text("❌ Doesn't leverage your mineral theme")
                                    Text("❌ Misses opportunity for visual delight")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Recommendation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🎯 Recommendation")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stick with Colorful! 🌈")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("Your users are discovering beautiful, colorful rocks and minerals. The vibrant, mineral-inspired colors enhance that magical discovery experience and perfectly match your brand identity.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.green.opacity(0.1),
                                    Color.blue.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Styling Comparison")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
