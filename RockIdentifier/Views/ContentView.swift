// Rock Identifier: Crystal ID - Restored Seamless Experience
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
    
    // Processing view state
    @State private var showProcessingView: Bool = false
    
    // Developer settings sheet
    @State private var showDeveloperSettings: Bool = false
    
    // Settings sheet
    @State private var showSettings: Bool = false
    
    // Camera permission modal state
    @State private var showCameraPermissionModal: Bool = false
    @State private var cameraPermissionGranted: Bool = false
    
    // Track onboarding completion
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // Observe app state for paywall changes
    @ObservedObject private var appState = AppState.shared
    
    // Initialize notification observer for developer mode toggle
    init() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ToggleDeveloperMode"),
            object: nil,
            queue: .main
        ) { _ in
            // Toggle will be handled in .onReceive view modifier
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Camera view
            CameraView(
                isActive: Binding(
                    get: { cameraIsActive && cameraPermissionGranted },
                    set: { cameraIsActive = $0 }
                ),
                onCaptureImage: { image in
                    withAnimation {
                        if subscriptionManager.status.isActive || subscriptionManager.remainingIdentifications > 0 {
                            showProcessingView = true
                            processImage(image)
                        } else {
                            print("No identifications remaining - showing paywall instead")
                            if !subscriptionManager.status.isActive && subscriptionManager.remainingIdentifications <= 0 {
                                PaywallManager.shared.showSoftPaywall()
                            }
                        }
                    }
                },
                onShowSettings: {
                    showSettings = true
                },
                showCollection: $showCollection,
                remainingIdentifications: subscriptionManager.remainingIdentifications
            )
            
            // Processing view overlay - Back to original seamless experience
            if showProcessingView {
                ProcessingView(
                    isVisible: $showProcessingView,
                    capturedImage: identificationService.currentImage,
                    onProcessingComplete: { result in
                        // Update the identification service with the result
                        identificationService.state = .success(result)
                    }
                )
                .zIndex(10)
                .transition(.opacity)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.black)
        // Show collection sheet
        .sheet(isPresented: $showCollection) {
            CollectionListView(
                isPresented: $showCollection,
                collectionManager: collectionManager
            )
        }
        // Show result sheet
        .sheet(isPresented: $showResultView) {
            if case .success(let result) = identificationService.state {
                EnhancedRockResultView(
                    isPresented: $showResultView,
                    result: result,
                    collectionManager: collectionManager
                )
                .onDisappear {
                    resetToCamera()
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
        // Show settings sheet
        .sheet(isPresented: $showSettings) {
            SettingsView(isPresented: $showSettings)
                .environmentObject(subscriptionManager)
        }
        // Show error alert if identification fails
        .alert(isPresented: .constant(identificationService.state.errorMessage != nil)) {
            Alert(
                title: Text("Identification Failed"),
                message: Text(identificationService.state.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    resetToCamera()
                }
            )
        }
        .onChange(of: identificationService.state) { state in
            handleStateChange(state)
        }
        // Handle developer mode toggle notification
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleDeveloperMode"))) { _ in
            showDeveloperSettings = true
            HapticManager.shared.successFeedback()
        }
        // Camera permission modal overlay
        .overlay(
            Group {
                if showCameraPermissionModal {
                    CameraPermissionModalView(
                        isPresented: $showCameraPermissionModal,
                        onPermissionGranted: {
                            cameraPermissionGranted = true
                            // Small delay to let modal dismiss animation complete
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                // Camera will now initialize properly
                                print("Camera permission granted, camera will become active")
                            }
                        }
                    )
                    .transition(.opacity)
                }
            }
        )
        // Check camera permission when paywall states change
        .onChange(of: appState.showHardPaywall) { _ in
            // When hard paywall is dismissed, check camera permission
            if !appState.showHardPaywall {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("Hard paywall dismissed - checking camera permission")
                    checkInitialCameraPermission()
                }
            }
        }
        .onChange(of: appState.showSoftPaywall) { showingSoftPaywall in
            print("RockIdentifierApp: Soft paywall state changed to: \(showingSoftPaywall)")
            // When soft paywall is dismissed, check camera permission
            if !showingSoftPaywall {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("Soft paywall dismissed - checking camera permission")
                    checkInitialCameraPermission()
                }
            }
        }
    }
    
    // Handle state changes - Back to original simple flow
    private func handleStateChange(_ state: IdentificationState) {
        switch state {
        case .processing:
            print("Processing identification")
            
        case .retrying(let attempt, let totalAttempts):
            print("Retrying identification: attempt \(attempt + 1) of \(totalAttempts + 1)")
            
        case .success:
            print("Identification complete")
            // Hide processing view first
            withAnimation {
                showProcessingView = false
            }
            
            // Switch to success state
            cameraIsActive = false
            
            // Notify FreeTierManager of successful identification
            FreeTierManager.shared.handleSuccessfulIdentification()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("Showing result view")
                showResultView = true
            }
            
        case .error:
            print("Identification error: \(state.errorMessage ?? "Unknown error")")
            // Hide processing view and show error
            withAnimation {
                showProcessingView = false
            }
            HapticManager.shared.errorFeedback()
            
        case .idle:
            print("Identification service idle")
        }
    }
    
    // Process the captured image
    private func processImage(_ image: UIImage) {
        // Check if user has identifications remaining
        if !subscriptionManager.status.isActive && subscriptionManager.remainingIdentifications <= 0 {
            print("Identification limit reached - showing paywall")
            
            withAnimation {
                showProcessingView = false
            }
            
            PaywallManager.shared.showSoftPaywall()
            return
        }
        
        // Record the identification
        let recordSuccess = subscriptionManager.recordIdentification()
        if !recordSuccess {
            print("Identification limit reached - showing paywall")
            
            withAnimation {
                showProcessingView = false
            }
            
            PaywallManager.shared.showSoftPaywall()
            return
        }
        
        // Process the image with the identification service
        identificationService.identifyRock(from: image)
    }
    
    // Reset to camera view
    private func resetToCamera() {
        identificationService.state = .idle
        withAnimation {
            cameraIsActive = true
        }
    }
    
    // MARK: - Camera Permission Management
    
    /// Check camera permission status and show modal if needed
    private func checkInitialCameraPermission() {
        let currentStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        print("ContentView: checkInitialCameraPermission called - currentStatus: \(currentStatus)")
        print("ContentView: hasCompletedOnboarding: \(hasCompletedOnboarding)")
        print("ContentView: appState.showHardPaywall: \(appState.showHardPaywall)")
        print("ContentView: appState.showSoftPaywall: \(appState.showSoftPaywall)")
        
        switch currentStatus {
        case .authorized:
            cameraPermissionGranted = true
            showCameraPermissionModal = false
            print("Camera permission already granted")
            
        case .notDetermined, .denied, .restricted:
            // Only show modal if:
            // 1. Onboarding is complete AND
            // 2. No paywalls are currently showing
            if hasCompletedOnboarding && !appState.showHardPaywall && !appState.showSoftPaywall {
                cameraPermissionGranted = false
                showCameraPermissionModal = true
                print("ContentView: SHOWING camera permission modal (paywall flow complete)")
            } else {
                // Don't show modal yet - onboarding not complete or paywall is active
                cameraPermissionGranted = false
                showCameraPermissionModal = false
                if !hasCompletedOnboarding {
                    print("Onboarding not complete - deferring camera permission")
                } else {
                    print("ContentView: Paywall active - deferring camera permission modal")
                }
            }
            
        @unknown default:
            cameraPermissionGranted = false
            showCameraPermissionModal = hasCompletedOnboarding && !appState.showHardPaywall && !appState.showSoftPaywall
        }
    }
}

// Collection list view - redirects to the real CollectionView
struct CollectionListView: View {
    @Binding var isPresented: Bool
    var collectionManager: CollectionManager
    
    var body: some View {
        NavigationView {
            CollectionView()
                .environmentObject(collectionManager)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isPresented = false
                        }
                    }
                }
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
                            HapticManager.shared.successFeedback()
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
                        HapticManager.shared.mediumImpact()
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
        Button(action: {
            HapticManager.shared.selectionChanged()
            action()
        }) {
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
                                .frame(width: 30, alignment: .leading)
                                .font(.system(size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize, weight: .bold))
                            
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