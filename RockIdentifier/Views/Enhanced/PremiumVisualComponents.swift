// Rock Identifier: Crystal ID - Premium SwiftUI Visual Components
// Enhanced visual elements to replace static SVG illustrations
// Muoyo Okome

import SwiftUI

// MARK: - Page 1: Floating Crystal with Light Refractions

struct FloatingCrystalView: View {
    @State private var rotationAngle: Double = 0
    @State private var floatOffset: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var sparkleOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Main crystal body with gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "A855F7").opacity(0.9),
                            Color(hex: "7C3AED").opacity(0.7),
                            Color(hex: "6366F1").opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 140)
                .overlay(
                    // Inner crystal facets
                    VStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { index in
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 2)
                                .offset(x: CGFloat(index % 2 == 0 ? -10 : 10))
                        }
                    }
                )
                .overlay(
                    // Crystal shine effect
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.clear,
                            Color.white.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 20)
                    )
                )
                .scaleEffect(pulseScale)
                .rotationEffect(.degrees(rotationAngle))
                .offset(y: floatOffset)
            
            // Sparkle effects around crystal
            ForEach(0..<6, id: \.self) { index in
                SparkleParticle(index: index)
                    .opacity(sparkleOpacity)
            }
            
            // Light refraction beams
            ForEach(0..<3, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.6),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 60, height: 2)
                    .offset(
                        x: 70,
                        y: CGFloat(-20 + (index * 20))
                    )
                    .rotationEffect(.degrees(Double(index * 15)))
                    .opacity(0.7)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Continuous rotation
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Floating motion
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            floatOffset = -15
        }
        
        // Gentle pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
        
        // Sparkle appearance
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            sparkleOpacity = 1.0
        }
    }
}

struct SparkleParticle: View {
    let index: Int
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(
                x: cos(Double(index) * .pi / 3) * 80,
                y: sin(Double(index) * .pi / 3) * 80
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(Double(index) * 0.2)) {
                    scale = 1.0
                }
                
                withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Page 2: AI Scanning Animation

struct AIScanningView: View {
    @State private var scanPosition: CGFloat = -100
    @State private var pulseOpacity: Double = 0.3
    @State private var dataPoints: [DataPoint] = []
    
    var body: some View {
        ZStack {
            // Crystal being scanned
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "10B981").opacity(0.8),
                            Color(hex: "059669").opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 120)
                .overlay(
                    // Crystal internal structure
                    VStack(spacing: 4) {
                        ForEach(0..<6, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                        }
                    }
                )
            
            // Scanning beam effect
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.8),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 4, height: 140)
                .offset(x: scanPosition)
                .opacity(pulseOpacity)
            
            // Data points appearing
            ForEach(dataPoints) { point in
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .position(point.position)
                    .opacity(point.opacity)
                    .scaleEffect(point.scale)
            }
            
            // Analysis result indicators
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 60, height: 12)
                        .overlay(
                            Rectangle()
                                .fill(Color(hex: "10B981"))
                                .frame(height: 8)
                                .cornerRadius(4)
                                .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.3), value: scanPosition)
                        )
                }
            }
            .offset(y: 100)
        }
        .onAppear {
            startScanningAnimation()
        }
    }
    
    private func startScanningAnimation() {
        // Scanning beam movement
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            scanPosition = 100
        }
        
        // Pulse effect
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseOpacity = 0.8
        }
        
        // Generate data points with delay instead of timer
        generateDataPointsSequence()
    }
    
    private func generateDataPointsSequence() {
        generateDataPoint()
        
        // Schedule next data point
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.generateDataPointsSequence()
        }
    }
    
    private func generateDataPoint() {
        let newPoint = DataPoint(
            position: CGPoint(
                x: CGFloat.random(in: -40...40),
                y: CGFloat.random(in: -50...50)
            )
        )
        
        dataPoints.append(newPoint)
        
        // Animate point appearance
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            if let index = dataPoints.firstIndex(where: { $0.id == newPoint.id }) {
                dataPoints[index].opacity = 1.0
                dataPoints[index].scale = 1.0
            }
        }
        
        // Remove point after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dataPoints.removeAll { $0.id == newPoint.id }
        }
    }
}

struct DataPoint: Identifiable {
    let id = UUID()
    let position: CGPoint
    var opacity: Double = 0.0
    var scale: CGFloat = 0.5
}

// MARK: - Page 3: Dynamic Collection Grid

struct DynamicCollectionView: View {
    @State private var collectionItems: [CollectionItem] = []
    @State private var showCollection = false
    
    let gridItems = [
        CollectionItem(color: Color(hex: "A855F7"), shape: .crystal, position: CGPoint(x: -60, y: -40)),
        CollectionItem(color: Color(hex: "10B981"), shape: .gem, position: CGPoint(x: 0, y: -40)),
        CollectionItem(color: Color(hex: "3B82F6"), shape: .stone, position: CGPoint(x: 60, y: -40)),
        CollectionItem(color: Color(hex: "F59E0B"), shape: .crystal, position: CGPoint(x: -60, y: 20)),
        CollectionItem(color: Color(hex: "EF4444"), shape: .gem, position: CGPoint(x: 0, y: 20)),
        CollectionItem(color: Color(hex: "8B5CF6"), shape: .stone, position: CGPoint(x: 60, y: 20))
    ]
    
    var body: some View {
        ZStack {
            // Collection container
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .frame(width: 200, height: 140)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            
            // Collection items
            ForEach(collectionItems) { item in
                CollectionItemShape(item: item)
                    .position(item.currentPosition)
                    .scaleEffect(item.scale)
                    .opacity(item.opacity)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: item.currentPosition)
            }
            
            // "My Collection" label
            Text("My Collection")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .offset(y: -85)
        }
        .onAppear {
            buildCollectionAnimation()
        }
    }
    
    private func buildCollectionAnimation() {
        // Start with empty collection
        collectionItems = gridItems.map { item in
            var newItem = item
            newItem.currentPosition = CGPoint(x: 0, y: -200) // Start from above
            newItem.opacity = 0.0
            newItem.scale = 0.5
            return newItem
        }
        
        // Animate items falling into place
        for (index, item) in gridItems.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    if let itemIndex = collectionItems.firstIndex(where: { $0.id == item.id }) {
                        collectionItems[itemIndex].currentPosition = item.position
                        collectionItems[itemIndex].opacity = 1.0
                        collectionItems[itemIndex].scale = 1.0
                    }
                }
            }
        }
    }
}

struct CollectionItem: Identifiable {
    let id = UUID()
    let color: Color
    let shape: Shape
    let position: CGPoint
    var currentPosition: CGPoint = .zero
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
    
    enum Shape {
        case crystal, gem, stone
    }
}

struct CollectionItemShape: View {
    let item: CollectionItem
    
    var body: some View {
        Group {
            switch item.shape {
            case .crystal:
                Diamond()
                    .fill(item.color)
                    .frame(width: 24, height: 24)
            case .gem:
                Circle()
                    .fill(item.color)
                    .frame(width: 20, height: 20)
            case .stone:
                RoundedRectangle(cornerRadius: 6)
                    .fill(item.color)
                    .frame(width: 22, height: 18)
            }
        }
        .overlay(
            // Shine effect
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.4),
                    Color.clear
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .mask(
                Group {
                    switch item.shape {
                    case .crystal:
                        Diamond()
                    case .gem:
                        Circle()
                    case .stone:
                        RoundedRectangle(cornerRadius: 6)
                    }
                }
            )
        )
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.move(to: CGPoint(x: center.x, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: center.y))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Page 4: Camera Aperture with Depth Effect

struct CameraApertureView: View {
    @State private var apertureScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.3
    @State private var focusRings: [FocusRing] = []
    @State private var scanLines: [CameraScanLine] = []
    
    var body: some View {
        ZStack {
            // Camera body
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .frame(width: 120, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            
            // Camera lens
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.9),
                            Color.gray.opacity(0.6),
                            Color.white.opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    // Aperture blades
                    ForEach(0..<8, id: \.self) { index in
                        Rectangle()
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 20, height: 3)
                            .offset(y: -8)
                            .rotationEffect(.degrees(Double(index * 45)))
                    }
                )
                .scaleEffect(apertureScale)
            
            // Focus rings
            ForEach(focusRings) { ring in
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: ring.size, height: ring.size)
                    .opacity(ring.opacity)
                    .scaleEffect(ring.scale)
            }
            
            // Scan lines
            ForEach(scanLines) { line in
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 80, height: 1)
                    .offset(y: line.yPosition)
                    .opacity(line.opacity)
            }
            
            // Ready indicator
            Circle()
                .fill(Color(hex: "10B981"))
                .frame(width: 12, height: 12)
                .offset(x: 45, y: -25)
                .opacity(pulseOpacity)
        }
        .onAppear {
            startCameraAnimation()
        }
    }
    
    private func startCameraAnimation() {
        // Aperture pulsing
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            apertureScale = 1.1
        }
        
        // Ready indicator pulsing
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseOpacity = 1.0
        }
        
        // Generate focus rings periodically
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
                self.generateFocusRing()
            }
        }
        
        // Generate scan lines periodically
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
                self.generateScanLine()
            }
        }
    }
    
    private func generateFocusRing() {
        let ring = FocusRing()
        focusRings.append(ring)
        
        withAnimation(.easeOut(duration: 2.0)) {
            if let index = focusRings.firstIndex(where: { $0.id == ring.id }) {
                focusRings[index].size = 120
                focusRings[index].opacity = 0.0
                focusRings[index].scale = 1.5
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            focusRings.removeAll { $0.id == ring.id }
        }
    }
    
    private func generateScanLine() {
        let line = CameraScanLine()
        scanLines.append(line)
        
        withAnimation(.linear(duration: 1.0)) {
            if let index = scanLines.firstIndex(where: { $0.id == line.id }) {
                scanLines[index].yPosition = 40
                scanLines[index].opacity = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            scanLines.removeAll { $0.id == line.id }
        }
    }
}

struct FocusRing: Identifiable {
    let id = UUID()
    var size: CGFloat = 70
    var opacity: Double = 0.8
    var scale: CGFloat = 1.0
}

struct CameraScanLine: Identifiable {
    let id = UUID()
    var yPosition: CGFloat = -40
    var opacity: Double = 0.8
}
