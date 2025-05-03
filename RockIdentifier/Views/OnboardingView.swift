// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Discover Your Rocks",
            description: "Identify any rock, mineral, crystal, or gemstone instantly with our advanced AI technology.",
            imageName: "magnifyingglass"
        ),
        OnboardingPage(
            title: "Learn Fascinating Details",
            description: "Uncover the physical properties, chemical composition, and geological origins of your specimens.",
            imageName: "sparkles"
        ),
        OnboardingPage(
            title: "Build Your Collection",
            description: "Save your identified finds in your personal collection to track and organize your discoveries.",
            imageName: "square.grid.2x2"
        ),
        OnboardingPage(
            title: "Camera Access",
            description: "Rock Identifier needs camera access to analyze your specimens. We don't store your photos without permission.",
            imageName: "camera"
        )
    ]
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count) { index in
                        VStack(spacing: 30) {
                            // Icon
                            Image(systemName: pages[index].imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.white)
                            
                            // Title
                            Text(pages[index].title)
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            // Description
                            Text(pages[index].description)
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                Spacer()
                
                // Next/Get Started button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        if currentPage == pages.count - 1 {
                            // Request camera permission on the last page
                            requestCameraPermission()
                            isPresented = false
                        }
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(width: 250, height: 60)
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.bottom, 50)
                }
            }
        }
    }
    
    // Function to request camera permissions
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            // Permission handled by the camera view
        }
    }
}

// Onboarding page model
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

import AVFoundation
