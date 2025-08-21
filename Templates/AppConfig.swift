// Configuration Template for Identifier Apps
// Copy this to your new project and customize

struct AppConfig {
    
    // MARK: - App Identity
    static let appName = "{{APP_NAME}}"
    static let identifierType = "{{IDENTIFIER_TYPE}}"
    static let bundleId = "com.mokome.{{IDENTIFIER_TYPE}}identifier"
    
    // MARK: - Identification Settings
    struct Identification {
        static let freeIdentificationLimit = 3
        static let systemPrompt = """
        You are an expert {{IDENTIFIER_TYPE}} identification specialist. When users submit photos of {{IDENTIFIER_TYPE}}s, provide accurate identification with detailed information.
        
        Focus on:
        - Species identification
        - Physical characteristics
        - Habitat and growing conditions
        - {{IDENTIFIER_SPECIFIC_ATTRIBUTES}}
        - Safety information (if applicable)
        - Interesting facts
        
        Return results in the specified JSON format.
        """
        
        static let confidenceThreshold: Double = 0.7
        static let maxImageSize: CGFloat = 1024
    }
    
    // MARK: - Onboarding Content
    struct Onboarding {
        static let screens: [OnboardingScreen] = [
            OnboardingScreen(
                title: "Discover {{IDENTIFIER_TYPE_TITLE}}s",
                subtitle: "Instantly identify any {{IDENTIFIER_TYPE}} with AI-powered recognition",
                imageName: "onboarding_1"
            ),
            OnboardingScreen(
                title: "Learn & Explore",
                subtitle: "Get detailed information about each {{IDENTIFIER_TYPE}} you find",
                imageName: "onboarding_2"
            ),
            OnboardingScreen(
                title: "Build Your Collection",
                subtitle: "Save your discoveries and track your finds over time",
                imageName: "onboarding_3"
            ),
            OnboardingScreen(
                title: "Start Identifying",
                subtitle: "Point your camera at any {{IDENTIFIER_TYPE}} to get started",
                imageName: "onboarding_4"
            )
        ]
    }
    
    // MARK: - UI Customization
    struct UI {
        static let primaryColor = Color(red: 0.2, green: 0.6, blue: 0.4) // Customize per app
        static let accentColor = Color(red: 0.8, green: 0.4, blue: 0.2)
        static let cameraGuideText = "Position {{IDENTIFIER_TYPE}} in frame"
        static let resultHeaderText = "{{IDENTIFIER_TYPE_TITLE}} Identified!"
    }
    
    // MARK: - Revenue Cat Products
    struct Subscription {
        static let weeklyProductId = "{{IDENTIFIER_TYPE}}_weekly_premium"
        static let yearlyProductId = "{{IDENTIFIER_TYPE}}_yearly_premium"
        static let entitlementId = "{{IDENTIFIER_TYPE}}_premium"
    }
}
