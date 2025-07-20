// Rock Identifier: Stone Scan
// Muoyo Okome
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var showRestoreAlert = false
    @State private var restoreAlertMessage = ""
    @State private var isLoadingLifetime = false
    @State private var showLifetimeAlert = false
    @State private var lifetimeAlertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Text("Subscription Status")
                        Spacer()
                        Text(subscriptionManager.status.isActive ? "Premium" : "Free")
                            .foregroundColor(subscriptionManager.status.isActive ? .green : .orange)
                            .fontWeight(.medium)
                    }
                    
                    if !subscriptionManager.status.isActive {
                        HStack {
                            Text("Remaining Identifications")
                            Spacer()
                            Text("\(subscriptionManager.remainingIdentifications)")
                                .fontWeight(.medium)
                        }
                        
                        Button("Upgrade to Premium") {
                            // Dismiss settings first, then show paywall
                            isPresented = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                PaywallManager.shared.showSoftPaywall()
                            }
                        }
                        .foregroundColor(.blue)
                        
                        Button(isLoadingLifetime ? "Processing..." : "Get Lifetime Access") {
                            purchaseLifetime()
                        }
                        .foregroundColor(.blue)
                        .disabled(isLoadingLifetime)
                    }
                    
                    if subscriptionManager.status.isActive {
                        Button("Manage Subscription") {
                            // Open subscription management in Settings app
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // Always show restore button for both free and premium users
                    Button("Restore Purchases") {
                        // Restore purchases
                        subscriptionManager.restorePurchases { success, error in
                            DispatchQueue.main.async {
                                if success && subscriptionManager.status.isActive {
                                    // Successfully restored
                                    print("Settings: Successfully restored subscription")
                                    restoreAlertMessage = "Your subscription has been successfully restored!"
                                    showRestoreAlert = true
                                } else if let error = error {
                                    print("Settings: Restore error: \(error.localizedDescription)")
                                    restoreAlertMessage = "Restore failed: \(error.localizedDescription)"
                                    showRestoreAlert = true
                                } else if success && !subscriptionManager.status.isActive {
                                    restoreAlertMessage = "No active subscriptions found. If you previously purchased a subscription, make sure you're signed in with the correct Apple ID."
                                    showRestoreAlert = true
                                }
                            }
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("App")) {
                    HStack {
                        Text("Rock Identifier")
                        Spacer()
                        Text("Stone Scan")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Support")) {
                    Button(action: {
                        // Open email app for support
                        if let url = URL(string: "mailto:support@appmagic.co?subject=Rock%20Identifier%20Support") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Contact Support")
                            Spacer()
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button(action: {
                        // Open App Store for review
                        if let url = URL(string: "https://apps.apple.com/app/id6745438668?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Rate the App")
                            Spacer()
                            Image(systemName: "star")
                                .foregroundColor(.blue)
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
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
            .alert(isPresented: $showRestoreAlert) {
                Alert(
                    title: Text("Restore Purchases"),
                    message: Text(restoreAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showLifetimeAlert) {
                Alert(
                    title: Text("Lifetime Purchase"),
                    message: Text(lifetimeAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func purchaseLifetime() {
        isLoadingLifetime = true
        
        subscriptionManager.purchaseLifetime { success, error in
            DispatchQueue.main.async {
                isLoadingLifetime = false
                
                if success {
                    lifetimeAlertMessage = "Lifetime access purchased successfully! You now have unlimited access to all premium features."
                    showLifetimeAlert = true
                } else if let error = error {
                    if let nsError = error as NSError?, nsError.code == 1009 {
                        // User cancelled - do nothing
                    } else {
                        lifetimeAlertMessage = "Lifetime purchase failed: \(error.localizedDescription)"
                        showLifetimeAlert = true
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
            .environmentObject(SubscriptionManager())
    }
}
