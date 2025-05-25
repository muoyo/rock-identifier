// Rock Identifier: Crystal ID
// Muoyo Okome
//

import UIKit
import SwiftUI

// MARK: - SwiftUI Color to UIColor Extension

extension Color {
    var uiColor: UIColor {
        return UIColor(self)
    }
}

/// Generates visually appealing shareable cards for rock identification results
/// Implements multiple card styles and customization options
class ShareableCardGenerator {
    
    // MARK: - Card Styles
    
    enum CardStyle {
        case classic       // Clean, minimalist design
        case vibrant       // Colorful with gradients
        case scientific    // Data-focused layout
        case social        // Optimized for social sharing
        
        var cardSize: CGSize {
            switch self {
            case .classic, .vibrant, .scientific:
                return CGSize(width: 400, height: 600)
            case .social:
                return CGSize(width: 400, height: 400) // Square for Instagram
            }
        }
    }
    
    // MARK: - Card Content Options
    
    struct CardContent {
        let includeImage: Bool
        let includeBasicInfo: Bool
        let includePhysicalProperties: Bool
        let includeChemicalProperties: Bool
        let includeFormation: Bool
        let includeUses: Bool
        let includeAppBranding: Bool
        let includeConfidence: Bool
        
        static let `default` = CardContent(
            includeImage: true,
            includeBasicInfo: true,
            includePhysicalProperties: true,
            includeChemicalProperties: false,
            includeFormation: false,
            includeUses: false,
            includeAppBranding: true,
            includeConfidence: true
        )
        
        static let minimal = CardContent(
            includeImage: true,
            includeBasicInfo: true,
            includePhysicalProperties: false,
            includeChemicalProperties: false,
            includeFormation: false,
            includeUses: false,
            includeAppBranding: true,
            includeConfidence: false
        )
        
        static let detailed = CardContent(
            includeImage: true,
            includeBasicInfo: true,
            includePhysicalProperties: true,
            includeChemicalProperties: true,
            includeFormation: true,
            includeUses: true,
            includeAppBranding: true,
            includeConfidence: true
        )
        
        static let social = CardContent(
            includeImage: true,
            includeBasicInfo: true,
            includePhysicalProperties: true,
            includeChemicalProperties: false,
            includeFormation: false,
            includeUses: false,
            includeAppBranding: true,
            includeConfidence: false
        )
    }
    
    // MARK: - Main Generation Function
    
    static func generateCard(
        for result: RockIdentificationResult,
        style: CardStyle = .vibrant,
        content: CardContent = .default
    ) -> UIImage? {
        let size = style.cardSize
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0 // High resolution for sharing
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            switch style {
            case .classic:
                drawClassicCard(in: rect, for: result, content: content, context: context)
            case .vibrant:
                drawVibrantCard(in: rect, for: result, content: content, context: context)
            case .scientific:
                drawScientificCard(in: rect, for: result, content: content, context: context)
            case .social:
                drawSocialCard(in: rect, for: result, content: content, context: context)
            }
        }
    }
    
    // MARK: - Card Drawing Functions
    
    private static func drawClassicCard(
        in rect: CGRect,
        for result: RockIdentificationResult,
        content: CardContent,
        context: UIGraphicsImageRendererContext
    ) {
        let ctx = context.cgContext
        
        // Background
        ctx.setFillColor(UIColor.systemBackground.cgColor)
        ctx.fill(rect)
        
        // Add subtle border
        ctx.setStrokeColor(UIColor.systemGray4.cgColor)
        ctx.setLineWidth(1.0)
        ctx.stroke(rect.insetBy(dx: 1, dy: 1))
        
        let padding: CGFloat = 20
        var currentY: CGFloat = padding
        
        // Rock image (if included)
        if content.includeImage, let image = result.image {
            let imageHeight: CGFloat = 180
            let imageRect = CGRect(
                x: padding,
                y: currentY,
                width: rect.width - 2 * padding,
                height: imageHeight
            )
            
            drawRoundedImage(image, in: imageRect, cornerRadius: 12, context: ctx)
            currentY += imageHeight + 20
        }
        
        // Basic info
        if content.includeBasicInfo {
            currentY = drawBasicInfo(
                result: result,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .classic,
                context: ctx
            )
        }
        
        // Physical properties
        if content.includePhysicalProperties {
            currentY = drawPhysicalProperties(
                properties: result.physicalProperties,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .classic,
                context: ctx
            )
        }
        
        // Confidence indicator
        if content.includeConfidence {
            currentY = drawConfidenceIndicator(
                confidence: result.confidence,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .classic,
                context: ctx
            )
        }
        
        // App branding
        if content.includeAppBranding {
            drawAppBranding(
                in: rect,
                padding: padding,
                style: .classic,
                context: ctx
            )
        }
    }
    
    private static func drawVibrantCard(
        in rect: CGRect,
        for result: RockIdentificationResult,
        content: CardContent,
        context: UIGraphicsImageRendererContext
    ) {
        let ctx = context.cgContext
        
        // Vibrant gradient background
        let colors = [
            UIColor(StyleGuide.Colors.roseQuartzPink).withAlphaComponent(0.1).cgColor,
            UIColor(StyleGuide.Colors.sapphireBlue).withAlphaComponent(0.05).cgColor,
            UIColor.systemBackground.cgColor
        ]
        
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 0.5, 1.0])!
        ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: rect.width, y: rect.height), options: [])
        
        // Decorative gradient border
        let borderGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [
            UIColor(StyleGuide.Colors.roseQuartzPink).cgColor,
            UIColor(StyleGuide.Colors.sapphireBlue).cgColor,
            UIColor(StyleGuide.Colors.emeraldGreen).cgColor
        ] as CFArray, locations: [0.0, 0.5, 1.0])!
        
        ctx.setLineWidth(3.0)
        let borderPath = UIBezierPath(roundedRect: rect.insetBy(dx: 1.5, dy: 1.5), cornerRadius: 16)
        ctx.addPath(borderPath.cgPath)
        ctx.replacePathWithStrokedPath()
        ctx.clip()
        ctx.drawLinearGradient(borderGradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: rect.width, y: 0), options: [])
        
        // Reset clipping
        ctx.resetClip()
        
        let padding: CGFloat = 24
        var currentY: CGFloat = padding
        
        // Rock image with enhanced styling
        if content.includeImage, let image = result.image {
            let imageHeight: CGFloat = 200
            let imageRect = CGRect(
                x: padding,
                y: currentY,
                width: rect.width - 2 * padding,
                height: imageHeight
            )
            
            // Add shadow behind image
            ctx.setShadow(offset: CGSize(width: 0, height: 4), blur: 8, color: UIColor.black.withAlphaComponent(0.2).cgColor)
            drawRoundedImage(image, in: imageRect, cornerRadius: 16, context: ctx)
            ctx.setShadow(offset: .zero, blur: 0, color: nil)
            
            currentY += imageHeight + 24
        }
        
        // Basic info with vibrant styling
        if content.includeBasicInfo {
            currentY = drawBasicInfo(
                result: result,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .vibrant,
                context: ctx
            )
        }
        
        // Physical properties with colorful accents
        if content.includePhysicalProperties {
            currentY = drawPhysicalProperties(
                properties: result.physicalProperties,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .vibrant,
                context: ctx
            )
        }
        
        // Confidence with gradient
        if content.includeConfidence {
            currentY = drawConfidenceIndicator(
                confidence: result.confidence,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .vibrant,
                context: ctx
            )
        }
        
        // App branding with style
        if content.includeAppBranding {
            drawAppBranding(
                in: rect,
                padding: padding,
                style: .vibrant,
                context: ctx
            )
        }
    }
    
    private static func drawScientificCard(
        in rect: CGRect,
        for result: RockIdentificationResult,
        content: CardContent,
        context: UIGraphicsImageRendererContext
    ) {
        let ctx = context.cgContext
        
        // Clean white background with subtle grid
        ctx.setFillColor(UIColor.systemBackground.cgColor)
        ctx.fill(rect)
        
        // Grid pattern
        ctx.setStrokeColor(UIColor.systemGray5.cgColor)
        ctx.setLineWidth(0.5)
        
        let gridSpacing: CGFloat = 20
        for x in stride(from: 0, through: rect.width, by: gridSpacing) {
            ctx.move(to: CGPoint(x: x, y: 0))
            ctx.addLine(to: CGPoint(x: x, y: rect.height))
        }
        for y in stride(from: 0, through: rect.height, by: gridSpacing) {
            ctx.move(to: CGPoint(x: 0, y: y))
            ctx.addLine(to: CGPoint(x: rect.width, y: y))
        }
        ctx.strokePath()
        
        // Scientific border
        ctx.setStrokeColor(UIColor.label.cgColor)
        ctx.setLineWidth(2.0)
        ctx.stroke(rect.insetBy(dx: 1, dy: 1))
        
        let padding: CGFloat = 20
        var currentY: CGFloat = padding
        
        // All content with scientific formatting
        if content.includeImage, let image = result.image {
            let imageHeight: CGFloat = 160
            let imageRect = CGRect(
                x: padding,
                y: currentY,
                width: rect.width - 2 * padding,
                height: imageHeight
            )
            
            drawRoundedImage(image, in: imageRect, cornerRadius: 8, context: ctx)
            currentY += imageHeight + 16
        }
        
        if content.includeBasicInfo {
            currentY = drawBasicInfo(
                result: result,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .scientific,
                context: ctx
            )
        }
        
        if content.includePhysicalProperties {
            currentY = drawPhysicalProperties(
                properties: result.physicalProperties,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .scientific,
                context: ctx
            )
        }
        
        if content.includeChemicalProperties {
            currentY = drawChemicalProperties(
                properties: result.chemicalProperties,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .scientific,
                context: ctx
            )
        }
        
        if content.includeAppBranding {
            drawAppBranding(
                in: rect,
                padding: padding,
                style: .scientific,
                context: ctx
            )
        }
    }
    
    private static func drawSocialCard(
        in rect: CGRect,
        for result: RockIdentificationResult,
        content: CardContent,
        context: UIGraphicsImageRendererContext
    ) {
        let ctx = context.cgContext
        
        // Instagram-optimized square format
        // Gradient background optimized for social sharing
        let colors = [
            UIColor(StyleGuide.Colors.emeraldGreen).withAlphaComponent(0.1).cgColor,
            UIColor(StyleGuide.Colors.roseQuartzPink).withAlphaComponent(0.1).cgColor,
            UIColor.systemBackground.cgColor
        ]
        
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 0.5, 1.0])!
        ctx.drawRadialGradient(gradient, startCenter: CGPoint(x: rect.width * 0.3, y: rect.height * 0.3), startRadius: 0, endCenter: CGPoint(x: rect.width * 0.7, y: rect.height * 0.7), endRadius: rect.width * 0.8, options: [])
        
        let padding: CGFloat = 20
        var currentY: CGFloat = padding
        
        // Large rock image taking up most space
        if content.includeImage, let image = result.image {
            let imageSize: CGFloat = rect.width - 2 * padding
            let imageRect = CGRect(
                x: padding,
                y: currentY,
                width: imageSize,
                height: imageSize * 0.6
            )
            
            // Enhanced shadow for social media
            ctx.setShadow(offset: CGSize(width: 0, height: 6), blur: 12, color: UIColor.black.withAlphaComponent(0.3).cgColor)
            drawRoundedImage(image, in: imageRect, cornerRadius: 20, context: ctx)
            ctx.setShadow(offset: .zero, blur: 0, color: nil)
            
            currentY += imageRect.height + 16
        }
        
        // Bold, large text for social media
        if content.includeBasicInfo {
            currentY = drawBasicInfo(
                result: result,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .social,
                context: ctx
            )
        }
        
        // Key properties only
        if content.includePhysicalProperties {
            currentY = drawPhysicalProperties(
                properties: result.physicalProperties,
                in: rect,
                startY: currentY,
                padding: padding,
                style: .social,
                context: ctx
            )
        }
        
        // Prominent app branding for social
        if content.includeAppBranding {
            drawAppBranding(
                in: rect,
                padding: padding,
                style: .social,
                context: ctx
            )
        }
    }
    
    // MARK: - Helper Drawing Functions
    
    private static func drawRoundedImage(_ image: UIImage, in rect: CGRect, cornerRadius: CGFloat, context: CGContext) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.addPath(path.cgPath)
        context.clip()
        image.draw(in: rect)
        context.resetClip()
    }
    
    private static func drawBasicInfo(
        result: RockIdentificationResult,
        in rect: CGRect,
        startY: CGFloat,
        padding: CGFloat,
        style: CardStyle,
        context: CGContext
    ) -> CGFloat {
        var currentY = startY
        
        // Rock name
        let nameAttributes: [NSAttributedString.Key: Any] = {
            switch style {
            case .classic:
                return [
                    .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                    .foregroundColor: UIColor.label
                ]
            case .vibrant, .social:
                return [
                    .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                    .foregroundColor: UIColor(StyleGuide.Colors.roseQuartzPink)
                ]
            case .scientific:
                return [
                    .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
                    .foregroundColor: UIColor.label
                ]
            }
        }()
        
        let nameString = NSAttributedString(string: result.name, attributes: nameAttributes)
        let nameRect = CGRect(x: padding, y: currentY, width: rect.width - 2 * padding, height: 40)
        nameString.draw(in: nameRect)
        currentY += 40
        
        // Category
        let categoryAttributes: [NSAttributedString.Key: Any] = {
            switch style {
            case .classic, .scientific:
                return [
                    .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            case .vibrant, .social:
                return [
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                    .foregroundColor: UIColor(StyleGuide.Colors.sapphireBlue)
                ]
            }
        }()
        
        let categoryString = NSAttributedString(string: result.category, attributes: categoryAttributes)
        let categoryRect = CGRect(x: padding, y: currentY, width: rect.width - 2 * padding, height: 25)
        categoryString.draw(in: categoryRect)
        currentY += 35
        
        return currentY
    }
    
    private static func drawPhysicalProperties(
        properties: PhysicalProperties,
        in rect: CGRect,
        startY: CGFloat,
        padding: CGFloat,
        style: CardStyle,
        context: CGContext
    ) -> CGFloat {
        var currentY = startY
        
        // Section title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: style == .vibrant ? UIColor(StyleGuide.Colors.emeraldGreen) : UIColor.label
        ]
        
        let titleString = NSAttributedString(string: "Physical Properties", attributes: titleAttributes)
        let titleRect = CGRect(x: padding, y: currentY, width: rect.width - 2 * padding, height: 20)
        titleString.draw(in: titleRect)
        currentY += 25
        
        // Key properties
        let propertyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.label
        ]
        
        let keyProperties = [
            ("Color", properties.color),
            ("Hardness", properties.hardness),
            ("Luster", properties.luster)
        ]
        
        for (label, value) in keyProperties {
            let propertyText = "\(label): \(value)"
            let propertyString = NSAttributedString(string: propertyText, attributes: propertyAttributes)
            let propertyRect = CGRect(x: padding + 10, y: currentY, width: rect.width - 2 * padding - 10, height: 18)
            propertyString.draw(in: propertyRect)
            currentY += 20
        }
        
        currentY += 10
        return currentY
    }
    
    private static func drawChemicalProperties(
        properties: ChemicalProperties,
        in rect: CGRect,
        startY: CGFloat,
        padding: CGFloat,
        style: CardStyle,
        context: CGContext
    ) -> CGFloat {
        var currentY = startY
        
        // Section title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: style == .vibrant ? UIColor(StyleGuide.Colors.sapphireBlue) : UIColor.label
        ]
        
        let titleString = NSAttributedString(string: "Chemical Properties", attributes: titleAttributes)
        let titleRect = CGRect(x: padding, y: currentY, width: rect.width - 2 * padding, height: 20)
        titleString.draw(in: titleRect)
        currentY += 25
        
        // Formula
        if let formula = properties.formula {
            let formulaAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor.label
            ]
            
            let formulaString = NSAttributedString(string: formula, attributes: formulaAttributes)
            let formulaRect = CGRect(x: padding + 10, y: currentY, width: rect.width - 2 * padding - 10, height: 25)
            formulaString.draw(in: formulaRect)
            currentY += 30
        }
        
        // Composition
        let compositionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.label
        ]
        
        let compositionString = NSAttributedString(string: properties.composition, attributes: compositionAttributes)
        let compositionRect = CGRect(x: padding + 10, y: currentY, width: rect.width - 2 * padding - 10, height: 40)
        compositionString.draw(in: compositionRect)
        currentY += 50
        
        return currentY
    }
    
    private static func drawConfidenceIndicator(
        confidence: Double,
        in rect: CGRect,
        startY: CGFloat,
        padding: CGFloat,
        style: CardStyle,
        context: CGContext
    ) -> CGFloat {
        var currentY = startY
        
        // Confidence bar
        let barWidth: CGFloat = rect.width - 2 * padding
        let barHeight: CGFloat = 8
        let barRect = CGRect(x: padding, y: currentY, width: barWidth, height: barHeight)
        
        // Background
        context.setFillColor(UIColor.systemGray5.cgColor)
        let backgroundPath = UIBezierPath(roundedRect: barRect, cornerRadius: barHeight / 2)
        context.addPath(backgroundPath.cgPath)
        context.fillPath()
        
        // Fill
        let fillWidth = barWidth * CGFloat(confidence)
        let fillRect = CGRect(x: padding, y: currentY, width: fillWidth, height: barHeight)
        let fillColor = confidence >= 0.8 ? UIColor(StyleGuide.Colors.emeraldGreen) : 
                       confidence >= 0.5 ? UIColor(StyleGuide.Colors.citrineGold) : 
                       UIColor(StyleGuide.Colors.roseQuartzPink)
        
        context.setFillColor(fillColor.cgColor)
        let fillPath = UIBezierPath(roundedRect: fillRect, cornerRadius: barHeight / 2)
        context.addPath(fillPath.cgPath)
        context.fillPath()
        
        currentY += barHeight + 5
        
        // Confidence text
        let confidenceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let confidenceText = "\(Int(confidence * 100))% Confidence"
        let confidenceString = NSAttributedString(string: confidenceText, attributes: confidenceAttributes)
        let confidenceRect = CGRect(x: padding, y: currentY, width: rect.width - 2 * padding, height: 15)
        confidenceString.draw(in: confidenceRect)
        currentY += 25
        
        return currentY
    }
    
    private static func drawAppBranding(
        in rect: CGRect,
        padding: CGFloat,
        style: CardStyle,
        context: CGContext
    ) {
        let brandingY = rect.height - 40
        
        // App name and tagline
        let brandingAttributes: [NSAttributedString.Key: Any] = {
            switch style {
            case .classic, .scientific:
                return [
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                    .foregroundColor: UIColor.tertiaryLabel
                ]
            case .vibrant, .social:
                return [
                    .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                    .foregroundColor: UIColor(StyleGuide.Colors.roseQuartzPink)
                ]
            }
        }()
        
        let brandingText = "Rock Identifier: Crystal ID"
        let brandingString = NSAttributedString(string: brandingText, attributes: brandingAttributes)
        let brandingRect = CGRect(x: padding, y: brandingY, width: rect.width - 2 * padding, height: 20)
        brandingString.draw(in: brandingRect)
        
        // CTA text
        let ctaAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor.tertiaryLabel
        ]
        
        let ctaText = "Identify rocks instantly with AI"
        let ctaString = NSAttributedString(string: ctaText, attributes: ctaAttributes)
        let ctaRect = CGRect(x: padding, y: brandingY + 15, width: rect.width - 2 * padding, height: 15)
        ctaString.draw(in: ctaRect)
    }
}
