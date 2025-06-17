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
    
    let crystalColors = [
        Color(hex: "E8D5FF"), // Light lavender
        Color(hex: "B794F6"), // Medium purple
        Color(hex: "805AD5"), // Deep purple
        Color(hex: "553C9A")  // Dark purple base
    ]
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            crystalColors[1].opacity(0.3),
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
            
            // Light beams rotating around crystal
            ForEach(0..<6, id: \.self) { index in
                LightBeam()
                    .rotationEffect(.degrees(lightBeamRotation + Double(index * 60)))
                    .opacity(0.6)
            }
            
            // Main crystal structure
            ZStack {
                // Crystal base (larger hexagonal structure)
                CrystalShape(baseWidth: 80, height: 120, facets: 6)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: crystalColors[0], location: 0.0),
                                .init(color: crystalColors[1], location: 0.3),
                                .init(color: crystalColors[2], location: 0.7),
                                .init(color: crystalColors[3], location: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Inner crystal structure
                        CrystalShape(baseWidth: 60, height: 90, facets: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.4),
                                        crystalColors[1].opacity(0.6),
                                        crystalColors[2].opacity(0.3)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        // Crystal highlights and reflections
                        CrystalHighlights()
                    )
                
                // Secondary crystal formations
                CrystalCluster()
                    .offset(x: -30, y: 20)
                    .scaleEffect(0.4)
                    .opacity(0.8)
                
                CrystalCluster()
                    .offset(x: 35, y: -15)
                    .scaleEffect(0.3)
                    .opacity(0.7)
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
            
            // Floating sparkles around the crystal
            ForEach(0..<8, id: \.self) { index in
                SparkleParticle(index: index)
                    .opacity(sparkleOpacity)
            }
            
            // Magical particle system
            MagicalParticles()
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
        
        // Light beam rotation
        withAnimation(.linear(duration: 12.0).repeatForever(autoreverses: false)) {
            lightBeamRotation = 360
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
