// Rock Identifier: Crystal ID - Camera Permission Modal (Overlay Version)
// Muoyo Okome
//

import SwiftUI
import AVFoundation

struct CameraPermissionModalView: View {
    @Binding var isPresented: Bool
    let onPermissionGranted: () -> Void
    
    @State private var showingPermissionDeniedAlert = false
    @State private var isRequestingPermission = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer() // Push modal to bottom
            
            VStack(spacing: 0) {
                // Compact top section
                VStack(spacing: 20) {
                    // Handle indicator
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray3))
                        .frame(width: 40, height: 6)
                        .padding(.top, 12)
                    
                    // Header - more compact
                    VStack(spacing: 12) {
                        // Camera icon - smaller
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("PrimaryBlue"),
                                            Color("SecondaryPurple")
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        // Title and description - more compact
                        VStack(spacing: 6) {
                            Text("Camera Access Required")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black) // Static color for light modal background
                            
                            Text("Enable camera access to start identifying rocks")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.gray) // Static color for light modal background
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Remove mock camera preview since real camera is visible behind
                    // Remove features preview to save space - users can see the real interface
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                // Bottom section with buttons - more compact
                VStack(spacing: 12) {
                    // Main action button
                    Button(action: {
                        requestCameraPermission()
                    }) {
                        HStack {
                            if isRequestingPermission {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "camera")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            
                            Text(isRequestingPermission ? "Requesting Access..." : "Continue")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("AccentGreen"),
                                    Color("EmeraldGreen")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(isRequestingPermission)
                    .buttonStyle(ModalButtonStyle())
                    
                    // Privacy note
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("Photos are processed securely and not stored")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Remove "Maybe Later" button since permission is required
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30) // Reduced bottom padding
            }
            .background(
                // Direct alpha value instead of layered transparency
                Color(red: 1, green: 1, blue: 1, opacity: 0.97)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.2), radius: 20, x: 0, y: -5)
            .padding(.horizontal, 12) // Slightly larger side margins
        }
        .alert("Camera Access Required", isPresented: $showingPermissionDeniedAlert) {
            Button("Settings") {
                PermissionManager.shared.openSettings()
            }
            Button("Not Now", role: .cancel) { }
        } message: {
            Text("Rock Identifier needs camera access to identify rocks and minerals. You can enable this in Settings.")
        }
    }
    
    private func requestCameraPermission() {
        isRequestingPermission = true
        HapticManager.shared.mediumImpact()
        
        PermissionManager.shared.requestCameraPermission { granted in
            DispatchQueue.main.async {
                self.isRequestingPermission = false
                
                if granted {
                    // Permission granted - proceed to main app
                    HapticManager.shared.successFeedback()
                    withAnimation(.easeInOut(duration: 0.4)) {
                        self.isPresented = false
                    }
                    // Small delay to let animation complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.onPermissionGranted()
                    }
                } else {
                    // Permission denied - show alert
                    HapticManager.shared.errorFeedback()
                    self.showingPermissionDeniedAlert = true
                }
            }
        }
    }
}

// Simplified grid preview for modal
struct RockPositioningGridPreview: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Simple cross in center
        let centerX = rect.width / 2
        let centerY = rect.height / 2
        
        // Horizontal line
        path.move(to: CGPoint(x: centerX - 15, y: centerY))
        path.addLine(to: CGPoint(x: centerX + 15, y: centerY))
        
        // Vertical line
        path.move(to: CGPoint(x: centerX, y: centerY - 15))
        path.addLine(to: CGPoint(x: centerX, y: centerY + 15))
        
        // Corner brackets
        let bracketSize: CGFloat = 12
        
        // Top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + bracketSize))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + bracketSize, y: rect.minY))
        
        // Top-right
        path.move(to: CGPoint(x: rect.maxX - bracketSize, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + bracketSize))
        
        // Bottom-left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - bracketSize))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + bracketSize, y: rect.maxY))
        
        // Bottom-right
        path.move(to: CGPoint(x: rect.maxX - bracketSize, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bracketSize))
        
        return path
    }
}

// Compact feature preview for modal
struct ModalFeaturePreview: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Button style for modal
struct ModalButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
