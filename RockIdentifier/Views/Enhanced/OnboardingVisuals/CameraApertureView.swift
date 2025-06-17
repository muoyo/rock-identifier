//
// CameraApertureView.swift
// Rock Identifier: Crystal ID
//
// Professional camera aperture interface for onboarding
// Muoyo Okome
//

import SwiftUI
import Foundation

struct CameraApertureView: View {
    @State private var apertureScale: CGFloat = 1.0
    @State private var focusRingScales: [CGFloat] = [1.0, 1.0, 1.0]
    @State private var focusRingOpacities: [Double] = [0.8, 0.6, 0.4]
    @State private var scanLinePosition: CGFloat = -100
    @State private var statusLightOpacity: Double = 0.3
    @State private var viewfinderOpacity: Double = 0.8
    @State private var readyIndicatorScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Camera viewfinder background - more solid and less translucent
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.95),
                            Color.black.opacity(0.85),
                            Color.black.opacity(0.95)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.6),
                                    Color.gray.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
            
            // Viewfinder grid lines
            ViewfinderGrid()
                .opacity(0.4)
            
            // Main camera aperture with realistic blade count
            ZStack {
                // Aperture blades creating realistic camera opening (6 blades instead of 8)
                ForEach(0..<6, id: \.self) { index in
                    ApertureBlade(index: index, scale: apertureScale)
                }
                
                // Center opening
                Circle()
                    .fill(Color.black)
                    .frame(width: 35 * apertureScale, height: 35 * apertureScale)
                
                // Aperture reflection
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.15),
                                Color.clear
                            ]),
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 18
                        )
                    )
                    .frame(width: 35 * apertureScale, height: 35 * apertureScale)
            }
            .scaleEffect(1.5)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: apertureScale)
            
            // Focus rings expanding outward
            ForEach(0..<focusRingScales.count, id: \.self) { index in
                Circle()
                    .stroke(
                        Color.cyan.opacity(focusRingOpacities[index]),
                        lineWidth: 2
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(focusRingScales[index])
                    .animation(
                        .easeOut(duration: 2.0)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.5),
                        value: focusRingScales[index]
                    )
            }
            
            // Scanning lines for active detection feel
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.green.opacity(0.8),
                            Color.green.opacity(0.4),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 180, height: 3)
                .offset(y: scanLinePosition)
                .animation(.linear(duration: 2.0).repeatForever(autoreverses: true), value: scanLinePosition)
            
            // Camera UI elements
            VStack {
                // Top UI bar
                HStack {
                    // Flash indicator
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.slash")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text("AUTO")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    // Status light
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .opacity(statusLightOpacity)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: statusLightOpacity)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                Spacer()
                
                // Bottom UI bar
                HStack {
                    // Focus mode
                    Text("AF")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    // Ready indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                            .scaleEffect(readyIndicatorScale)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: readyIndicatorScale)
                        
                        Text("READY")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    // Exposure info
                    Text("1/60")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(6)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .frame(width: 200, height: 160)
            
            // Professional camera housing
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.8),
                            Color.black.opacity(0.4),
                            Color.gray.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 220, height: 180)
            
            // Lens mount indicators
            ForEach(0..<4, id: \.self) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 2, height: 8)
                    .offset(y: -95)
                    .rotationEffect(.degrees(Double(index * 90)))
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            startCameraAnimation()
        }
    }
    
    private func startCameraAnimation() {
        // Aperture breathing effect
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            apertureScale = 1.3
        }
        
        // Focus rings expansion
        for i in 0..<focusRingScales.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                    focusRingScales[i] = 2.0
                    focusRingOpacities[i] = 0.0
                }
            }
        }
        
        // Reset focus rings periodically
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            for i in 0..<focusRingScales.count {
                focusRingScales[i] = 1.0
                focusRingOpacities[i] = [0.8, 0.6, 0.4][i]
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                    withAnimation(.easeOut(duration: 2.0)) {
                        focusRingScales[i] = 2.0
                        focusRingOpacities[i] = 0.0
                    }
                }
            }
        }
        
        // Scanning line movement
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
            scanLinePosition = 100
        }
        
        // Status light pulsing
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            statusLightOpacity = 1.0
        }
        
        // Ready indicator pulsing
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            readyIndicatorScale = 1.2
        }
        
        // Removed viewfinder breathing for more stable appearance
        // withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
        //     viewfinderOpacity = 1.0
        // }
    }
}

// MARK: - Aperture Blade

struct ApertureBlade: View {
    let index: Int
    let scale: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.8),
                        Color.black.opacity(0.6),
                        Color.gray.opacity(0.4)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 25, height: 8)
            .offset(y: -30 + (10 * scale)) // Blades close/open with scale
            .rotationEffect(.degrees(Double(index * 60))) // 60 degrees for 6 blades
    }
}

// MARK: - Viewfinder Grid

struct ViewfinderGrid: View {
    var body: some View {
        ZStack {
            // Rule of thirds grid
            Path { path in
                let bounds = CGRect(x: -90, y: -70, width: 180, height: 140)
                
                // Vertical lines
                for i in 1..<3 {
                    let x = bounds.minX + bounds.width * CGFloat(i) / 3
                    path.move(to: CGPoint(x: x, y: bounds.minY))
                    path.addLine(to: CGPoint(x: x, y: bounds.maxY))
                }
                
                // Horizontal lines
                for i in 1..<3 {
                    let y = bounds.minY + bounds.height * CGFloat(i) / 3
                    path.move(to: CGPoint(x: bounds.minX, y: y))
                    path.addLine(to: CGPoint(x: bounds.maxX, y: y))
                }
            }
            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
            
            // Center focus point
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    .frame(width: 20, height: 20)
                
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 2, height: 2)
            }
            
            // Corner brackets
            ForEach(0..<4, id: \.self) { corner in
                CornerBracket()
                    .position(cornerPositions[corner])
            }
        }
    }
    
    private var cornerPositions: [CGPoint] {
        return [
            CGPoint(x: -75, y: -55), // Top left
            CGPoint(x: 75, y: -55),  // Top right
            CGPoint(x: -75, y: 55),  // Bottom left
            CGPoint(x: 75, y: 55)    // Bottom right
        ]
    }
}

// MARK: - Corner Bracket

struct CornerBracket: View {
    var body: some View {
        ZStack {
            // Horizontal line
            Rectangle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 15, height: 1)
                .offset(x: -7.5)
            
            // Vertical line
            Rectangle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 1, height: 15)
                .offset(y: -7.5)
        }
    }
}
