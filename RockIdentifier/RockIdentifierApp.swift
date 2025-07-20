// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import RevenueCat
import AVFoundation
import StoreKit

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
        // Configure audio session to allow mixing with other audio
        configureAudioSession()
        
        // Configure RevenueCat
        RevenueCatConfig.configure()
        
        // Note: Entitlement mapping should be configured in the RevenueCat dashboard
        // rather than in code, as the API has likely changed in the current SDK version
    }
    
    // MARK: - Helper Functions
    
    /// Check and show paywall after onboarding
    private func checkAndShowPaywall() {
        print("RockIdentifierApp: Checking for paywall after onboarding")
        let showedHardPaywall = PaywallManager.shared.showHardPaywallIfNeeded()
        PaywallManager.shared.logState()
        
        // If hard paywall wasn't shown, always show soft paywall after onboarding
        if !showedHardPaywall {
            print("RockIdentifierApp: No hard paywall shown, showing soft paywall after onboarding")
            PaywallManager.shared.showSoftPaywall()
        }
    }
    
    /// Request native iOS rating prompt
    private func requestNativeRating() {
        print("RockIdentifierApp: Requesting native iOS rating")
        
        // Brief delay to ensure paywall is fully dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                print("RockIdentifierApp: Native rating prompt requested")
            } else {
                print("RockIdentifierApp: Could not find active window scene for rating prompt")
            }
        }
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
                    
                    // If hard paywall wasn't shown, always show soft paywall on launch
                    if !showedHardPaywall {
                        print("RockIdentifierApp: No hard paywall shown, showing soft paywall on launch")
                        PaywallManager.shared.showSoftPaywall()
                    }
                } else {
                    print("RockIdentifierApp: Onboarding not completed yet, skipping paywall check")
                }
            }
            .sheet(isPresented: $showOnboarding, onDismiss: {
                hasCompletedOnboarding = true
                
                // Go directly to paywall after onboarding
                print("RockIdentifierApp: Onboarding completed, showing paywall")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    checkAndShowPaywall()
                }
            }) {
                DelightfulOnboardingView(isPresented: $showOnboarding)
            }
            // Soft paywall sheet (can be dismissed)
            .sheet(isPresented: $appState.showSoftPaywall, onDismiss: {
                // Show native iOS rating prompt after soft paywall dismissal
                requestNativeRating()
            }) {
                PaywallView(isDismissable: true)
                    .environmentObject(subscriptionManager)
            }
            // Hard paywall sheet (cannot be dismissed)
            .sheet(isPresented: $appState.showHardPaywall, onDismiss: {
                // Show native iOS rating prompt after hard paywall dismissal
                requestNativeRating()
            }) {
                PaywallView(isDismissable: false)
                    .environmentObject(subscriptionManager)
            }

        }
    }
    
    // MARK: - Audio Session Configuration
    
    /// Configures the audio session to allow mixing with other audio sources
    /// This prevents the app from interrupting background music/podcasts when using the camera
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Set the audio session category to allow mixing with other audio
            // .ambient allows the app to play alongside other audio
            // .mixWithOthers allows mixing with other apps' audio
            try audioSession.setCategory(.ambient, options: [.mixWithOthers])
            
            // Activate the audio session
            try audioSession.setActive(true)
            
            print("Audio session configured successfully - mixing with other audio enabled")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
}
