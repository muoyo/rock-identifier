//
// PerformantFloatingCrystalView.swift
// Rock Identifier: Crystal ID
//
// Performance-optimized crystal visual for onboarding with radiating waves
// Maintains magical feel while eliminating hangs
// Muoyo Okome
//

import SwiftUI
import Foundation

struct PerformantFloatingCrystalView: View {
    @State private var rockFloat: CGFloat = 0
    @State private var glowOpacity: Double = 0.6
    @State private var amethystPositions: [CGPoint] = []
    @State private var amethystOpacities: [Double] = []
    @State private var waveScales: [CGFloat] = [0.0, 0.0, 0.0, 0.0]
    @State private var waveOpacities: [Double] = [0.8, 0.6, 0.4, 0.2]
    @State private var scanLinePosition: CGFloat = -125
    @State private var showScanLine = true
    
    // Simple, elegant blue diamond color palette
    let rockColors = [
        Color(hex: "E6F3FF"), // Very light blue
        Color(hex: "B3D9FF"), // Light blue
        Color(hex: "4A90E2"), // Medium blue
        Color(hex: "2C5282")  // Deep blue
    ]
    
    var body: some View {
        ZStack {
            // Background glow - single, simple animation
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "E8D5FF").opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 1000
                    )
                )
                .frame(width: 200, height: 200)
                .opacity(glowOpacity)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: false), value: glowOpacity)
            
            // Radiating waves from the rock - MUCH more impactful
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "4A90E2").opacity(waveOpacities[index]),
                                Color(hex: "E8D5FF").opacity(waveOpacities[index] * 0.5),
                                Color.clear
                            ]),
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 60, height: 60)
                    .scaleEffect(waveScales[index])
                    .opacity(waveOpacities[index])
                    .animation(
                        .easeOut(duration: 2.5)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.4),
                        value: waveScales[index]
                    )
            }
            

            
            // HORIZONTAL scanning line that moves UP & DOWN - IN FRONT of rock
            if showScanLine {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.cyan.opacity(0.8),
                                Color.blue.opacity(0.9),
                                Color.cyan.opacity(0.8),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 350, height: 3) // HORIZONTAL line: wide & short
                    .offset(y: scanLinePosition)
                    .animation(.linear(duration: 4.0).repeatForever(autoreverses: true), value: scanLinePosition)
                    .zIndex(10) // IN FRONT of rock
            }
            
            // Main rock specimen - ROTATED to different angle and bigger
            ZStack {
                // Rock shadow for depth
                RockSpecimen2()
                    .fill(Color.black.opacity(0.2))
                    .offset(x: 3, y: 8)
                    .blur(radius: 4)
                
                // Main rock with realistic geology
                RockSpecimen2()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: rockColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Subtle highlight outline only
                        RockSpecimen2()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                // Small crystal accent - single, simple crystal
                SimpleDiamond()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "E8D5FF"),
                                Color(hex: "9F7AEA")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 15, height: 15)
                    .offset(x: 35, y: -25)
                    .opacity(0.8)
            }
            .scaleEffect(1.8) // Even bigger for more impact
            .rotationEffect(.degrees(25)) // Rotated to different angle from Screen 2
            .offset(y: rockFloat)
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: rockFloat)
            
            // Gentle amethyst rain - LIMITED to 5 crystals max
            ForEach(0..<5, id: \.self) { index in
                if index < amethystPositions.count {
                    SimpleAmethyst()
                        .position(amethystPositions[index])
                        .opacity(amethystOpacities.indices.contains(index) ? amethystOpacities[index] : 0.0)
                }
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            startEnhancedAnimations()
        }
    }
    
    private func startEnhancedAnimations() {
        // Start floating motion - single, simple animation
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            rockFloat = -15
        }
        
        // Start glow pulse - single, simple animation
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            glowOpacity = 0.8
        }
        
        // Start radiating waves - MUCH more dramatic
        startRadiatingWaves()
        
        // Start SLOW vertical scan line (top to bottom)
        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: true)) {
            scanLinePosition = 125 // Move from top to bottom
        }
        
        // Initialize amethyst rain - SINGLE setup, no timers
        startAmethystRain()
    }
    
    private func startRadiatingWaves() {
        // Initialize wave scales
        for i in 0..<4 {
            withAnimation(
                .easeOut(duration: 2.5)
                .repeatForever(autoreverses: false)
                .delay(Double(i) * 0.4)
            ) {
                waveScales[i] = 4.0 // Much bigger scale for dramatic effect
            }
        }
        
        // Reset waves periodically for continuous effect
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            // Reset all waves
            for i in 0..<4 {
                waveScales[i] = 0.0
            }
            
            // Restart wave animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                for i in 0..<4 {
                    withAnimation(
                        .easeOut(duration: 2.5)
                        .delay(Double(i) * 0.4)
                    ) {
                        waveScales[i] = 4.0
                    }
                }
            }
        }
    }
    
    private func startAmethystRain() {
        // Initialize positions - simple, no complex calculations
        amethystPositions = [
            CGPoint(x: -80, y: -100),
            CGPoint(x: 60, y: -120),
            CGPoint(x: -20, y: -140),
            CGPoint(x: 90, y: -90),
            CGPoint(x: -110, y: -80)
        ]
        
        amethystOpacities = Array(repeating: 0.0, count: 5)
        
        // Simple staggered animation - no complex timers
        for i in 0..<5 {
            withAnimation(
                .easeInOut(duration: 4.0)
                .delay(Double(i) * 0.8)
                .repeatForever(autoreverses: false)
            ) {
                if i < amethystPositions.count {
                    amethystPositions[i] = CGPoint(
                        x: amethystPositions[i].x + CGFloat.random(in: -20...20),
                        y: 150
                    )
                }
                if i < amethystOpacities.count {
                    amethystOpacities[i] = 0.5
                }
            }
        }
    }
}

// MARK: - Simplified Supporting Views

struct SimpleAmethyst: View {
    var body: some View {
        SimpleDiamond()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "E8D5FF"),
                        Color(hex: "9F7AEA")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 8, height: 8)
            .overlay(
                // Simple highlight
                SimpleDiamond()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 4, height: 4)
                    .offset(x: -1, y: -1)
            )
    }
}

// Simple diamond shape - much more efficient than complex crystal
struct SimpleDiamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height)
        
        // Simple diamond - 4 points only
        path.move(to: CGPoint(x: center.x, y: center.y - size/2)) // Top
        path.addLine(to: CGPoint(x: center.x + size/2, y: center.y)) // Right
        path.addLine(to: CGPoint(x: center.x, y: center.y + size/2)) // Bottom
        path.addLine(to: CGPoint(x: center.x - size/2, y: center.y)) // Left
        path.closeSubpath()
        
        return path
    }
}

// Natural rock shape - irregular but simple
struct NaturalRockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = rect.width
        let height = rect.height
        
        // Create irregular rock shape with natural edges
        // Start from top-left area
        path.move(to: CGPoint(x: center.x - width * 0.3, y: center.y - height * 0.25))
        
        // Top edge with natural bumps
        path.addQuadCurve(
            to: CGPoint(x: center.x + width * 0.1, y: center.y - height * 0.4),
            control: CGPoint(x: center.x - width * 0.1, y: center.y - height * 0.45)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: center.x + width * 0.35, y: center.y - height * 0.15),
            control: CGPoint(x: center.x + width * 0.25, y: center.y - height * 0.3)
        )
        
        // Right edge
        path.addQuadCurve(
            to: CGPoint(x: center.x + width * 0.25, y: center.y + height * 0.2),
            control: CGPoint(x: center.x + width * 0.4, y: center.y)
        )
        
        // Bottom edge
        path.addQuadCurve(
            to: CGPoint(x: center.x - width * 0.1, y: center.y + height * 0.35),
            control: CGPoint(x: center.x + width * 0.1, y: center.y + height * 0.4)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: center.x - width * 0.35, y: center.y + height * 0.1),
            control: CGPoint(x: center.x - width * 0.25, y: center.y + height * 0.3)
        )
        
        // Left edge back to start
        path.addQuadCurve(
            to: CGPoint(x: center.x - width * 0.3, y: center.y - height * 0.25),
            control: CGPoint(x: center.x - width * 0.4, y: center.y - height * 0.1)
        )
        
        return path
    }
}

// MARK: - Rock Specimen Shape (reused from AIScanningView but rotated differently)

struct RockSpecimen2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size: CGFloat = min(rect.width, rect.height) * 0.6
        
        // Create irregular rock shape with realistic geology
        path.move(to: CGPoint(x: center.x - size * 0.4, y: center.y - size * 0.3))
        
        // Top edge with mineral formations
        path.addCurve(
            to: CGPoint(x: center.x - size * 0.1, y: center.y - size * 0.45),
            control1: CGPoint(x: center.x - size * 0.3, y: center.y - size * 0.5),
            control2: CGPoint(x: center.x - size * 0.2, y: center.y - size * 0.48)
        )
        
        path.addCurve(
            to: CGPoint(x: center.x + size * 0.2, y: center.y - size * 0.35),
            control1: CGPoint(x: center.x, y: center.y - size * 0.42),
            control2: CGPoint(x: center.x + size * 0.1, y: center.y - size * 0.4)
        )
        
        path.addCurve(
            to: CGPoint(x: center.x + size * 0.45, y: center.y - size * 0.1),
            control1: CGPoint(x: center.x + size * 0.35, y: center.y - size * 0.25),
            control2: CGPoint(x: center.x + size * 0.4, y: center.y - size * 0.18)
        )
        
        // Right edge
        path.addCurve(
            to: CGPoint(x: center.x + size * 0.4, y: center.y + size * 0.2),
            control1: CGPoint(x: center.x + size * 0.5, y: center.y),
            control2: CGPoint(x: center.x + size * 0.48, y: center.y + size * 0.1)
        )
        
        // Bottom edge with sedimentary layers
        path.addCurve(
            to: CGPoint(x: center.x + size * 0.1, y: center.y + size * 0.4),
            control1: CGPoint(x: center.x + size * 0.3, y: center.y + size * 0.35),
            control2: CGPoint(x: center.x + size * 0.2, y: center.y + size * 0.38)
        )
        
        path.addCurve(
            to: CGPoint(x: center.x - size * 0.2, y: center.y + size * 0.35),
            control1: CGPoint(x: center.x, y: center.y + size * 0.45),
            control2: CGPoint(x: center.x - size * 0.1, y: center.y + size * 0.4)
        )
        
        // Left edge back to start
        path.addCurve(
            to: CGPoint(x: center.x - size * 0.4, y: center.y - size * 0.3),
            control1: CGPoint(x: center.x - size * 0.35, y: center.y + size * 0.1),
            control2: CGPoint(x: center.x - size * 0.42, y: center.y - size * 0.1)
        )
        
        return path
    }
}
