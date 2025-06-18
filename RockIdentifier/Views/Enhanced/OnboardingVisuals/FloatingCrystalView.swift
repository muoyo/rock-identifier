//
// FloatingCrystalView.swift
// Rock Identifier: Crystal ID
//
// Premium realistic crystal visual for onboarding
// Muoyo Okome
//

import SwiftUI
import Foundation

struct FloatingCrystalView: View {
    @State private var rotationAngle: Double = 0
    @State private var floatingOffset: CGFloat = 0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var sparkleOpacity: Double = 0.0
    @State private var lightBeamRotation: Double = 0
    
    // More complementary rock colors for amethyst rain theme
    let rockColors = [
        Color(hex: "E8D5FF").opacity(0.8), // Light amethyst tint
        Color(hex: "B8860B"), // Dark goldenrod (complements purple)
        Color(hex: "8B7355"), // Medium brown
        Color(hex: "654321")  // Dark brown base
    ]
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            rockColors[1].opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .scaleEffect(scaleEffect)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: scaleEffect)
            
            // Light beams rotating around rock (kept as user likes them)
            ForEach(0..<6, id: \.self) { index in
                LightBeam()
                    .rotationEffect(.degrees(lightBeamRotation + Double(index * 60)))
                    .opacity(0.6)
            }
            
            // Main rock specimen with magical effects
            ZStack {
                // Realistic rock specimen shape
                RealRockSpecimen()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: rockColors[0], location: 0.0),
                                .init(color: rockColors[1], location: 0.3),
                                .init(color: rockColors[2], location: 0.7),
                                .init(color: rockColors[3], location: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Rock surface details
                        RealRockSurfaceDetails()
                    )
                    .overlay(
                        // Rock highlights and texture
                        RealRockSpecimen()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: 120, height: 100)
                
                // Magical crystal formations growing from the rock
                CrystalCluster()
                    .offset(x: -35, y: -25)
                    .scaleEffect(0.3)
                    .opacity(0.8)
                
                CrystalCluster()
                    .offset(x: 40, y: -20)
                    .scaleEffect(0.25)
                    .opacity(0.7)
                    
                CrystalCluster()
                    .offset(x: 20, y: 30)
                    .scaleEffect(0.2)
                    .opacity(0.6)
            }
            .scaleEffect(1.2)
            .rotationEffect(.degrees(rotationAngle))
            .rotation3DEffect(
                .degrees(Foundation.sin(rotationAngle * .pi / 180) * 15),
                axis: (x: 1, y: 0, z: 0)
            )
            .offset(y: floatingOffset)
            .animation(.linear(duration: 8.0).repeatForever(autoreverses: false), value: rotationAngle)
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: floatingOffset)
            
            // Floating sparkles around the crystal (enhanced treasure vibe)
            ForEach(0..<12, id: \.self) { index in
                TreasureSparkle(index: index)
                    .opacity(sparkleOpacity)
            }
            
            // Treasure elements for maximum delight (elegant geological theme)
            AmethystRain()
            
            // Gentle shooting stars for magical atmosphere
            ShootingStars()
            
            // Magical particle system (enhanced)
            EnhancedTreasureParticles()
        }
        .frame(width: 280, height: 280)
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Start continuous rotation
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Start floating motion
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            floatingOffset = -15
        }
        
        // Start pulsing scale
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            scaleEffect = 1.1
        }
        
        // Start sparkle effects
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            sparkleOpacity = 0.8
        }
        
        // Light beam rotation (enhanced for treasure effect)
        withAnimation(.linear(duration: 10.0).repeatForever(autoreverses: false)) {
            lightBeamRotation = 360
        }
    }
}

// MARK: - Real Rock Specimen Shape

struct RealRockSpecimen: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = rect.width
        let height = rect.height
        
        // Create realistic irregular rock shape
        path.move(to: CGPoint(x: center.x - width * 0.35, y: center.y - height * 0.2))
        
        // Top edge with natural rock irregularities
        path.addCurve(
            to: CGPoint(x: center.x - width * 0.1, y: center.y - height * 0.4),
            control1: CGPoint(x: center.x - width * 0.25, y: center.y - height * 0.35),
            control2: CGPoint(x: center.x - width * 0.15, y: center.y - height * 0.42)
        )
        
        path.addCurve(
            to: CGPoint(x: center.x + width * 0.2, y: center.y - height * 0.35),
            control1: CGPoint(x: center.x + width * 0.05, y: center.y - height * 0.38),
            control2: CGPoint(x: center.x + width * 0.15, y: center.y - height * 0.37)
        )
        
        path.addCurve(
            to: CGPoint(x: center.x + width * 0.4, y: center.y - height * 0.1),
            control1: CGPoint(x: center.x + width * 0.3, y: center.y - height * 0.25),
            control2: CGPoint(x: center.x + width * 0.38, y: center.y - height * 0.18)
        )
        
        // Right edge
        path.addCurve(
            to: CGPoint(x: center.x + width * 0.35, y: center.y + height * 0.2),
            control1: CGPoint(x: center.x + width * 0.42, y: center.y + height * 0.05),
            control2: CGPoint(x: center.x + width * 0.4, y: center.y + height * 0.15)
        )
        
        // Bottom edge
        path.addCurve(
            to: CGPoint(x: center.x + width * 0.1, y: center.y + height * 0.4),
            control1: CGPoint(x: center.x + width * 0.25, y: center.y + height * 0.35),
            control2: CGPoint(x: center.x + width * 0.18, y: center.y + height * 0.38)
        )
        
        path.addCurve(
            to: CGPoint(x: center.x - width * 0.2, y: center.y + height * 0.35),
            control1: CGPoint(x: center.x - width * 0.05, y: center.y + height * 0.42),
            control2: CGPoint(x: center.x - width * 0.15, y: center.y + height * 0.4)
        )
        
        // Left edge back to start
        path.addCurve(
            to: CGPoint(x: center.x - width * 0.35, y: center.y - height * 0.2),
            control1: CGPoint(x: center.x - width * 0.3, y: center.y + height * 0.1),
            control2: CGPoint(x: center.x - width * 0.38, y: center.y - height * 0.05)
        )
        
        return path
    }
}

struct RealRockSurfaceDetails: View {
    var body: some View {
        ZStack {
            // Mineral veins running through the rock
            Path { path in
                path.move(to: CGPoint(x: 15, y: 20))
                path.addCurve(
                    to: CGPoint(x: 75, y: 45),
                    control1: CGPoint(x: 35, y: 25),
                    control2: CGPoint(x: 55, y: 40)
                )
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FFD700").opacity(0.6), // Gold vein
                        Color(hex: "FFA500").opacity(0.4)  // Orange
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 1.5
            )
            
            // Secondary mineral streak
            Path { path in
                path.move(to: CGPoint(x: 25, y: 50))
                path.addCurve(
                    to: CGPoint(x: 65, y: 75),
                    control1: CGPoint(x: 40, y: 60),
                    control2: CGPoint(x: 50, y: 70)
                )
            }
            .stroke(Color(hex: "C0C0C0").opacity(0.5), lineWidth: 1) // Silver streak
            
            // Rock texture spots
            ForEach(0..<6, id: \.self) { index in
                let positions: [CGPoint] = [
                    CGPoint(x: 20, y: 25),
                    CGPoint(x: 55, y: 15),
                    CGPoint(x: 80, y: 35),
                    CGPoint(x: 30, y: 65),
                    CGPoint(x: 70, y: 55),
                    CGPoint(x: 45, y: 75)
                ]
                
                Circle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                    .position(positions[index])
            }
            
            // Natural rock fracture lines
            Path { path in
                path.move(to: CGPoint(x: 10, y: 40))
                path.addLine(to: CGPoint(x: 40, y: 35))
                path.addLine(to: CGPoint(x: 70, y: 45))
            }
            .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
            
            // Surface weathering marks
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 12, height: 1)
                    .offset(x: CGFloat(index * 15 - 15), y: CGFloat(index * 10 - 5))
                    .rotationEffect(.degrees(Double(index * 15 - 15)))
            }
        }
    }
}

// MARK: - Crystal Shape Components

struct CrystalShape: Shape {
    let baseWidth: CGFloat
    let height: CGFloat
    let facets: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let topPoint = CGPoint(x: center.x, y: center.y - height/2)
        let bottomPoint = CGPoint(x: center.x, y: center.y + height/2)
        
        // Create hexagonal crystal structure
        let angleStep = 2 * .pi / Double(facets)
        var points: [CGPoint] = []
        
        // Top ring of points
        for i in 0..<facets {
            let angle = Double(i) * angleStep
            let x = center.x + Foundation.cos(angle) * (baseWidth * 0.3) / 2
            let y = center.y - height * 0.2 + Foundation.sin(angle) * (baseWidth * 0.3) / 2
            points.append(CGPoint(x: x, y: y))
        }
        
        // Middle ring of points (widest part)
        var middlePoints: [CGPoint] = []
        for i in 0..<facets {
            let angle = Double(i) * angleStep
            let x = center.x + Foundation.cos(angle) * baseWidth / 2
            let y = center.y + Foundation.sin(angle) * baseWidth / 2
            middlePoints.append(CGPoint(x: x, y: y))
        }
        
        // Bottom ring of points
        var bottomPoints: [CGPoint] = []
        for i in 0..<facets {
            let angle = Double(i) * angleStep
            let x = center.x + Foundation.cos(angle) * (baseWidth * 0.4) / 2
            let y = center.y + height * 0.2 + Foundation.sin(angle) * (baseWidth * 0.4) / 2
            bottomPoints.append(CGPoint(x: x, y: y))
        }
        
        // Draw crystal faces
        // Top pyramid
        for i in 0..<facets {
            let nextI = (i + 1) % facets
            path.move(to: topPoint)
            path.addLine(to: points[i])
            path.addLine(to: points[nextI])
            path.closeSubpath()
        }
        
        // Middle section
        for i in 0..<facets {
            let nextI = (i + 1) % facets
            path.move(to: points[i])
            path.addLine(to: middlePoints[i])
            path.addLine(to: middlePoints[nextI])
            path.addLine(to: points[nextI])
            path.closeSubpath()
        }
        
        // Lower section
        for i in 0..<facets {
            let nextI = (i + 1) % facets
            path.move(to: middlePoints[i])
            path.addLine(to: bottomPoints[i])
            path.addLine(to: bottomPoints[nextI])
            path.addLine(to: middlePoints[nextI])
            path.closeSubpath()
        }
        
        // Bottom pyramid
        for i in 0..<facets {
            let nextI = (i + 1) % facets
            path.move(to: bottomPoints[i])
            path.addLine(to: bottomPoint)
            path.addLine(to: bottomPoints[nextI])
            path.closeSubpath()
        }
        
        return path
    }
}

struct CrystalHighlights: View {
    var body: some View {
        ZStack {
            // Primary highlight streak
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 4, height: 60)
                .offset(x: -15, y: -20)
                .rotationEffect(.degrees(-20))
            
            // Secondary highlight
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.6))
                .frame(width: 2, height: 30)
                .offset(x: 20, y: -10)
                .rotationEffect(.degrees(15))
            
            // Reflection spots
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 8, height: 8)
                .offset(x: -10, y: -25)
            
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 6, height: 6)
                .offset(x: 15, y: 10)
        }
    }
}

struct CrystalCluster: View {
    var body: some View {
        ZStack {
            // Small crystal formation
            CrystalShape(baseWidth: 30, height: 45, facets: 5)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "F0E6FF"),
                            Color(hex: "D6BCFA"),
                            Color(hex: "9F7AEA")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                CrystalShape(baseWidth: 30, height: 45, facets: 5)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
}

struct LightBeam: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color(hex: "E8D5FF").opacity(0.5),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 200, height: 2)
            .blur(radius: 1)
    }
}

struct TreasureSparkle: View {
    let index: Int
    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0.0
    
    private var treasureIcons: [String] {
        ["sparkles", "star.fill", "diamond.fill", "circle.fill"]
    }
    
    private var treasureColors: [Color] {
        [.yellow, Color(hex: "FFD700"), Color(hex: "FFA500"), .white]
    }
    
    var body: some View {
        Image(systemName: treasureIcons[index % treasureIcons.count])
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(treasureColors[index % treasureColors.count])
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .animation(
                .easeInOut(duration: 4.0)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.2),
                value: position
            )
            .onAppear {
                startTreasureAnimation()
            }
    }
    
    private func startTreasureAnimation() {
        let angle = Double(index) * (2 * .pi / 12) // 12 sparkles around circle
        let radius: CGFloat = 85
        
        // Initial position
        position = CGPoint(
            x: Foundation.cos(angle) * radius,
            y: Foundation.sin(angle) * radius
        )
        
        // Animate to new position with treasure-like movement
        withAnimation(
            .easeInOut(duration: 4.0)
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.3)
        ) {
            position = CGPoint(
                x: Foundation.cos(angle) * (radius + 25),
                y: Foundation.sin(angle) * (radius + 25)
            )
            opacity = 0.7
            scale = 1.2
        }
        
        // Treasure glint rotation
        withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
}

struct AmethystRain: View {
    @State private var amethystPositions: [CGPoint] = []
    @State private var amethystOpacities: [Double] = []
    @State private var amethystScales: [CGFloat] = []
    @State private var amethystRotations: [Double] = []
    
    var body: some View {
        ZStack {
            // Gently falling amethyst crystals
            ForEach(0..<8, id: \.self) { index in
                if index < amethystPositions.count {
                    AmethystCrystal(size: 8.0) // Fixed size instead of random
                        .scaleEffect(amethystScales.indices.contains(index) ? amethystScales[index] : 1.0)
                        .opacity(amethystOpacities.indices.contains(index) ? amethystOpacities[index] : 0.0)
                        .rotationEffect(.degrees(amethystRotations.indices.contains(index) ? amethystRotations[index] : 0))
                        .position(amethystPositions[index])
                }
            }
        }
        .onAppear {
            startAmethystRain()
        }
    }
    
    private func startAmethystRain() {
        // Initialize amethyst positions starting from top
        amethystPositions = (0..<8).map { index in
            CGPoint(
                x: CGFloat(Double.random(in: -120...120)),
                y: CGFloat(-150 - Double(index * 20)) // Start above screen
            )
        }
        
        amethystOpacities = Array(repeating: 0.0, count: 8)
        amethystScales = Array(repeating: 0.5, count: 8)
        amethystRotations = Array(repeating: 0.0, count: 8)
        
        // Animate amethysts falling gently
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.8) {
                withAnimation(.easeInOut(duration: 5.5)) {
                    amethystPositions[i] = CGPoint(
                        x: amethystPositions[i].x + CGFloat(Double.random(in: -20...20)), // Slight drift
                        y: 180 // Fall to bottom
                    )
                    amethystOpacities[i] = 0.6
                    amethystScales[i] = 1.0
                }
                
                // Gentle rotation while falling
                withAnimation(.linear(duration: 10.0).repeatForever(autoreverses: false)) {
                    amethystRotations[i] = 360
                }
            }
        }
        
        // Reset rain cycle
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            startAmethystRain()
        }
    }
}

struct AmethystCrystal: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Crystal shape
            Diamond()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "E8D5FF"), // Light amethyst
                            Color(hex: "B794F6"), // Medium purple
                            Color(hex: "805AD5"), // Deep purple
                            Color(hex: "553C9A")  // Dark purple
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // Crystal highlight
            Diamond()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .frame(width: size * 0.6, height: size * 0.6)
        }
    }
}

struct ShootingStars: View {
    @State private var starTrails: [StarTrail] = []
    
    var body: some View {
        ZStack {
            ForEach(starTrails) { trail in
                ShootingStarView(trail: trail)
            }
        }
        .onAppear {
            startShootingStars()
        }
    }
    
    private func startShootingStars() {
        // Create shooting stars periodically
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            let newTrail = StarTrail()
            starTrails.append(newTrail)
            
            // Remove old trails
            if starTrails.count > 4 {
                starTrails.removeFirst()
            }
        }
    }
}

struct StarTrail: Identifiable {
    let id = UUID()
    let startPoint: CGPoint
    let endPoint: CGPoint
    let duration: Double
    
    init() {
        // Random start point from top edge
        self.startPoint = CGPoint(
            x: CGFloat(Double.random(in: -100...100)),
            y: -140
        )
        
        // End point diagonal down and across
        self.endPoint = CGPoint(
            x: startPoint.x + CGFloat(Double.random(in: 80...120)),
            y: CGFloat(Double.random(in: 100...140))
        )
        
        self.duration = 2.0
    }
}

struct ShootingStarView: View {
    let trail: StarTrail
    @State private var progress: CGFloat = 0.0
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Star trail
            Path { path in
                let currentPoint = CGPoint(
                    x: trail.startPoint.x + (trail.endPoint.x - trail.startPoint.x) * progress,
                    y: trail.startPoint.y + (trail.endPoint.y - trail.startPoint.y) * progress
                )
                
                // Create trailing effect
                for i in 0..<5 {
                    let trailProgress = max(0, progress - CGFloat(i) * 0.1)
                    let trailPoint = CGPoint(
                        x: trail.startPoint.x + (trail.endPoint.x - trail.startPoint.x) * trailProgress,
                        y: trail.startPoint.y + (trail.endPoint.y - trail.startPoint.y) * trailProgress
                    )
                    
                    if i == 0 {
                        path.move(to: trailPoint)
                    } else {
                        path.addLine(to: trailPoint)
                    }
                }
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.8),
                        Color(hex: "E8D5FF").opacity(0.6),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 2
            )
            .opacity(opacity)
            
            // Star head
            Image(systemName: "star.fill")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white)
                .position(
                    CGPoint(
                        x: trail.startPoint.x + (trail.endPoint.x - trail.startPoint.x) * progress,
                        y: trail.startPoint.y + (trail.endPoint.y - trail.startPoint.y) * progress
                    )
                )
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: trail.duration)) {
                progress = 1.0
                opacity = 1.0
            }
            
            // Fade out at the end
            DispatchQueue.main.asyncAfter(deadline: .now() + trail.duration * 0.7) {
                withAnimation(.easeOut(duration: trail.duration * 0.3)) {
                    opacity = 0.0
                }
            }
        }
    }
}

struct TreasureElements: View {
    @State private var coinPositions: [CGPoint] = []
    @State private var coinOpacities: [Double] = []
    @State private var coinScales: [CGFloat] = []
    @State private var gemRotations: [Double] = []
    
    var body: some View {
        ZStack {
            // Floating gold coins
            ForEach(0..<6, id: \.self) { index in
                if index < coinPositions.count {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "FFD700"),
                                        Color(hex: "FFA500"),
                                        Color(hex: "FF8C00")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 12, height: 12)
                        
                        Circle()
                            .stroke(Color(hex: "DAA520"), lineWidth: 1)
                            .frame(width: 12, height: 12)
                        
                        Text("$")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(Color(hex: "8B4513"))
                    }
                    .scaleEffect(coinScales.indices.contains(index) ? coinScales[index] : 1.0)
                    .opacity(coinOpacities.indices.contains(index) ? coinOpacities[index] : 0.0)
                    .position(coinPositions[index])
                }
            }
            
            // Floating gems
            ForEach(0..<4, id: \.self) { index in
                let gemColors: [Color] = [.red, .green, .blue, .purple]
                
                Diamond()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                gemColors[index].opacity(0.8),
                                gemColors[index],
                                gemColors[index].opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 10, height: 10)
                    .rotationEffect(.degrees(gemRotations.indices.contains(index) ? gemRotations[index] : 0))
                    .position(
                        CGPoint(
                            x: Foundation.cos(Double(index) * .pi / 2) * 90,
                            y: Foundation.sin(Double(index) * .pi / 2) * 90
                        )
                    )
                    .opacity(0.7)
            }
            
            // Treasure chest glow behind the rock
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "FFD700").opacity(0.3),
                            Color(hex: "FFA500").opacity(0.2),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: coinScales)
        }
        .onAppear {
            startTreasureElementsAnimation()
        }
    }
    
    private func startTreasureElementsAnimation() {
        // Initialize coin positions in a circle around the rock
        coinPositions = (0..<6).map { index in
            let angle = Double(index) * (.pi / 3) // 60 degrees apart
            let radius: CGFloat = 100
            return CGPoint(
                x: Foundation.cos(angle) * radius,
                y: Foundation.sin(angle) * radius
            )
        }
        
        coinOpacities = Array(repeating: 0.0, count: 6)
        coinScales = Array(repeating: 0.5, count: 6)
        gemRotations = Array(repeating: 0.0, count: 4)
        
        // Animate coins appearing
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    coinOpacities[i] = Double.random(in: 0.4...0.8)
                    coinScales[i] = CGFloat.random(in: 0.8...1.2)
                }
            }
        }
        
        // Animate gems rotating
        for i in 0..<4 {
            withAnimation(.linear(duration: Double.random(in: 3.0...6.0)).repeatForever(autoreverses: false)) {
                gemRotations[i] = 360
            }
        }
        
        // Periodic treasure glints
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            for i in 0..<6 {
                withAnimation(.easeInOut(duration: 0.5)) {
                    coinScales[i] = CGFloat.random(in: 1.2...1.5)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        coinScales[i] = CGFloat.random(in: 0.8...1.2)
                    }
                }
            }
        }
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Create diamond shape
        path.move(to: CGPoint(x: center.x, y: center.y - size/2)) // Top
        path.addLine(to: CGPoint(x: center.x + size/3, y: center.y)) // Right
        path.addLine(to: CGPoint(x: center.x, y: center.y + size/2)) // Bottom
        path.addLine(to: CGPoint(x: center.x - size/3, y: center.y)) // Left
        path.closeSubpath()
        
        return path
    }
}

struct EnhancedTreasureParticles: View {
    @State private var particles: [TreasureParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                particle.color,
                                particle.color.opacity(0.6),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: particle.size/2
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .animation(
                        .linear(duration: particle.duration)
                            .repeatForever(autoreverses: false),
                        value: particle.position
                    )
            }
        }
        .onAppear {
            createTreasureParticles()
        }
    }
    
    private func createTreasureParticles() {
        particles = []
        
        for _ in 0..<8 {
            let particle = TreasureParticle()
            particles.append(particle)
            
            // Animate particle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].position = CGPoint(
                        x: Double.random(in: -140...140),
                        y: Double.random(in: -140...140)
                    )
                }
            }
        }
        
        // Recreate particles periodically
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            createTreasureParticles()
        }
    }
}

struct TreasureParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let opacity: Double
    let duration: Double
    let color: Color
    
    init() {
        // Start from center and animate outward
        self.position = CGPoint(x: 0, y: 0)
        self.size = 6.0
        self.opacity = 0.5
        self.duration = 4.0
        
        // Treasure colors
        let treasureColors: [Color] = [
            Color(hex: "FFD700"), // Gold
            Color(hex: "FFA500"), // Orange gold
            Color(hex: "FFFF00"), // Bright yellow
            Color(hex: "DAA520"), // Goldenrod
            .white
        ]
        self.color = treasureColors.randomElement() ?? .yellow
    }
}

struct TreasureCompass: View {
    @State private var rotation: Double = 0.0
    
    var body: some View {
        ZStack {
            // Compass background
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "8B4513").opacity(0.8), // Brown
                            Color(hex: "654321").opacity(0.6)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 15
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color(hex: "DAA520"), lineWidth: 1)
                )
            
            // Compass needle pointing to treasure
            Path { path in
                path.move(to: CGPoint(x: 15, y: 15))
                path.addLine(to: CGPoint(x: 15, y: 5))
            }
            .stroke(Color(hex: "FFD700"), lineWidth: 2)
            .rotationEffect(.degrees(rotation))
            
            // North indicator
            Text("N")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(Color(hex: "FFD700"))
                .offset(y: -10)
            
            // Center dot
            Circle()
                .fill(Color(hex: "8B4513"))
                .frame(width: 4, height: 4)
        }
        .onAppear {
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct SparkleParticle: View {
    let index: Int
    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
            .animation(
                .easeInOut(duration: Double.random(in: 2.0...4.0))
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.3),
                value: position
            )
            .onAppear {
                startSparkleAnimation()
            }
    }
    
    private func startSparkleAnimation() {
        let angle = Double(index) * (2 * .pi / 8) // 8 sparkles around circle
        let radius: CGFloat = 80
        
        // Initial position
        position = CGPoint(
            x: Foundation.cos(angle) * radius,
            y: Foundation.sin(angle) * radius
        )
        
        // Animate to new position
        withAnimation(
            .easeInOut(duration: Double.random(in: 3.0...5.0))
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.2)
        ) {
            position = CGPoint(
                x: Foundation.cos(angle) * (radius + 20),
                y: Foundation.sin(angle) * (radius + 20)
            )
            opacity = Double.random(in: 0.3...0.8)
            scale = CGFloat.random(in: 0.8...1.2)
        }
    }
}

struct MagicalParticles: View {
    @State private var particles: [MagicalParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color(hex: "E8D5FF"),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: particle.size/2
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .animation(
                        .linear(duration: particle.duration)
                            .repeatForever(autoreverses: false),
                        value: particle.position
                    )
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        particles = []
        
        for _ in 0..<6 {
            let particle = MagicalParticle()
            particles.append(particle)
            
            // Animate particle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].position = CGPoint(
                        x: CGFloat.random(in: -140...140),
                        y: CGFloat.random(in: -140...140)
                    )
                }
            }
        }
        
        // Recreate particles periodically
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            createParticles()
        }
    }
}

struct MagicalParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let opacity: Double
    let duration: Double
    
    init() {
        // Start from center and animate outward
        self.position = CGPoint(x: 0, y: 0)
        self.size = CGFloat.random(in: 3...8)
        self.opacity = Double.random(in: 0.2...0.6)
        self.duration = Double.random(in: 2.0...4.0)
    }
}

// Color extension is already available in Extensions/Color+Extension.swift
