// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

struct DeveloperSettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var subscriptionManager: SubscriptionManager
    
    @State private var showActionConfirmation = false
    @State private var lastAction = ""
    @State private var showPaywall = false
    @State private var isHardPaywall = false
    @State private var showAnimationDemo = false
    @State private var showStylingComparison = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Developer Tools")) {
                    HStack {
                        Text("Developer Mode")
                        Spacer()
                        Text("Enabled")
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                }
                
                Section(header: Text("UI Testing")) {
                    Button(action: {
                        showStylingComparison = true
                    }) {
                        HStack {
                            Text("Icon Styling Comparison")
                            Spacer()
                            Image(systemName: "paintbrush.pointed.fill")
                                .foregroundColor(.purple)
                        }
                    }
                    
                    Text("Compare colorful vs grey icon styling approaches")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading)
                }
                Section(header: Text("Paywall Testing")) {
                    Button(action: {
                        // Show PaywallView with dismissable paywall
                        isHardPaywall = false
                        showPaywall = true
                    }) {
                        HStack {
                            Text("Show Soft Paywall")
                            Spacer()
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Button(action: {
                        // Set isDismissable to false to test hard paywall
                        isHardPaywall = true
                        showPaywall = true
                    }) {
                        HStack {
                            Text("Show Hard Paywall")
                            Spacer()
                            Image(systemName: "lock.circle")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: {
                        // Reset version tracking to simulate first launch
                        PaywallManager.shared.resetVersionForTesting()
                        PaywallManager.shared.logState()
                        lastAction = "Version tracking reset!"
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Reset Version Tracking")
                            Spacer()
                            Image(systemName: "arrow.triangle.2.circlepath.circle")
                                .foregroundColor(.purple)
                        }
                    }
                    
                    Button(action: {
                        // Show hard paywall if needed
                        let shown = PaywallManager.shared.showHardPaywallIfNeeded()
                        PaywallManager.shared.logState()
                        lastAction = shown ? "Hard paywall shown!" : "Hard paywall not shown (already shown for this version)"
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Trigger Hard Paywall Check")
                            Spacer()
                            Image(systemName: "exclamationmark.shield.fill")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Section(header: Text("Identification Limits")) {
                    HStack {
                        Text("Remaining Identifications")
                        Spacer()
                        Text("\(subscriptionManager.remainingIdentifications)")
                            .fontWeight(.medium)
                    }
                    
                    Button(action: {
                        // Always allow action in developer settings
                        subscriptionManager.identificationCounter.resetCounter()
                        subscriptionManager.objectWillChange.send() // Force UI updates
                        lastAction = "Identification count reset!"
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Reset Identification Count")
                            Spacer()
                            Image(systemName: "arrow.counterclockwise.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Subscription Testing")) {
                    Button(action: {
                        subscriptionManager.debugSubscriptionState()
                        lastAction = "Subscription debug info logged to console (check Xcode console)"
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Debug Subscription State")
                            Spacer()
                            Image(systemName: "ant.circle")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Button(action: {
                        subscriptionManager.resetToFree()
                        lastAction = "Reset to Free tier"
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Reset to Free Tier")
                            Spacer()
                            Image(systemName: "person")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Button(action: {
                        subscriptionManager.setMockPremium(plan: .weekly)
                        lastAction = "Set to Premium (Weekly)"
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Set to Premium (Weekly)")
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button(action: {
                        subscriptionManager.setMockPremium(plan: .yearly)
                        lastAction = "Set to Premium (Yearly)"
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Set to Premium (Yearly)")
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.purple)
                        }
                    }
                }
                
                Section(header: Text("First-Time Experience Testing")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Current Status")
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(UserDefaults.standard.bool(forKey: "has_identified_rock_before") ? "Experienced User" : "First-Time User")
                                    .fontWeight(.medium)
                                    .foregroundColor(UserDefaults.standard.bool(forKey: "has_identified_rock_before") ? .blue : .green)
                                
                                Text(ReviewPromptManager.shared.shouldShowReviewPrompt() ? "Review Prompt Ready" : "Review Prompt Shown")
                                    .font(.caption2)
                                    .foregroundColor(ReviewPromptManager.shared.shouldShowReviewPrompt() ? .green : .orange)
                            }
                        }
                        
                        Text(UserDefaults.standard.bool(forKey: "has_identified_rock_before") ? "Next identification will use regular animation" : "Next identification will trigger first-time celebration → review prompt!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "has_identified_rock_before")
                        ReviewPromptManager.shared.resetForTesting() // Also reset review prompt!
                        lastAction = "Reset to First-Time User! This also resets the review prompt so you can test the complete flow: Enhanced celebration → User dismisses → Review prompt appears."
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Reset to First-Time User")
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "has_identified_rock_before")
                        lastAction = "Set as Experienced User! Next identification will use regular (still excellent) animation."
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Set as Experienced User")
                            Spacer()
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("First-Time Enhancements:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text("• 60% more sparkles (120 vs 75)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Larger sparkle sizes (30% bigger)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Shooting stars across screen")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Celebration burst at rock name")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Enhanced 4-stage haptic sequence")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Personal congratulations message")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• 40% longer celebration duration")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Review prompt after celebration")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    
                    Button(action: {
                        ReviewPromptManager.shared.resetForTesting()
                        lastAction = "Review prompt reset! Use this to test the review prompt separately, or after using 'Set as Experienced User'."
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Reset Review Prompt Only")
                            Spacer()
                            Image(systemName: "star.bubble")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text("Use 'Reset to First-Time User' for complete flow testing, or this button to test review prompt independently.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading)
                        .padding(.top, 2)
                }
                
                Section(header: Text("Result Animation Testing")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Animation Timing Profile")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Picker("Timing Profile", selection: Binding(
                            get: { ResultRevealAnimations.currentProfile },
                            set: { newProfile in
                                ResultRevealAnimations.currentProfile = newProfile
                                lastAction = "Changed animation profile to \(newProfile.rawValue)"
                                showActionConfirmation = true
                            }
                        )) {
                            ForEach(ResultRevealAnimations.TimingProfile.allCases, id: \.self) { profile in
                                Text(profile.rawValue).tag(profile)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text("Test different timing profiles for the A-HA moment reveal animation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        let profile = ResultRevealAnimations.currentProfile
                        let timing = profile.config
                        lastAction = """
                        Current Profile: \(profile.rawValue)
                        Total Duration: \(String(format: "%.1f", timing.actionsStartTime + 0.5))s
                        Dramatic Pause: \(String(format: "%.1f", timing.dramaticPause))s
                        Name Focus: \(String(format: "%.1f", timing.nameFocus))s
                        Sparkles: \(String(format: "%.1f", timing.sparklesDuration))s
                        """
                        showActionConfirmation = true
                    }) {
                        HStack {
                            Text("Show Timing Details")
                            Spacer()
                            Image(systemName: "timer")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button(action: {
                        showAnimationDemo = true
                    }) {
                        HStack {
                            Text("Preview Animation")
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Section(header: Text("Legal")) {
                    Button(action: {
                        if let url = URL(string: "https://appmagic.co/app/privacypolicy.html") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://apple.com/legal/internet-services/itunes/dev/stdeula") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Terms of Use")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("App Info")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Developer Settings")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
            .alert(isPresented: $showActionConfirmation) {
                Alert(
                    title: Text("Action Completed"),
                    message: Text(lastAction),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(isDismissable: !isHardPaywall)
                    .environmentObject(subscriptionManager)
            }
            .sheet(isPresented: $showAnimationDemo) {
                AnimationDemoView()
            }
            .sheet(isPresented: $showStylingComparison) {
                StylingComparisonView()
            }
        }
    }
}
