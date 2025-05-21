// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    // State variables
    @State private var trialEnabled: Bool = false // Default to off - yearly plan selected
    @State private var selectedPlan: SubscriptionPlan = .yearly // Default to yearly plan
    @State private var isLoading: Bool = false
    @State private var showSuccessMessage: Bool = false
    
    // Dismissability logic
    @State private var canBeDismissed: Bool = false
    @State private var secondsUntilDismissable: Int = 5 // 5 second timer before dismiss is allowed
    
    // Reference to shared app state
    @ObservedObject private var appState = AppState.shared
    
    // Whether to show close button (passed from parent)
    var isDismissable: Bool = true
    
    // Animation properties for crystal
    @State private var sparklePosition: CGPoint = CGPoint(x: 0.2, y: 0.2)
    @State private var animationPhase: Double = 0
    
    // Timer for sparkling effect
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    // Timer for dismissable countdown
    let dismissTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Check if paywall can currently be swiped to dismiss
    var canSwipeDismiss: Bool {
        // If it's not dismissable at all (hard paywall), never allow swipe dismiss
        if !isDismissable {
            return false
        }
        
        // If it's a soft paywall, only allow swipe dismiss after countdown ends
        return canBeDismissed
    }
    
    // Computed property to determine if swipe-to-dismiss should be disabled
    private var shouldDisableSwipeToDismiss: Bool {
        return !isDismissable || (!canBeDismissed && isDismissable)
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Close button if dismissable
                    if isDismissable {
                        HStack {
                            Spacer()
                            
                            if canBeDismissed {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                                .padding(.trailing, 16)
                                .padding(.top, 16)
                                .transition(.opacity)
                            } else {
                                // Circular progress indicator for countdown
                                ZStack {
                                    // Background circle
                                    Circle()
                                        .stroke(lineWidth: 3)
                                        .foregroundColor(Color(.systemGray5))
                                        .frame(width: 36, height: 36)
                                    
                                    // Progress circle
                                    Circle()
                                        .trim(from: 0, to: CGFloat(5 - secondsUntilDismissable) / 5.0)
                                        .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                        .foregroundColor(.blue)
                                        .rotationEffect(Angle(degrees: -90))
                                        .frame(width: 36, height: 36)
                                        .animation(.linear(duration: 1), value: secondsUntilDismissable)
                                    
                                    // Counter text
                                    Text("\(secondsUntilDismissable)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.trailing, 16)
                                .padding(.top, 16)
                            }
                        }
                        .onReceive(dismissTimer) { _ in
                            if secondsUntilDismissable > 0 && !canBeDismissed {
                                secondsUntilDismissable -= 1
                                
                                if secondsUntilDismissable == 0 {
                                    withAnimation {
                                        canBeDismissed = true
                                        // Update the global state for swipe dismissal
                                        appState.paywallSwipeDismissable = true
                                    }
                                }
                            }
                        }
                    }
                    
                    // App icon and crystal
                    VStack(spacing: 10) {
                        // Crystal image with animation
                        ZStack {
                            crystalView
                                .frame(width: 130, height: 100)
                                .onReceive(timer) { _ in
                                    // Change sparkle position
                                    withAnimation(.easeInOut(duration: 1.5)) {
                                        sparklePosition = CGPoint(
                                            x: CGFloat.random(in: 0.1...0.9), 
                                            y: CGFloat.random(in: 0.1...0.9)
                                        )
                                        animationPhase += 1
                                    }
                                }
                        }
                        .padding(.bottom, 10)
                        
                        // Title and subtitle
                        Text("Rock Identifier Pro")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Discover the hidden stories in every stone")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, isDismissable ? 0 : 20)
                    
                    // Benefits list
                    VStack(alignment: .leading, spacing: 16) {
                        benefitRow(
                            icon: "infinity",
                            text: "Unlimited rock identifications",
                            color: .blue
                        )
                        
                        benefitRow(
                            icon: "sparkles",
                            text: "Discover fascinating geological origins",
                            color: .purple
                        )
                        
                        benefitRow(
                            icon: "square.grid.2x2.fill",
                            text: "Build your personal collection library",
                            color: .green
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Trial toggle - ensure text is on one line with grey border
                    HStack(spacing: 4) { // Reduce spacing between elements
                        Text("Not Sure? Enable Free Trial")
                            .font(.headline) // Back to normal size
                            .lineLimit(1)
                        
                        Spacer(minLength: 8) // Minimum space but giving text priority
                        
                        Toggle("", isOn: $trialEnabled)
                            .labelsHidden() // Hide any extra space from labels
                            .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                            .frame(width: 50) // Control the width of the toggle
                            // Make the toggle more visible when disabled with a custom style
                            .padding(2)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: trialEnabled ? 0 : 1)
                                    .background(Color.gray.opacity(trialEnabled ? 0 : 0.1))
                                    .cornerRadius(16)
                            )
                            .onChange(of: trialEnabled) { newValue in
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                
                                // Link toggle to selected plan
                                if newValue {
                                    selectedPlan = .weekly
                                } else {
                                    selectedPlan = .yearly
                                }
                            }
                    }
                    .padding(.horizontal, 16) // Less horizontal padding outside container
                    .padding(.vertical, 12) // Add vertical padding
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Subtle grey border
                    )
                    .padding(.horizontal)
                    
                    // Subscription options
                    VStack(spacing: 16) {
                        // Yearly plan
                        planButton(
                            plan: .yearly,
                            title: "Yearly Plan",
                            originalPrice: "$211.48",
                            discount: "SAVE 90%"
                        )
                        
                        // 3-day trial then weekly
                        planButton(
                            plan: .weekly,
                            title: "3-Day Free Trial",
                            isTrial: true,
                            showTrial: true // Always show trial info, regardless of toggle
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    // Continue button - taller with larger, bold text
                    Button(action: {
                        purchaseSubscription()
                    }) {
                        ZStack {
                            Text(selectedPlan == .yearly ? "Continue" : "Start Free Trial")
                                .font(.system(size: 22, weight: .bold)) // Larger bold text
                                .foregroundColor(.white)
                                .padding(.vertical, 25) // Taller button
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .opacity(isLoading ? 0 : 1)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                            }
                        }
                    }
                    .disabled(isLoading)
                    
                    // Continue with limited version button
                    // Commented out since we already have the X to dismiss
                    /*
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Continue with Limited Version")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 12)
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                    */
                    
                    // Bottom links
                    HStack(spacing: 20) {
                        bottomLink(text: "Restore", action: restorePurchases)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        bottomLink(text: "Terms", action: showTerms)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        bottomLink(text: "Privacy", action: showPrivacy)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.vertical)
            }
        }
        .onChange(of: selectedPlan) { newPlan in
            // Link selected plan to toggle
            trialEnabled = newPlan == .weekly
        }
        .alert(isPresented: $showSuccessMessage) {
            Alert(
                title: Text("Purchase Successful"),
                message: Text("You now have unlimited access to all premium features!"),
                dismissButton: .default(Text("Start Exploring")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .modifier(InteractiveDismissModifier(isEnabled: shouldDisableSwipeToDismiss))
        .onAppear {
            // Check if user has an active subscription - dismiss immediately if so
            if subscriptionManager.status.isActive {
                print("PaywallView: User has active subscription - dismissing paywall")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                return
            }
            
            // Reset app state when view appears
            if !isDismissable {
                // Hard paywall - never dismissable
                appState.paywallSwipeDismissable = false
            } else {
                // Soft paywall - start as not dismissable
                appState.paywallSwipeDismissable = false
            }
        }
    }
    
    // Stylized crystal view with animation
    private var crystalView: some View {
        ZStack {
            // Base shape with gradient
            ZStack {
                // Top half (pentagon)
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    let centerX = width / 2
                    let centerY = height / 2
                    
                    Path { path in
                        // Define pentagon points
                        let topPoint = CGPoint(x: centerX, y: centerY - height * 0.4)
                        let topLeftPoint = CGPoint(x: centerX - width * 0.35, y: centerY - height * 0.1)
                        let topRightPoint = CGPoint(x: centerX + width * 0.35, y: centerY - height * 0.1)
                        let bottomLeftPoint = CGPoint(x: centerX - width * 0.25, y: centerY + height * 0.1)
                        let bottomRightPoint = CGPoint(x: centerX + width * 0.25, y: centerY + height * 0.1)
                        
                        path.move(to: topPoint)
                        path.addLine(to: topRightPoint)
                        path.addLine(to: bottomRightPoint)
                        path.addLine(to: bottomLeftPoint)
                        path.addLine(to: topLeftPoint)
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.7),
                                Color.teal.opacity(0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                // Bottom half (inverted pentagon)
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    let centerX = width / 2
                    let centerY = height / 2
                    
                    Path { path in
                        // Define pentagon points
                        let topLeftPoint = CGPoint(x: centerX - width * 0.25, y: centerY + height * 0.1)
                        let topRightPoint = CGPoint(x: centerX + width * 0.25, y: centerY + height * 0.1)
                        let bottomLeftPoint = CGPoint(x: centerX - width * 0.35, y: centerY + height * 0.4)
                        let bottomRightPoint = CGPoint(x: centerX + width * 0.35, y: centerY + height * 0.4)
                        let bottomPoint = CGPoint(x: centerX, y: centerY + height * 0.45)
                        
                        path.move(to: topLeftPoint)
                        path.addLine(to: topRightPoint)
                        path.addLine(to: bottomRightPoint)
                        path.addLine(to: bottomPoint)
                        path.addLine(to: bottomLeftPoint)
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.5),
                                Color.blue
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            // Sparkle effect
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 12, height: 12)
                .blur(radius: 2)
                .position(x: 130 * sparklePosition.x, y: 130 * sparklePosition.y)
            
            // Reflection effect
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 30, height: 30)
                .blur(radius: 6)
                .position(x: 35, y: 40)
        }
    }
    
    // Helper function to create benefit rows
    private func benefitRow(icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 36, height: 36)
                )
            
            Text(text)
                .font(.system(size: 16))
        }
    }
    
    // Helper function to create plan buttons
    private func planButton(plan: SubscriptionPlan, title: String? = nil, originalPrice: String? = nil, discount: String? = nil, isTrial: Bool = false, showTrial: Bool = false) -> some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            selectedPlan = plan
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title ?? plan.displayName)
                        .font(.headline)
                        .foregroundColor(Color(.label)) // Use system label color for automatic dark mode support
                    
                    HStack {
                        if let originalPrice = originalPrice {
                            Text(originalPrice)
                                .strikethrough()
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if isTrial && showTrial {
                            Text("then \(plan.price)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text(plan.price)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if let discount = discount {
                    Text(discount)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(12)
                } else if isTrial && showTrial {
                    HStack(spacing: 4) {
                        Text("FREE")
                            .bold()
                            .foregroundColor(Color(.label)) // Use system label color for automatic dark mode support
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == plan ? Color.red : Color.gray.opacity(0.2), lineWidth: 2)
            )
        }
    }
    
    // Helper function to create bottom links
    private func bottomLink(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // Purchase subscription
    private func purchaseSubscription() {
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Show loading indicator
        isLoading = true
        
        // Initiate purchase with completion handler
        subscriptionManager.purchase(plan: selectedPlan, isTrialEnabled: trialEnabled) { success, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    // Purchase successful
                    self.showSuccessMessage = true
                } else if let error = error {
                    // For user cancellations, don't show error message
                    if let nsError = error as NSError?, nsError.code == 1005 {  // User cancelled
                        // Do nothing, user cancelled
                    } else {
                        // Show error message for other errors
                        self.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // Show an error alert with the provided message
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Purchase Failed",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
            self.purchaseSubscription()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    // Restore purchases
    private func restorePurchases() {
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Show loading indicator
        isLoading = true
        
        // Call restore function with completion handler
        subscriptionManager.restorePurchases { success, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success && subscriptionManager.status.isActive {
                    // Show success message if subscription is active
                    self.showSuccessMessage = true
                } else if let error = error {
                    // Show error alert
                    self.showRestoreErrorAlert(message: error.localizedDescription)
                } else if success && !subscriptionManager.status.isActive {
                    // No active subscriptions found
                    self.showRestoreErrorAlert(message: "No active subscriptions found. If you previously purchased a subscription, make sure you're signed in with the correct Apple ID.")
                }
            }
        }
    }
    
    // Show a restore error alert
    private func showRestoreErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Restore Result",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    // Show terms
    private func showTerms() {
        // Would open terms page in production
        print("Would show terms page")
    }
    
    // Show privacy policy
    private func showPrivacy() {
        // Would open privacy policy in production
        print("Would show privacy policy")
    }
}

// MARK: - Helper Extensions

// Custom modifier for handling interactive dismiss across iOS versions
struct InteractiveDismissModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.interactiveDismissDisabled(isEnabled)
        } else {
            content
        }
    }
}

// Preview provider
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(isDismissable: true)
            .environmentObject(SubscriptionManager())
    }
}
