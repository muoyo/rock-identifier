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
    
    // Observe AppState for paywall presentation
    @ObservedObject private var appState = AppState.shared
    
    init() {
        // Configure RevenueCat
        RevenueCatConfig.configure()
        
        // Note: Entitlement mapping should be configured in the RevenueCat dashboard
        // rather than in code, as the API has likely changed in the current SDK version
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
            .onAppear {
                print("RockIdentifierApp: onAppear called")
                
                // Initialize FreeTierManager with subscription manager
                FreeTierManager.shared.setSubscriptionManager(subscriptionManager)
                
                // Show the hard paywall immediately if needed (only if onboarding completed)
                if hasCompletedOnboarding {
                    print("RockIdentifierApp: Onboarding completed, checking for hard paywall")
                    let showedHardPaywall = PaywallManager.shared.showHardPaywallIfNeeded()
                    PaywallManager.shared.logState()
                    
                    // If hard paywall wasn't shown, check if we should show soft paywall
                    // based on remaining identifications
                    if !showedHardPaywall && subscriptionManager.remainingIdentifications <= 0 {
                        print("RockIdentifierApp: No identifications remaining, showing soft paywall on launch")
                        PaywallManager.shared.showSoftPaywall()
                    }
                } else {
                    print("RockIdentifierApp: Onboarding not completed yet, skipping paywall check")
                }
            }
            .sheet(isPresented: $showOnboarding, onDismiss: {
                hasCompletedOnboarding = true
                // Check if we should show paywall after onboarding
                print("RockIdentifierApp: Onboarding dismissed, checking for hard paywall")
                let showedHardPaywall = PaywallManager.shared.showHardPaywallIfNeeded()
                PaywallManager.shared.logState()
                
                // If hard paywall wasn't shown, check if we should show soft paywall
                // based on remaining identifications
                if !showedHardPaywall && subscriptionManager.remainingIdentifications <= 0 {
                    print("RockIdentifierApp: No identifications remaining, showing soft paywall after onboarding")
                    PaywallManager.shared.showSoftPaywall()
                }
            }) {
                OnboardingView(isPresented: $showOnboarding)
            }
            // Soft paywall sheet (can be dismissed)
            .sheet(isPresented: $appState.showSoftPaywall) {
                PaywallView(isDismissable: true)
                    .environmentObject(subscriptionManager)
            }
            // Hard paywall sheet (cannot be dismissed)
            .sheet(isPresented: $appState.showHardPaywall) {
                PaywallView(isDismissable: false)
                    .environmentObject(subscriptionManager)
            }
        }
    }
}
