// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    
    @Binding var isActive: Bool
    @State var screen: GeometryProxy?
    
    @State private var captureSession: AVCaptureSession? = AVCaptureSession()
    @State private var photoOutput: AVCapturePhotoOutput? = AVCapturePhotoOutput()
    // Use a @StateObject to ensure the delegate persists throughout view lifecycle
    @StateObject private var photoCaptureDelegate = PhotoCaptureDelegate()
    
    @State private var shutterFlash: Bool = false
    
    // Callback for when an image is captured
    let onCaptureImage: (UIImage) -> Void
    
    // Callback for when settings should be shown
    let onShowSettings: () -> Void
    
    // Image picker related states
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var filename: String? = nil
    
    // Collection view toggle
    @Binding var showCollection: Bool
    
    // Flash control
    @State private var flashOn: Bool = false
    
    // Number of identifications remaining (for free tier)
    let remainingIdentifications: Int
    
    // Grid overlay toggle (helps with positioning rocks)
    @State private var showGrid: Bool = true
    
    // Environment access
    @Environment(\.colorScheme) var colorScheme
    
    // Toggle flashlight
    func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        flashOn = !flashOn
        
        do {
            try device.lockForConfiguration()
            device.torchMode = flashOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Flashlight could not be used")
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Camera preview
            VStack {
                if let captureSession = captureSession, let photoOutput = photoOutput {
                    CameraPreviewView(captureSession: captureSession, photoOutput: photoOutput, photoCaptureDelegate: photoCaptureDelegate)
                    .frame(width: screen?.size.width, height: screen?.size.height, alignment: .center)
                    .onAppear {
                        print("==> CameraPreviewView appeared, checking camera permission")
                        checkCameraPermission()
                    }
                }
            }
            .opacity(isActive ? 1 : (1 - 0.66))
            
            // Enhanced grid overlay for better rock positioning
            if showGrid && !shutterFlash {
                ZStack {
                    // Shadow backdrop for visibility in various lighting conditions
                    RockPositioningGrid()
                        .stroke(Color.black.opacity(0.3), lineWidth: 3)
                        .frame(width: 260, height: 260)
                    
                    // Main grid with animation
                    RockPositioningGrid()
                        .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                        .frame(width: 250, height: 250)
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showGrid)
                }
                .position(x: (screen?.size.width ?? 0) / 2, y: (screen?.size.height ?? 0) / 2.2)
            }
            
            // Only show camera controls when not capturing
            if !shutterFlash {
                // Top controls
                VStack {
                    HStack {
                        // Remaining identifications counter (or unlimited for premium)
                        HStack(spacing: 4) {
                            Image(systemName: remainingIdentifications == Int.max ? "infinity" : "camera.viewfinder")
                            .foregroundColor(remainingIdentifications == Int.max ? .blue : (remainingIdentifications < 2 ? .orange : .green))
                            .font(.system(size: 12))
                            
                            Text(remainingIdentifications == Int.max ? "Unlimited" : "\(remainingIdentifications)/3 remaining")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(remainingIdentifications == Int.max ? .blue : (remainingIdentifications < 2 ? .orange : .white))
                        }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(remainingIdentifications == Int.max ? Color.blue.opacity(0.5) : 
                                   (remainingIdentifications < 2 ? Color.orange.opacity(0.7) : Color.green.opacity(0.3)), lineWidth: 1)
                    )
                    .padding(.leading)
                    .onTapGesture(count: 5) {
                        // Handle secret developer mode activation
                        NotificationCenter.default.post(name: NSNotification.Name("ToggleDeveloperMode"), object: nil)
                        // Haptic feedback for confirmation
                        HapticManager.shared.successFeedback()
                    }
                        
                        Spacer()
                        
                        // Flash toggle button
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            self.toggleFlashlight()
                        }) {
                            Image(systemName: flashOn ? "bolt.fill" : "bolt.slash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22, alignment: .center)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        
                        // Grid toggle button
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            showGrid.toggle()
                        }) {
                            Image(systemName: showGrid ? "grid" : "grid.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22, alignment: .center)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        
                        // Settings button
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            onShowSettings()
                        }) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22, alignment: .center)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 10)
                    
                    // Enhanced guidance with context-sensitive tips
                    VStack(spacing: 5) {
                        Text("Position rock in the center")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            // Positioning tip
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 10))
                                Text("Center")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.white.opacity(0.9))
                            
                            // Lighting tip
                            HStack(spacing: 4) {
                                Image(systemName: "light.max")
                                    .font(.system(size: 10))
                                Text("Good Light")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.white.opacity(0.9))
                            
                            // Distance tip
                            HStack(spacing: 4) {
                                Image(systemName: "ruler")
                                    .font(.system(size: 10))
                                Text("4-8 inches")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .padding(.top, 10)
                    .opacity(showGrid ? 1 : 0)
                    
                    Spacer()
                }
                
                // Bottom camera controls
                VStack {
                    Spacer()
                    
                    HStack {
                        // Enhanced photo library button
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            showImagePicker = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "photo.on.rectangle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 26, height: 26)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(EnhancedScaleButtonStyle(scaleAmount: 0.92, animationType: .easeInOut(duration: 0.2)))
                        .sheet(isPresented: $showImagePicker) {
                            PhotoPicker(isPresented: $showImagePicker, selectedImage: $selectedImage, filename: $filename)
                                .accentColor(.blue)
                        }
                        
                        Spacer()
                        
                        // Enhanced camera capture button with animation
                        Button(action: {
                            // Premium users or users with remaining IDs can take photos
                            if remainingIdentifications == Int.max || remainingIdentifications > 0 {
                                print("==> capturePhoto")
                                // Haptic feedback for better user experience
                                HapticManager.shared.lightImpact()
                                
                                // Show shutter flash effect with improved animation
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    shutterFlash = true
                                }
                                
                                // Make sure the delegate callback is set up
                                print("==> Ensuring photo capture delegate callback is set up")
                                setupCamera() // Make sure callback is set up before capture
                                
                                // Take the photo with optimized settings
                                if let photoOutput = photoOutput {
                                    let settings = AVCapturePhotoSettings()
                                    settings.isHighResolutionPhotoEnabled = true
                                    if self.flashOn {
                                        settings.flashMode = .on
                                    }
                                    
                                    print("==> Initiating photo capture with \(self.photoCaptureDelegate)")
                                    photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate)
                                }
                            }
                            else {
                                // Show soft paywall instead of capturing photo when no identifications left (free tier only)
                                print("==> No identifications remaining - showing soft paywall")
                                HapticManager.shared.warningFeedback()
                                PaywallManager.shared.showSoftPaywall()
                            }
                        }) {
                            ZStack {
                                // Outer ring
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 88, height: 88)
                                
                                // Inner button
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 76, height: 76)
                                
                                // Camera icon
                                Image(systemName: "camera")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, alignment: .center)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(CaptureButtonStyle())
                        // Visual indicator that the button will show paywall instead of capturing when no identifications left
                        // Only show for free tier users who have used all identifications
                        .overlay(
                            remainingIdentifications <= 0 && remainingIdentifications != Int.max ? 
                                ZStack {
                                    // White backdrop for visibility
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    
                                    // Lock icon
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 32, height: 32)
                                .background(Color.red.opacity(0.8))
                                .clipShape(Circle())
                                .position(x: 60, y: 20)
                                : nil
                        )
                        
                        Spacer()
                        
                        // Enhanced collection button
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            showCollection.toggle()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "square.grid.2x2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 26, alignment: .center)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(EnhancedScaleButtonStyle(scaleAmount: 0.92, animationType: .easeInOut(duration: 0.2)))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20 + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0))
                }
            }
        }
        // Flash animation for shutter effect only
        .overlay(
            shutterFlash ? 
                ZStack {
                    // Flash effect
                    Color.white.opacity(0.85).edgesIgnoringSafeArea(.all)
                    
                    // Subtle capture animation
                    Circle()
                        .stroke(Color.blue.opacity(0.5), lineWidth: 5)
                        .frame(width: 100, height: 100)
                        .scaleEffect(shutterFlash ? 1.5 : 1.0)
                        .opacity(shutterFlash ? 0 : 1)
                        .animation(.easeOut(duration: 0.3), value: shutterFlash)
                }
                : nil
        )
        .onChange(of: shutterFlash) { isFlashing in
            if isFlashing {
                // Turn off the flash after a brief moment with improved timing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.easeOut(duration: 0.15)) {
                        shutterFlash = false
                    }
                }
            }
        }
        .onChange(of: showCollection) { value in
            if value {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isActive = false
                }
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isActive = true
                }
            }
        }
        .onChange(of: isActive) { value in
            if isActive {
                self.startCameraSession()
            }
            else {
                self.stopCameraSession()
            }
        }
        .onChange(of: selectedImage) { selectedImage in
            print("==> onChange triggered for selectedImage")
            if let uploadedImage = selectedImage {
                print("==> selectedImage is not nil: \(uploadedImage.size.width) x \(uploadedImage.size.height)")
                // Show shutter flash for uploaded image
                withAnimation {
                    shutterFlash = true
                }
                
                // Use a short delay to allow flash animation to appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    print("==> Calling onCaptureImage with uploadedImage")
                    // Pass the uploaded image to the identification service
                    onCaptureImage(uploadedImage)
                    
                    // Reset selected image to nil for future uploads
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("==> Resetting selectedImage to nil")
                        self.selectedImage = nil
                    }
                }
            } else {
                print("==> selectedImage is nil")
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func stopCameraSession() {
        if let captureSession = captureSession, captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                print("==> captureSession.stopRunning()")
                captureSession.stopRunning()
                self.captureSession = nil
                self.photoOutput = nil
            }
        }
    }
    
    private func startCameraSession() {
        print("==> startCameraSession")
        if let _ = captureSession {} else {
            captureSession = AVCaptureSession()
        }
        if let _ = photoOutput {} else {
            photoOutput = AVCapturePhotoOutput()
        }
        
        // Re-setup the camera if needed
        setupCamera()
        
        if let captureSession = captureSession, !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                print("==> captureSession.startRunning()")
                captureSession.startRunning()
            }
        }
    }
    
    private func setupCamera() {
        // Initialize and configure the capture session
        if let captureSession = captureSession {
            // Configure the capture session for photo capture
            captureSession.beginConfiguration()
            
            // Set photo quality preset
            captureSession.sessionPreset = .photo
            
            // Add video input
            if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
               let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
               captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                
                // Configure camera for rock photography
                try? videoDevice.lockForConfiguration()
                if videoDevice.isFocusModeSupported(.continuousAutoFocus) {
                    videoDevice.focusMode = .continuousAutoFocus
                }
                videoDevice.unlockForConfiguration()
            }
            
            // Add photo output
            if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                photoOutput.isHighResolutionCaptureEnabled = true
                if #available(iOS 13.0, *) {
                    photoOutput.maxPhotoQualityPrioritization = .quality
                }
            }
            
            captureSession.commitConfiguration()
            
            // Start running the capture session
            if !captureSession.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    captureSession.startRunning()
                }
            }
        }
        
        // Set up the photo capture delegate callback
        print("==> Setting up photoCaptureDelegate callback")
        photoCaptureDelegate.onPhotoCapture = { image in
            print("==> onPhotoCapture called with image: \(image.size.width) x \(image.size.height)")
            // Resize image to appropriate size for rock identification
            if let resizedImage = image.resized(toHeight: max(1000, image.size.height)) {
                print("==> Image resized to: \(resizedImage.size.width) x \(resizedImage.size.height)")
                
                // Important: Call onCaptureImage directly without going through selectedImage
                print("==> DIRECT PATH: Calling onCaptureImage directly from camera capture")
                DispatchQueue.main.async {
                    self.onCaptureImage(resizedImage)
                    // Don't set selectedImage to avoid duplicate calls
                }
            } else {
                print("==> ERROR: Failed to resize image")
            }
        }
        print("==> Camera setup completed")
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Already authorized
            DispatchQueue.main.async {
                self.setupCamera()
            }
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                } else {
                    print("Camera permission denied")
                    // Could show an alert here to inform the user
                }
            }
        case .denied, .restricted:
            // Permission denied or restricted, handle accordingly
            print("Camera access denied or restricted")
            // Could show an alert here to guide user to settings
            break
        @unknown default:
            break
        }
    }
}

// Enhanced rock positioning grid with depth guide
struct RockPositioningGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Outer border with rounded corners
        let cornerRadius: CGFloat = 8
        let roundedRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height)
        path.addRoundedRect(in: roundedRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        
        // Cross in center
        let centerX = rect.width / 2
        let centerY = rect.height / 2
        
        // Horizontal line
        path.move(to: CGPoint(x: centerX - 15, y: centerY))
        path.addLine(to: CGPoint(x: centerX + 15, y: centerY))
        
        // Vertical line
        path.move(to: CGPoint(x: centerX, y: centerY - 15))
        path.addLine(to: CGPoint(x: centerX, y: centerY + 15))
        
        // Corner brackets with improved visibility
        let bracketSize: CGFloat = 25
        let bracketThickness: CGFloat = 3 // This won't affect line thickness but adds visual emphasis
        
        // Top-left bracket
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + bracketSize))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + bracketSize, y: rect.minY))
        
        // Top-right bracket
        path.move(to: CGPoint(x: rect.maxX - bracketSize, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + bracketSize))
        
        // Bottom-left bracket
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - bracketSize))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + bracketSize, y: rect.maxY))
        
        // Bottom-right bracket
        path.move(to: CGPoint(x: rect.maxX - bracketSize, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bracketSize))
        
        // Add depth marker circles - indicates ideal focusing distance
        let outerRadius: CGFloat = 12
        let innerRadius: CGFloat = 5
        
        // Outer circle
        path.addEllipse(in: CGRect(x: centerX - outerRadius, y: centerY - outerRadius, 
                                   width: outerRadius * 2, height: outerRadius * 2))
        
        // Inner circle
        path.addEllipse(in: CGRect(x: centerX - innerRadius, y: centerY - innerRadius, 
                                   width: innerRadius * 2, height: innerRadius * 2))
        
        return path
    }
}

struct CaptureButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Enhanced CameraPreviewView for rock photography
struct CameraPreviewView: UIViewRepresentable {
    var captureSession: AVCaptureSession
    var photoOutput: AVCapturePhotoOutput
    var photoCaptureDelegate: AVCapturePhotoCaptureDelegate

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        // Use the existing session configuration from CameraView
        // Don't reconfigure the session here - just create the preview layer
        
        // Configure camera device for optimized rock photography if needed
        if let connection = photoOutput.connection(with: .video) {
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            }
        }
        
        // Add preview layer using the existing session
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PhotoCaptureDelegate: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    var onPhotoCapture: ((UIImage) -> Void)? {
        didSet {
            print("==> PhotoCaptureDelegate: onPhotoCapture callback set")
        }
    }

    override init() {
        super.init()
        print("==> PhotoCaptureDelegate initialized with ID: \(ObjectIdentifier(self))")
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Could not get image data from capture")
            return
        }
        
        if let image = UIImage(data: imageData) {
            print("Photo captured successfully with dimensions: \(image.size.width) x \(image.size.height)")
            print("Thread for photoOutput completion: \(Thread.isMainThread ? "Main thread" : "Background thread")")
            
            // Check if callback is set
            if onPhotoCapture == nil {
                print("==> ERROR: onPhotoCapture callback is nil!")
            } else {
                print("==> onPhotoCapture callback is set")
            }
            
            // Always dispatch to main thread before calling back
            DispatchQueue.main.async { 
                print("Calling onPhotoCapture on main thread")
                self.onPhotoCapture?(image)
            }
        } else {
            print("Failed to create UIImage from captured data")
        }
    }
}
