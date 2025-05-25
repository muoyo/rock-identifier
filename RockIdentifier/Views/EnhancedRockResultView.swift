// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import AVFoundation

struct EnhancedRockResultView: View {
    @Binding var isPresented: Bool
    let result: RockIdentificationResult
    let collectionManager: CollectionManager
    
    // State variables for animations and UI
    @State private var addedToCollection: Bool = false
    @State private var selectedTab = 0
    @State private var showShareSheet = false
    @State private var showEnhancedShareSheet = false
    @State private var showNotes: Bool = false
    @State private var userNotes: String = ""
    @State private var backgroundGradientRotation = 0.0
    
    // Enhanced animation state variables
    @State private var revealState: RevealState = .initial
    @State private var animationStage: AnimationStage = .waiting
    @State private var isNameFocused: Bool = false
    @State private var isSparklesActive: Bool = false
    @State private var tabRevealIndex: Int = -1
    @State private var propertyRevealIndex: Int = -1
    @State private var showNameSpotlight: Bool = false
    @State private var isDramaticPause: Bool = false
    @State private var pauseProgress: Double = 0.0
    
    // Individual reveal states for fine-grained control
    @State private var imageRevealed: Bool = false
    @State private var nameRevealed: Bool = false
    @State private var categoryRevealed: Bool = false
    @State private var confidenceRevealed: Bool = false
    @State private var tabsRevealed: [Bool] = [false, false, false, false]
    @State private var actionsRevealed: Bool = false
    
    // Haptic feedback generators
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    let notificationGenerator = UINotificationFeedbackGenerator()
    
    // Reveal state enum
    enum RevealState {
        case initial
        case imageRevealed
        case nameRevealed
        case categoryRevealed
        case confidenceRevealed
        case tabsRevealed
        case contentRevealed
        case actionsRevealed
        case complete
    }
    
    // Animation stage for the enhanced reveal system
    enum AnimationStage {
        case waiting
        case imageAppearing
        case dramaticPause
        case nameAppearing
        case nameFocused
        case propertiesAppearing
        case tabsAppearing
        case contentRevealing
        case actionsRevealing
        case complete
    }
    
    // Enhanced timing system using ResultRevealAnimations
    private var timing: ResultRevealAnimations.TimingConfiguration {
        ResultRevealAnimations.timing
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    // Background gradient with subtle animation
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.05),
                            Color.purple.opacity(0.06),
                            Color.blue.opacity(0.04),
                            Color.cyan.opacity(0.05),
                            Color.blue.opacity(0.05)
                        ]),
                        center: .center,
                        startAngle: .degrees(backgroundGradientRotation),
                        endAngle: .degrees(backgroundGradientRotation + 360)
                    )
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 30).repeatForever(autoreverses: false)) {
                            backgroundGradientRotation = 360
                        }
                    }
                    
                    // Enhanced sparkles effect (shown during A-HA moment)
                    EnhancedSparklesView(
                        isActive: isSparklesActive,
                        duration: timing.sparklesDuration
                    )
                    
                    // Name spotlight effect during focus moment
                    if showNameSpotlight {
                        Color.clear.nameSpotlight(isActive: showNameSpotlight, geometry: geometry)
                    }
                    
                    // Main content
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Hero image section
                                ZStack(alignment: .bottom) {
                                    if let image = result.image {
                                        Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.7)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                        .stroke(LinearGradient(
                                            gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.5), Color.purple.opacity(0.3)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ), lineWidth: 3)
                                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 0)
                                                    )
                                                    .shadow(color: Color.primary.opacity(0.2), radius: 15, x: 0, y: 8)
                                                    .enhancedReveal(stage: .image, isActive: imageRevealed)
                                            .overlay(
                                                // Dramatic pause progress indicator for placeholder
                                                Group {
                                                    if isDramaticPause {
                                                        VStack {
                                                            Spacer()
                                                            HStack {
                                                                Spacer()
                                                                
                                                                // Subtle pulsing dots to show progress
                                                                HStack(spacing: 4) {
                                                                    ForEach(0..<3) { index in
                                                                        Circle()
                                                                            .fill(Color.white.opacity(0.8))
                                                                            .frame(width: 6, height: 6)
                                                                            .scaleEffect(pauseProgress > Double(index) * 0.33 ? 1.2 : 0.8)
                                                                            .opacity(pauseProgress > Double(index) * 0.33 ? 1.0 : 0.4)
                                                                            .animation(
                                                                                Animation.easeInOut(duration: 0.4)
                                                                                    .repeatForever(autoreverses: true)
                                                                                    .delay(Double(index) * 0.2),
                                                                                value: isDramaticPause
                                                                            )
                                                                    }
                                                                }
                                                                .padding(.horizontal, 12)
                                                                .padding(.vertical, 8)
                                                                .background(
                                                                    Capsule()
                                                                        .fill(Color.black.opacity(0.3))
                                                                )
                                                                
                                                                Spacer()
                                                            }
                                                            .padding(.bottom, 16)
                                                        }
                                                        .transition(.opacity)
                                                    }
                                                }
                                            )
                                    } else {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.7)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .font(.system(size: 50))
                                                    .foregroundColor(.white.opacity(0.7))
                                            )
                                            .enhancedReveal(stage: .image, isActive: imageRevealed)
                                    }
                                    
                                    // Recognition badge - appears with enhanced timing and centered
                                    if imageRevealed {
                                        HStack {
                                            Spacer()
                                            VStack {
                                                Spacer()
                                                HStack(spacing: 4) {
                                                    Image(systemName: "checkmark.seal.fill")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 12, weight: .bold))
                                                    Text("Identified")
                                                        .font(.caption2)
                                                        .bold()
                                                        .foregroundColor(.white)
                                                }
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(StyleGuide.Colors.emeraldGradient)
                                                .cornerRadius(12)
                                                .shadow(color: StyleGuide.Colors.emeraldGreen.opacity(0.4), radius: 4, x: 0, y: 2)
                                                .padding(.trailing, 16)
                                                .padding(.bottom, 16)
                                            }
                                        }
                                        .enhancedReveal(stage: .image, isActive: imageRevealed)
                                    }
                                }
                                .padding(.top, 20)
                                
                                // Rock name and category
                                VStack(spacing: 8) {
                                    // Rock name with enhanced focus effects - neutral colors for better readability
                                    Text(result.name)
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)  // Uses system primary (black in light mode, white in dark)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .enhancedReveal(stage: .name, isActive: nameRevealed)
                                        .shadow(color: Color.black.opacity(0.1), radius: isNameFocused ? 8 : 2, x: 0, y: 1)
                                        .scaleEffect(isNameFocused ? 1.05 : 1.0)
                                        .animation(ResultRevealAnimations.Curves.attentionGrab, value: isNameFocused)
                                    
                                    // Category with staggered reveal - neutral grey for subtitle
                                    Text(result.category)
                                        .font(.headline)
                                        .foregroundColor(.secondary)  // System secondary grey
                                        .enhancedReveal(stage: .category, isActive: categoryRevealed)
                                    
                                    // Confidence indicator with enhanced reveal
                                    EnhancedConfidenceIndicator(value: result.confidence)
                                        .frame(width: 180, height: 40)
                                        .padding(.top, 8)
                                        .enhancedReveal(stage: .confidence, isActive: confidenceRevealed)
                                }
                                .padding(.vertical, 16)
                                
                                // Tab selection
                                VStack(spacing: 0) {
                                    HStack {
                                        EnhancedTabButton(
                                            title: "Physical",
                                            systemImage: "ruler",
                                            isSelected: selectedTab == 0
                                        ) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedTab = 0
                                            }
                                            HapticManager.shared.selectionChanged()
                                        }
                                        .enhancedReveal(stage: .tabs(index: 0), isActive: tabsRevealed[0])
                                        
                                        EnhancedTabButton(
                                            title: "Chemical",
                                            systemImage: "atom",
                                            isSelected: selectedTab == 1
                                        ) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedTab = 1
                                            }
                                            HapticManager.shared.selectionChanged()
                                        }
                                        .enhancedReveal(stage: .tabs(index: 1), isActive: tabsRevealed[1])
                                        
                                        EnhancedTabButton(
                                            title: "Formation",
                                            systemImage: "mountain.2",
                                            isSelected: selectedTab == 2
                                        ) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedTab = 2
                                            }
                                            HapticManager.shared.selectionChanged()
                                        }
                                        .enhancedReveal(stage: .tabs(index: 2), isActive: tabsRevealed[2])
                                        
                                        EnhancedTabButton(
                                            title: "Uses",
                                            systemImage: "hammer",
                                            isSelected: selectedTab == 3
                                        ) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedTab = 3
                                            }
                                            HapticManager.shared.selectionChanged()
                                        }
                                        .enhancedReveal(stage: .tabs(index: 3), isActive: tabsRevealed[3])
                                    }
                                    .padding(.horizontal)
                                    
                                    // Tab indicator
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 3)
                                        
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: max(5, geometry.size.width / 4 - 10), height: 3)
                                            .offset(x: CGFloat(selectedTab) * (geometry.size.width / 4))
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                                    }
                                    .padding(.top, 4)
                                    .opacity(tabsRevealed.allSatisfy { $0 } ? 1 : 0)
                                        .animation(ResultRevealAnimations.Curves.storytellingFlow, value: tabsRevealed.allSatisfy { $0 })
                                }
                                
                                // Tab content with animation
                                ZStack {
                                    // Physical Properties Tab
                                    EnhancedPhysicalPropertiesView(properties: result.physicalProperties)
                                        .opacity(selectedTab == 0 ? 1 : 0)
                                        .offset(x: selectedTab == 0 ? 0 : selectedTab < 0 ? -50 : 50)
                                    
                                    // Chemical Properties Tab
                                    EnhancedChemicalPropertiesView(properties: result.chemicalProperties)
                                        .opacity(selectedTab == 1 ? 1 : 0)
                                        .offset(x: selectedTab == 1 ? 0 : selectedTab < 1 ? -50 : 50)
                                    
                                    // Formation Tab
                                    EnhancedFormationView(formation: result.formation)
                                        .opacity(selectedTab == 2 ? 1 : 0)
                                        .offset(x: selectedTab == 2 ? 0 : selectedTab < 2 ? -50 : 50)
                                    
                                    // Uses Tab with enhanced fact selection
                                    EnhancedFactDisplayView(
                                    uses: result.uses,
                                    rockName: result.name,
                        confidence: result.confidence
                    )
                    .opacity(selectedTab == 3 ? 1 : 0)
                    .offset(x: selectedTab == 3 ? 0 : selectedTab < 3 ? -50 : 50)
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                                .opacity(tabsRevealed.allSatisfy { $0 } ? 1 : 0)
                                .animation(ResultRevealAnimations.Curves.storytellingFlow.delay(0.5), value: tabsRevealed.allSatisfy { $0 })
                                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                                
                                Spacer(minLength: 60)
                            }
                        }
                        
                        // Action buttons at bottom
                        VStack(spacing: 12) {
                            Divider()
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 12) {
                                // Add to Collection button
                                Button(action: {
                                    if !addedToCollection {
                                        // Add to collection
                                        collectionManager.addRock(result)
                                        
                                        // Update UI state and provide feedback
                                        withAnimation(.spring()) {
                                            addedToCollection = true
                                        }
                                        
                                        // Haptic feedback
                                        notificationGenerator.notificationOccurred(.success)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: addedToCollection ? "checkmark.circle.fill" : "plus.circle.fill")
                                            .font(.system(size: 18))
                                        
                                        Text(addedToCollection ? "Added to Collection" : "Add to Collection")
                                            .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(addedToCollection ? Color.green : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(color: (addedToCollection ? Color.green : Color.blue).opacity(0.3), radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(EnhancedScaleButtonStyle())
                                
                                // Share buttons row
                                HStack(spacing: 12) {
                                    // Enhanced Share button
                                    Button(action: {
                                        impactGenerator.impactOccurred(intensity: 0.6)
                                        showEnhancedShareSheet = true
                                    }) {
                                        HStack {
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.system(size: 16))
                                            
                                            Text("Create & Share")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(StyleGuide.Colors.emeraldGradient)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .shadow(color: StyleGuide.Colors.emeraldGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                                    }
                                    .buttonStyle(EnhancedScaleButtonStyle())
                                    .sheet(isPresented: $showEnhancedShareSheet) {
                                        EnhancedShareSheet(result: result, isPresented: $showEnhancedShareSheet)
                                    }
                                    
                                    // Quick Share button (original functionality)
                                    Button(action: {
                                        impactGenerator.impactOccurred(intensity: 0.4)
                                        showShareSheet = true
                                    }) {
                                        HStack {
                                            Image(systemName: "photo")
                                                .font(.system(size: 14))
                                            
                                            Text("Quick Share")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(EnhancedScaleButtonStyle())
                                    .sheet(isPresented: $showShareSheet) {
                                        if let image = result.image {
                                            ShareSheet(items: [
                                                image,
                                                "I identified this \(result.name) using Rock Identifier!"
                                            ])
                                        } else {
                                            ShareSheet(items: ["I identified this \(result.name) using Rock Identifier!"])
                                        }
                                    }
                                }
                            }
                            
                            // Notes button - shows a text area for user notes
                            Button(action: {
                                impactGenerator.impactOccurred(intensity: 0.4)
                                withAnimation {
                                    showNotes.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: showNotes ? "note.text.badge.minus" : "note.text.badge.plus")
                                    Text(showNotes ? "Hide Notes" : "Add Notes")
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .foregroundColor(.primary)
                            }
                            
                            // Notes text editor - shown when notes button is toggled
                            if showNotes {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your notes about this rock:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    TextEditor(text: $userNotes)
                                        .padding(8)
                                        .frame(height: 100)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                .padding(.top, 4)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20 + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0))
                        .background(
                            Rectangle()
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: -4)
                                .edgesIgnoringSafeArea(.bottom)
                        )
                        .enhancedReveal(stage: .actions, isActive: actionsRevealed)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button(action: {
                        // Save notes if needed
                        saveFavoriteAndNotes()
                        
                        // Dismiss the view
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                        Text("Back")
                            .foregroundColor(.primary)
                    },
                    trailing: Button(action: {
                        // Save notes if needed
                        saveFavoriteAndNotes()
                        
                        // Dismiss the view
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("Done")
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                )
            }
            .onAppear {
                startEnhancedRevealAnimation()
            }
        }
    }
    
    // Save user notes and favorite status before dismissing
    private func saveFavoriteAndNotes() {
        // This updates the collection manager's stored rock with the notes
        if addedToCollection && !userNotes.isEmpty {
            // Only update notes if we've added the rock to collection and have notes
            collectionManager.updateNotes(for: result.id, notes: userNotes)
            print("Saved notes to collection: \(userNotes)")
        }
    }
    
    // Enhanced A-HA moment reveal animation sequence with dramatic storytelling
    private func startEnhancedRevealAnimation() {
        // Prepare haptic engines for the journey
        HapticManager.shared.mediumImpact() // Prepare engines
        
        // Stage 1: Image reveal (the specimen appears)
        DispatchQueue.main.asyncAfter(deadline: .now() + timing.imageAppearTime) {
            withAnimation(ResultRevealAnimations.Curves.storytellingFlow) {
                imageRevealed = true
                animationStage = .imageAppearing
                revealState = .imageRevealed
            }
            
            // Gentle haptic for image appearance
            HapticManager.shared.lightImpact()
        }
        
        // Stage 2: THE DRAMATIC PAUSE (building anticipation with progress indicator)
        DispatchQueue.main.asyncAfter(deadline: .now() + timing.imageAppearTime + timing.imageReveal) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isDramaticPause = true
                animationStage = .dramaticPause
            }
            
            // Animate progress during the pause
            withAnimation(.linear(duration: timing.dramaticPause)) {
                pauseProgress = 1.0
            }
            
            // Tension-building haptic
            HapticManager.shared.mediumImpact()
        }
        
        // Stage 3: Name reveal (the BIG moment) - hide pause indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + timing.nameAppearTime) {
            withAnimation(ResultRevealAnimations.Curves.dramaticEntrance) {
                nameRevealed = true
                animationStage = .nameAppearing
                revealState = .nameRevealed
                isDramaticPause = false  // Hide the pause indicator
            }
            
            // Major haptic for the reveal moment
            HapticManager.shared.heavyImpact()
        }
        
        // Stage 4: Name focus effect (spotlight moment)
        DispatchQueue.main.asyncAfter(deadline: .now() + timing.nameAppearTime + timing.nameReveal) {
            withAnimation(ResultRevealAnimations.Curves.attentionGrab) {
                isNameFocused = true
                showNameSpotlight = true
                animationStage = .nameFocused
            }
            
            // Success celebration haptic
            HapticManager.shared.successFeedback()
            
            // End focus after focus duration
            DispatchQueue.main.asyncAfter(deadline: .now() + timing.nameFocus) {
                withAnimation(ResultRevealAnimations.Curves.gentleFade) {
                    isNameFocused = false
                    showNameSpotlight = false
                }
            }
        }
        
        // Stage 5: Sparkles celebration (the magic moment)
        DispatchQueue.main.asyncAfter(deadline: .now() + timing.sparklesTime) {
            withAnimation(ResultRevealAnimations.Curves.bouncyReveal) {
                isSparklesActive = true
            }
            
            // Sparkles end automatically based on duration
            DispatchQueue.main.asyncAfter(deadline: .now() + timing.sparklesDuration) {
                withAnimation(ResultRevealAnimations.Curves.gentleFade) {
                    isSparklesActive = false
                }
            }
        }
        
        // Stage 6: Category reveal (supporting information)
        DispatchQueue.main.asyncAfter(deadline: .now() + timing.categoryAppearTime) {
            withAnimation(ResultRevealAnimations.Curves.storytellingFlow) {
                categoryRevealed = true
                revealState = .categoryRevealed
            }
        }
        
        // Stage 7: Confidence reveal (validation)
        DispatchQueue.main.asyncAfter(deadline: .now() + timing.confidenceAppearTime) {
            withAnimation(ResultRevealAnimations.Curves.storytellingFlow) {
                confidenceRevealed = true
                revealState = .confidenceRevealed
            }
        }
        
        // Stage 8: Sequential tab reveals (the story unfolds)
        for i in 0..<4 {
            let tabDelay = timing.firstTabTime + (Double(i) * timing.tabRevealStagger)
            DispatchQueue.main.asyncAfter(deadline: .now() + tabDelay) {
                withAnimation(ResultRevealAnimations.Curves.bouncyReveal) {
                    tabsRevealed[i] = true
                }
                
                // Subtle haptic for each tab
                HapticManager.shared.lightImpact()
                
                // Update reveal state when all tabs are revealed
                if i == 3 {
                    revealState = .tabsRevealed
                    animationStage = .tabsAppearing
                }
            }
        }
        
        // Stage 9: Actions reveal (final call to action)
        DispatchQueue.main.asyncAfter(deadline: .now() + timing.actionsStartTime) {
            withAnimation(ResultRevealAnimations.Curves.storytellingFlow) {
                actionsRevealed = true
                revealState = .complete
                animationStage = .complete
            }
            
            // Final completion haptic
            HapticManager.shared.successFeedback()
        }
        
        // Debug logging for timing optimization (can be removed in production)
        #if DEBUG
        print("[Animation] Using timing profile: \(ResultRevealAnimations.currentProfile.rawValue)")
        print("[Animation] Total sequence duration: \(timing.actionsStartTime + 0.5)s")
        #endif
    }
}

// Enhanced tab button with better visual feedback
struct EnhancedTabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

    // Enhanced confidence indicator with better visuals
struct EnhancedConfidenceIndicator: View {
    let value: Double // 0.0 to 1.0
    @State private var animatedValue: Double = 0
    @State private var pulsing: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            Capsule()
                .fill(Color(.systemGray5))
                .frame(height: 12)
            
            // Filled progress
            Capsule()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [confidenceColorStart, confidenceColorEnd]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: max(0, min(UIScreen.main.bounds.width * 0.33 * animatedValue, UIScreen.main.bounds.width * 0.33)), height: 12)
                .animation(.easeOut(duration: 1.2), value: animatedValue)
                .scaleEffect(y: pulsing ? 1.05 : 1.0, anchor: .leading)
                .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulsing)
            
            // Label
            HStack {
                Text("\(Int(value * 100))% Confidence")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                
                Spacer()
            }
            .padding(.horizontal, 10)
        }
        .onAppear {
            // Animate the fill when the view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animatedValue = value
                pulsing = true
            }
        }
    }
    
    // Dynamic gradient based on confidence level
    var confidenceColorStart: Color {
        if value >= 0.8 {
            return .green
        } else if value >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
    
    var confidenceColorEnd: Color {
        if value >= 0.8 {
            return Color.green.opacity(0.7)
        } else if value >= 0.5 {
            return Color.orange.opacity(0.7)
        } else {
            return Color.red.opacity(0.7)
        }
    }
}

// Enhanced physical properties view
struct EnhancedPhysicalPropertiesView: View {
    let properties: PhysicalProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Physical Properties")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "ruler")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 4)
            
            // Main properties section
            VStack(spacing: 16) {
                // Color with swatch
                EnhancedPropertyRow(
                    label: "Color",
                    value: properties.color,
                    iconName: "circle.fill",
                    showDivider: true
                )
                
                // Hardness with Mohs scale if available
                EnhancedPropertyRow(
                    label: "Hardness",
                    value: properties.hardness,
                    iconName: "hammer",
                    showDivider: true
                )
                
                // Luster property
                EnhancedPropertyRow(
                    label: "Luster",
                    value: properties.luster,
                    iconName: "sparkles",
                    showDivider: true
                )
                
                // Optional properties
                Group {
                    if let streak = properties.streak {
                        EnhancedPropertyRow(
                            label: "Streak",
                            value: streak,
                            iconName: "scribble",
                            showDivider: true
                        )
                    }
                    
                    if let transparency = properties.transparency {
                        EnhancedPropertyRow(
                            label: "Transparency",
                            value: transparency,
                            iconName: "eye",
                            showDivider: true
                        )
                    }
                    
                    if let crystalSystem = properties.crystalSystem {
                        EnhancedPropertyRow(
                            label: "Crystal System",
                            value: crystalSystem,
                            iconName: "cube",
                            showDivider: true
                        )
                    }
                    
                    if let cleavage = properties.cleavage {
                        EnhancedPropertyRow(
                            label: "Cleavage",
                            value: cleavage,
                            iconName: "scissors",
                            showDivider: true
                        )
                    }
                    
                    if let fracture = properties.fracture {
                        EnhancedPropertyRow(
                            label: "Fracture",
                            value: fracture,
                            iconName: "bolt.fill",
                            showDivider: true
                        )
                    }
                    
                    if let specificGravity = properties.specificGravity {
                        EnhancedPropertyRow(
                            label: "Specific Gravity",
                            value: specificGravity,
                            iconName: "scalemass",
                            showDivider: false
                        )
                    }
                }
            }
            .padding(.horizontal, 6)
            
            // Additional properties if any
            if let additionalProps = properties.additionalProperties, !additionalProps.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Properties")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    ForEach(additionalProps.keys.sorted(), id: \.self) { key in
                        if let value = additionalProps[key] {
                            EnhancedPropertyRow(
                                label: key,
                                value: value,
                                iconName: "info.circle",
                                showDivider: true
                            )
                        }
                    }
                }
                .padding(.horizontal, 6)
            }
        }
    }
}

// Enhanced chemical properties view
struct EnhancedChemicalPropertiesView: View {
    let properties: ChemicalProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Chemical Properties")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "atom")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 4)
            
            // Formula section
            if let formula = properties.formula {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chemical Formula")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formula)
                        .font(.system(size: 24, weight: .medium))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.bottom, 6)
            }
            
            // Composition
            EnhancedPropertyRow(
                label: "Composition",
                value: properties.composition,
                iconName: "doc.plaintext",
                showDivider: true
            )
            
            // Elements section
            if let elements = properties.elements, !elements.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Elements")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    ForEach(elements, id: \.symbol) { element in
                        HStack(alignment: .center, spacing: 12) {
                            // Element symbol in a box
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 40, height: 40)
                                
                                Text(element.symbol)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(element.name)
                                    .font(.system(size: 16, weight: .medium))
                                
                                if let percentage = element.percentage {
                                    // Show percentage with visual bar
                                    HStack(spacing: 6) {
                                        Text("\(String(format: "%.1f", percentage))%")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        // Percentage bar
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 100, height: 6)
                                                .cornerRadius(3)
                                            
                                            Rectangle()
                                                .fill(Color.blue)
                                                .frame(width: max(0, min(percentage, 100)) * 100 / 100, height: 6)
                                                .cornerRadius(3)
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
            
            // Minerals present
            if let minerals = properties.mineralsPresent, !minerals.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Minerals Present")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    VStack(spacing: 8) {
                        ForEach(minerals, id: \.self) { mineral in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.blue)
                                
                                Text(mineral)
                                    .font(.subheadline)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 6)
                }
            }
            
            // Reactivity
            if let reactivity = properties.reactivity {
                EnhancedPropertyRow(
                    label: "Reactivity",
                    value: reactivity,
                    iconName: "bolt.horizontal",
                    showDivider: false
                )
            }
        }
    }
}

// Enhanced formation view
struct EnhancedFormationView: View {
    let formation: Formation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Formation")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "mountain.2")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 4)
            
            // Type and environment
            VStack(spacing: 16) {
                EnhancedPropertyRow(
                    label: "Type",
                    value: formation.formationType,
                    iconName: "square.stack.3d.up",
                    showDivider: true
                )
                
                EnhancedPropertyRow(
                    label: "Environment",
                    value: formation.environment,
                    iconName: "globe",
                    showDivider: true
                )
                
                if let geologicalAge = formation.geologicalAge {
                    EnhancedPropertyRow(
                        label: "Geological Age",
                        value: geologicalAge,
                        iconName: "clock",
                        showDivider: true
                    )
                }
                
                EnhancedPropertyRow(
                    label: "Formation Process",
                    value: formation.formationProcess,
                    iconName: "arrow.triangle.merge",
                    showDivider: true
                )
            }
            .padding(.horizontal, 6)
            
            // Locations map section
            if let locations = formation.commonLocations, !locations.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common Locations")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    // World map image placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .frame(height: 150)
                            .overlay(
                                Image(systemName: "map")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                        
                        // Location list overlay
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(locations, id: \.self) { location in
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin")
                                        .foregroundColor(.red)
                                        .font(.system(size: 14))
                                    
                                    Text(location)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground).opacity(0.85))
                        .cornerRadius(10)
                        .padding(12)
                    }
                }
            }
            
            // Associated minerals
            if let minerals = formation.associatedMinerals, !minerals.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Associated Minerals")
                        .font(.headline)
                        .padding(.top, 4)
                    
                    // Horizontal scrolling list of associated minerals
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(minerals, id: \.self) { mineral in
                                Text(mineral)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}



// Enhanced property row with beautiful styling and icon colors
struct EnhancedPropertyRow: View {
    let label: String
    let value: String
    let iconName: String
    let showDivider: Bool
    
    @State private var hasAnimated = false
    @State private var shine = false
    @State private var opacity: Double = 0
    
    // Color selection based on icon for beautiful theming
    private var iconColor: Color {
        switch iconName {
        case "circle.fill":
            return StyleGuide.Colors.amethystPurple
        case "hammer":
            return StyleGuide.Colors.emeraldGreen
        case "sparkles":
            return StyleGuide.Colors.citrineGold
        case "scribble":
            return StyleGuide.Colors.roseQuartzPink
        case "eye":
            return StyleGuide.Colors.sapphireBlue
        case "cube":
            return StyleGuide.Colors.amethystPurple
        case "scissors":
            return StyleGuide.Colors.emeraldGreen
        case "bolt.fill":
            return StyleGuide.Colors.citrineGold
        case "scalemass":
            return StyleGuide.Colors.roseQuartzPink
        case "doc.plaintext":
            return StyleGuide.Colors.sapphireBlue
        case "square.stack.3d.up":
            return StyleGuide.Colors.roseQuartzPink
        case "globe":
            return StyleGuide.Colors.emeraldGreen
        case "clock":
            return StyleGuide.Colors.sapphireBlue
        case "arrow.triangle.merge":
            return StyleGuide.Colors.amethystPurple
        case "atom":
            return StyleGuide.Colors.emeraldGreen
        case "ruler":
            return StyleGuide.Colors.sapphireBlue
        case "mountain.2":
            return StyleGuide.Colors.citrineGold
        default:
            return StyleGuide.Colors.amethystPurple
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Property content
            HStack(alignment: .top, spacing: 14) {
                // Enhanced icon with subtle animation
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    
                    // Subtle pulse ring
                    Circle()
                        .stroke(iconColor.opacity(hasAnimated ? 0.0 : 0.3), lineWidth: 2)
                        .frame(width: 34, height: 34)
                        .scaleEffect(hasAnimated ? 1.2 : 1.0)
                        .opacity(hasAnimated ? 0.0 : 1.0)
                        .animation(
                            Animation.easeOut(duration: 1.0).delay(0.3),
                            value: hasAnimated
                        )
                    
                    // Shine effect overlay
                    Circle()
                        .trim(from: 0.0, to: 0.2)
                        .stroke(Color.white.opacity(shine ? 0.0 : 0.6), lineWidth: 2)
                        .frame(width: 30, height: 30)
                        .rotationEffect(Angle(degrees: shine ? 360 : 0))
                        .animation(Animation.linear(duration: 1.2).delay(0.5).repeatCount(1, autoreverses: false),
                                   value: shine)
                    
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.system(size: 16, weight: .medium))
                }
                
                // Label and value with improved typography
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                    
                    Text(value)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.6), value: opacity)
            .onAppear {
                // Fade in with slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    opacity = 1.0
                    hasAnimated = true
                    shine = true
                }
            }
            
            // Enhanced divider with gradient
            if showDivider {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        iconColor.opacity(0.3),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .padding(.leading, 44)
                .padding(.top, 8)
            }
        }
    }
}

// Note: Old SparklesView replaced by EnhancedSparklesView in ResultRevealAnimations.swift

struct EnhancedRockResultView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock data for preview
        let mockPhysicalProperties = PhysicalProperties(
            color: "Purple to violet",
            hardness: "7 (Mohs scale)",
            luster: "Vitreous",
            streak: "White",
            transparency: "Transparent to Translucent",
            crystalSystem: "Hexagonal",
            cleavage: "None",
            fracture: "Conchoidal",
            specificGravity: "2.65"
        )
        
        let mockChemicalProperties = ChemicalProperties(
            formula: "SiO₂",
            composition: "Silicon dioxide",
            elements: [
                Element(name: "Silicon", symbol: "Si", percentage: 46.7),
                Element(name: "Oxygen", symbol: "O", percentage: 53.3)
            ],
            mineralsPresent: ["Quartz"],
            reactivity: "None"
        )
        
        let mockFormation = Formation(
            formationType: "Mineral",
            environment: "Forms in vugs and cavities in igneous rocks",
            geologicalAge: "Various ages",
            commonLocations: ["Brazil", "Uruguay", "Zambia", "South Korea", "Russia"],
            associatedMinerals: ["Quartz", "Calcite", "Fluorite"],
            formationProcess: "Crystallizes from silicon-rich fluids"
        )
        
        let mockUses = Uses(
            industrial: ["Jewelry making", "Decorative stones", "Electronics"],
            historical: ["Used by ancient Egyptians for jewelry", "Believed to protect against intoxication"],
            modern: ["Gemstone jewelry", "Ornamental objects", "Crystal healing"],
            metaphysical: ["Associated with spiritual awareness", "Said to promote calm and balance"],
            funFacts: [
                "The name comes from Ancient Greek 'amethystos' meaning 'not intoxicated'",
                "It's the birthstone for February",
                "Amethyst loses its color when heated, turning yellow or orange"
            ]
        )
        
        let mockResult = RockIdentificationResult(
            image: UIImage(systemName: "photo"),
            name: "Amethyst",
            category: "Quartz Variety",
            confidence: 0.92,
            physicalProperties: mockPhysicalProperties,
            chemicalProperties: mockChemicalProperties,
            formation: mockFormation,
            uses: mockUses
        )
        
        return EnhancedRockResultView(
            isPresented: .constant(true),
            result: mockResult,
            collectionManager: CollectionManager()
        )
    }
}
