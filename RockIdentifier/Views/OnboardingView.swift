// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @State private var showPermissionAlert = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    let pages = [
        OnboardingPage(
            title: "Discover Your Rocks",
            description: "Identify any rock, mineral, crystal, or gemstone instantly with our AI-powered recognition technology.",
            imageName: "onboarding-discover"
        ),
        OnboardingPage(
            title: "Learn Fascinating Details",
            description: "Uncover the physical properties, chemical composition, formation history, and unique uses of your specimens.",
            imageName: "onboarding-details"
        ),
        OnboardingPage(
            title: "Build Your Collection",
            description: "Save your identified finds in your personal collection to track, organize, and revisit your discoveries.",
            imageName: "onboarding-collection"
        ),
        OnboardingPage(
            title: "Camera Access",
            description: "Rock Identifier needs camera access to analyze your specimens. We only use photos for identification and never store them without your permission.",
            imageName: "onboarding-camera"
        )
    ]
    
    // Gradient colors for more visual interest
    let gradientColors = [
        [Color(hex: "4568DC"), Color(hex: "B06AB3")], // Blue to Purple
        [Color(hex: "3A1C71"), Color(hex: "D76D77")], // Deep Purple to Pink
        [Color(hex: "0F2027"), Color(hex: "2C5364")], // Dark Blue to Teal
        [Color(hex: "5614B0"), Color(hex: "DBD65C")] // Purple to Yellow
    ]
    
    var body: some View {
        ZStack {
            // Dynamic gradient background based on page
            LinearGradient(
                gradient: Gradient(colors: gradientColors[currentPage]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background pattern to add visual interest
            GeometryPattern()
                .opacity(0.05)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    // Page indicator
                    PageIndicator(current: currentPage, total: pages.count)
                        .padding(.leading)
                    
                    Spacer()
                    
                    // Skip button
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.trailing)
                    }
                }
                .padding(.top, 20)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                .transition(.slide)
                
                // Bottom controls
                VStack(spacing: 15) {
                    // Next/Get Started button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            // Request camera permission on the last page
                            requestCameraPermission()
                        }
                    } label: {
                        HStack {
                            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            if currentPage < pages.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(gradientColors[currentPage][0])
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    
                    // Subtle hint for swiping
                    if currentPage < pages.count - 1 {
                        Text("Swipe to explore")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 8)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Camera Access Required"),
                message: Text("Rock Identifier needs camera access to analyze your specimens. Please enable camera access in Settings."),
                primaryButton: .default(Text("Settings")) {
                    PermissionManager.shared.openSettings()
                    completeOnboarding()
                },
                secondaryButton: .cancel {
                    completeOnboarding()
                }
            )
        }
    }
    
    // Function to request camera permissions
    private func requestCameraPermission() {
        PermissionManager.shared.requestCameraPermission { granted in
            if granted {
                // Permission granted
                completeOnboarding()
            } else {
                // Show alert if permission denied
                if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
                    showPermissionAlert = true
                } else {
                    completeOnboarding()
                }
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        isPresented = false
    }
}

// MARK: - Supporting Views

// Individual page view
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Image
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 280)
                .padding(.horizontal, 20)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}

// Page indicator dots
struct PageIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(current == index ? Color.white : Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .scaleEffect(current == index ? 1.2 : 1.0)
                    .animation(.spring(), value: current)
            }
        }
    }
}

// Background pattern to add visual depth
struct GeometryPattern: View {
    var body: some View {
        Canvas { context, size in
            // Draw geometric pattern
            for i in stride(from: 0, to: size.width, by: 80) {
                for j in stride(from: 0, to: size.height, by: 80) {
                    let path = Path { path in
                        let randomSize = CGFloat.random(in: 15...40)
                        let x = i + CGFloat.random(in: -10...10)
                        let y = j + CGFloat.random(in: -10...10)
                        
                        let shape = Int.random(in: 0...3)
                        switch shape {
                        case 0: // Square
                            path.addRect(CGRect(x: x, y: y, width: randomSize, height: randomSize))
                        case 1: // Circle
                            path.addEllipse(in: CGRect(x: x, y: y, width: randomSize, height: randomSize))
                        case 2: // Triangle
                            path.move(to: CGPoint(x: x, y: y))
                            path.addLine(to: CGPoint(x: x + randomSize, y: y))
                            path.addLine(to: CGPoint(x: x + randomSize/2, y: y - randomSize))
                            path.closeSubpath()
                        default: // Diamond
                            path.move(to: CGPoint(x: x, y: y + randomSize/2))
                            path.addLine(to: CGPoint(x: x + randomSize/2, y: y))
                            path.addLine(to: CGPoint(x: x + randomSize, y: y + randomSize/2))
                            path.addLine(to: CGPoint(x: x + randomSize/2, y: y + randomSize))
                            path.closeSubpath()
                        }
                    }
                    
                    context.stroke(path, with: .color(.white), lineWidth: 0.5)
                }
            }
        }
    }
}

// Onboarding page model
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

