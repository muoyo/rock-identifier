// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import UIKit

struct SplashView: View {
    // Animation states
    @State private var showOutline = false
    @State private var showTopFacet = false
    @State private var showSideFacets = false
    @State private var showAllFacets = false
    @State private var showScanLine = false
    @State private var scanPosition = 0.0
    @State private var showSparkle = false
    @State private var showTitle = false
    
    // Completion handler
    var onComplete: () -> Void
    
    // Background color - using white/cream to match app icon
    let backgroundColor = Color(hex: "E6DFD3") // Light beige/cream color from icon
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()
            
            // Crystal and animation elements
            ZStack {
                // Viewfinder corners - with clean L shapes
                ViewfinderCorners()
                
                // Crystal elements based on animation state
                ZStack {
                    // Crystal outline (only shown in stage 1)
                    if showOutline && !showTopFacet {
                        CrystalOutline()
                    }
                    
                    // Crystal facets - appear sequentially
                    if showTopFacet {
                        TopFacet()
                    }
                    
                    if showSideFacets {
                        SideFacets()
                    }
                    
                    if showAllFacets {
                        BottomFacets()
                        CenterFacet()
                    }
                    
                    // Reflections appear in final stage
                    if showSparkle {
                        Reflections()
                    }
                }
                
                // Scan line
                if showScanLine {
                    ScanLine(position: scanPosition)
                }
            }
            .frame(width: 340, height: 340) // Making the crystal larger
            
            // App title appears at the end
            if showTitle {
                VStack {
                    Spacer()
                    Text("Rock Identifier")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.bottom, 70)
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            // Start animation sequence
            startAnimationSequence()
        }
    }
    
    // Animation sequence timing - slower to give users more time to enjoy
    private func startAnimationSequence() {
        // Stage 1: Show outline (0.0s)
        withAnimation(.easeInOut(duration: 0.6)) {
            showOutline = true
        }
        
        // Subtle haptic for outline appearance
        HapticManager.shared.lightImpact()
        
        // Stage 2: Show top facet (0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.4)) {
                showTopFacet = true
            }
            
            // Subtle haptic for top facet
            HapticManager.shared.lightImpact()
        }
        
        // Stage 3: Show side facets (1.4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeInOut(duration: 0.4)) {
                showSideFacets = true
            }
            
            // Subtle haptic for side facets
            HapticManager.shared.lightImpact()
        }
        
        // Stage 4: Show all facets (2.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.4)) {
                showAllFacets = true
            }
            
            // Medium haptic for all facets appearing
            HapticManager.shared.mediumImpact()
        }
        
        // Stage 5: Show scan line (2.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showScanLine = true
            }
            
            // Haptic for scan line appearance
            HapticManager.shared.selectionChanged()
            
            // Animate scan line position
            withAnimation(.easeInOut(duration: 1.2)) {
                scanPosition = 1.0
            }
        }
        
        // Stage 6: Show sparkle and title (4.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 0.4)) {
                showSparkle = true
                showTitle = true
            }
            
            // Success haptic for final reveal
            HapticManager.shared.successFeedback()
            
            // Complete animation after a longer pause (2 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
        }
    }
}

// MARK: - Component Views

// Viewfinder corners - smooth L-shaped corners with curved transitions
struct ViewfinderCorners: View {
    var body: some View {
        ZStack {
            // Top left
            SmoothRockCorner(position: .topLeft)
            
            // Top right
            SmoothRockCorner(position: .topRight)
            
            // Bottom left
            SmoothRockCorner(position: .bottomLeft)
            
            // Bottom right
            SmoothRockCorner(position: .bottomRight)
        }
    }
}

// Individual smooth corner for rock theme
struct SmoothRockCorner: View {
    enum Position {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    let position: Position
    private let thickness: CGFloat = 8
    private let length: CGFloat = 50
    private let cornerRadius: CGFloat = 3
    
    var body: some View {
        Path { path in
            switch position {
            case .topLeft:
                // Start from horizontal end
                path.move(to: CGPoint(x: 30 + length, y: 30))
                // Line to corner
                path.addLine(to: CGPoint(x: 30 + cornerRadius, y: 30))
                // Curved corner
                path.addQuadCurve(
                    to: CGPoint(x: 30, y: 30 + cornerRadius),
                    control: CGPoint(x: 30, y: 30)
                )
                // Line to vertical end
                path.addLine(to: CGPoint(x: 30, y: 30 + length))
                // Thickness - vertical side
                path.addLine(to: CGPoint(x: 30 + thickness, y: 30 + length))
                // Back to corner (inside)
                path.addLine(to: CGPoint(x: 30 + thickness, y: 30 + thickness + cornerRadius))
                // Inner curve
                path.addQuadCurve(
                    to: CGPoint(x: 30 + thickness + cornerRadius, y: 30 + thickness),
                    control: CGPoint(x: 30 + thickness, y: 30 + thickness)
                )
                // Back to start
                path.addLine(to: CGPoint(x: 30 + length, y: 30 + thickness))
                path.closeSubpath()
                
            case .topRight:
                // Start from horizontal start
                path.move(to: CGPoint(x: 310 - length, y: 30))
                // Line to corner
                path.addLine(to: CGPoint(x: 310 - cornerRadius, y: 30))
                // Curved corner
                path.addQuadCurve(
                    to: CGPoint(x: 310, y: 30 + cornerRadius),
                    control: CGPoint(x: 310, y: 30)
                )
                // Line to vertical end
                path.addLine(to: CGPoint(x: 310, y: 30 + length))
                // Thickness - vertical side
                path.addLine(to: CGPoint(x: 310 - thickness, y: 30 + length))
                // Back to corner (inside)
                path.addLine(to: CGPoint(x: 310 - thickness, y: 30 + thickness + cornerRadius))
                // Inner curve
                path.addQuadCurve(
                    to: CGPoint(x: 310 - thickness - cornerRadius, y: 30 + thickness),
                    control: CGPoint(x: 310 - thickness, y: 30 + thickness)
                )
                // Back to start
                path.addLine(to: CGPoint(x: 310 - length, y: 30 + thickness))
                path.closeSubpath()
                
            case .bottomLeft:
                // Start from horizontal end
                path.move(to: CGPoint(x: 30 + length, y: 310))
                // Line to corner
                path.addLine(to: CGPoint(x: 30 + cornerRadius, y: 310))
                // Curved corner
                path.addQuadCurve(
                    to: CGPoint(x: 30, y: 310 - cornerRadius),
                    control: CGPoint(x: 30, y: 310)
                )
                // Line to vertical end
                path.addLine(to: CGPoint(x: 30, y: 310 - length))
                // Thickness - vertical side
                path.addLine(to: CGPoint(x: 30 + thickness, y: 310 - length))
                // Back to corner (inside)
                path.addLine(to: CGPoint(x: 30 + thickness, y: 310 - thickness - cornerRadius))
                // Inner curve
                path.addQuadCurve(
                    to: CGPoint(x: 30 + thickness + cornerRadius, y: 310 - thickness),
                    control: CGPoint(x: 30 + thickness, y: 310 - thickness)
                )
                // Back to start
                path.addLine(to: CGPoint(x: 30 + length, y: 310 - thickness))
                path.closeSubpath()
                
            case .bottomRight:
                // Start from horizontal start
                path.move(to: CGPoint(x: 310 - length, y: 310))
                // Line to corner
                path.addLine(to: CGPoint(x: 310 - cornerRadius, y: 310))
                // Curved corner
                path.addQuadCurve(
                    to: CGPoint(x: 310, y: 310 - cornerRadius),
                    control: CGPoint(x: 310, y: 310)
                )
                // Line to vertical end
                path.addLine(to: CGPoint(x: 310, y: 310 - length))
                // Thickness - vertical side
                path.addLine(to: CGPoint(x: 310 - thickness, y: 310 - length))
                // Back to corner (inside)
                path.addLine(to: CGPoint(x: 310 - thickness, y: 310 - thickness - cornerRadius))
                // Inner curve
                path.addQuadCurve(
                    to: CGPoint(x: 310 - thickness - cornerRadius, y: 310 - thickness),
                    control: CGPoint(x: 310 - thickness, y: 310 - thickness)
                )
                // Back to start
                path.addLine(to: CGPoint(x: 310 - length, y: 310 - thickness))
                path.closeSubpath()
            }
        }
        .fill(Color.black) // Keeping existing black color for rock theme
        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

// Crystal outline
struct CrystalOutline: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 170, y: 70))
            path.addLine(to: CGPoint(x: 70, y: 140))
            path.addLine(to: CGPoint(x: 70, y: 240))
            path.addLine(to: CGPoint(x: 170, y: 280))
            path.addLine(to: CGPoint(x: 270, y: 240))
            path.addLine(to: CGPoint(x: 270, y: 140))
            path.closeSubpath()
        }
        .stroke(Color(hex: "8B0000"), lineWidth: 2)
        .opacity(0.7)
    }
}

// Top facet
struct TopFacet: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 170, y: 70))
            path.addLine(to: CGPoint(x: 70, y: 140))
            path.addLine(to: CGPoint(x: 170, y: 170))
            path.addLine(to: CGPoint(x: 270, y: 140))
            path.closeSubpath()
        }
        .fill(Color(hex: "FF6B8A"))
    }
}

// Side facets
struct SideFacets: View {
    var body: some View {
        ZStack {
            // Left side facet
            Path { path in
                path.move(to: CGPoint(x: 70, y: 140))
                path.addLine(to: CGPoint(x: 70, y: 240))
                path.addLine(to: CGPoint(x: 170, y: 170))
                path.closeSubpath()
            }
            .fill(Color(hex: "FF3B5C"))
            
            // Right side facet
            Path { path in
                path.move(to: CGPoint(x: 270, y: 140))
                path.addLine(to: CGPoint(x: 270, y: 240))
                path.addLine(to: CGPoint(x: 170, y: 170))
                path.closeSubpath()
            }
            .fill(Color(hex: "FF3B5C"))
        }
    }
}

// Bottom facets
struct BottomFacets: View {
    var body: some View {
        ZStack {
            // Left bottom facet
            Path { path in
                path.move(to: CGPoint(x: 70, y: 240))
                path.addLine(to: CGPoint(x: 170, y: 280))
                path.addLine(to: CGPoint(x: 170, y: 170))
                path.closeSubpath()
            }
            .fill(Color(hex: "C51D2E"))
            
            // Right bottom facet
            Path { path in
                path.move(to: CGPoint(x: 270, y: 240))
                path.addLine(to: CGPoint(x: 170, y: 280))
                path.addLine(to: CGPoint(x: 170, y: 170))
                path.closeSubpath()
            }
            .fill(Color(hex: "C51D2E"))
        }
    }
}

// Center facet
struct CenterFacet: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 140, y: 170))
            path.addLine(to: CGPoint(x: 170, y: 200))
            path.addLine(to: CGPoint(x: 200, y: 170))
            path.addLine(to: CGPoint(x: 170, y: 140))
            path.closeSubpath()
        }
        .fill(Color(hex: "FFB6C1"))
    }
}

// Enhanced scan line with smooth gradient and glow
struct ScanLine: View {
    var position: Double // 0.0 (top) to 1.0 (bottom)
    
    var body: some View {
        let yPosition = 70.0 + position * 210.0 // Map 0-1 to 70-280 (crystal bounds)
        
        ZStack {
            // Main scan line with rock-themed gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color(hex: "FF3B5C"), // Primary rock pink
                            Color(hex: "FF6B8A"), // Lighter rock pink
                            Color(hex: "FFB6C1"), // Soft rock pink
                            Color(hex: "FF6B8A"), // Lighter rock pink
                            Color(hex: "FF3B5C"), // Primary rock pink
                            Color.clear
                        ]), 
                        startPoint: .leading, 
                        endPoint: .trailing
                    )
                )
                .frame(width: 280, height: 2)
                .position(x: 170, y: yPosition)
            
            // Enhanced glow effect
            Rectangle()
                .fill(Color(hex: "FF3B5C").opacity(0.4))
                .frame(width: 260, height: 8)
                .blur(radius: 4)
                .position(x: 170, y: yPosition)
        }
    }
}

// Reflections and sparkle
struct Reflections: View {
    var body: some View {
        ZStack {
            // Main reflection
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 40, height: 40)
                .position(x: 130, y: 100)
            
            // Smaller reflection
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 20, height: 20)
                .position(x: 150, y: 90)
            
            // Sparkle effect
            ZStack {
                // Horizontal line
                Path { path in
                    path.move(to: CGPoint(x: 115, y: 100))
                    path.addLine(to: CGPoint(x: 145, y: 100))
                }
                .stroke(Color.white, lineWidth: 2)
                
                // Vertical line
                Path { path in
                    path.move(to: CGPoint(x: 130, y: 85))
                    path.addLine(to: CGPoint(x: 130, y: 115))
                }
                .stroke(Color.white, lineWidth: 2)
                
                // Diagonal lines
                Path { path in
                    path.move(to: CGPoint(x: 120, y: 90))
                    path.addLine(to: CGPoint(x: 140, y: 110))
                    path.move(to: CGPoint(x: 120, y: 110))
                    path.addLine(to: CGPoint(x: 140, y: 90))
                }
                .stroke(Color.white, lineWidth: 1.5)
            }
            .opacity(0.7)
            .position(x: 130, y: 100)
        }
    }
}

