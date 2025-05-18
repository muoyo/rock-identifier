// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import RevenueCat

@main
struct RockIdentifierApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboarding = false
    @State private var showSplash = true
    
    // Initialize the subscription manager as a StateObject so it persists across the app
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    init() {
        // Configure RevenueCat with enhanced settings
        RevenueCatConfig.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content view with subscription manager passed as environment object
                ContentView()
                    .environmentObject(subscriptionManager)
                
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
