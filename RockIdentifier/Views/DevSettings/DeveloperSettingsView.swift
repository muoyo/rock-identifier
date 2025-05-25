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
                
                // Future sections can be added here
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
