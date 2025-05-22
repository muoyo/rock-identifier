// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

/// Configuration for the A-HA moment result reveal animation system
/// This system creates a dramatic, storytelling sequence that turns the identification
/// reveal into a delightful experience that builds anticipation and celebrates discovery.
struct ResultRevealAnimations {
    
    // MARK: - Timing Profiles
    
    /// Different timing profiles for A/B testing the reveal sequence
    enum TimingProfile: String, CaseIterable {
        case dramatic = "Dramatic"           // Longer pauses, more anticipation
        case energetic = "Energetic"         // Faster paced, more excitement
        case storytelling = "Storytelling"   // Balanced, narrative flow
        case subtle = "Subtle"              // Gentle, calm progression
        
        var config: TimingConfiguration {
            switch self {
            case .dramatic:
                return TimingConfiguration(
                    initialPause: 0.3,
                    imageReveal: 1.0,
                    dramaticPause: 1.2,      // Longer pause before name
                    nameReveal: 0.8,
                    nameFocus: 0.6,
                    categoryReveal: 0.5,
                    confidenceReveal: 0.4,
                    sparklesStart: 0.2,
                    sparklesDuration: 4.0,
                    tabRevealStagger: 0.3,   // Longer stagger between tabs
                    propertyRevealStagger: 0.15,
                    actionsReveal: 0.6
                )
            case .energetic:
                return TimingConfiguration(
                    initialPause: 0.1,
                    imageReveal: 0.6,
                    dramaticPause: 0.6,
                    nameReveal: 0.5,
                    nameFocus: 0.3,
                    categoryReveal: 0.3,
                    confidenceReveal: 0.25,
                    sparklesStart: 0.1,
                    sparklesDuration: 2.5,
                    tabRevealStagger: 0.15,
                    propertyRevealStagger: 0.08,
                    actionsReveal: 0.4
                )
            case .storytelling:
                return TimingConfiguration(
                    initialPause: 0.2,
                    imageReveal: 0.8,
                    dramaticPause: 1.0,
                    nameReveal: 0.7,
                    nameFocus: 0.5,
                    categoryReveal: 0.4,
                    confidenceReveal: 0.35,
                    sparklesStart: 0.15,
                    sparklesDuration: 3.5,
                    tabRevealStagger: 0.2,
                    propertyRevealStagger: 0.12,
                    actionsReveal: 0.5
                )
            case .subtle:
                return TimingConfiguration(
                    initialPause: 0.4,
                    imageReveal: 1.2,
                    dramaticPause: 0.8,
                    nameReveal: 1.0,
                    nameFocus: 0.8,
                    categoryReveal: 0.6,
                    confidenceReveal: 0.5,
                    sparklesStart: 0.3,
                    sparklesDuration: 5.0,
                    tabRevealStagger: 0.4,
                    propertyRevealStagger: 0.2,
                    actionsReveal: 0.8
                )
            }
        }
    }
    
    // MARK: - Timing Configuration
    
    struct TimingConfiguration {
        // Initial sequence timing
        let initialPause: Double              // Pause before anything happens
        let imageReveal: Double              // Time for image to appear
        let dramaticPause: Double            // THE dramatic pause before name
        let nameReveal: Double               // Time for name animation
        let nameFocus: Double                // Additional focus time on name
        let categoryReveal: Double           // Category reveal timing
        let confidenceReveal: Double         // Confidence indicator timing
        
        // Special effects timing
        let sparklesStart: Double            // Delay before sparkles begin
        let sparklesDuration: Double         // How long sparkles last
        
        // Content reveal timing
        let tabRevealStagger: Double         // Stagger between each tab appearing
        let propertyRevealStagger: Double    // Stagger between property rows
        let actionsReveal: Double            // Action buttons reveal timing
        
        // Computed cumulative timings
        var imageAppearTime: Double { initialPause }
        var nameAppearTime: Double { imageAppearTime + imageReveal + dramaticPause }
        var nameFocusEndTime: Double { nameAppearTime + nameReveal + nameFocus }
        var categoryAppearTime: Double { nameFocusEndTime + 0.2 }
        var confidenceAppearTime: Double { categoryAppearTime + categoryReveal }
        var sparklesTime: Double { nameAppearTime + nameReveal + sparklesStart }
        var firstTabTime: Double { confidenceAppearTime + confidenceReveal + 0.3 }
        var contentStartTime: Double { firstTabTime + (tabRevealStagger * 4) + 0.2 }
        var actionsStartTime: Double { contentStartTime + 0.5 }
    }
    
    // MARK: - Visual Effects Configuration
    
    struct VisualEffects {
        // Name focus effects
        static let nameSpotlightRadius: CGFloat = 100
        static let nameGlowRadius: CGFloat = 20
        static let nameScalePulse: CGFloat = 1.08
        static let nameBounceScale: CGFloat = 1.15
        
        // Image reveal effects
        static let imageInitialScale: CGFloat = 0.7
        static let imageFinalScale: CGFloat = 1.0
        static let imageGlowIntensity: Double = 0.4
        
        // Property reveal effects
        static let propertySlideDistance: CGFloat = 30
        static let propertyInitialOpacity: Double = 0
        static let propertyFinalOpacity: Double = 1
        
        // Tab reveal effects
        static let tabInitialOffset: CGFloat = -20
        static let tabBounceHeight: CGFloat = -5
        
        // Sparkles configuration
        static let sparkleCount: Int = 75
        static let sparkleVariance: Double = 0.8
        static let sparkleMaxSize: CGFloat = 20
        static let sparkleMinSize: CGFloat = 6
    }
    
    // MARK: - Animation Curves
    
    struct Curves {
        /// Dramatic entrance curve for the rock name
        static let dramaticEntrance = Animation.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.3)
        
        /// Bouncy reveal for playful elements
        static let bouncyReveal = Animation.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.2)
        
        /// Smooth storytelling flow
        static let storytellingFlow = Animation.easeInOut(duration: 0.7)
        
        /// Quick attention grabber
        static let attentionGrab = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.1)
        
        /// Gentle fade for subtle elements
        static let gentleFade = Animation.easeInOut(duration: 0.5)
        
        /// Elastic bounce for special moments
        static let elasticBounce = Animation.spring(response: 0.7, dampingFraction: 0.4, blendDuration: 0.3)
    }
    
    // MARK: - Current Profile Management
    
    /// The currently active timing profile (can be changed for A/B testing)
    static var currentProfile: TimingProfile = .storytelling
    
    /// Quick access to current timing configuration
    static var timing: TimingConfiguration {
        return currentProfile.config
    }
    
    // MARK: - Animation State Helpers
    
    /// Calculates the appropriate delay for a given reveal stage
    static func delayFor(stage: RevealStage) -> Double {
        switch stage {
        case .image:
            return timing.imageAppearTime
        case .name:
            return timing.nameAppearTime
        case .category:
            return timing.categoryAppearTime
        case .confidence:
            return timing.confidenceAppearTime
        case .sparkles:
            return timing.sparklesTime
        case .tabs(let index):
            return timing.firstTabTime + (Double(index) * timing.tabRevealStagger)
        case .properties(let index):
            return timing.contentStartTime + (Double(index) * timing.propertyRevealStagger)
        case .actions:
            return timing.actionsStartTime
        }
    }
    
    /// Calculates the animation curve for a given reveal stage
    static func curveFor(stage: RevealStage) -> Animation {
        switch stage {
        case .image:
            return Curves.storytellingFlow
        case .name:
            return Curves.dramaticEntrance
        case .category:
            return Curves.gentleFade
        case .confidence:
            return Curves.storytellingFlow
        case .sparkles:
            return Curves.bouncyReveal
        case .tabs:
            return Curves.bouncyReveal
        case .properties:
            return Curves.gentleFade
        case .actions:
            return Curves.storytellingFlow
        }
    }
}

// MARK: - Reveal Stage Enum

enum RevealStage: Equatable {
    case image
    case name
    case category
    case confidence
    case sparkles
    case tabs(index: Int)
    case properties(index: Int)
    case actions
}

// MARK: - Enhanced Animation Modifiers

struct EnhancedRevealModifier: ViewModifier {
    let stage: RevealStage
    let isActive: Bool
    
    @State private var hasAppeared = false
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .scaleEffect(getScaleEffect())
            .offset(y: getOffsetY())
            .blur(radius: hasAppeared ? 0 : 2)
            .onAppear {
                if isActive {
                    startRevealAnimation()
                }
            }
            .onChange(of: isActive) { newValue in
                if newValue && !hasAppeared {
                    startRevealAnimation()
                }
            }
    }
    
    private func startRevealAnimation() {
        let delay = ResultRevealAnimations.delayFor(stage: stage)
        let curve = ResultRevealAnimations.curveFor(stage: stage)
        
        withAnimation(curve.delay(delay)) {
            hasAppeared = true
        }
        
        // Add special effects for certain stages
        if case .name = stage {
            startNameFocusEffect()
        }
    }
    
    private func startNameFocusEffect() {
        let focusDelay = ResultRevealAnimations.timing.nameAppearTime + ResultRevealAnimations.timing.nameReveal
        
        DispatchQueue.main.asyncAfter(deadline: .now() + focusDelay) {
            withAnimation(ResultRevealAnimations.Curves.attentionGrab) {
                isPulsing = true
            }
            
            // Stop pulsing after focus period
            DispatchQueue.main.asyncAfter(deadline: .now() + ResultRevealAnimations.timing.nameFocus) {
                withAnimation(ResultRevealAnimations.Curves.gentleFade) {
                    isPulsing = false
                }
            }
        }
    }
    
    private func getScaleEffect() -> CGFloat {
        switch stage {
        case .image:
            return hasAppeared ? ResultRevealAnimations.VisualEffects.imageFinalScale : ResultRevealAnimations.VisualEffects.imageInitialScale
        case .name:
            if isPulsing {
                return ResultRevealAnimations.VisualEffects.nameScalePulse
            }
            return hasAppeared ? 1.0 : 0.8
        case .tabs:
            return hasAppeared ? 1.0 : 0.9
        default:
            return hasAppeared ? 1.0 : 0.95
        }
    }
    
    private func getOffsetY() -> CGFloat {
        switch stage {
        case .tabs:
            return hasAppeared ? 0 : ResultRevealAnimations.VisualEffects.tabInitialOffset
        case .properties:
            return hasAppeared ? 0 : ResultRevealAnimations.VisualEffects.propertySlideDistance
        default:
            return 0
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply enhanced reveal animation to any view
    func enhancedReveal(stage: RevealStage, isActive: Bool = true) -> some View {
        self.modifier(EnhancedRevealModifier(stage: stage, isActive: isActive))
    }
    
    /// Apply name spotlight effect
    func nameSpotlight(isActive: Bool, geometry: GeometryProxy) -> some View {
        self.overlay(
            ZStack {
                if isActive {
                    // Spotlight effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    StyleGuide.Colors.amethystPurple.opacity(0.1),
                                    StyleGuide.Colors.amethystPurple.opacity(0.05)
                                ]),
                                center: .center,
                                startRadius: 50,
                                endRadius: ResultRevealAnimations.VisualEffects.nameSpotlightRadius
                            )
                        )
                        .frame(width: ResultRevealAnimations.VisualEffects.nameSpotlightRadius * 2)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.4)
                        .animation(ResultRevealAnimations.Curves.gentleFade, value: isActive)
                }
            }
        )
    }
}

// MARK: - Enhanced Sparkles System

struct EnhancedSparklesView: View {
    let isActive: Bool
    let duration: Double
    
    @State private var sparklesData: [SparkleData] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isActive {
                    ForEach(sparklesData, id: \.id) { sparkle in
                        EnhancedSparkle(
                            data: sparkle,
                            containerSize: geometry.size
                        )
                    }
                }
            }
        }
        .onAppear {
            generateSparklesData()
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                generateSparklesData()
            }
        }
    }
    
    private func generateSparklesData() {
        sparklesData = (0..<ResultRevealAnimations.VisualEffects.sparkleCount).map { index in
            SparkleData(
                id: index,
                delay: Double.random(in: 0...duration * 0.3),
                duration: Double.random(in: duration * 0.5...duration),
                size: CGFloat.random(
                    in: ResultRevealAnimations.VisualEffects.sparkleMinSize...ResultRevealAnimations.VisualEffects.sparkleMaxSize
                ),
                isLarge: index % 8 == 0,
                color: sparkleColor(for: index),
                initialPosition: randomPosition(),
                rotationSpeed: Double.random(in: 180...720)
            )
        }
    }
    
    private func sparkleColor(for index: Int) -> Color {
        // Golden sparkles theme - more magical and cohesive
        let colors: [Color] = [
            StyleGuide.Colors.citrineGold,
            StyleGuide.Colors.citrineGold.opacity(0.9),
            Color.yellow.opacity(0.95),
            Color.orange.opacity(0.8),
            StyleGuide.Colors.citrineGoldDark,
            Color.white.opacity(0.9)
        ]
        return colors[index % colors.count]
    }
    
    private func randomPosition() -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...0.8)
        )
    }
}

struct SparkleData {
    let id: Int
    let delay: Double
    let duration: Double
    let size: CGFloat
    let isLarge: Bool
    let color: Color
    let initialPosition: CGPoint
    let rotationSpeed: Double
}

struct EnhancedSparkle: View {
    let data: SparkleData
    let containerSize: CGSize
    
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.1
    @State private var rotation: Double = 0
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Group {
            if data.isLarge {
                Image(systemName: "sparkle")
                    .font(.system(size: data.size))
                    .foregroundColor(data.color)
            } else {
                Image(systemName: "star.fill")
                    .font(.system(size: data.size * 0.8))
                    .foregroundColor(data.color)
            }
        }
        .opacity(opacity)
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .position(
            x: data.initialPosition.x * containerSize.width,
            y: data.initialPosition.y * containerSize.height + yOffset
        )
        .shadow(color: data.color.opacity(0.6), radius: 4, x: 0, y: 0)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Entrance animation
        withAnimation(
            ResultRevealAnimations.Curves.bouncyReveal.delay(data.delay)
        ) {
            opacity = 0.9
            scale = 1.0
        }
        
        // Continuous rotation
        withAnimation(
            Animation.linear(duration: data.rotationSpeed / 360).repeatForever(autoreverses: false).delay(data.delay)
        ) {
            rotation = data.rotationSpeed
        }
        
        // Float upward
        withAnimation(
            Animation.easeOut(duration: data.duration).delay(data.delay)
        ) {
            yOffset = -50
        }
        
        // Exit animation
        withAnimation(
            Animation.easeIn(duration: 0.5).delay(data.delay + data.duration * 0.7)
        ) {
            opacity = 0
            scale = 1.5
        }
    }
}
