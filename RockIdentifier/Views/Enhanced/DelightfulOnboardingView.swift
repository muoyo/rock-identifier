// Rock Identifier: Crystal ID - Delightful Onboarding Experience
// Enhanced version focused on building anticipation and emotional connection
// Muoyo Okome

import SwiftUI
import AVFoundation

struct DelightfulOnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @State private var showPermissionAlert = false
    @State private var sparkleLocations: [CGPoint] = []
    @State private var animateSparkles = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // Premium onboarding pages with concise, impactful copy
    let pages = [
        DelightfulOnboardingPage(
            title: "Turn Walks Into\nTreasure Hunts",
            subtitle: "Every stone tells an ancient story",
            description: "Discover the extraordinary hiding in plain sight.",
            imageName: "onboarding-discover",
            primaryAction: "Begin Exploring",
            interactive: .sparklingCrystal
        ),
        DelightfulOnboardingPage(
            title: "From Mystery\nto Mastery",
            subtitle: "Instant AI-powered identification",
            description: "Watch as mysteries transform into fascinating knowledge.",
            imageName: "onboarding-details",
            primaryAction: "See How It Works",
            interactive: .scanningDemo
        ),
        DelightfulOnboardingPage(
            title: "Build Your\nPersonal Museum",
            subtitle: "Every discovery becomes part of your story",
            description: "Track your finds and watch your knowledge grow.",
            imageName: "onboarding-collection",
            primaryAction: "Start Collecting",
            interactive: .collectionPreview
        ),
        DelightfulOnboardingPage(
            title: "Your First Discovery\nAwaits",
            subtitle: "Ready to unlock nature's mysteries?",
            description: "Point, tap, discover.",
            imageName: "onboarding-camera",
            primaryAction: "Start Discovering",
            interactive: .cameraPreview
        )
    ]
    
    // Enhanced gradient colors with more vibrancy
    let enhancedGradients = [
        [Color(hex: "667eea"), Color(hex: "764ba2")], // Purple Discovery
        [Color(hex: "f093fb"), Color(hex: "f5576c")], // Pink Knowledge  
        [Color(hex: "4facfe"), Color(hex: "00f2fe")], // Blue Collection
        [Color(hex: "43e97b"), Color(hex: "38f9d7")]  // Green Ready
    ]
    
    var body: some View {
        ZStack {
            // Enhanced gradient background with animation
            AnimatedGradientBackground(
                colors: enhancedGradients[currentPage],
                animationDuration: 2.0
            )
            .ignoresSafeArea()
            
            // Floating particles for magical atmosphere
            FloatingParticlesView(isActive: true)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced top bar
                HStack {
                    // Animated page indicator
                    EnhancedPageIndicator(
                        current: currentPage, 
                        total: pages.count,
                        accentColor: .white
                    )
                    .padding(.leading)
                    
                    Spacer()
                    
                    // Skip button with subtle animation
                    Button {
                        HapticManager.shared.lightImpact()
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                            )
                            .scaleEffect(1.0)
                    }
                    .buttonStyle(EnhancedScaleButtonStyle(scaleAmount: 0.95))
                    .padding(.trailing)
                }
                .padding(.top, 20)
                
                // Enhanced page content with staggered animations
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        DelightfulOnboardingPageView(
                            page: pages[index],
                            pageIndex: index,
                            isActive: currentPage == index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: currentPage) { newPage in
                    // Haptic feedback on page change
                    HapticManager.shared.selectionChanged()
                    
                    // Trigger sparkle animation for certain pages
                    if newPage == 0 {
                        createSparkleEffect()
                    }
                }
                
                // Enhanced bottom controls
                VStack(spacing: 20) {
                    // Primary action button with enhanced styling
                    Button {
                        HapticManager.shared.mediumImpact()
                        
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            // Enhanced permission request
                            requestCameraPermissionWithDelight()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(pages[currentPage].primaryAction)
                                .textStyle(.buttonTextLarge)
                            
                            if currentPage < pages.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.25),
                                            Color.white.opacity(0.15)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .modifier(StyleGuide.Shadow.medium(color: Color.black.opacity(0.3)))
                    }
                    .buttonStyle(EnhancedScaleButtonStyle(scaleAmount: 0.95))
                    .padding(.horizontal, 30)
                    
                    // Enhanced navigation hint
                    if currentPage < pages.count - 1 {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.draw")
                                .font(.caption)
                                .opacity(0.7)
                            
                            Text("Swipe to continue your journey")
                                .font(.caption)
                                .opacity(0.7)
                        }
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                        .transition(.opacity.combined(with: .slide))
                    }
                }
                .padding(.bottom, 40)
            }
            
            // Sparkle overlay for magical moments
            if !sparkleLocations.isEmpty {
                ForEach(0..<sparkleLocations.count, id: \.self) { index in
                    SparkleView()
                        .position(sparkleLocations[index])
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Unlock Your Camera's Potential"),
                message: Text("To identify rocks and minerals, Rock Identifier needs access to your camera. This helps us capture the clearest images for the most accurate identifications."),
                primaryButton: .default(Text("Open Settings")) {
                    PermissionManager.shared.openSettings()
                    completeOnboarding()
                },
                secondaryButton: .cancel(Text("Maybe Later")) {
                    completeOnboarding()
                }
            )
        }
    }
    
    // MARK: - Enhanced Permission Request
    private func requestCameraPermissionWithDelight() {
        // Add anticipation with haptic feedback
        HapticManager.shared.successFeedback()
        
        PermissionManager.shared.requestCameraPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    // Celebrate with sparkle effect
                    createCelebrationSparkles()
                    
                    // Delay completion to show celebration
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        completeOnboarding()
                    }
                } else {
                    if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
                        showPermissionAlert = true
                    } else {
                        completeOnboarding()
                    }
                }
            }
        }
    }
    
    // MARK: - Sparkle Effects
    private func createSparkleEffect() {
        sparkleLocations = []
        
        // Create random sparkle positions
        for _ in 0..<5 {
            let x = CGFloat.random(in: 50...UIScreen.main.bounds.width - 50)
            let y = CGFloat.random(in: 100...UIScreen.main.bounds.height - 200)
            sparkleLocations.append(CGPoint(x: x, y: y))
        }
        
        // Animate sparkles
        withAnimation(.easeInOut(duration: 1.5)) {
            animateSparkles = true
        }
        
        // Remove sparkles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                sparkleLocations = []
                animateSparkles = false
            }
        }
    }
    
    private func createCelebrationSparkles() {
        sparkleLocations = []
        
        // Create celebration sparkles around the screen
        for _ in 0..<12 {
            let x = CGFloat.random(in: 30...UIScreen.main.bounds.width - 30)
            let y = CGFloat.random(in: 80...UIScreen.main.bounds.height - 150)
            sparkleLocations.append(CGPoint(x: x, y: y))
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            animateSparkles = true
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        isPresented = false
    }
}

// MARK: - Supporting Views

struct DelightfulOnboardingPageView: View {
    let page: DelightfulOnboardingPage
    let pageIndex: Int
    let isActive: Bool
    
    @State private var titleAppeared = false
    @State private var subtitleAppeared = false
    @State private var descriptionAppeared = false
    @State private var imageAppeared = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)
            
            // Premium SwiftUI-rendered visual instead of static image
            ZStack {
                // Dynamic visual based on page
                switch pageIndex {
                case 0:
                    FloatingCrystalView()
                case 1:
                    AIScanningView()
                case 2:
                    DynamicCollectionView()
                case 3:
                    CameraApertureView()
                default:
                    FloatingCrystalView()
                }
            }
            .frame(height: 280)
            .scaleEffect(imageAppeared ? 1.0 : 0.8)
            .opacity(imageAppeared ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1), value: imageAppeared)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            
            // Enhanced content section with premium spacing
            VStack(spacing: 24) {
                // Title with staggered animation - Large, bold white text
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .offset(y: titleAppeared ? 0 : 20)
                    .opacity(titleAppeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: titleAppeared)
                
                // Subtitle with animation - Medium weight white text
                Text(page.subtitle)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .offset(y: subtitleAppeared ? 0 : 15)
                    .opacity(subtitleAppeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: subtitleAppeared)
                
                // Description with animation - Regular white text, slightly smaller
                Text(page.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 40)
                    .offset(y: descriptionAppeared ? 0 : 15)
                    .opacity(descriptionAppeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: descriptionAppeared)
            }
            
            Spacer(minLength: 30)
        }
        .onAppear {
            if isActive {
                startPageAnimations()
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startPageAnimations()
            } else {
                resetPageAnimations()
            }
        }
    }
    
    private func startPageAnimations() {
        titleAppeared = false
        subtitleAppeared = false
        descriptionAppeared = false
        imageAppeared = false
        
        // Staggered entrance animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            imageAppeared = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            titleAppeared = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            subtitleAppeared = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            descriptionAppeared = true
        }
    }
    
    private func resetPageAnimations() {
        titleAppeared = false
        subtitleAppeared = false
        descriptionAppeared = false
        imageAppeared = false
    }
}

// MARK: - Enhanced Supporting Components

struct EnhancedPageIndicator: View {
    let current: Int
    let total: Int
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<total, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(current == index ? accentColor : accentColor.opacity(0.3))
                    .frame(width: current == index ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: current)
            }
        }
    }
}

struct AnimatedGradientBackground: View {
    let colors: [Color]
    let animationDuration: Double
    
    @State private var animateGradient = false
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: animateGradient ? .topTrailing : .topLeading,
                    endPoint: animateGradient ? .bottomLeading : .bottomTrailing
                )
            )
            .onAppear {
                withAnimation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }
    }
}

struct FloatingParticlesView: View {
    let isActive: Bool
    @State private var particles: [ParticleData] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .animation(.linear(duration: particle.duration).repeatForever(autoreverses: false), value: particle.position)
            }
        }
        .onAppear {
            if isActive {
                createParticles()
            }
        }
    }
    
    private func createParticles() {
        particles = []
        
        for _ in 0..<8 {
            let particle = ParticleData()
            particles.append(particle)
            
            // Animate particle movement
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].position = CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: -50
                    )
                }
            }
        }
    }
}

struct SparkleView: View {
    @State private var scale: CGFloat = 0.0
    @State private var rotation: Double = 0.0
    @State private var opacity: Double = 0.0
    
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                
                withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                    opacity = 0.0
                    scale = 0.5
                }
            }
    }
}

// MARK: - Data Models

struct DelightfulOnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let primaryAction: String
    let interactive: InteractiveType
}

// Keeping for backward compatibility but not used with new premium visuals
enum InteractiveType {
    case sparklingCrystal
    case scanningDemo
    case collectionPreview
    case cameraPreview
}

struct ParticleData: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let opacity: Double
    let duration: Double
    
    init() {
        self.position = CGPoint(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: UIScreen.main.bounds.height + 50
        )
        self.size = CGFloat.random(in: 2...6)
        self.opacity = Double.random(in: 0.2...0.6)
        self.duration = Double.random(in: 3...8)
    }
}


