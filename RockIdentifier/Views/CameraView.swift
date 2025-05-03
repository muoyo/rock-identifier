// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    @Binding var isActive: Bool
    @State var screen: GeometryProxy?
    
    @State private var captureSession: AVCaptureSession? = AVCaptureSession()
    @State private var photoOutput: AVCapturePhotoOutput? = AVCapturePhotoOutput()
    private let photoCaptureDelegate = PhotoCaptureDelegate()
    
    @State private var isProcessing: Bool = false
    @State private var shutterFlash: Bool = false
    
    // Callback for when an image is captured
    let onCaptureImage: (UIImage) -> Void
    
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
                        checkCameraPermission()
                    }
                }
            }
            .opacity(isActive ? 1 : (1 - 0.66))
            
            // Grid overlay for better rock positioning
            if showGrid && !isProcessing {
                RockPositioningGrid()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    .frame(width: 250, height: 250)
                    .position(x: (screen?.size.width ?? 0) / 2, y: (screen?.size.height ?? 0) / 2.2)
            }
            
            // Processing overlay
            if isProcessing {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text("Analyzing your specimen...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .background(shutterFlash ? Color.white : Color.black.opacity(0.7))
                .onAppear {
                    withAnimation {
                        shutterFlash = false
                    }
                }
            }
            else {
                // Top controls
                VStack {
                    HStack {
                        // Remaining identifications counter
                        Text("\(remainingIdentifications) identifications left")
                            .font(.caption)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .padding(.leading)
                        
                        Spacer()
                        
                        // Flash toggle button
                        Button(action: {
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
                        .padding(.trailing)
                    }
                    .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 10)
                    
                    // Guidance text for better photo capture
                    Text("Position rock in the center, ensure good lighting")
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .padding(.top, 10)
                        .opacity(showGrid ? 1 : 0)
                    
                    Spacer()
                }
                
                // Bottom camera controls
                VStack {
                    Spacer()
                    
                    HStack {
                        // Photo library button
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30, alignment: .center)
                                .clipped()
                                .padding(22)
                                .background(Color.black.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(40)
                        }
                        .sheet(isPresented: $showImagePicker) {
                            PhotoPicker(isPresented: $showImagePicker, selectedImage: $selectedImage, filename: $filename)
                                .accentColor(.blue)
                        }
                        
                        Spacer()
                        
                        // Camera capture button
                        Button(action: {
                            if let photoOutput = photoOutput {
                                print("==> capturePhoto")
                                // Show shutter flash effect
                                withAnimation {
                                    shutterFlash = true
                                    isProcessing = true
                                }
                                // Take the photo
                                let settings = AVCapturePhotoSettings()
                                photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate)
                            }
                        }) {
                            Image(systemName: "camera")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, alignment: .center)
                                .clipped()
                                .padding(25)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Collection button
                        Button(action: {
                            showCollection.toggle()
                        }) {
                            Image(systemName: "square.grid.2x2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, alignment: .center)
                                .clipped()
                                .padding(22)
                                .background(Color.black.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(40)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20 + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0))
                }
            }
        }
        .onChange(of: isProcessing) { value in
            if value {
                shutterFlash = true
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
            if let uploadedImage = selectedImage {
                // Set processing state for uploaded image
                isProcessing = true
                shutterFlash = true
                
                // Use a short delay to allow processing animation to appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Pass the uploaded image to the identification service
                    onCaptureImage(uploadedImage)
                }
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
        
        if let captureSession = captureSession, !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                print("==> captureSession.startRunning()")
                captureSession.startRunning()
            }
        }
    }
    
    private func setupCamera() {
        // Initialize and configure the capture session
        photoCaptureDelegate.onPhotoCapture = { image in
            // Resize image to appropriate size for rock identification
            if let resizedImage = image.resized(toHeight: max(1000, image.size.height)) {
                self.selectedImage = resizedImage
                // Set isProcessing to true first to show processing overlay
                isProcessing = true
                // Then call onCaptureImage with the captured image
                DispatchQueue.main.async {
                    onCaptureImage(resizedImage)
                }
            }
        }
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Already authorized
            setupCamera()
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    setupCamera()
                }
                // Handle if not granted
            }
        case .denied, .restricted:
            // Permission denied or restricted, handle accordingly
            break
        @unknown default:
            break
        }
    }
}

// Rock positioning grid shape
struct RockPositioningGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Outer border
        path.addRect(rect)
        
        // Cross in center
        let centerX = rect.width / 2
        let centerY = rect.height / 2
        
        // Horizontal line
        path.move(to: CGPoint(x: centerX - 15, y: centerY))
        path.addLine(to: CGPoint(x: centerX + 15, y: centerY))
        
        // Vertical line
        path.move(to: CGPoint(x: centerX, y: centerY - 15))
        path.addLine(to: CGPoint(x: centerX, y: centerY + 15))
        
        // Corner brackets
        let bracketSize: CGFloat = 20
        
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
        
        return path
    }
}

// Reuse CameraPreviewView and PhotoCaptureDelegate from template
struct CameraPreviewView: UIViewRepresentable {
    var captureSession: AVCaptureSession
    var photoOutput: AVCapturePhotoOutput
    var photoCaptureDelegate: AVCapturePhotoCaptureDelegate

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        // Setup capture session with optimal settings for rock photography
        captureSession.sessionPreset = .photo
        
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            // Configure device for rock photography (focus, exposure, etc.)
            do {
                try videoDevice.lockForConfiguration()
                
                // Enable auto focus
                if videoDevice.isFocusModeSupported(.continuousAutoFocus) {
                    videoDevice.focusMode = .continuousAutoFocus
                }
                
                // Enable auto exposure
                if videoDevice.isExposureModeSupported(.continuousAutoExposure) {
                    videoDevice.exposureMode = .continuousAutoExposure
                }
                
                // Enable macro mode if available (for detailed rock textures)
                if #available(iOS 15.0, *) {
                    // In real implementation, would use proper macro mode APIs
                }
                
                videoDevice.unlockForConfiguration()
            } catch {
                print("Error configuring camera: \(error)")
            }
            
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                  captureSession.canAddInput(videoDeviceInput) else { return view }
            captureSession.addInput(videoDeviceInput)
            
            // Add photo output
            guard captureSession.canAddOutput(photoOutput) else { return view }
            captureSession.addOutput(photoOutput)
            
            // Configure high quality photo output
            photoOutput.isHighResolutionCaptureEnabled = true
            if #available(iOS 13.0, *) {
                photoOutput.maxPhotoQualityPrioritization = .quality
            }
            
            // Add preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            // Start session
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    var onPhotoCapture: ((UIImage) -> Void)?

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        if let image = UIImage(data: imageData) {
            onPhotoCapture?(image)
        }
    }
}
