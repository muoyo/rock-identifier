// Rock Identifier: Crystal ID
// Enhanced Mineral-Inspired Paywall
// Muoyo Okome
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    // State variables - preserved exactly as before
    @State private var trialEnabled: Bool = false
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isLoading: Bool = false
    @State private var showSuccessMessage: Bool = false
    @State private var canBeDismissed: Bool = false
    @State private var secondsUntilDismissable: Int = 5
    
    // Reference to shared app state - preserved
    @ObservedObject private var appState = AppState.shared
    var isDismissable: Bool = true
    
    // Enhanced crystal animation properties
    @State private var sparklePosition: CGPoint = CGPoint(x: 0.2, y: 0.2)
    @State private var animationPhase: Double = 0
    @State private var crystalRotation: Double = 0
    @State private var crystalScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -200
    @State private var backgroundGradientRotation: Double = 0
    
    // Benefit card animation states
    @State private var benefitCardsRevealed: [Bool] = [false, false, false]
    @State private var planCardsRevealed: [Bool] = [false, false]
    
    // Floating particles
    @State private var floatingParticles: [FloatingParticle] = []
    
    // Timers - preserved
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    let dismissTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Computed properties - preserved exactly
    var canSwipeDismiss: Bool {
        if !isDismissable { return false }
        return canBeDismissed
    }
    
    private var shouldDisableSwipeToDismiss: Bool {
        return !isDismissable || (!canBeDismissed && isDismissable)
    }
    
    var body: some View {
        ZStack {
            // Enhanced magical background
            magicalBackground
            
            // Floating sparkle particles
            ForEach(floatingParticles.indices, id: \.self) { index in
                if index < floatingParticles.count {
                    FloatingSparkleView(particle: floatingParticles[index])
                }
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    // Enhanced close button section
                    enhancedCloseButtonSection
                    
                    // Magical crystal hero section
                    enhancedCrystalHeroSection
                    
                    // Enhanced benefits section
                    enhancedBenefitsSection
                    
                    // Enhanced trial toggle
                    enhancedTrialToggle
                    
                    // Enhanced subscription plans
                    enhancedSubscriptionPlans
                    
                    // Enhanced continue button
                    enhancedContinueButton
                    
                    // Enhanced bottom links
                    enhancedBottomLinks
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            startMagicalAnimations()
            preservedOnAppearLogic()
        }
        .onChange(of: selectedPlan) { newPlan in
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
    }
    
    // MARK: - Enhanced UI Components
    
    private var magicalBackground: some View {
        ZStack {
            // Base gradient background
            AngularGradient(
                gradient: Gradient(colors: [
                    StyleGuide.Colors.amethystBackground,
                    StyleGuide.Colors.emeraldBackground,
                    StyleGuide.Colors.citrineBackground,
                    StyleGuide.Colors.amethystBackground
                ]),
                center: .center,
                startAngle: .degrees(backgroundGradientRotation),
                endAngle: .degrees(backgroundGradientRotation + 360)
            )
            .opacity(0.3)
            .edgesIgnoringSafeArea(.all)
            .animation(.linear(duration: 60).repeatForever(autoreverses: false), value: backgroundGradientRotation)
            
            // Overlay for readability
            Color(.systemBackground)
                .opacity(0.85)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    private var enhancedCloseButtonSection: some View {
        Group {
            if isDismissable {
                HStack {
                    Spacer()
                    
                    if canBeDismissed {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                        .mineralShadow(.gray, intensity: .small)
                        .padding(.trailing, 20)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .scale))
                    } else {
                        // Enhanced countdown circle
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                                .frame(width: 40, height: 40)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(5 - secondsUntilDismissable) / 5.0)
                                .stroke(Color.gray.opacity(0.6), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 40, height: 40)
                                .animation(.linear(duration: 1), value: secondsUntilDismissable)
                            
                            Text("\(secondsUntilDismissable)")
                                .font(StyleGuide.Typography.captionBold)
                                .foregroundColor(Color.gray)
                        }
                        .mineralShadow(.gray, intensity: .medium)
                        .padding(.trailing, 20)
                        .padding(.top, 8)
                    }
                }
                .onReceive(dismissTimer) { _ in
                    if secondsUntilDismissable > 0 && !canBeDismissed {
                        secondsUntilDismissable -= 1
                        
                        if secondsUntilDismissable == 0 {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                canBeDismissed = true
                                appState.paywallSwipeDismissable = true
                            }
                            HapticManager.shared.successFeedback()
                        }
                    }
                }
            }
        }
    }
    
    private var enhancedCrystalHeroSection: some View {
        VStack(spacing: 16) {
            // Enhanced magical crystal
            ZStack {
                enhancedCrystalView
                    .frame(width: 120, height: 100)
                    .scaleEffect(crystalScale)
                    .rotationEffect(.degrees(crystalRotation))
                    .mineralShadow(StyleGuide.Colors.roseQuartzPink, intensity: .large)
                    .onReceive(timer) { _ in
                        withAnimation(.easeInOut(duration: 2.0)) {
                            sparklePosition = CGPoint(
                                x: CGFloat.random(in: 0.15...0.85),
                                y: CGFloat.random(in: 0.15...0.85)
                            )
                            animationPhase += 1
                        }
                    }
                
                // Shimmer overlay effect
                shimmerOverlay
            }
            .padding(.bottom, 0)
            
            // Enhanced title section
            VStack(spacing: 8) {
                Text("Rock Identifier Pro")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Discover the hidden stories in every stone")
                    .textStyle(.bodyLarge)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, -20)
        .padding(.bottom, 24)
    }
    
    private var enhancedBenefitsSection: some View {
        HStack {
            Spacer()
            
            // Fixed-width centered container
            VStack(spacing: 12) {
                ForEach(0..<3) { index in
                    centeredBenefitRow(
                        icon: benefitIcons[index],
                        text: benefitTexts[index],
                        color: benefitColors[index],
                        isRevealed: benefitCardsRevealed[index]
                    )
                }
            }
            .frame(width: 270 ) // Fixed width sized for content
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 20)
    }
    
    private var enhancedTrialToggle: some View {
        HStack(spacing: 12) {
            Text("Not Sure? Enable Free Trial")
                .textStyle(.headlineMedium)
                .lineLimit(1)
            
            Spacer(minLength: 8)
            
            Toggle("", isOn: $trialEnabled)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: StyleGuide.Colors.roseQuartzPink))
                .frame(width: 50)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
                        .fill(trialEnabled ? StyleGuide.Colors.roseQuartzPink.opacity(0.1) : StyleGuide.Colors.overlay10)
                        .overlay(
                            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
                                .strokeBorder(
                                    trialEnabled ? StyleGuide.Colors.roseQuartzGradient : LinearGradient(
                                        colors: [Color.gray.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                )
                .onChange(of: trialEnabled) { newValue in
                    HapticManager.shared.selectionChanged()
                    selectedPlan = newValue ? .weekly : .yearly
                }
        }
        .mineralPadding(.all, .medium)
        .background(
            ZStack {
                // Glassmorphism background
                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium))
                
                // Border overlay
                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                    .strokeBorder(
                        Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            }
        )
        .mineralShadow(.gray, intensity: .subtle)
        .mineralPadding(.horizontal, .medium)
        .padding(.bottom, 20)
    }
    
    private var enhancedSubscriptionPlans: some View {
        VStack(spacing: 16) {
            // Yearly plan
            enhancedPlanCard(
                plan: .yearly,
                title: "Yearly Plan",
                originalPrice: "$211.48",
                discount: "SAVE 90%",
                isRevealed: planCardsRevealed[0],
                isPremium: true
            )
            
            // Trial plan
            enhancedPlanCard(
                plan: .weekly,
                title: "3-Day Free Trial",
                isTrial: true,
                showTrial: true,
                isRevealed: planCardsRevealed[1],
                isPremium: false
            )
        }
        .mineralPadding(.horizontal, .medium)
        .padding(.bottom, 20)
    }
    
    private var enhancedContinueButton: some View {
        Button(action: {
            purchaseSubscription()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                    .fill(StyleGuide.Colors.roseQuartzPink)
                    .frame(height: 90)
                    .mineralShadow(StyleGuide.Colors.roseQuartzPink, intensity: .large)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                } else {
                    Text(selectedPlan == .yearly ? "Continue" : "Start Free Trial")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(isLoading)
        .scaleEffect(isLoading ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
        .mineralPadding(.horizontal, .medium)
        .padding(.bottom, 20)
    }
    
    private var enhancedBottomLinks: some View {
        HStack(spacing: 20) {
            enhancedBottomLink(text: "Restore", action: restorePurchases)
            
            Circle()
                .fill(StyleGuide.Colors.amethystPurple.opacity(0.3))
                .frame(width: 4, height: 4)
            
            enhancedBottomLink(text: "Terms", action: showTerms)
            
            Circle()
                .fill(StyleGuide.Colors.amethystPurple.opacity(0.3))
                .frame(width: 4, height: 4)
            
            enhancedBottomLink(text: "Privacy", action: showPrivacy)
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Enhanced Crystal Components
    
    private var enhancedCrystalView: some View {
        ZStack {
            // Main crystal body with enhanced gradients
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height
                let centerX = width / 2
                let centerY = height / 2
                
                ZStack {
                    // Top facet with rose quartz gradient
                    Path { path in
                        let topPoint = CGPoint(x: centerX, y: centerY - height * 0.45)
                        let topLeftPoint = CGPoint(x: centerX - width * 0.38, y: centerY - height * 0.15)
                        let topRightPoint = CGPoint(x: centerX + width * 0.38, y: centerY - height * 0.15)
                        let bottomLeftPoint = CGPoint(x: centerX - width * 0.28, y: centerY + height * 0.05)
                        let bottomRightPoint = CGPoint(x: centerX + width * 0.28, y: centerY + height * 0.05)
                        
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
                                StyleGuide.Colors.roseQuartzPink,
                                StyleGuide.Colors.roseQuartzPink.opacity(0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Bottom facet with deeper rose quartz
                    Path { path in
                        let topLeftPoint = CGPoint(x: centerX - width * 0.28, y: centerY + height * 0.05)
                        let topRightPoint = CGPoint(x: centerX + width * 0.28, y: centerY + height * 0.05)
                        let bottomLeftPoint = CGPoint(x: centerX - width * 0.38, y: centerY + height * 0.35)
                        let bottomRightPoint = CGPoint(x: centerX + width * 0.38, y: centerY + height * 0.35)
                        let bottomPoint = CGPoint(x: centerX, y: centerY + height * 0.48)
                        
                        path.move(to: topLeftPoint)
                        path.addLine(to: topRightPoint)
                        path.addLine(to: bottomRightPoint)
                        path.addLine(to: bottomPoint)
                        path.addLine(to: bottomLeftPoint)
                        path.closeSubpath()
                    }
                    .fill(StyleGuide.Colors.roseQuartzGradient)
                    
                    // Side facets for depth
                    Path { path in
                        let points = [
                            CGPoint(x: centerX - width * 0.38, y: centerY - height * 0.15),
                            CGPoint(x: centerX - width * 0.28, y: centerY + height * 0.05),
                            CGPoint(x: centerX - width * 0.38, y: centerY + height * 0.35)
                        ]
                        
                        path.move(to: points[0])
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                        path.closeSubpath()
                    }
                    .fill(StyleGuide.Colors.roseQuartzPink.opacity(0.7))
                }
            }
            .compositingGroup()
            
            // Enhanced sparkle effects
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
                    .blur(radius: 2)
                    .position(
                        x: 140 * CGFloat.random(in: 0.2...0.8),
                        y: 110 * CGFloat.random(in: 0.2...0.8)
                    )
                    .opacity(Double(index) == animationPhase.truncatingRemainder(dividingBy: 5) ? 1 : 0.3)
                    .animation(.easeInOut(duration: 0.5), value: animationPhase)
            }
            
            // Main sparkle that follows sparklePosition
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .blur(radius: 1)
                .position(x: 140 * sparklePosition.x, y: 110 * sparklePosition.y)
                .opacity(0.9)
            
            // Reflection highlight
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.2),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 25
                    )
                )
                .frame(width: 40, height: 25)
                .position(x: 50, y: 35)
        }
    }
    
    private var shimmerOverlay: some View {
        RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.4),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 140, height: 110)
            .rotationEffect(.degrees(20))
            .offset(x: shimmerOffset)
            .onAppear {
                withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                    shimmerOffset = 200
                }
            }
            .allowsHitTesting(false)
    }
    
    // MARK: - Centered Benefit Row
    
    private func centeredBenefitRow(icon: String, text: String, color: Color, isRevealed: Bool) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20, height: 20)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer() // Push content to left within the fixed container
        }
        .opacity(isRevealed ? 1.0 : 0.0)
        .offset(x: isRevealed ? 0 : -20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isRevealed)
    }
    
    // MARK: - Simple Benefit Row (less prominent)
    
    private func simpleBenefitRow(icon: String, text: String, color: Color, isRevealed: Bool) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20, height: 20)
            
        Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .opacity(isRevealed ? 1.0 : 0.0)
        .offset(x: isRevealed ? 0 : -20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isRevealed)
    }
    
    // MARK: - Enhanced Benefit Card
    
    private func enhancedBenefitCard(icon: String, text: String, gradient: LinearGradient, isRevealed: Bool) -> some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 50, height: 50)
                    .mineralShadow(.gray, intensity: .medium)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .textStyle(.bodyMedium)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .mineralPadding(.all, .medium)
        .background(
            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                .fill(StyleGuide.Colors.background)
                .overlay(
                    RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                        .strokeBorder(gradient.opacity(0.3), lineWidth: 1.5)
                )
        )
        .mineralShadow(.gray, intensity: .small)
        .scaleEffect(isRevealed ? 1.0 : 0.9)
        .opacity(isRevealed ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isRevealed)
    }
    
    // MARK: - Enhanced Plan Card
    
    private func enhancedPlanCard(
        plan: SubscriptionPlan,
        title: String? = nil,
        originalPrice: String? = nil,
        discount: String? = nil,
        isTrial: Bool = false,
        showTrial: Bool = false,
        isRevealed: Bool,
        isPremium: Bool
    ) -> some View {
        Button(action: {
            HapticManager.shared.selectionChanged()
            selectedPlan = plan
        }) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title ?? plan.displayName)
                            .textStyle(.headlineMedium)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            if let originalPrice = originalPrice {
                                Text(originalPrice)
                                    .strikethrough()
                                    .textStyle(.captionMedium)
                                    .foregroundColor(.secondary)
                            }
                            
                            if isTrial && showTrial {
                                Text("then \(plan.price)")
                                    .textStyle(.captionMedium)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(plan.price)
                                    .textStyle(.captionMedium)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if let discount = discount {
                        Text(discount)
                            .textStyle(.badgeText)
                            .foregroundColor(.white)
                            .mineralPadding(.horizontal, .small)
                            .mineralPadding(.vertical, .extraSmall)
                            .background(StyleGuide.Colors.roseQuartzPink)
                            .mineralCornerRadius(.pill)
                            .mineralShadow(StyleGuide.Colors.roseQuartzPink, intensity: .small)
                    } else if isTrial && showTrial {
                        HStack(spacing: 6) {
                            Text("FREE")
                                .textStyle(.headlineMedium)
                                .foregroundColor(StyleGuide.Colors.roseQuartzPink)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(StyleGuide.Colors.roseQuartzPink)
                        }
                    }
                }
                
                // Selection indicator
                if selectedPlan == plan {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(StyleGuide.Colors.roseQuartzPink)
                        
                        Text("Selected")
                            .textStyle(.captionBold)
                            .foregroundColor(StyleGuide.Colors.roseQuartzPink)
                        
                        Spacer()
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .mineralPadding(.all, .medium)
            .background(
                ZStack {
                    // Glassmorphism background
                    RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium))
                    
                    // Border overlay
                    RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                        .strokeBorder(
                            selectedPlan == plan 
                                ? LinearGradient(colors: [StyleGuide.Colors.roseQuartzPink], startPoint: .leading, endPoint: .trailing) // StyleGuide.Colors.roseQuartzGradient
                                : LinearGradient(colors: [Color.white.opacity(0.3)], startPoint: .leading, endPoint: .trailing),
                            lineWidth: selectedPlan == plan ? 2.5 : 1
                        )
                }
            )
            .mineralShadow(
                selectedPlan == plan 
                    ? StyleGuide.Colors.roseQuartzPink
                    : .gray,
                intensity: selectedPlan == plan ? .medium : .small
            )
            .scaleEffect(isRevealed ? 1.0 : 0.95)
            .opacity(isRevealed ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isRevealed)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedPlan)
        }
    }
    
    // MARK: - Enhanced Bottom Link
    
    private func enhancedBottomLink(text: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            Text(text)
                .textStyle(.captionMedium)
                .foregroundColor(StyleGuide.Colors.amethystPurple)
        }
    }
    
    // MARK: - Animation & Data Properties
    
    private let benefitIcons = ["infinity", "sparkles", "square.grid.2x2.fill"]
    private let benefitTexts = [
        "Unlimited rock identifications",
        "Discover fascinating geological origins", 
        "Build your personal collection library"
    ]
    private let benefitColors = [
        Color.roseQuartzPink,
        Color.roseQuartzPink,
        Color.roseQuartzPink
    ]
    
    // MARK: - Animation Functions
    
    private func startMagicalAnimations() {
        // Background rotation
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
            backgroundGradientRotation = 360
        }
        
        // Crystal gentle rotation
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            crystalRotation = 3
        }
        
        // Crystal breathing scale
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            crystalScale = 1.05
        }
        
        // Staggered benefit card reveals
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3 + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    benefitCardsRevealed[i] = true
                }
            }
        }
        
        // Staggered plan card reveals
        for i in 0..<2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2 + 2.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    planCardsRevealed[i] = true
                }
            }
        }
        
        // Initialize floating particles
        floatingParticles = (0..<8).map { _ in
            FloatingParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 100...700)
                ),
                opacity: Double.random(in: 0.1...0.4),
                scale: CGFloat.random(in: 0.5...1.2)
            )
        }
    }
    
    private func preservedOnAppearLogic() {
        // Preserved exactly from original
        if subscriptionManager.status.isActive {
            print("PaywallView: User has active subscription - dismissing paywall")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.presentationMode.wrappedValue.dismiss()
            }
            return
        }
        
        if !isDismissable {
            appState.paywallSwipeDismissable = false
        } else {
            appState.paywallSwipeDismissable = false
        }
    }
    
    // MARK: - Preserved Functionality (unchanged)
    
    private func purchaseSubscription() {
        HapticManager.shared.mediumImpact()
        isLoading = true
        
        subscriptionManager.purchase(plan: selectedPlan, isTrialEnabled: trialEnabled) { success, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    HapticManager.shared.successFeedback()
                    self.showSuccessMessage = true
                } else if let error = error {
                    if let nsError = error as NSError?, nsError.code == 1005 {
                        // User cancelled - do nothing
                    } else {
                        HapticManager.shared.errorFeedback()
                        self.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
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
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func restorePurchases() {
        HapticManager.shared.lightImpact()
        isLoading = true
        
        subscriptionManager.restorePurchases { success, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success && subscriptionManager.status.isActive {
                    self.showSuccessMessage = true
                } else if let error = error {
                    self.showRestoreErrorAlert(message: error.localizedDescription)
                } else if success && !subscriptionManager.status.isActive {
                    self.showRestoreErrorAlert(message: "No active subscriptions found. If you previously purchased a subscription, make sure you're signed in with the correct Apple ID.")
                }
            }
        }
    }
    
    private func showRestoreErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Restore Result",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func showTerms() {
        print("Would show terms page")
    }
    
    private func showPrivacy() {
        print("Would show privacy policy")
    }
}

// MARK: - Supporting Components

struct FloatingParticle {
    var position: CGPoint
    var opacity: Double
    var scale: CGFloat
}

struct FloatingSparkleView: View {
    let particle: FloatingParticle
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0.1
    
    var body: some View {
        Circle()
            .fill(StyleGuide.Colors.roseQuartzPink.opacity(0.6))
            .frame(width: 4 * particle.scale, height: 4 * particle.scale)
            .position(x: particle.position.x, y: particle.position.y + yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 3...6))
                    .repeatForever(autoreverses: true)
                ) {
                    yOffset = CGFloat.random(in: -30...30)
                    opacity = particle.opacity
                }
            }
    }
}

// MARK: - Preserved Helper Extensions

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

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(isDismissable: true)
            .environmentObject(SubscriptionManager())
    }
}
