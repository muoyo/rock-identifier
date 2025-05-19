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
        }
    }
}
