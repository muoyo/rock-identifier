//
// AIScanningView.swift
// Rock Identifier: Crystal ID
//
// AI scanning animation with realistic rock specimen
// Muoyo Okome
//

import SwiftUI
import Foundation

struct AIScanningView: View {
    @State private var scanProgress: CGFloat = 0.0
    @State private var dataPointsVisible: [Bool] = Array(repeating: false, count: 6)
    @State private var analysisProgress: [CGFloat] = Array(repeating: 0.0, count: 4)
    @State private var scanLinePosition: CGFloat = 0.0
    @State private var pulseOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            // Background scanning grid
            ScanningGrid()
                .opacity(0.3)
            
            // Main rock specimen being analyzed
            ZStack {
                // Rock shadow
                RockSpecimen()
                    .fill(Color.black.opacity(0.2))
                    .offset(x: 3, y: 8)
                    .blur(radius: 4)
                
                // Main rock with realistic geology
                RockSpecimen()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "8B7355"), // Light brown
                                Color(hex: "6B5B73"), // Medium purple-brown
                                Color(hex: "4A4458"), // Dark purple-gray
                                Color(hex: "2D2E3F")  // Very dark base
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Rock surface details and mineral veins
                        RockSurfaceDetails()
                    )
                    .overlay(
                        // Scanning overlay effects
                        RockSpecimen()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.cyan.opacity(0.8),
                                        Color.blue.opacity(0.6),
                                        Color.clear
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 2
                            )
                            .opacity(pulseOpacity)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseOpacity)
                    )
            }
            .scaleEffect(1.2)
            
            // Scanning beam that moves across the rock
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.cyan.opacity(0.8),
                            Color.blue.opacity(0.6),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 4, height: 200)
                .offset(x: scanLinePosition)
                .animation(.linear(duration: 2.0).repeatForever(autoreverses: true), value: scanLinePosition)
            
            // AI Analysis data points floating around rock
            ForEach(0..<dataPointsVisible.count, id: \.self) { index in
                if dataPointsVisible[index] {
                    AnalysisDataPoint(type: DataPointType.allCases[index])
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Analysis progress indicators at bottom
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    ForEach(0..<analysisProgress.count, id: \.self) { index in
                        AnalysisProgressBar(
                            progress: analysisProgress[index],
                            color: progressColors[index],
                            label: progressLabels[index]
                        )
                    }
                }
                .padding(.bottom, 20)
            }
            
            // Scanning progress arc
            Circle()
                .trim(from: 0, to: scanProgress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.cyan,
                            Color.blue,
                            Color.purple
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: false), value: scanProgress)
        }
        .frame(width: 280, height: 280)
        .onAppear {
            startScanningAnimation()
        }
    }
    
    private let progressColors: [Color] = [
        Color.cyan,
        Color.blue,
        Color.purple,
        Color.green
    ]
    
    private let progressLabels: [String] = [
        "Composition",
        "Structure", 
        "Formation",
        "Classification"
    ]
    
    private func startScanningAnimation() {
        // Start scanning line movement
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
            scanLinePosition = 80
        }
        
        // Start progress scanning
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: false)) {
            scanProgress = 1.0
        }
        
        // Start pulsing
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseOpacity = 0.8
        }
        
        // Animate data points appearing
        for i in 0..<dataPointsVisible.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    dataPointsVisible[i] = true
                }
            }
        }
        
        // Animate analysis progress bars
        for i in 0..<analysisProgress.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.8) {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    analysisProgress[i] = 1.0
                }
            }
        }
        
        // Reset and repeat data points
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            // Hide all data points
            for i in 0..<dataPointsVisible.count {
                dataPointsVisible[i] = false
            }
            
            // Show them again with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                for i in 0..<dataPointsVisible.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                        withAnimation(.spring()) {
                            dataPointsVisible[i] = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Rock Specimen Shape

struct RockSpecimen: Shape {
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

// MARK: - Rock Surface Details

struct RockSurfaceDetails: View {
    var body: some View {
        ZStack {
            // Mineral veins
            Path { path in
                path.move(to: CGPoint(x: 20, y: 40))
                path.addCurve(
                    to: CGPoint(x: 80, y: 70),
                    control1: CGPoint(x: 40, y: 45),
                    control2: CGPoint(x: 60, y: 65)
                )
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FFD700").opacity(0.8), // Gold
                        Color(hex: "FFA500").opacity(0.6)  // Orange
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 2
            )
            
            // Secondary mineral vein
            Path { path in
                path.move(to: CGPoint(x: 10, y: 60))
                path.addCurve(
                    to: CGPoint(x: 60, y: 90),
                    control1: CGPoint(x: 30, y: 70),
                    control2: CGPoint(x: 45, y: 85)
                )
            }
            .stroke(Color(hex: "C0C0C0").opacity(0.7), lineWidth: 1.5) // Silver
            
            // Crystal inclusions
            ForEach(0..<4, id: \.self) { index in
                let positions: [CGPoint] = [
                    CGPoint(x: 25, y: 35),
                    CGPoint(x: 65, y: 25),
                    CGPoint(x: 45, y: 75),
                    CGPoint(x: 75, y: 55)
                ]
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "E6E6FA"), // Lavender
                                Color(hex: "DDA0DD"), // Plum
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 4
                        )
                    )
                    .frame(width: 6, height: 6)
                    .position(positions[index])
            }
            
            // Surface texture lines (sedimentary layers)
            ForEach(0..<3, id: \.self) { index in
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 60, height: 0.5)
                    .offset(x: CGFloat(index * 5), y: CGFloat(index * 15 + 10))
                    .rotationEffect(.degrees(Double(index * 5 - 10)))
            }
        }
    }
}

// MARK: - Scanning Grid

struct ScanningGrid: View {
    var body: some View {
        Path { path in
            let spacing: CGFloat = 20
            let bounds = CGRect(x: -140, y: -140, width: 280, height: 280)
            
            // Vertical lines
            for x in stride(from: bounds.minX, through: bounds.maxX, by: spacing) {
                path.move(to: CGPoint(x: x, y: bounds.minY))
                path.addLine(to: CGPoint(x: x, y: bounds.maxY))
            }
            
            // Horizontal lines
            for y in stride(from: bounds.minY, through: bounds.maxY, by: spacing) {
                path.move(to: CGPoint(x: bounds.minX, y: y))
                path.addLine(to: CGPoint(x: bounds.maxX, y: y))
            }
        }
        .stroke(Color.cyan.opacity(0.3), lineWidth: 0.5)
    }
}

// MARK: - Analysis Data Points

enum DataPointType: CaseIterable {
    case composition, hardness, density, structure, formation, classification
    
    var info: (icon: String, label: String, color: Color) {
        switch self {
        case .composition:
            return ("atom", "SiO₂ 60%", .cyan)
        case .hardness:
            return ("hammer", "Hardness: 7", .blue)
        case .density:
            return ("scalemass", "2.65 g/cm³", .purple)
        case .structure:
            return ("grid", "Crystalline", .green)
        case .formation:
            return ("thermometer", "Igneous", .orange)
        case .classification:
            return ("tag", "Quartz", .red)
        }
    }
    
    var position: CGPoint {
        let positions: [CGPoint] = [
            CGPoint(x: -80, y: -60),  // composition
            CGPoint(x: 80, y: -40),   // hardness
            CGPoint(x: -70, y: 50),   // density
            CGPoint(x: 85, y: 30),    // structure
            CGPoint(x: -60, y: 10),   // formation
            CGPoint(x: 70, y: -70)    // classification
        ]
        return positions[DataPointType.allCases.firstIndex(of: self) ?? 0]
    }
}

struct AnalysisDataPoint: View {
    let type: DataPointType
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: type.info.icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(type.info.color)
            
            Text(type.info.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(type.info.color.opacity(0.6), lineWidth: 1)
                )
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .position(type.position)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                opacity = 1.0
                scale = 1.0
            }
        }
    }
}

// MARK: - Analysis Progress Bar

struct AnalysisProgressBar: View {
    let progress: CGFloat
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 50, height: 4)
                .overlay(
                    HStack {
                        Rectangle()
                            .fill(color)
                            .frame(width: 50 * progress, height: 4)
                        Spacer(minLength: 0)
                    }
                )
                .cornerRadius(2)
            
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
