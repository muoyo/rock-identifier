//
// DynamicCollectionView.swift
// Rock Identifier: Crystal ID
//
// Dynamic collection building animation with MASSIVE visual impact and delight
// Muoyo Okome
//

import SwiftUI
import Foundation

struct DynamicCollectionView: View {
    @State private var visibleItems: [Bool] = Array(repeating: false, count: 9) // More items for bigger impact
    @State private var itemScales: [CGFloat] = Array(repeating: 0.0, count: 9)
    @State private var containerOpacity: Double = 0.0
    @State private var titleOpacity: Double = 0.0
    @State private var sparklePositions: [CGPoint] = []
    @State private var showSparkles = false
    @State private var counterText = ""
    @State private var counterOpacity: Double = 0.0
    
    let specimens = [
        RockSpecimenData(name: "Amethyst", color: .purple, shape: .crystal, position: 0),
        RockSpecimenData(name: "Rose Quartz", color: .pink, shape: .rounded, position: 1),
        RockSpecimenData(name: "Obsidian", color: .black, shape: .sharp, position: 2),
        RockSpecimenData(name: "Citrine", color: .yellow, shape: .crystal, position: 3),
        RockSpecimenData(name: "Malachite", color: .green, shape: .banded, position: 4),
        RockSpecimenData(name: "Tiger's Eye", color: .brown, shape: .smooth, position: 5),
        RockSpecimenData(name: "Fluorite", color: .blue, shape: .crystal, position: 6),
        RockSpecimenData(name: "Garnet", color: .red, shape: .rounded, position: 7),
        RockSpecimenData(name: "Pyrite", color: .gold, shape: .cubic, position: 8)
    ]
    
    var body: some View {
        ZStack {
            // MASSIVE collection container background with stunning gradient
            ZStack {
                // Background fill with more dramatic gradient
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glowing border stroke
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.6),
                                Color.cyan.opacity(0.4),
                                Color.purple.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                
                // Inner glow effect
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 200
                        )
                    )
            }
            .frame(width: 350, height: 310) // Shorter container since no big title
            .opacity(containerOpacity)
            .scaleEffect(containerOpacity) // Scale in with opacity
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: containerOpacity)
            
            VStack(spacing: 20) {
                // Collection grid title and counter - SIMPLIFIED
                VStack(spacing: 8) {
                    // Just show the counter, no redundant title
                    Text(counterText)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(counterOpacity)
                        .animation(.easeInOut(duration: 0.3), value: counterOpacity)
                        .padding(.top, 16) // Add breathing room from container top
                }
                
                // Collection grid - MUCH BIGGER 3x3 grid for maximum impact
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(0..<specimens.count, id: \.self) { index in
                        if visibleItems[index] {
                            CollectionRockItem(specimen: specimens[index])
                                .scaleEffect(itemScales[index])
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity).combined(with: .slide),
                                    removal: .scale.combined(with: .opacity)
                                ))
                        } else {
                            // Placeholder to maintain grid structure
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 80, height: 70) // Proper placeholder
                        }
                    }
                }
                .frame(width: 300, height: 280) // Properly sized grid
                .clipped() // Ensure nothing goes outside bounds
            }
            .frame(width: 350, height: 310) // Match container size
            .clipped() // Additional clipping to ensure containment
            
            // Celebration sparkles when items are added
            if showSparkles {
                ForEach(0..<sparklePositions.count, id: \.self) { index in
                    if index < sparklePositions.count {
                        CelebrationSparkle()
                            .position(sparklePositions[index])
                    }
                }
            }
        }
        .frame(width: 280, height: 280) // Overall component size constraint
        .onAppear {
            startMassiveCollectionAnimation()
        }
    }
    
    private func startMassiveCollectionAnimation() {
        // Show container first with dramatic entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            containerOpacity = 1.0
        }
        
        // Show title with SIMPLER animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                titleOpacity = 1.0 // Just fade in the counter
            }
        }
        
        // Add items one by one with MUCH more dramatic physics and celebrations
        for i in 0..<specimens.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5 + 1.0) {
                // Update counter first
                updateCounter(count: i + 1)
                
                // Create celebration sparkles for this item
                createCelebrationSparkles(for: i)
                
                // Add the item with dramatic animation
                withAnimation(.spring(response: 0.7, dampingFraction: 0.5)) {
                    visibleItems[i] = true
                    itemScales[i] = 1.0
                }
                
                // Add satisfying bounce effect - BIGGER
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                        itemScales[i] = 1.3 // BIGGER bounce
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        itemScales[i] = 1.0
                    }
                }
            }
        }
        
        // Reset and repeat animation with longer interval
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            resetAndRestartMassive()
        }
    }
    
    private func updateCounter(count: Int) {
        withAnimation(.easeOut(duration: 0.2)) {
            counterOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            counterText = "\(count) rocks discovered"
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                counterOpacity = 1.0
            }
        }
    }
    
    private func createCelebrationSparkles(for itemIndex: Int) {
        // Create sparkles around the item position
        let gridColumns = 3
        let row = itemIndex / gridColumns
        let col = itemIndex % gridColumns
        
        // Calculate approximate item position
        let itemX = CGFloat(col - 1) * 100 // Approximate column spacing
        let itemY = CGFloat(row - 1) * 90 // Approximate row spacing
        
        // Create sparkles around this position
        var newSparkles: [CGPoint] = []
        for _ in 0..<6 {
            let sparkleX = itemX + CGFloat.random(in: -40...40)
            let sparkleY = itemY + CGFloat.random(in: -40...40)
            newSparkles.append(CGPoint(x: sparkleX, y: sparkleY))
        }
        
        sparklePositions.append(contentsOf: newSparkles)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            showSparkles = true
        }
        
        // Remove sparkles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                if sparklePositions.count >= newSparkles.count {
                    sparklePositions.removeFirst(newSparkles.count)
                }
                if sparklePositions.isEmpty {
                    showSparkles = false
                }
            }
        }
    }
    
    private func resetAndRestartMassive() {
        // Hide counter
        withAnimation(.easeOut(duration: 0.3)) {
            counterOpacity = 0.0
        }
        
        // Hide all items with staggered animation
        for i in stride(from: visibleItems.count - 1, through: 0, by: -1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(visibleItems.count - 1 - i) * 0.1) {
                withAnimation(.easeOut(duration: 0.3)) {
                    visibleItems[i] = false
                    itemScales[i] = 0.0
                }
            }
        }
        
        // Restart after brief pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            for i in 0..<specimens.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                    updateCounter(count: i + 1)
                    createCelebrationSparkles(for: i)
                    
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.5)) {
                        visibleItems[i] = true
                        itemScales[i] = 1.0
                    }
                }
            }
        }
    }
}

// MARK: - Celebration Sparkle

struct CelebrationSparkle: View {
    @State private var scale: CGFloat = 0.0
    @State private var rotation: Double = 0.0
    @State private var opacity: Double = 0.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .offset(offset)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1.2
                    opacity = 1.0
                    offset = CGSize(
                        width: CGFloat.random(in: -30...30),
                        height: CGFloat.random(in: -30...30)
                    )
                }
                
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                
                withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                    opacity = 0.0
                    scale = 0.3
                }
            }
    }
}

// MARK: - Rock Specimen Data

struct RockSpecimenData {
    let name: String
    let color: SpecimenColor
    let shape: SpecimenShape
    let position: Int
    
    enum SpecimenColor {
        case purple, pink, black, yellow, green, brown, blue, red, gold
        
        var gradientColors: [Color] {
            switch self {
            case .purple:
                return [Color(hex: "E8D5FF"), Color(hex: "B794F6"), Color(hex: "805AD5")]
            case .pink:
                return [Color(hex: "FFE4E1"), Color(hex: "FFB6C1"), Color(hex: "FF69B4")]
            case .black:
                return [Color(hex: "4A5568"), Color(hex: "2D3748"), Color(hex: "1A202C")]
            case .yellow:
                return [Color(hex: "FFF8DC"), Color(hex: "FFD700"), Color(hex: "FFA500")]
            case .green:
                return [Color(hex: "E6FFFA"), Color(hex: "4FD1C7"), Color(hex: "319795")]
            case .brown:
                return [Color(hex: "D4BFAA"), Color(hex: "A0826D"), Color(hex: "744C4E")]
            case .blue:
                return [Color(hex: "E6F7FF"), Color(hex: "87CEEB"), Color(hex: "4682B4")]
            case .red:
                return [Color(hex: "FFE4E1"), Color(hex: "FF6B6B"), Color(hex: "DC143C")]
            case .gold:
                return [Color(hex: "FFF8DC"), Color(hex: "FFD700"), Color(hex: "DAA520")]
            }
        }
    }
    
    enum SpecimenShape {
        case crystal, rounded, sharp, banded, smooth, cubic
    }
}

// MARK: - Collection Rock Item - BIGGER AND MORE DETAILED

struct CollectionRockItem: View {
    let specimen: RockSpecimenData
    @State private var isHovered = false
    @State private var shimmerOffset: CGFloat = -200
    
    @ViewBuilder
    private func createRockShape() -> some View {
        let gradient = LinearGradient(
            gradient: Gradient(colors: specimen.color.gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        switch specimen.shape {
        case .crystal:
            CrystalRockShape()
                .fill(gradient)
        case .rounded:
            RoundedRockShape()
                .fill(gradient)
        case .sharp:
            SharpRockShape()
                .fill(gradient)
        case .banded:
            BandedRockShape()
                .fill(gradient)
        case .smooth:
            SmoothRockShape()
                .fill(gradient)
        case .cubic:
            CubicRockShape()
                .fill(gradient)
        }
    }
    
    @ViewBuilder
    private func createRockStroke() -> some View {
        let strokeColor = Color.white.opacity(0.4)
        let strokeWidth: CGFloat = 1.0
        
        switch specimen.shape {
        case .crystal:
            CrystalRockShape().stroke(strokeColor, lineWidth: strokeWidth)
        case .rounded:
            RoundedRockShape().stroke(strokeColor, lineWidth: strokeWidth)
        case .sharp:
            SharpRockShape().stroke(strokeColor, lineWidth: strokeWidth)
        case .banded:
            BandedRockShape().stroke(strokeColor, lineWidth: strokeWidth)
        case .smooth:
            SmoothRockShape().stroke(strokeColor, lineWidth: strokeWidth)
        case .cubic:
            CubicRockShape().stroke(strokeColor, lineWidth: strokeWidth)
        }
    }
    
    var body: some View {
        ZStack {
            // Rock shape with gradient fill - MUCH BIGGER
            createRockShape()
                .overlay(
                    // Rock surface details
                    RockSurfaceOverlay(specimen: specimen)
                )
                .overlay(
                    // Realistic rock highlights
                    createRockStroke()
                )
                .overlay(
                    // Shimmer effect on rock
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 20)
                        .offset(x: shimmerOffset)
                        .animation(.linear(duration: 1.5).delay(Double.random(in: 0...2)).repeatForever(autoreverses: false), value: shimmerOffset)
                )
                .frame(width: 60, height: 50) // Properly sized rocks
                .clipped()
            
            // Specimen label - bigger and more prominent
            VStack {
                Spacer()
                Text(specimen.name)
                    .font(.system(size: 11, weight: .semibold, design: .rounded)) // Bigger, bolder font
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                            )
                    )
                    .offset(y: 12)
            }
        }
        .scaleEffect(isHovered ? 1.1 : 1.0) // Bigger hover effect
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onAppear {
            // Start shimmer after a random delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...2)) {
                shimmerOffset = 200
            }
        }
    }
}

// MARK: - Enhanced Rock Shapes

struct CrystalRockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Create crystal-like hexagonal shape
        let angles = (0..<6).map { Double($0) * .pi / 3 }
        let points = angles.map { angle in
            CGPoint(
                x: center.x + cos(angle) * size * 0.4,
                y: center.y + sin(angle) * size * 0.3
            )
        }
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        
        return path
    }
}

struct RoundedRockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Create rounded, pebble-like shape
        path.addEllipse(in: CGRect(
            x: center.x - size * 0.45,
            y: center.y - size * 0.35,
            width: size * 0.9,
            height: size * 0.7
        ))
        
        return path
    }
}

struct SharpRockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Create sharp, angular obsidian-like shape
        path.move(to: CGPoint(x: center.x - size * 0.3, y: center.y + size * 0.3))
        path.addLine(to: CGPoint(x: center.x - size * 0.4, y: center.y - size * 0.1))
        path.addLine(to: CGPoint(x: center.x, y: center.y - size * 0.4))
        path.addLine(to: CGPoint(x: center.x + size * 0.4, y: center.y - size * 0.2))
        path.addLine(to: CGPoint(x: center.x + size * 0.3, y: center.y + size * 0.3))
        path.addLine(to: CGPoint(x: center.x, y: center.y + size * 0.2))
        path.closeSubpath()
        
        return path
    }
}

struct BandedRockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Create layered, sedimentary-like shape
        path.addRoundedRect(
            in: CGRect(
                x: center.x - size * 0.4,
                y: center.y - size * 0.3,
                width: size * 0.8,
                height: size * 0.6
            ),
            cornerSize: CGSize(width: 8, height: 8)
        )
        
        return path
    }
}

struct SmoothRockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.8
        
        // Create smooth, weathered rock shape
        path.move(to: CGPoint(x: center.x - size * 0.3, y: center.y - size * 0.2))
        path.addCurve(
            to: CGPoint(x: center.x + size * 0.3, y: center.y - size * 0.3),
            control1: CGPoint(x: center.x, y: center.y - size * 0.4),
            control2: CGPoint(x: center.x + size * 0.2, y: center.y - size * 0.35)
        )
        path.addCurve(
            to: CGPoint(x: center.x + size * 0.4, y: center.y + size * 0.2),
            control1: CGPoint(x: center.x + size * 0.4, y: center.y - size * 0.1),
            control2: CGPoint(x: center.x + size * 0.45, y: center.y + size * 0.1)
        )
        path.addCurve(
            to: CGPoint(x: center.x - size * 0.2, y: center.y + size * 0.3),
            control1: CGPoint(x: center.x + size * 0.1, y: center.y + size * 0.35),
            control2: CGPoint(x: center.x, y: center.y + size * 0.32)
        )
        path.addCurve(
            to: CGPoint(x: center.x - size * 0.3, y: center.y - size * 0.2),
            control1: CGPoint(x: center.x - size * 0.35, y: center.y + size * 0.1),
            control2: CGPoint(x: center.x - size * 0.35, y: center.y - size * 0.05)
        )
        
        return path
    }
}

struct CubicRockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) * 0.7
        
        // Create cubic pyrite-like shape
        path.addRect(CGRect(
            x: center.x - size * 0.35,
            y: center.y - size * 0.35,
            width: size * 0.7,
            height: size * 0.7
        ))
        
        return path
    }
}

// MARK: - Rock Surface Overlay

struct RockSurfaceOverlay: View {
    let specimen: RockSpecimenData
    
    var body: some View {
        ZStack {
            switch specimen.shape {
            case .crystal:
                // Crystal facet lines
                Path { path in
                    path.move(to: CGPoint(x: 15, y: 10))
                    path.addLine(to: CGPoint(x: 55, y: 20))
                    path.move(to: CGPoint(x: 25, y: 35))
                    path.addLine(to: CGPoint(x: 45, y: 45))
                }
                .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                
            case .banded:
                // Sedimentary layers
                ForEach(0..<4, id: \.self) { index in
                    Rectangle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 50, height: 1.5)
                        .offset(y: CGFloat(index * 10 - 15))
                }
                
            case .sharp:
                // Sharp edges highlight
                Path { path in
                    path.move(to: CGPoint(x: 20, y: 15))
                    path.addLine(to: CGPoint(x: 35, y: 8))
                    path.addLine(to: CGPoint(x: 50, y: 18))
                }
                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                
            case .cubic:
                // Cubic crystal faces
                Rectangle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: 30, height: 30)
                
            default:
                // General surface texture
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 4, height: 4)
                        .offset(
                            x: CGFloat.random(in: -20...20),
                            y: CGFloat.random(in: -15...15)
                        )
                }
            }
        }
    }
}
