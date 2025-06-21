// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import AVFoundation

struct ProcessingView: View {
    @Binding var isVisible: Bool
    @State private var showCancelConfirm: Bool = false
    
    // Processing state management
    @State private var currentStage: ProcessingStage = .initializing
    @State private var analysisProgress: CGFloat = 0.0
    @State private var shouldShowResult: Bool = false
    @State private var hasError: Bool = false
    @State private var errorMessage: String = ""
    @State private var retryAttempt: Int = 0
    @State private var maxRetryAttempts: Int = 3
    @State private var isRetrying: Bool = false
    
    // Captured rock image (passed from CameraView)
    var capturedImage: UIImage?
    
    // Callback for when processing is complete
    var onProcessingComplete: ((RockIdentificationResult) -> Void)?
    
    // Rock identification service
    @StateObject private var rockService = RockIdentificationService()
    
    // Mock identification result (for testing without API)
    @State private var identificationResult: RockIdentificationResult? = nil
    
    // Animation states
    @State private var rotationAngle: Double = 0
    @State private var glowOpacity: Double = 0.5
    @State private var scanLinePosition: CGFloat = -1
    @State private var pulseScale: CGFloat = 1.0
    @State private var processingStepIndex: Int = 0
    @State private var showStepCompletion: Bool = false
    
    // Haptic feedback generator
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    let successGenerator = UINotificationFeedbackGenerator()
    
    // Timer for processing simulation
    let processingTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    // Processing stages with descriptions
    enum ProcessingStage: Int, CaseIterable {
        case initializing = 0
        case analyzingStructure = 1
        case identifyingMinerals = 2
        case checkingProperties = 3
        case comparingDatabase = 4
        case finalizing = 5
        case retrying = 6
        case complete = 7
        
        var title: String {
            switch self {
            case .initializing: return "Initializing..."
            case .analyzingStructure: return "Analyzing Structure"
            case .identifyingMinerals: return "Identifying Minerals"
            case .checkingProperties: return "Checking Properties"
            case .comparingDatabase: return "Comparing Database"
            case .finalizing: return "Finalizing Results"
            case .retrying: return "Retrying Connection"
            case .complete: return "Identification Complete!"
            }
        }
        
        var description: String {
            switch self {
            case .initializing: return "Preparing for analysis..."
            case .analyzingStructure: return "Examining crystal structure, grain patterns, and texture..."
            case .identifyingMinerals: return "Identifying component minerals and chemical makeup..."
            case .checkingProperties: return "Analyzing hardness, luster, and physical characteristics..."
            case .comparingDatabase: return "Comparing with our geological database of specimens..."
            case .finalizing: return "Assembling detailed information about your rock..."
            case .retrying: return "Connection interrupted, attempting to reconnect..."
            case .complete: return "Your rock has been successfully identified!"
            }
        }
        
        var targetProgress: CGFloat {
            switch self {
            case .initializing: return 0.1
            case .analyzingStructure: return 0.3
            case .identifyingMinerals: return 0.5
            case .checkingProperties: return 0.7
            case .comparingDatabase: return 0.85
            case .finalizing: return 0.95
            case .retrying: return 0.7 // Reset progress during retry
            case .complete: return 1.0
            }
        }
    }
    
    // Animation timing (ms per stage)
    private let stageDurations: [TimeInterval] = [1.5, 3.0, 3.0, 2.5, 2.5, 1.5, 0.5]
    
    // Background gradient colors
    private let gradientColors = [Color(hex: "191970"), Color(hex: "000033")]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background
                LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        ZStack {
                            // Subtle particle effect
                            ForEach(0..<15) { i in
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: CGFloat.random(in: 2...6))
                                    .position(
                                        x: CGFloat.random(in: 0...geometry.size.width),
                                        y: CGFloat.random(in: 0...geometry.size.height)
                                    )
                                    .blur(radius: 1)
                            }
                        }
                    )
                
                VStack(spacing: 15) {
                    // Top header with animated text
                    Text("Analyzing Your Rock")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                        .opacity(1.0)
                        .scaleEffect(pulseScale)
                        .padding(.top, 20)
                    
                    // Rock image display
                    ZStack {
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: min(geometry.size.width * 0.7, 250), height: min(geometry.size.width * 0.7, 250))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                                        .scaleEffect(pulseScale)
                                )
                                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        } else {
                            // Placeholder if no image
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: min(geometry.size.width * 0.7, 250), height: min(geometry.size.width * 0.7, 250))
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white.opacity(0.5))
                                )
                        }
                        
                        // Scanning line animation
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.clear, .blue.opacity(0.7), .clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: min(geometry.size.width * 0.7, 250), height: 3)
                            .offset(y: scanLinePosition * min(geometry.size.width * 0.7, 250) / 2)
                            .opacity(currentStage == .complete ? 0 : 1)
                        
                        // Success checkmark (shown when complete)
                        if currentStage == .complete {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.green)
                                .opacity(0.9)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Progress bar
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress indicator
                        Capsule()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: max(0, min(geometry.size.width * 0.85 * analysisProgress, geometry.size.width * 0.85)), height: 8)
                            .animation(.easeInOut(duration: 0.3), value: analysisProgress)
                    }
                    .frame(width: geometry.size.width * 0.85)
                    .padding(.bottom, 10)
                    
                    // Current stage information
                    VStack(spacing: 5) {
                        Text(currentStage.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                        
                        Text(currentStage.description)
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(height: 40)
                            .padding(.horizontal)
                            .id(currentStage.rawValue) // Force redraw when stage changes
                            .transition(.opacity)
                        
                        // Retry information
                        if isRetrying && retryAttempt > 0 {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.orange)
                                    .rotationEffect(.degrees(rotationAngle))
                                Text("Attempt \(retryAttempt + 1) of \(maxRetryAttempts + 1)")
                                    .foregroundColor(.orange.opacity(0.9))
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.top, 5)
                            .transition(.opacity)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Step indicators
                    HStack(spacing: 12) {
                        ForEach(ProcessingStage.allCases.filter { $0 != .initializing && $0 != .complete }, id: \.self) { stage in
                            StepIndicator(
                                stage: stage,
                                currentStage: currentStage,
                                showCompletion: showStepCompletion && currentStage.rawValue > stage.rawValue
                            )
                        }
                    }
                    .padding(.vertical, 15)
                    
                    // Cancel button
                    Button(action: {
                        impactGenerator.impactOccurred()
                        showCancelConfirm = true
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .padding(.top, 5)
                    .alert(isPresented: $showCancelConfirm) {
                        Alert(
                            title: Text("Cancel Identification?"),
                            message: Text("Are you sure you want to cancel the rock identification process?"),
                            primaryButton: .destructive(Text("Yes, Cancel")) {
                                // Cancel the rock identification service
                                rockService.cancelIdentification()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isVisible = false
                                }
                            },
                            secondaryButton: .cancel(Text("Continue"))
                        )
                    }
                    
                    Spacer()
                }
                .padding()
                
                // Error overlay
                if hasError {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Identification Error")
                            .font(.title2)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            withAnimation {
                                isVisible = false
                            }
                        }) {
                            Text("Try Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 30)
                                .background(Color.blue.opacity(0.7))
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding(40)
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(20)
                    .transition(.opacity)
                }
            }
        }
        .onReceive(processingTimer) { _ in
            updateProcessingAnimation()
        }
        .onReceive(rockService.$state) { state in
            handleRockServiceStateChange(state)
        }
        .onAppear {
            startProcessingAnimation()
            startIdentification()
        }
    }
    
    // MARK: - Animations
    
    private func startProcessingAnimation() {
        // Start pulsing animation
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
            glowOpacity = 0.8
        }
        
        // Start scan line animation
        withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            scanLinePosition = 1
        }
        
        // Start rotation animation for effects
        withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
    
    private func updateProcessingAnimation() {
        // Only update if not complete
        guard currentStage != .complete && !hasError else { return }
        
        // Update progress based on current stage
        if analysisProgress < currentStage.targetProgress {
            analysisProgress += 0.003
            
            // Check if we've hit the next stage threshold
            if analysisProgress >= currentStage.targetProgress && currentStage.rawValue < ProcessingStage.complete.rawValue {
                transitionToNextStage()
            }
        }
    }
    
    private func transitionToNextStage() {
        // Play haptic feedback
        impactGenerator.impactOccurred()
        
        // Show completion for the current step
        withAnimation {
            showStepCompletion = true
        }
        
        // Short delay before moving to next stage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                if let nextStage = ProcessingStage(rawValue: currentStage.rawValue + 1) {
                    currentStage = nextStage
                }
                
                // Check if complete
                if currentStage == .complete {
                    completeIdentification()
                }
            }
        }
    }
    
    // MARK: - Rock Identification
    
    private func startIdentification() {
        guard let image = capturedImage else {
            handleError(message: "No image available for identification")
            return
        }
        
        // Start actual rock identification using the service
        rockService.identifyRock(from: image)
    }
    
    private func handleRockServiceStateChange(_ state: IdentificationState) {
        switch state {
        case .idle:
            // Reset to initial state
            break
            
        case .processing:
            // Continue with visual processing animation
            if hasError {
                withAnimation {
                    hasError = false
                    errorMessage = ""
                }
            }
            
        case .retrying(let attempt, let totalAttempts):
            // Handle retry state
            withAnimation {
                isRetrying = true
                retryAttempt = attempt
                maxRetryAttempts = totalAttempts
                currentStage = .retrying
                analysisProgress = 0.7 // Reset progress during retry
            }
            
        case .success(let result):
            // Handle successful identification
            identificationResult = result
            withAnimation {
                isRetrying = false
                currentStage = .complete
                analysisProgress = 1.0
            }
            completeIdentification()
            
        case .error(let message):
            // Handle error
            withAnimation {
                isRetrying = false
            }
            handleError(message: message)
        }
    }
    
    private func simulateProcessing() {
        // This function simulates the API call and processing
        // In a real implementation, you would call your RockIdentificationService here
        
        // Create a mock result after the process is complete
        let mockRock = RockIdentificationResult(
            id: UUID(),
            image: capturedImage,
            name: "Amethyst",
            category: "Quartz Variety",
            confidence: 0.92,
            physicalProperties: PhysicalProperties(
                color: "Purple to violet",
                hardness: "7 (Mohs scale)",
                luster: "Vitreous",
                streak: "White",
                transparency: "Transparent to Translucent",
                crystalSystem: "Hexagonal",
                fracture: "Conchoidal"
            ),
            chemicalProperties: ChemicalProperties(
                formula: "SiO₂",
                composition: "Silicon dioxide",
                elements: [
                    Element(name: "Silicon", symbol: "Si", percentage: 46.7),
                    Element(name: "Oxygen", symbol: "O", percentage: 53.3)
                ],
                reactivity: "None"
            ),
            formation: Formation(
                formationType: "Mineral",
                environment: "Forms in vugs and cavities in igneous rocks",
                geologicalAge: "Various ages",
                commonLocations: ["Brazil", "Uruguay", "Zambia", "South Korea", "Russia"],
                associatedMinerals: ["Quartz", "Calcite", "Fluorite"],
                formationProcess: "Crystallizes from silicon-rich fluids"
            ),
            uses: Uses(
                historical: ["Used by ancient Egyptians for jewelry and amulets", "Believed to protect against intoxication and harm"],
                modern: ["Decorative gemstone", "Jewelry", "Ornamental objects"],
                metaphysical: ["Associated with spiritual awareness", "Said to promote calm and balance"],
                funFacts: ["The name comes from Ancient Greek 'amethystos' meaning 'not intoxicated'", "It's the birthstone for February", "Amethyst loses its color when heated, turning yellow or orange"]
            )
        )
        
        // Save mock result for callback
        identificationResult = mockRock
    }
    
    private func completeIdentification() {
        // Play success haptic
        successGenerator.notificationOccurred(.success)
        
        // Allow animation to complete before transitioning
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Call completion handler with result
            if let result = identificationResult {
                onProcessingComplete?(result)
            }
            
            // Close processing view
            withAnimation {
                isVisible = false
            }
        }
    }
    
    private func handleError(message: String) {
        errorMessage = message
        withAnimation {
            hasError = true
        }
    }
}

// MARK: - Helper Views

struct StepIndicator: View {
    var stage: ProcessingView.ProcessingStage
    var currentStage: ProcessingView.ProcessingStage
    var showCompletion: Bool
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(backgroundColor)
                .frame(width: 30, height: 30)
            
            // Step number or checkmark
            if showCompletion {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("\(stage.rawValue)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var backgroundColor: Color {
        if showCompletion {
            return .green
        } else if stage.rawValue == currentStage.rawValue {
            return .blue
        } else if stage.rawValue < currentStage.rawValue {
            return .blue.opacity(0.5)
        } else {
            return .gray.opacity(0.3)
        }
    }
}

struct ProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessingView(isVisible: .constant(true), capturedImage: UIImage(systemName: "photo"))
    }
}
