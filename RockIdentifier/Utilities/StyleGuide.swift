// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

/// Comprehensive style guide for Rock Identifier's vibrant, mineral-inspired design
/// Based on feedback from casual rockhounds who want their rock identification to feel
/// joyful, magical, and celebratory rather than clinical or academic.
/// 
/// Usage:
/// - Apply text styles: .textStyle(.heroTitle)
/// - Apply button styles: .mineralButton(.primary)
/// - Apply spacing: .mineralPadding(.all, .medium)
/// - Apply corner radius: .mineralCornerRadius(.large)
/// - Apply card styles: .vibrantCard(.elevated)
/// - Apply shadows: .mineralShadow(.emeraldGreen, intensity: .medium)
struct StyleGuide {
    
    // MARK: - Corner Radius (Rounded for friendliness and fun)
    struct CornerRadius {
        /// Subtle rounding for small elements (4pt)
        static let extraSmall: CGFloat = 4
        /// Small radius for buttons and minor elements (12pt)
        static let small: CGFloat = 12
        /// Medium radius for cards and most UI elements (16pt)
        static let medium: CGFloat = 16
        /// Large radius for prominent elements (20pt)
        static let large: CGFloat = 20
        /// Extra large radius for hero elements (24pt)
        static let extraLarge: CGFloat = 24
        /// Pill radius for capsule-shaped buttons (28pt)
        static let pill: CGFloat = 28
    }
    
    // MARK: - Spacing & Padding (Generous spacing for breathability)
    struct Spacing {
        /// Tight spacing for related elements (4pt)
        static let tight: CGFloat = 4
        /// Extra small spacing (8pt)
        static let extraSmall: CGFloat = 8
        /// Small spacing (12pt)
        static let small: CGFloat = 12
        /// Medium spacing - most common (16pt)
        static let medium: CGFloat = 16
        /// Large spacing for sections (20pt)
        static let large: CGFloat = 20
        /// Extra large spacing (24pt)
        static let extraLarge: CGFloat = 24
        /// Loose spacing for major sections (32pt)
        static let loose: CGFloat = 32
        /// Extra loose spacing for hero areas (40pt)
        static let extraLoose: CGFloat = 40
    }
    
    // MARK: - Vibrant Mineral-Inspired Colors
    struct Colors {
        // Primary mineral colors - vibrant and energetic
        // static let amethystPurple = Color(hexString: "9B59B6")
        // static let amethystPurpleDark = Color(hexString: "8E44AD")
        // static let emeraldGreen = Color(hexString: "2ECC71")
        // static let emeraldGreenDark = Color(hexString: "27AE60")
        // static let citrineGold = Color(hexString: "F1C40F")
        // static let citrineGoldDark = Color(hexString: "F39C12")
        // static let sapphireBlue = Color(hexString: "3498DB")
        // static let sapphireBlueDark = Color(hexString: "2980B9")
        // static let roseQuartzPink = Color(hexString: "E91E63")
        // static let roseQuartzPinkLight = Color(hexString: "F06292")
        
        // More vibrant amethyst purples
        static let amethystPurple = Color(hexString: "A855F7")        // More electric purple
        static let amethystPurpleDark = Color(hexString: "7C3AED")    // Deep vibrant purple

        // More vibrant emerald greens
        static let emeraldGreen = Color(hexString: "10B981")          // Richer emerald
        static let emeraldGreenDark = Color(hexString: "059669")      // Deep forest emerald

        // More vibrant citrine golds
        static let citrineGold = Color(hexString: "FBBF24")           // Brighter golden yellow
        static let citrineGoldDark = Color(hexString: "F59E0B")       // Rich amber gold

        // More vibrant sapphire blues
        static let sapphireBlue = Color(hexString: "3B82F6")          // Electric sapphire blue
        static let sapphireBlueDark = Color(hexString: "1D4ED8")      // Deep royal blue
        
        // More vibrant ruby reds in lieu of rose quartz
        static let roseQuartzPink = Color(hexString: "FF2843")
        static let roseQuartzPinkDark = Color(hexString: "CC0020")

        
        // Gradient combinations for magical effects
        static let amethystGradient = LinearGradient(
            gradient: Gradient(colors: [amethystPurple, amethystPurpleDark]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let emeraldGradient = LinearGradient(
            gradient: Gradient(colors: [emeraldGreen, emeraldGreenDark]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let citrineGradient = LinearGradient(
            gradient: Gradient(colors: [citrineGold, citrineGoldDark]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let sapphireGradient = LinearGradient(
            gradient: Gradient(colors: [sapphireBlue, sapphireBlueDark]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let roseQuartzGradient = LinearGradient(
            gradient: Gradient(colors: [roseQuartzPink, roseQuartzPinkDark]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Multi-color gradients for special effects
        static let rainbowGradient = LinearGradient(
            gradient: Gradient(colors: [amethystPurple, emeraldGreen, citrineGold, sapphireBlue]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let geologicalGradient = LinearGradient(
            gradient: Gradient(colors: [roseQuartzPink, amethystPurple, sapphireBlue]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Semantic colors using mineral palette
        static let primary = amethystPurple
        static let primaryGradient = amethystGradient
        static let success = emeraldGreen
        static let successGradient = emeraldGradient
        static let warning = citrineGold
        static let warningGradient = citrineGradient
        static let info = sapphireBlue
        static let infoGradient = sapphireGradient
        static let accent = roseQuartzPink
        static let accentGradient = roseQuartzGradient
        
        // Background colors with subtle tints
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        
        // Tinted backgrounds for magical feel
        static let amethystBackground = amethystPurple.opacity(0.05)
        static let emeraldBackground = emeraldGreen.opacity(0.05)
        static let citrineBackground = citrineGold.opacity(0.05)
        
        // Overlay colors with mineral tints instead of pure black/white
        static let overlay10 = amethystPurple.opacity(0.1)
        static let overlay20 = amethystPurple.opacity(0.2)
        static let overlay30 = amethystPurple.opacity(0.3)
        static let overlay50 = amethystPurple.opacity(0.5)
        static let overlay70 = amethystPurple.opacity(0.7)
        static let overlay85 = amethystPurple.opacity(0.85)
        
        // Light overlays for dark backgrounds
        static let lightOverlay10 = Color.white.opacity(0.1)
        static let lightOverlay20 = Color.white.opacity(0.2)
        static let lightOverlay30 = Color.white.opacity(0.3)
        static let lightOverlay70 = Color.white.opacity(0.7)
        static let lightOverlay90 = Color.white.opacity(0.9)
    }
    
    // MARK: - Typography (Personality-rich and readable)
    struct Typography {
        // Display text styles - bold and energetic
        static let heroTitle = Font.system(size: 36, weight: .bold, design: .rounded)
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 24, weight: .bold, design: .rounded)
        
        // Content text styles with personality
        static let headline = Font.headline.weight(.bold)
        static let headlineMedium = Font.headline.weight(.semibold)
        static let body = Font.body
        static let bodyMedium = Font.body.weight(.medium)
        static let bodyBold = Font.body.weight(.bold)
        static let bodyLarge = Font.system(size: 18, weight: .regular)
        
        // Supporting text styles
        static let caption = Font.caption
        static let captionMedium = Font.caption.weight(.medium)
        static let captionBold = Font.caption.weight(.bold)
        static let subheadline = Font.subheadline
        static let subheadlineMedium = Font.subheadline.weight(.medium)
        static let subheadlineSemibold = Font.subheadline.weight(.semibold)
        
        // Special UI text styles
        static let buttonText = Font.system(size: 16, weight: .bold, design: .rounded)
        static let buttonTextLarge = Font.system(size: 18, weight: .bold, design: .rounded)
        static let tabText = Font.caption.weight(.semibold)
        static let badgeText = Font.system(size: 12, weight: .bold, design: .rounded)
        static let navigationTitle = Font.system(size: 18, weight: .bold, design: .rounded)
    }
    
    // MARK: - Text Style Enum (Consistent text styling throughout app)
    enum TextStyle {
        case heroTitle
        case largeTitle
        case title
        case title2
        case headline
        case headlineMedium
        case body
        case bodyMedium
        case bodyBold
        case bodyLarge
        case caption
        case captionMedium
        case captionBold
        case subheadline
        case subheadlineMedium
        case subheadlineSemibold
        case buttonText
        case buttonTextLarge
        case tabText
        case badgeText
        case navigationTitle
        
        var font: Font {
            switch self {
            case .heroTitle: return Typography.heroTitle
            case .largeTitle: return Typography.largeTitle
            case .title: return Typography.title
            case .title2: return Typography.title2
            case .headline: return Typography.headline
            case .headlineMedium: return Typography.headlineMedium
            case .body: return Typography.body
            case .bodyMedium: return Typography.bodyMedium
            case .bodyBold: return Typography.bodyBold
            case .bodyLarge: return Typography.bodyLarge
            case .caption: return Typography.caption
            case .captionMedium: return Typography.captionMedium
            case .captionBold: return Typography.captionBold
            case .subheadline: return Typography.subheadline
            case .subheadlineMedium: return Typography.subheadlineMedium
            case .subheadlineSemibold: return Typography.subheadlineSemibold
            case .buttonText: return Typography.buttonText
            case .buttonTextLarge: return Typography.buttonTextLarge
            case .tabText: return Typography.tabText
            case .badgeText: return Typography.badgeText
            case .navigationTitle: return Typography.navigationTitle
            }
        }
        
        var color: Color {
            switch self {
            case .heroTitle, .largeTitle, .title, .title2:
                return StyleGuide.Colors.primary
            case .headline, .headlineMedium:
                return .primary
            case .body, .bodyMedium, .bodyBold, .bodyLarge:
                return .primary
            case .caption, .captionMedium, .captionBold:
                return .secondary
            case .subheadline, .subheadlineMedium, .subheadlineSemibold:
                return .primary
            case .buttonText, .buttonTextLarge:
                return .white
            case .tabText:
                return StyleGuide.Colors.primary
            case .badgeText:
                return .white
            case .navigationTitle:
                return StyleGuide.Colors.primary
            }
        }
    }
    
    // MARK: - Shadows (Colorful and magical)
    struct Shadow {
        // Define a ViewModifier for shadow
        struct ShadowModifier: ViewModifier {
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
            
            func body(content: Content) -> some View {
                content.shadow(color: color, radius: radius, x: x, y: y)
            }
        }
        
        /// Subtle shadow with mineral tint
        static func subtle(color: Color = StyleGuide.Colors.amethystPurple) -> ShadowModifier {
            ShadowModifier(color: color.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        
        /// Small shadow for buttons and small elements
        static func small(color: Color = StyleGuide.Colors.amethystPurple) -> ShadowModifier {
            ShadowModifier(color: color.opacity(0.15), radius: 4, x: 0, y: 2)
        }
        
        /// Medium shadow for cards and elevated elements
        static func medium(color: Color = StyleGuide.Colors.amethystPurple) -> ShadowModifier {
            ShadowModifier(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        
        /// Large shadow for prominent elements
        static func large(color: Color = StyleGuide.Colors.amethystPurple) -> ShadowModifier {
            ShadowModifier(color: color.opacity(0.25), radius: 12, x: 0, y: 6)
        }
        
        /// Magical glow effect for special moments
        static func glow(color: Color, radius: CGFloat = 12) -> ShadowModifier {
            ShadowModifier(color: color.opacity(0.4), radius: radius, x: 0, y: 0)
        }
        
        // Define a ViewModifier for rainbow glow
        struct RainbowGlowModifier: ViewModifier {
            let radius: CGFloat
            
            func body(content: Content) -> some View {
                content
                    .shadow(color: StyleGuide.Colors.roseQuartzPink.opacity(0.3), radius: radius, x: -2, y: -2)
                    .shadow(color: StyleGuide.Colors.amethystPurple.opacity(0.3), radius: radius, x: 0, y: 0)
                    .shadow(color: StyleGuide.Colors.sapphireBlue.opacity(0.3), radius: radius, x: 2, y: 2)
            }
        }
        
        /// Multi-colored glow for A-HA moments
        static func rainbowGlow(radius: CGFloat = 15) -> RainbowGlowModifier {
            RainbowGlowModifier(radius: radius)
        }
    }
    
    // MARK: - Button Styles (Vibrant and bouncy)
    struct ButtonStyle {
        /// Primary button - amethyst gradient with bounce
        static func primary(cornerRadius: CGFloat = CornerRadius.medium) -> VibrantPrimaryButtonStyle {
            VibrantPrimaryButtonStyle(cornerRadius: cornerRadius)
        }
        
        /// Secondary button - emerald gradient
        static func secondary(cornerRadius: CGFloat = CornerRadius.medium) -> VibrantSecondaryButtonStyle {
            VibrantSecondaryButtonStyle(cornerRadius: cornerRadius)
        }
        
        /// Tertiary button - subtle with mineral tint
        static func tertiary(cornerRadius: CGFloat = CornerRadius.medium) -> VibrantTertiaryButtonStyle {
            VibrantTertiaryButtonStyle(cornerRadius: cornerRadius)
        }
        
        /// Floating action button - extra bouncy with gradient
        static func floatingAction() -> VibrantFloatingActionButtonStyle {
            VibrantFloatingActionButtonStyle()
        }
        
        /// Scale button for delightful interactions
        static func scale(intensity: CGFloat = 0.95) -> VibrantScaleButtonStyle {
            VibrantScaleButtonStyle(scaleAmount: intensity)
        }
        
        /// Pill button with rainbow gradient
        static func pill() -> VibrantPillButtonStyle {
            VibrantPillButtonStyle()
        }
        
        /// Tab button with mineral theming
        static func tab() -> VibrantTabButtonStyle {
            VibrantTabButtonStyle()
        }
    }
    
    // MARK: - Card Styles (Elevated and magical)
    struct Card {
        // Define a specific return type for card views
        struct CardView<Content: View>: View {
            let content: Content
            
            var body: some View {
                content
            }
            
            init(@ViewBuilder content: () -> Content) {
                self.content = content()
            }
        }
        
        /// Standard card with subtle mineral tint
        static func standard(cornerRadius: CGFloat = CornerRadius.large) -> some View {
            CardView {
                VStack { EmptyView() }
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Colors.background)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Colors.amethystPurple.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .modifier(Shadow.small())
            }
        }
        
        /// Elevated card for important content
        static func elevated(cornerRadius: CGFloat = CornerRadius.large) -> some View {
            CardView {
                VStack { EmptyView() }
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Colors.background)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Colors.rainbowGradient, lineWidth: 2)
                            )
                    )
                    .modifier(Shadow.medium())
            }
        }
        
        /// Hero card with magical gradient border
        static func hero(cornerRadius: CGFloat = CornerRadius.extraLarge) -> some View {
            CardView {
                VStack { EmptyView() }
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Colors.background)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .strokeBorder(Colors.geologicalGradient, lineWidth: 3)
                            )
                    )
                    .modifier(Shadow.large())
                    .modifier(Shadow.rainbowGlow())
            }
        }
        
        /// Collection item card with playful styling
        static func collection(cornerRadius: CGFloat = CornerRadius.large) -> some View {
            CardView {
                VStack { EmptyView() }
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Colors.background)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Colors.amethystPurple.opacity(0.2), lineWidth: 1.5)
                            )
                    )
                    .modifier(Shadow.medium(color: Colors.amethystPurple))
            }
        }
    }
    
    // MARK: - Badge Styles (Playful and informative)
    struct Badge {
        // Define a specific badge view type
        struct BadgeView: View {
            let text: String
            let background: LinearGradient
            let shadowColor: Color
            let rotationDegrees: Double
            
            var body: some View {
                Text(text)
                    .font(Typography.badgeText)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, Spacing.extraSmall)
                    .background(background)
                    .cornerRadius(CornerRadius.pill)
                    .modifier(Shadow.small(color: shadowColor))
                    .rotationEffect(.degrees(rotationDegrees))
            }
            
            init(text: String, background: LinearGradient, shadowColor: Color, rotationDegrees: Double = 0) {
                self.text = text
                self.background = background
                self.shadowColor = shadowColor
                self.rotationDegrees = rotationDegrees
            }
        }
        
        /// Success badge with emerald gradient
        static func success(_ text: String) -> BadgeView {
            BadgeView(text: text, background: Colors.emeraldGradient, shadowColor: Colors.emeraldGreen)
        }
        
        /// Info badge with sapphire gradient
        static func info(_ text: String) -> BadgeView {
            BadgeView(text: text, background: Colors.sapphireGradient, shadowColor: Colors.sapphireBlue)
        }
        
        /// Warning badge with citrine gradient
        static func warning(_ text: String) -> BadgeView {
            BadgeView(text: text, background: Colors.citrineGradient, shadowColor: Colors.citrineGold)
        }
        
        /// Accent badge with rose quartz gradient
        static func accent(_ text: String) -> BadgeView {
            BadgeView(text: text, background: Colors.roseQuartzGradient, shadowColor: Colors.roseQuartzPink, rotationDegrees: -1) // Playful tilt
        }
        
        /// Primary badge with amethyst gradient
        static func primary(_ text: String) -> BadgeView {
            BadgeView(text: text, background: Colors.amethystGradient, shadowColor: Colors.amethystPurple)
        }
    }
}

// MARK: - Custom Button Style Implementations

struct VibrantPrimaryButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StyleGuide.Typography.buttonText)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(StyleGuide.Colors.amethystGradient)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .modifier(StyleGuide.Shadow.medium(color: StyleGuide.Colors.amethystPurple))
    }
}

struct VibrantSecondaryButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StyleGuide.Typography.buttonText)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(StyleGuide.Colors.emeraldGradient)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .modifier(StyleGuide.Shadow.medium(color: StyleGuide.Colors.emeraldGreen))
    }
}

struct VibrantTertiaryButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StyleGuide.Typography.buttonText)
            .foregroundColor(StyleGuide.Colors.amethystPurple)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(StyleGuide.Colors.amethystBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(StyleGuide.Colors.amethystGradient, lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct VibrantFloatingActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StyleGuide.Typography.buttonTextLarge)
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(StyleGuide.Colors.roseQuartzGradient)
            .cornerRadius(30)
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.5), value: configuration.isPressed)
            .modifier(StyleGuide.Shadow.large(color: StyleGuide.Colors.roseQuartzPink))
    }
}

struct VibrantScaleButtonStyle: ButtonStyle {
    let scaleAmount: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Enhanced scale button style with configurable intensity
struct EnhancedScaleButtonStyle: ButtonStyle {
    let scaleAmount: CGFloat
    let animationType: AnimationType
    
    enum AnimationType {
        case spring
        case easeInOut(duration: Double)
        
        var animation: Animation {
            switch self {
            case .spring:
                return .spring(response: 0.3, dampingFraction: 0.6)
            case .easeInOut(let duration):
                return .easeInOut(duration: duration)
            }
        }
    }
    
    init(scaleAmount: CGFloat = 0.95, animationType: AnimationType = .spring) {
        self.scaleAmount = scaleAmount
        self.animationType = animationType
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(animationType.animation, value: configuration.isPressed)
    }
}

/// Convenience typealias for backward compatibility
typealias ScaleButtonStyle = EnhancedScaleButtonStyle

struct VibrantPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StyleGuide.Typography.captionBold)
            .foregroundColor(.white)
            .padding(.horizontal, StyleGuide.Spacing.medium)
            .padding(.vertical, StyleGuide.Spacing.extraSmall)
            .background(StyleGuide.Colors.rainbowGradient)
            .cornerRadius(StyleGuide.CornerRadius.pill)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .modifier(StyleGuide.Shadow.small())
    }
}

struct VibrantTabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Helper Extensions

extension Color {
    // Create a unique initializer name to avoid conflicts
    init(hexString hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Quick access to mineral colors from Assets.xcassets
    static let assetAmethystPurple = Color("AmethystPurple")
    static let assetEmeraldGreen = Color("AccentGreen")
    static let assetCitrineGold = Color("AccentOrange")
    static let assetSapphireBlue = Color("PrimaryBlue")
    static let assetRoseQuartzPink = Color("RoseQuartzPink")
}

// MARK: - View Modifiers for Easy Application

struct VibrantCardStyle: ViewModifier {
    let style: Style
    
    enum Style {
        case standard, elevated, hero, collection
    }
    
    func body(content: Content) -> some View {
        switch style {
        case .standard:
            content.overlay(StyleGuide.Card.standard())
        case .elevated:
            content.overlay(StyleGuide.Card.elevated())
        case .hero:
            content.overlay(StyleGuide.Card.hero())
        case .collection:
            content.overlay(StyleGuide.Card.collection())
        }
    }
}

extension View {
    /// Apply vibrant card styling
    func vibrantCard(_ style: VibrantCardStyle.Style = .standard) -> some View {
        self.modifier(VibrantCardStyle(style: style))
    }
    
    /// Apply rainbow glow effect for special moments
    func rainbowGlow(radius: CGFloat = 15) -> some View {
        return self.modifier(StyleGuide.Shadow.rainbowGlow(radius: radius))
    }
    
    /// Apply mineral-tinted shadow
    func mineralShadow(_ color: Color = StyleGuide.Colors.amethystPurple, intensity: StyleGuide.Shadow.Intensity = .medium) -> some View {
        switch intensity {
        case .subtle:
            return self.modifier(StyleGuide.Shadow.subtle(color: color))
        case .small:
            return self.modifier(StyleGuide.Shadow.small(color: color))
        case .medium:
            return self.modifier(StyleGuide.Shadow.medium(color: color))
        case .large:
            return self.modifier(StyleGuide.Shadow.large(color: color))
        }
    }
    
    /// Apply consistent text styling using StyleGuide TextStyle enum
    func textStyle(_ style: StyleGuide.TextStyle) -> some View {
        self.font(style.font)
            .foregroundColor(style.color)
    }
    
    /// Apply mineral-themed button styling
    func mineralButton(_ style: StyleGuide.MineralButtonStyle = .primary) -> AnyView {
        switch style {
        case .primary:
            return AnyView(self.buttonStyle(StyleGuide.ButtonStyle.primary()))
        case .secondary:
            return AnyView(self.buttonStyle(StyleGuide.ButtonStyle.secondary()))
        case .tertiary:
            return AnyView(self.buttonStyle(StyleGuide.ButtonStyle.tertiary()))
        case .floatingAction:
            return AnyView(self.buttonStyle(StyleGuide.ButtonStyle.floatingAction()))
        case .pill:
            return AnyView(self.buttonStyle(StyleGuide.ButtonStyle.pill()))
        case .scale:
            return AnyView(self.buttonStyle(StyleGuide.ButtonStyle.scale()))
        }
    }
    
    /// Apply consistent padding using StyleGuide spacing
    func mineralPadding(_ edges: Edge.Set = .all, _ spacing: StyleGuide.SpacingSize = .medium) -> some View {
        self.padding(edges, spacing.value)
    }
    
    /// Apply consistent corner radius using StyleGuide values
    func mineralCornerRadius(_ size: StyleGuide.CornerRadiusSize = .medium) -> some View {
        self.cornerRadius(size.value)
    }
}

extension StyleGuide.Shadow {
    enum Intensity {
        case subtle, small, medium, large
    }
}

extension StyleGuide.Card {
    enum CardStyle {
        case standard, elevated, hero, collection
    }
}

// MARK: - Additional Enums for Convenience

extension StyleGuide {
    enum MineralButtonStyle {
        case primary, secondary, tertiary, floatingAction, pill, scale
    }
    
    enum SpacingSize {
        case tight, extraSmall, small, medium, large, extraLarge, loose, extraLoose
        
        var value: CGFloat {
            switch self {
            case .tight: return StyleGuide.Spacing.tight
            case .extraSmall: return StyleGuide.Spacing.extraSmall
            case .small: return StyleGuide.Spacing.small
            case .medium: return StyleGuide.Spacing.medium
            case .large: return StyleGuide.Spacing.large
            case .extraLarge: return StyleGuide.Spacing.extraLarge
            case .loose: return StyleGuide.Spacing.loose
            case .extraLoose: return StyleGuide.Spacing.extraLoose
            }
        }
    }
    
    enum CornerRadiusSize {
        case extraSmall, small, medium, large, extraLarge, pill
        
        var value: CGFloat {
            switch self {
            case .extraSmall: return StyleGuide.CornerRadius.extraSmall
            case .small: return StyleGuide.CornerRadius.small
            case .medium: return StyleGuide.CornerRadius.medium
            case .large: return StyleGuide.CornerRadius.large
            case .extraLarge: return StyleGuide.CornerRadius.extraLarge
            case .pill: return StyleGuide.CornerRadius.pill
            }
        }
    }
}
