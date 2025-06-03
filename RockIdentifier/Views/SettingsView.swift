// Rock Identifier: Stone Scan
// Muoyo Okome
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
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
                            // Show paywall
                            PaywallManager.shared.showSoftPaywall()
                        }
                        .foregroundColor(.blue)
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
                        if let url = URL(string: "https://appmagic.co/apps/privacypolicy.html") {
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
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
            .environmentObject(SubscriptionManager())
    }
}
