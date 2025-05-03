// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    // State for camera activation
    @State private var cameraIsActive: Bool = true
    
    // State for displaying collection
    @State private var showCollection: Bool = false
    
    // Rock identification service
    @StateObject private var identificationService = RockIdentificationService()
    
    // Collection manager
    @StateObject private var collectionManager = CollectionManager()
    
    // Result presentation state
    @State private var showResultView: Bool = false
    
    // Current user tier - would be managed by subscription service
    @State private var userTier: UserTier = .free
    
    // Remaining identifications count
    @State private var remainingIdentifications: Int = 3 // For free tier
    
    var body: some View {
        ZStack(alignment: .top) {
            // Camera view
            CameraView(
                isActive: $cameraIsActive,
                onCaptureImage: { image in
                    // When an image is captured, process it
                    processImage(image)
                },
                showCollection: $showCollection,
                remainingIdentifications: remainingIdentifications
            )
            .sheet(isPresented: $showCollection) {
                // Show collection view
                CollectionListView(
                    isPresented: $showCollection,
                    collectionManager: collectionManager
                )
            }
            .sheet(isPresented: $showResultView) {
                // Show result view after identification
                if case .success(let result) = identificationService.state {
                    RockResultView(
                        isPresented: $showResultView,
                        result: result,
                        collectionManager: collectionManager
                    )
                    .onDisappear {
                        // Reset camera view when result view is dismissed
                        withAnimation {
                            cameraIsActive = true
                        }
                    }
                }
            }
            
            // Show error alert if identification fails
            .alert(isPresented: .constant(
                identificationService.state.errorMessage != nil
            )) {
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
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.black)
        .onChange(of: identificationService.state) { state in
            // React to changes in identification state
            switch state {
            case .success:
                // Reduce remaining identifications for free tier
                if userTier == .free {
                    remainingIdentifications -= 1
                }
                
                // Important: First deactivate camera, then show result view
                // with a slight delay to allow for proper transitions
                cameraIsActive = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("Showing result view")
                    showResultView = true
                }
                
            case .error:
                // Error handling is done via alert
                print("Identification error: \(state.errorMessage ?? "Unknown error")")
                break
                
            case .processing:
                // Show processing state
                print("Processing identification")
                break
                
            case .idle:
                // Initial state
                print("Identification service idle")
                break
            }
        }
    }
    
    // Process the captured image
    private func processImage(_ image: UIImage) {
        // Check if user has identifications remaining
        if userTier == .free && remainingIdentifications <= 0 {
            // Show paywall
            // This would be implemented in Phase 4
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

// Placeholder for RockResultView (to be implemented in Phase 2)
struct RockResultView: View {
    @Binding var isPresented: Bool
    let result: RockIdentificationResult
    let collectionManager: CollectionManager
    
    @State private var addedToCollection: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Rock image
                if let image = result.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .padding()
                }
                
                // Rock name and category
                VStack(spacing: 8) {
                    Text(result.name)
                        .font(.title)
                        .bold()
                    
                    Text(result.category)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Confidence indicator
                    ConfidenceIndicator(value: result.confidence)
                        .frame(width: 120, height: 40)
                        .padding(.top, 4)
                }
                .padding()
                
                // Placeholder for detailed info (will be implemented in Phase 2)
                Text("Detailed information will be displayed here")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 20) {
                    Button(action: {
                        // Add to collection
                        if !addedToCollection {
                            collectionManager.addRock(result)
                            addedToCollection = true
                        }
                    }) {
                        Label(
                            addedToCollection ? "Added" : "Add to Collection",
                            systemImage: addedToCollection ? "checkmark.circle.fill" : "plus.circle"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(addedToCollection ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Share functionality would be implemented here
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray4))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
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
