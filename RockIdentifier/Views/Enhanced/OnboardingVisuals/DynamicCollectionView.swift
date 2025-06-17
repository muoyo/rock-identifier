//
// DynamicCollectionView.swift
// Rock Identifier: Crystal ID
//
// Dynamic collection building animation with proper containment
// Muoyo Okome
//

import SwiftUI
import Foundation

struct DynamicCollectionView: View {
    @State private var visibleItems: [Bool] = Array(repeating: false, count: 6)
    @State private var itemScales: [CGFloat] = Array(repeating: 0.0, count: 6)
    @State private var containerOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = -20
    @State private var titleOpacity: Double = 0.0
    
    let specimens = [
        RockSpecimenData(name: "Amethyst", color: .purple, shape: .crystal, position: 0),
        RockSpecimenData(name: "Rose Quartz", color: .pink, shape: .rounded, position: 1),
        RockSpecimenData(name: "Obsidian", color: .black, shape: .sharp, position: 2),
        RockSpecimenData(name: "Citrine", color: .yellow, shape: .crystal, position: 3),
        RockSpecimenData(name: "Malachite", color: .green, shape: .banded, position: 4),
        RockSpecimenData(name: "Tiger's Eye", color: .brown, shape: .smooth, position: 5)
    ]
    
    var body: some View {
        ZStack {
            // Collection container background
            ZStack {
                // Background fill
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border stroke
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            }
            .frame(width: 240, height: 180)
            .opacity(containerOpacity)
            .animation(.easeInOut(duration: 0.8), value: containerOpacity)
            
            VStack(spacing: 16) {
                // Collection title
                Text("My Collection")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: titleOffset)
                
                // Collection grid - properly contained
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(0..<specimens.count, id: \.self) { index in
                        if visibleItems[index] {
                            CollectionRockItem(specimen: specimens[index])
                                .scaleEffect(itemScales[index])
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                        } else {
                            // Placeholder to maintain grid structure
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 60, height: 50)
                        }
                    }
                }
                .frame(width: 200, height: 120) // Constrain grid size to ensure containment
                .clipped() // Ensure nothing goes outside bounds
            }
            .frame(width: 240, height: 180) // Match container size exactly
            .clipped() // Additional clipping to ensure containment
        }
        .frame(width: 280, height: 280) // Overall component size
        .onAppear {
            startCollectionAnimation()
        }
    }
    
    private func startCollectionAnimation() {
        // Show container first
        withAnimation(.easeInOut(duration: 0.5)) {
            containerOpacity = 1.0
        }
        
        // Show title
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
        }
        
        // Add items one by one with physics-based animation
        for i in 0..<specimens.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4 + 0.8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    visibleItems[i] = true
                    itemScales[i] = 1.0
                }
                
                // Add satisfying bounce effect
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        itemScales[i] = 1.2
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        itemScales[i] = 1.0
                    }
                }
            }
        }
        
        // Reset and repeat animation
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            resetAndRestart()
        }
    }
    
    private func resetAndRestart() {
        // Hide all items
        for i in 0..<visibleItems.count {
            visibleItems[i] = false
            itemScales[i] = 0.0
        }
        
        // Restart after brief pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for i in 0..<specimens.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        visibleItems[i] = true
                        itemScales[i] = 1.0
                    }
                }
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
        case purple, pink, black, yellow, green, brown
        
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
            }
        }
    }
    
    enum SpecimenShape {
        case crystal, rounded, sharp, banded, smooth
    }
}

// MARK: - Collection Rock Item

struct CollectionRockItem: View {
    let specimen: RockSpecimenData
    @State private var isHovered = false
    
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
        }
    }
    
    @ViewBuilder
    private func createRockStroke() -> some View {
        let strokeColor = Color.white.opacity(0.3)
        let strokeWidth: CGFloat = 0.5
        
        switch specimen.shape {
        case .crystal:
            CrystalRockShape()
                .stroke(strokeColor, lineWidth: strokeWidth)
        case .rounded:
            RoundedRockShape()
                .stroke(strokeColor, lineWidth: strokeWidth)
        case .sharp:
            SharpRockShape()
                .stroke(strokeColor, lineWidth: strokeWidth)
        case .banded:
            BandedRockShape()
                .stroke(strokeColor, lineWidth: strokeWidth)
        case .smooth:
            SmoothRockShape()
                .stroke(strokeColor, lineWidth: strokeWidth)
        }
    }
    
    var body: some View {
        ZStack {
            // Rock shape with gradient fill
            createRockShape()
                .overlay(
                    // Rock surface details
                    RockSurfaceOverlay(specimen: specimen)
                )
                .overlay(
                    // Realistic rock highlights
                    createRockStroke()
                )
                .frame(width: 50, height: 40) // Constrained size to fit in grid
            
            // Specimen label
            VStack {
                Spacer()
                Text(specimen.name)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.6))
                    )
                    .offset(y: 8)
            }
        }
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Rock Shapes

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

// MARK: - Rock Surface Overlay

struct RockSurfaceOverlay: View {
    let specimen: RockSpecimenData
    
    var body: some View {
        ZStack {
            switch specimen.shape {
            case .crystal:
                // Crystal facet lines
                Path { path in
                    path.move(to: CGPoint(x: 10, y: 5))
                    path.addLine(to: CGPoint(x: 40, y: 15))
                    path.move(to: CGPoint(x: 20, y: 25))
                    path.addLine(to: CGPoint(x: 35, y: 35))
                }
                .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                
            case .banded:
                // Sedimentary layers
                ForEach(0..<3, id: \.self) { index in
                    Rectangle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 35, height: 1)
                        .offset(y: CGFloat(index * 8 - 8))
                }
                
            case .sharp:
                // Sharp edges highlight
                Path { path in
                    path.move(to: CGPoint(x: 15, y: 10))
                    path.addLine(to: CGPoint(x: 25, y: 5))
                    path.addLine(to: CGPoint(x: 35, y: 12))
                }
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                
            default:
                // General surface texture
                ForEach(0..<2, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 3, height: 3)
                        .offset(
                            x: CGFloat.random(in: -15...15),
                            y: CGFloat.random(in: -10...10)
                        )
                }
            }
        }
    }
}
