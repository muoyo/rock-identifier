// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

@main
struct RockIdentifierApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboarding = false
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content view
                ContentView()
                
                // Show splash screen
                if showSplash {
                    SplashView(onComplete: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showSplash = false
                            // Show onboarding if needed after splash
                            if !hasCompletedOnboarding {
                                showOnboarding = true
                            }
                        }
                    })
                    .transition(.opacity)
                    .zIndex(2)
                }
                
                // Layer for onboarding transition
                if !hasCompletedOnboarding && !showSplash {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .zIndex(1)
                }
            }
            .sheet(isPresented: $showOnboarding, onDismiss: {
                hasCompletedOnboarding = true
            }) {
                OnboardingView(isPresented: $showOnboarding)
            }
        }
    }
}
