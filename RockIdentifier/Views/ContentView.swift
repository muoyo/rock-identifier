// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import AVFoundation
import UIKit

struct ContentView: View {
    // State for camera activation
    @State private var cameraIsActive: Bool = true
    
    // State for displaying collection
    @State private var showCollection: Bool = false
    
    // Rock identification service
    @StateObject private var identificationService = RockIdentificationService()
    
    // Subscription manager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    // Collection manager
    @StateObject private var collectionManager = CollectionManager()
    
    // Result presentation state
    @State private var showResultView: Bool = false
    
    // Current user tier - would be managed by subscription service
    // Using subscription service for tier information
    
    // Using subscription manager for remaining identifications count
    
    // Processing view state
    @State private var showProcessingView: Bool = false
    
    // Developer settings sheet
    @State private var showDeveloperSettings: Bool = false
    
    // Initialize notification observer for developer mode toggle
    init() {
        // Set up notification observer for developer mode toggle
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ToggleDeveloperMode"),
            object: nil,
            queue: .main
        ) { _ in
            // Toggle developer mode
            // We can't use a capture list here because this is initialized before the EnvironmentObject
            // The toggle will be handled in the .onReceive view modifier instead
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Camera view
            CameraView(
                isActive: $cameraIsActive,
                onCaptureImage: { image in
                    // When an image is captured, process it
                    withAnimation {
                        // Only show processing view if we have identifications left
                        if subscriptionManager.status.isActive || subscriptionManager.remainingIdentifications > 0 {
                            showProcessingView = true
                            processImage(image)
                        } else {
                            // If no identifications left, don't even show processing view
                            print("No identifications remaining - showing paywall instead")
                            // Show the paywall
                            if !subscriptionManager.status.isActive && subscriptionManager.remainingIdentifications <= 0 {
                                PaywallManager.shared.showSoftPaywall()
                            }
                        }
                    }
                },
                showCollection: $showCollection,
                remainingIdentifications: subscriptionManager.remainingIdentifications
            )
            
            // Processing view overlay
            if showProcessingView {
                ProcessingView(
                    isVisible: $showProcessingView,
                    capturedImage: identificationService.currentImage,
                    onProcessingComplete: { result in
                        // Update the identification service with the result
                        identificationService.state = .success(result)
                    }
                )
                .zIndex(10) // Ensure it's above other views
                .transition(.opacity)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.black)
        // Show collection sheet
        .sheet(isPresented: $showCollection) {
            // Show collection view
            CollectionListView(
                isPresented: $showCollection,
                collectionManager: collectionManager
            )
        }
        // Show result sheet
        .sheet(isPresented: $showResultView) {
            // Show result view after identification
            if case .success(let result) = identificationService.state {
                EnhancedRockResultView(
                    isPresented: $showResultView,
                    result: result,
                    collectionManager: collectionManager
                )
                .onDisappear {
                    // Reset camera view and identification state when result view is dismissed
                    identificationService.state = .idle
                    withAnimation {
                        cameraIsActive = true
                    }
                }
            }
        }
        // Show developer settings sheet
        .sheet(isPresented: $showDeveloperSettings) {
            DeveloperSettingsView(
                isPresented: $showDeveloperSettings,
                subscriptionManager: subscriptionManager
            )
        }
        // Show error alert if identification fails
        .alert(isPresented: .constant(identificationService.state.errorMessage != nil)) {
            Alert(
                title: Text("Identification Failed"),
                message: Text(identificationService.state.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    // Reset state and camera
                    identificationService.state = .idle
                    withAnimation {
                        cameraIsActive = true
                    }
                }
            )
        }
        .onChange(of: identificationService.state) { state in
            // React to changes in identification state
            switch state {
            case .success:
                // Hide processing view first
                withAnimation {
                    showProcessingView = false
                }
                
                // Switch to success state
                // Important: First deactivate camera, then show result view
                // with a slight delay to allow for proper transitions
                cameraIsActive = false
                
                // Notify FreeTierManager of successful identification
                // This might trigger a soft paywall based on remaining identifications
                FreeTierManager.shared.handleSuccessfulIdentification()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("Showing result view")
                    showResultView = true
                }
                
            case .error:
                // Hide processing view and show error
                withAnimation {
                    showProcessingView = false
                }
                
                // Error handling is done via alert
                print("Identification error: \(state.errorMessage ?? "Unknown error")")
                
            case .processing:
                // Processing is now shown with the dedicated processing view
                print("Processing identification")
                
            case .idle:
                // Initial state
                print("Identification service idle")
            }
        }
        // Handle developer mode toggle notification
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleDeveloperMode"))) { _ in
            // Show developer settings
            showDeveloperSettings = true
            
            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    // Process the captured image
    private func processImage(_ image: UIImage) {
        // Check if user has identifications remaining
        if !subscriptionManager.status.isActive && subscriptionManager.remainingIdentifications <= 0 {
            // Use FreeTierManager to handle this case - it will show the paywall if needed
            print("Identification limit reached - showing paywall")
            
            // Hide processing view immediately
            withAnimation {
                showProcessingView = false
            }
            
            // Show soft paywall
            PaywallManager.shared.showSoftPaywall()
            
            // *** DO NOT PROCEED WITH IDENTIFICATION ***
            return
        }
        
        // Record the identification (updates counter for free tier)
        let recordSuccess = subscriptionManager.recordIdentification()
        if !recordSuccess {
            // If we couldn't record (reached limit), show paywall
            print("Identification limit reached - showing paywall")
            
            // Hide processing view immediately
            withAnimation {
                showProcessingView = false
            }
            
            // Show soft paywall
            PaywallManager.shared.showSoftPaywall()
            
            // *** DO NOT PROCEED WITH IDENTIFICATION ***
            return
        }
        
        // Process the image with the identification service
        identificationService.identifyRock(from: image)
    }
}

// Extension to get error message from identification state
extension IdentificationState {
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}

// User tier enum
enum UserTier {
    case free
    case premium
}

// Placeholder for CollectionListView (to be implemented in Phase 3)
struct CollectionListView: View {
    @Binding var isPresented: Bool
    var collectionManager: CollectionManager
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Your Collection")
                    .font(.largeTitle)
                    .padding()
                
                if collectionManager.collection.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "square.stack.3d.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        
                        Text("No rocks in your collection yet")
                            .font(.headline)
                        
                        Text("Take a photo to identify a rock and add it to your collection")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Start Identifying")
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    // Collection list (placeholder)
                    Text("Your rocks will appear here")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

struct RockResultView: View {
    @Binding var isPresented: Bool
    let result: RockIdentificationResult
    let collectionManager: CollectionManager
    
    @State private var addedToCollection: Bool = false
    @State private var selectedTab = 0
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Rock image and basic info
                ScrollView {
                    VStack {
                        if let image = result.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .shadow(radius: 4)
                                .frame(maxHeight: 250)
                                .padding()
                        }
                        
                        // Rock name and category
                        VStack(spacing: 8) {
                            Text(result.name)
                                .font(.system(size: 32, weight: .bold))
                                .multilineTextAlignment(.center)
                            
                            Text(result.category)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            // Confidence indicator
                            ConfidenceIndicator(value: result.confidence)
                                .frame(width: 140, height: 30)
                                .padding(.top, 4)
                        }
                        .padding(.bottom)
                        
                        // Tab selection
                        VStack(spacing: 0) {
                            HStack {
                                TabButton(title: "Physical", systemImage: "ruler", isSelected: selectedTab == 0) {
                                    selectedTab = 0
                                }
                                
                                TabButton(title: "Chemical", systemImage: "atom", isSelected: selectedTab == 1) {
                                    selectedTab = 1
                                }
                                
                                TabButton(title: "Formation", systemImage: "mountain.2", isSelected: selectedTab == 2) {
                                    selectedTab = 2
                                }
                                
                                TabButton(title: "Uses", systemImage: "hammer", isSelected: selectedTab == 3) {
                                    selectedTab = 3
                                }
                            }
                            .padding(.horizontal)
                            
                            Divider()
                                .padding(.top, 8)
                        }
                        
                        // Tab content
                        VStack(alignment: .leading, spacing: 20) {
                            switch selectedTab {
                            case 0:
                                PhysicalPropertiesView(properties: result.physicalProperties)
                            case 1:
                                ChemicalPropertiesView(properties: result.chemicalProperties)
                            case 2:
                                FormationView(formation: result.formation)
                            case 3:
                                UsesView(uses: result.uses)
                            default:
                                PhysicalPropertiesView(properties: result.physicalProperties)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Divider()
                
                // Action buttons
                HStack(spacing: 20) {
                    Button(action: {
                        // Add to collection
                        if !addedToCollection {
                            collectionManager.addRock(result)
                            addedToCollection = true
                            
                            // Haptic feedback
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }
                    }) {
                        Label(
                            addedToCollection ? "Added to Collection" : "Add to Collection",
                            systemImage: addedToCollection ? "checkmark.circle.fill" : "plus.circle"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(addedToCollection ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray4))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showShareSheet) {
                        // Basic share sheet implementation
                        ShareSheet(items: ["Check out this \(result.name) I identified using Rock Identifier!"])
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
}

// Tab button component
struct TabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .blue : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// Individual tab views
struct PhysicalPropertiesView: View {
    let properties: PhysicalProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Physical Properties")
                .font(.title2)
                .bold()
            
            PropertyRow(label: "Color", value: properties.color)
            PropertyRow(label: "Hardness", value: properties.hardness)
            PropertyRow(label: "Luster", value: properties.luster)
            
            if let streak = properties.streak {
                PropertyRow(label: "Streak", value: streak)
            }
            
            if let transparency = properties.transparency {
                PropertyRow(label: "Transparency", value: transparency)
            }
            
            if let crystalSystem = properties.crystalSystem {
                PropertyRow(label: "Crystal System", value: crystalSystem)
            }
            
            if let cleavage = properties.cleavage {
                PropertyRow(label: "Cleavage", value: cleavage)
            }
            
            if let fracture = properties.fracture {
                PropertyRow(label: "Fracture", value: fracture)
            }
            
            if let specificGravity = properties.specificGravity {
                PropertyRow(label: "Specific Gravity", value: specificGravity)
            }
        }
    }
}

struct ChemicalPropertiesView: View {
    let properties: ChemicalProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chemical Properties")
                .font(.title2)
                .bold()
            
            if let formula = properties.formula {
                PropertyRow(label: "Chemical Formula", value: formula)
            }
            
            PropertyRow(label: "Composition", value: properties.composition)
            
            if let elements = properties.elements, !elements.isEmpty {
                Text("Elements")
                    .font(.headline)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(elements, id: \.symbol) { element in
                        HStack(alignment: .top) {
                            Text("\(element.symbol)")
                                .font(.subheadline)
                                .frame(width: 30, alignment: .leading)
                                .bold()
                            
                            Text(element.name)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            if let percentage = element.percentage {
                                Text("\(String(format: "%.1f", percentage))%")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    }
                }
            }
        }
    }
}

struct FormationView: View {
    let formation: Formation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Formation")
                .font(.title2)
                .bold()
            
            PropertyRow(label: "Type", value: formation.formationType)
            PropertyRow(label: "Environment", value: formation.environment)
            
            if let geologicalAge = formation.geologicalAge {
                PropertyRow(label: "Geological Age", value: geologicalAge)
            }
            
            if let locations = formation.commonLocations, !locations.isEmpty {
                Text("Common Locations")
                    .font(.headline)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(locations, id: \.self) { location in
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.secondary)
                            Text(location)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.leading, 4)
            }
            
            PropertyRow(label: "Formation Process", value: formation.formationProcess)
        }
    }
}

struct UsesView: View {
    let uses: Uses
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Uses & Interesting Facts")
                .font(.title2)
                .bold()
            
            if let industrial = uses.industrial, !industrial.isEmpty {
                UsesSection(title: "Industrial Uses", items: industrial, iconName: "gearshape.2")
            }
            
            if let historical = uses.historical, !historical.isEmpty {
                UsesSection(title: "Historical Uses", items: historical, iconName: "scroll")
            }
            
            if let modern = uses.modern, !modern.isEmpty {
                UsesSection(title: "Modern Uses", items: modern, iconName: "desktopcomputer")
            }
            
            if let metaphysical = uses.metaphysical, !metaphysical.isEmpty {
                UsesSection(title: "Metaphysical Properties", items: metaphysical, iconName: "sparkles")
            }
            
            if !uses.funFacts.isEmpty {
                Text("Fun Facts")
                    .font(.headline)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(uses.funFacts, id: \.self) { fact in
                        HStack(alignment: .top) {
                            Image(systemName: "lightbulb")
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            
                            Text(fact)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

struct UsesSection: View {
    let title: String
    let items: [String]
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top) {
                        Image(systemName: iconName)
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        Text(item)
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}

struct PropertyRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}

// ShareSheet implementation moved to dedicated ShareSheet.swift file

// Confidence indicator component
struct ConfidenceIndicator: View {
    let value: Double // 0.0 to 1.0
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background
            Rectangle()
                .foregroundColor(Color(.systemGray5))
                .cornerRadius(5)
            
            // Fill
            Rectangle()
                .frame(width: CGFloat(value) * UIScreen.main.bounds.width * 0.3)
                .foregroundColor(confidenceColor)
                .cornerRadius(5)
            
            // Text
            Text("\(Int(value * 100))% Confidence")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
        }
    }
    
    // Color based on confidence level
    var confidenceColor: Color {
        if value >= 0.8 {
            return .green
        } else if value >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
}
