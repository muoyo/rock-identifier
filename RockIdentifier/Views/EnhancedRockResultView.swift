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
    @State private var showNotes: Bool = false
    @State private var userNotes: String = ""
    @State private var backgroundGradientRotation = 0.0
    
    // Animation state variables
    @State private var revealState: RevealState = .initial
    @State private var imageScale: CGFloat = 0.8
    @State private var imageOpacity: Double = 0
    @State private var nameOpacity: Double = 0
    @State private var nameScale: CGFloat = 0.95
    @State private var categoryOpacity: Double = 0
    @State private var confidenceOpacity: Double = 0
    @State private var tabsOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var actionsOpacity: Double = 0
    @State private var sparklesActive: Bool = false
    
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
    
    // A-HA reveal animation timing - optimized for delight
    let imageAnimationDelay: Double = 0.2
    let nameAnimationDelay: Double = 0.8
    let categoryAnimationDelay: Double = 1.3
    let confidenceAnimationDelay: Double = 1.7
    let tabsAnimationDelay: Double = 2.1
    let contentAnimationDelay: Double = 2.3
    let actionsAnimationDelay: Double = 2.5
    let confettiAnimationDelay: Double = 1.4
    
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
                    
                    // Sparkles/particles effect (shown during A-HA moment)
                    if sparklesActive {
                        SparklesView()
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
                                                    .scaleEffect(imageScale)
                                                    .opacity(imageOpacity)
                                    } else {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.7)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .font(.system(size: 50))
                                                    .foregroundColor(.white.opacity(0.7))
                                            )
                                            .scaleEffect(imageScale)
                                            .opacity(imageOpacity)
                                    }
                                    
                                    // Recognition badge - appears in lower right of image
                                    if revealState != .initial {
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(.white)
                                            Text("Identified")
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green)
                                        .cornerRadius(16)
                                        .offset(x: -16, y: 16)
                                        .opacity(min(imageOpacity * 1.3, 1.0))
                                        .animation(.easeInOut(duration: 0.5).delay(0.8), value: imageOpacity)
                                    }
                                }
                                .padding(.top, 20)
                                
                                // Rock name and category
                                VStack(spacing: 8) {
                                    // Rock name
                                    Text(result.name)
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal)
                                        .scaleEffect(nameScale)
                                        .opacity(nameOpacity)
                                        .shadow(color: Color.blue.opacity(0.2), radius: 2, x: 0, y: 1)
                                    
                                    // Category
                                    Text(result.category)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .opacity(categoryOpacity)
                                    
                                    // Confidence indicator
                                    EnhancedConfidenceIndicator(value: result.confidence)
                                        .frame(width: 160, height: 36)
                                        .padding(.top, 8)
                                        .opacity(confidenceOpacity)
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
                                            impactGenerator.impactOccurred(intensity: 0.5)
                                        }
                                        
                                        EnhancedTabButton(
                                            title: "Chemical",
                                            systemImage: "atom",
                                            isSelected: selectedTab == 1
                                        ) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedTab = 1
                                            }
                                            impactGenerator.impactOccurred(intensity: 0.5)
                                        }
                                        
                                        EnhancedTabButton(
                                            title: "Formation",
                                            systemImage: "mountain.2",
                                            isSelected: selectedTab == 2
                                        ) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedTab = 2
                                            }
                                            impactGenerator.impactOccurred(intensity: 0.5)
                                        }
                                        
                                        EnhancedTabButton(
                                            title: "Uses",
                                            systemImage: "hammer",
                                            isSelected: selectedTab == 3
                                        ) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedTab = 3
                                            }
                                            impactGenerator.impactOccurred(intensity: 0.5)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .opacity(tabsOpacity)
                                    
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
                                    .opacity(tabsOpacity)
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
                                    
                                    // Uses Tab
                                    EnhancedUsesView(uses: result.uses)
                                        .opacity(selectedTab == 3 ? 1 : 0)
                                        .offset(x: selectedTab == 3 ? 0 : selectedTab < 3 ? -50 : 50)
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                                .opacity(contentOpacity)
                                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                                
                                Spacer(minLength: 60)
                            }
                        }
                        
                        // Action buttons at bottom
                        VStack(spacing: 12) {
                            Divider()
                                .padding(.bottom, 8)
                            
                            HStack(spacing: 20) {
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
                                
                                // Share button
                                Button(action: {
                                    impactGenerator.impactOccurred(intensity: 0.6)
                                    showShareSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 16))
                                        
                                        Text("Share")
                                            .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                                }
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
                        .opacity(actionsOpacity)
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
                startRevealAnimation()
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
    
    // A-HA moment reveal animation sequence
    private func startRevealAnimation() {
        // Prepare by loading haptic engines
        impactGenerator.prepare()
        notificationGenerator.prepare()
        
        // Image reveal
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.6).delay(imageAnimationDelay)) {
            imageOpacity = 1.0
            imageScale = 1.0
            revealState = .imageRevealed
        }
        
        // First haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + imageAnimationDelay + 0.2) {
            impactGenerator.impactOccurred(intensity: 0.5)
        }
        
        // Name reveal
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.6).delay(nameAnimationDelay)) {
            nameOpacity = 1.0
            nameScale = 1.0
            revealState = .nameRevealed
        }
        
        // Second haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + nameAnimationDelay + 0.1) {
            impactGenerator.impactOccurred(intensity: 0.6)
        }
        
        // Category reveal with spring animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5).delay(categoryAnimationDelay)) {
            categoryOpacity = 1.0
            revealState = .categoryRevealed
        }
        
        // Sparkles effect
        DispatchQueue.main.asyncAfter(deadline: .now() + confettiAnimationDelay) {
            withAnimation {
                sparklesActive = true
            }
            
            // Success notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                notificationGenerator.notificationOccurred(.success)
            }
            
            // Hide sparkles after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    sparklesActive = false
                }
            }
        }
        
        // Confidence reveal with spring animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.6).delay(confidenceAnimationDelay)) {
            confidenceOpacity = 1.0
            revealState = .confidenceRevealed
        }
        
        // Tabs reveal with spring animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5).delay(tabsAnimationDelay)) {
            tabsOpacity = 1.0
            revealState = .tabsRevealed
        }
        
        // Tab content reveal
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.6).delay(contentAnimationDelay)) {
            contentOpacity = 1.0
            revealState = .contentRevealed
        }
        
        // Action buttons reveal
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5).delay(actionsAnimationDelay)) {
            actionsOpacity = 1.0
            revealState = .complete
        }
        
        // Additional haptic feedback at completion
        DispatchQueue.main.asyncAfter(deadline: .now() + actionsAnimationDelay + 0.3) {
            impactGenerator.impactOccurred(intensity: 0.4)
        }
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

// Enhanced uses view
struct EnhancedUsesView: View {
    let uses: Uses
    
    // State for cycling through fun facts
    @State private var currentFactIndex = 0
    let factsTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Uses & Interesting Facts")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "hammer")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 4)
            
            // Fun Facts carousel - the "Did You Know" section
            if !uses.funFacts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Did You Know?")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Fun fact card with rotating facts
                    ZStack {
                        // Only show current fact
                        ForEach(0..<uses.funFacts.count, id: \.self) { index in
                            if index == currentFactIndex {
                                FunFactCard(fact: uses.funFacts[index], factNumber: index + 1, totalFacts: uses.funFacts.count)
                                    .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .trailing)),
                                                           removal: .opacity.combined(with: .move(edge: .leading))))
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.5), value: currentFactIndex)
                    .frame(height: 120)
                }
                .padding(.bottom, 10)
                .onReceive(factsTimer) { _ in
                    // Cycle to next fact every 5 seconds
                    if uses.funFacts.count > 1 {
                        withAnimation {
                            currentFactIndex = (currentFactIndex + 1) % uses.funFacts.count
                        }
                    }
                }
            }
            
            // Uses sections
            Group {
                // Historical uses
                if let historical = uses.historical, !historical.isEmpty {
                    EnhancedUsesSection(title: "Historical Uses", items: historical, iconName: "scroll")
                        .padding(.vertical, 4)
                }
                
                // Modern uses
                if let modern = uses.modern, !modern.isEmpty {
                    EnhancedUsesSection(title: "Modern Uses", items: modern, iconName: "clock")
                        .padding(.vertical, 4)
                }
                
                // Industrial uses
                if let industrial = uses.industrial, !industrial.isEmpty {
                    EnhancedUsesSection(title: "Industrial Uses", items: industrial, iconName: "gearshape.2")
                        .padding(.vertical, 4)
                }
                
                // Metaphysical properties
                if let metaphysical = uses.metaphysical, !metaphysical.isEmpty {
                    EnhancedUsesSection(title: "Metaphysical Properties", items: metaphysical, iconName: "sparkles")
                        .padding(.vertical, 4)
                }
            }
        }
    }
}

// Fun fact card component with nice styling
struct FunFactCard: View {
    let fact: String
    let factNumber: Int
    let totalFacts: Int
    
    @State private var isPulsing = false
    @State private var lightbulbRotation = 0.0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Card background with gradient
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color.yellow.opacity(0.25),
                        Color.orange.opacity(0.2),
                        Color.orange.opacity(0.15)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.5),
                                Color.orange.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1.5)
                )
                .shadow(color: Color.yellow.opacity(0.2), radius: isPulsing ? 6 : 3, x: 0, y: 0)
                .scaleEffect(isPulsing ? 1.01 : 1.0)
                .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPulsing)
                .onAppear {
                    isPulsing = true
                }
            
            // Card content
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    // Lightbulb icon with glow and rotation
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .blur(radius: isPulsing ? 6 : 4)
                        
                        // Icon
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.yellow)
                            .rotationEffect(.degrees(lightbulbRotation))
                            .animation(Animation.easeInOut(duration: 0.2).delay(1.5), value: lightbulbRotation)
                    }
                    .padding(.top, 3)
                    .onAppear {
                        // Small rotation effect after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            lightbulbRotation = 10
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                lightbulbRotation = -5
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    lightbulbRotation = 0
                                }
                            }
                        }
                    }
                    
                    // Fact text
                    Text(fact)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.trailing, 24)
                }
                
                Spacer()
                
                // Fact counter (e.g., 1/3)
                HStack {
                    Spacer()
                    
                    Text("\(factNumber)/\(totalFacts)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            
            // Page indicator dots
            if totalFacts > 1 {
                HStack(spacing: 4) {
                    ForEach(0..<totalFacts, id: \.self) { index in
                        Circle()
                            .fill(index == factNumber - 1 ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(8)
            }
        }
    }
}

// Enhanced uses section component
struct EnhancedUsesSection: View {
    let title: String
    let items: [String]
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section header
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
            }
            
            // Items list
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        // Bullet point with custom style
                        Circle()
                            .fill(Color.blue.opacity(0.6))
                            .frame(width: 6, height: 6)
                            .padding(.top, 8)
                        
                        Text(item)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 4)
        }
    }
}

// Enhanced property row component
struct EnhancedPropertyRow: View {
    let label: String
    let value: String
    let iconName: String
    let showDivider: Bool
    
    @State private var shine = false
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Property content
            HStack(alignment: .center, spacing: 12) {
                // Icon with pulse effect
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    // Shine effect
                    Circle()
                        .trim(from: 0.0, to: 0.2)
                        .stroke(Color.white.opacity(shine ? 0.0 : 0.5), lineWidth: 2)
                        .frame(width: 30, height: 30)
                        .rotationEffect(Angle(degrees: shine ? 360 : 0))
                        .animation(Animation.linear(duration: 1.2).delay(0.5).repeatCount(1, autoreverses: false),
                                   value: shine)
                    
                    // Icon
                    Image(systemName: iconName)
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                }
                
                // Label and value
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.system(size: 16))
                }
                
                Spacer()
            }
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.6), value: opacity)
            .onAppear {
                // Fade in with slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    opacity = 1.0
                    shine = true
                }
            }
            
            // Optional divider
            if showDivider {
                Divider()
                    .padding(.leading, 36)
                    .padding(.top, 8)
            }
        }
    }
}

// Sparkles view for the A-HA reveal animation
struct SparklesView: View {
    let sparkleCount = 50
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<sparkleCount, id: \.self) { index in
                    let isLarge = index % 10 == 0
                    
                    Sparkle(
                        size: isLarge ? CGFloat.random(in: 15...25) : CGFloat.random(in: 5...15),
                        position: CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.8)
                        ),
                        delay: Double.random(in: 0...2.0),
                        duration: Double.random(in: 1.0...3.0),
                        useAlternateIcon: Bool.random(),
                        color: sparkleColor(for: index)
                    )
                }
            }
        }
    }
    
    // Generate varied colors for sparkles
    private func sparkleColor(for index: Int) -> Color {
        let colors: [Color] = [
            .yellow,
            .yellow.opacity(0.8),
            .orange.opacity(0.9),
            .white.opacity(0.95),
            .yellow.opacity(0.7)
        ]
        
        return colors[index % colors.count]
    }
}

// Individual sparkle effect
struct Sparkle: View {
    let size: CGFloat
    let position: CGPoint
    let delay: Double
    let duration: Double
    let useAlternateIcon: Bool
    let color: Color
    
    @State private var isAnimating = false
    @State private var rotation: Double = Double.random(in: 0...360)
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    
    var body: some View {
        Group {
            if useAlternateIcon {
                Image(systemName: "sparkle")
                    .font(.system(size: size))
                    .foregroundColor(color)
                    .position(position)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotationEffect(.degrees(rotation))
                    .shadow(color: color.opacity(0.7), radius: 2, x: 0, y: 0)
                    .onAppear {
                        withAnimation(Animation.easeOut(duration: 0.2).delay(delay)) {
                            opacity = 0.9
                            scale = 1.0
                        }
                        
                        withAnimation(Animation.easeIn(duration: duration).delay(delay + 0.2)) {
                            opacity = 0
                            scale = 1.5
                            rotation += Double.random(in: 180...360)
                        }
                    }
            } else {
                Image(systemName: Bool.random() ? "star.fill" : "star")
                    .font(.system(size: size * 0.8))
                    .foregroundColor(color)
                    .position(position)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotationEffect(.degrees(rotation))
                    .shadow(color: color.opacity(0.7), radius: 2, x: 0, y: 0)
                    .onAppear {
                        withAnimation(Animation.easeOut(duration: 0.2).delay(delay)) {
                            opacity = 0.9
                            scale = 1.0
                        }
                        
                        withAnimation(Animation.easeIn(duration: duration).delay(delay + 0.2)) {
                            opacity = 0
                            scale = 1.5
                            rotation += Double.random(in: 180...360)
                        }
                    }
            }
        }
    }
}

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
