// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

@main
struct RockIdentifierApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                
                // Show onboarding if user hasn't completed it
                if !hasCompletedOnboarding {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .onAppear {
                            showOnboarding = true
                        }
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
