// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import UIKit

/// Enhanced share sheet with shareable card generation and customization options
struct EnhancedShareSheet: View {
    let result: RockIdentificationResult
    @Binding var isPresented: Bool
    
    @State private var selectedCardStyle: ShareableCardGenerator.CardStyle = .vibrant
    @State private var selectedContent: ShareableCardGenerator.CardContent = .default
    @State private var showCustomization = false
    @State private var showShareSheet = false
    @State private var generatedCard: UIImage?
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Share Your Discovery")
                        .font(StyleGuide.Typography.title2)
                        .foregroundColor(StyleGuide.Colors.roseQuartzPink)
                    
                    Text("Create a beautiful card to share your rock identification")
                        .font(StyleGuide.Typography.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Card Preview
                if let generatedCard = generatedCard {
                    VStack(spacing: 12) {
                        Text("Card Preview")
                            .font(StyleGuide.Typography.headline)
                            .foregroundColor(.primary)
                        
                        Image(uiImage: generatedCard)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(16)
                            .shadow(color: StyleGuide.Colors.roseQuartzPink.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                } else {
                    // Card generation placeholder
                    VStack(spacing: 16) {
                        if isGenerating {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(StyleGuide.Colors.roseQuartzPink)
                                
                                Text("Creating your shareable card...")
                                    .font(StyleGuide.Typography.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(StyleGuide.Colors.roseQuartzPink.opacity(0.6))
                                
                                Text("Card Preview")
                                    .font(StyleGuide.Typography.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Choose a style to generate your card")
                                    .font(StyleGuide.Typography.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }
                    }
                }
                
                // Card Style Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Card Style")
                        .font(StyleGuide.Typography.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach([ShareableCardGenerator.CardStyle.vibrant, .classic, .scientific, .social], id: \.self) { style in
                            CardStyleButton(
                                style: style,
                                isSelected: selectedCardStyle == style,
                                action: {
                                    selectedCardStyle = style
                                    generateCard()
                                }
                            )
                        }
                    }
                }
                
                // Content Options
                VStack(alignment: .leading, spacing: 12) {
                    Text("Content Options")
                        .font(StyleGuide.Typography.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        ContentOptionButton(
                            title: "Minimal",
                            description: "Name and image only",
                            isSelected: isContentEqual(selectedContent, .minimal),
                            action: {
                                selectedContent = .minimal
                                generateCard()
                            }
                        )
                        
                        ContentOptionButton(
                            title: "Standard",
                            description: "Key properties included",
                            isSelected: isContentEqual(selectedContent, .default),
                            action: {
                                selectedContent = .default
                                generateCard()
                            }
                        )
                        
                        ContentOptionButton(
                            title: "Detailed",
                            description: "All information",
                            isSelected: isContentEqual(selectedContent, .detailed),
                            action: {
                                selectedContent = .detailed
                                generateCard()
                            }
                        )
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    // Share button
                    Button(action: {
                        if generatedCard == nil {
                            generateCard()
                        }
                        
                        // Wait a moment for generation if needed
                        DispatchQueue.main.asyncAfter(deadline: .now() + (isGenerating ? 1.0 : 0.1)) {
                            showShareSheet = true
                        }
                    }) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            } else {
                                Image(systemName: "square.and.arrow.up")
                            }
                            
                            Text(isGenerating ? "Generating..." : "Share Card")
                        }
                        .font(StyleGuide.Typography.buttonText)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(StyleGuide.Colors.roseQuartzGradient)
                        .cornerRadius(12)
                        .disabled(isGenerating)
                    }
                    .buttonStyle(EnhancedScaleButtonStyle())
                    
                    // Cancel button
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(StyleGuide.Typography.buttonText)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                    .buttonStyle(EnhancedScaleButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .navigationBarTitle("Share", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
        .onAppear {
            generateCard()
        }
        .sheet(isPresented: $showShareSheet) {
            if let card = generatedCard {
                ShareSheet(items: [
                    card,
                    "I just identified this \(result.name) using Rock Identifier! 🪨✨ #RockIdentifier #Geology #Crystals"
                ])
            } else {
                ShareSheet(items: ["I just identified this \(result.name) using Rock Identifier!"])
            }
        }
    }
    
    private func generateCard() {
        isGenerating = true
        
        // Generate card asynchronously to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            let card = ShareableCardGenerator.generateCard(
                for: result,
                style: selectedCardStyle,
                content: selectedContent
            )
            
            DispatchQueue.main.async {
                self.generatedCard = card
                self.isGenerating = false
            }
        }
    }
    
    private func isContentEqual(_ content1: ShareableCardGenerator.CardContent, _ content2: ShareableCardGenerator.CardContent) -> Bool {
        return content1.includeImage == content2.includeImage &&
               content1.includeBasicInfo == content2.includeBasicInfo &&
               content1.includePhysicalProperties == content2.includePhysicalProperties &&
               content1.includeChemicalProperties == content2.includeChemicalProperties &&
               content1.includeFormation == content2.includeFormation &&
               content1.includeUses == content2.includeUses &&
               content1.includeAppBranding == content2.includeAppBranding &&
               content1.includeConfidence == content2.includeConfidence
    }
}

// MARK: - Supporting Views

struct CardStyleButton: View {
    let style: ShareableCardGenerator.CardStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Style icon
                Image(systemName: styleIcon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : styleColor)
                
                Text(styleName)
                    .font(StyleGuide.Typography.captionBold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(styleDescription)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? styleColor : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? styleColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(EnhancedScaleButtonStyle(scaleAmount: 0.97))
    }
    
    private var styleName: String {
        switch style {
        case .classic: return "Classic"
        case .vibrant: return "Vibrant"
        case .scientific: return "Scientific"
        case .social: return "Social"
        }
    }
    
    private var styleDescription: String {
        switch style {
        case .classic: return "Clean & minimal"
        case .vibrant: return "Colorful & fun"
        case .scientific: return "Data focused"
        case .social: return "Square format"
        }
    }
    
    private var styleIcon: String {
        switch style {
        case .classic: return "doc.text"
        case .vibrant: return "paintbrush.fill"
        case .scientific: return "chart.bar.doc.horizontal"
        case .social: return "square.on.square"
        }
    }
    
    private var styleColor: Color {
        switch style {
        case .classic: return Color(.systemGray)
        case .vibrant: return StyleGuide.Colors.roseQuartzPink
        case .scientific: return StyleGuide.Colors.sapphireBlue
        case .social: return StyleGuide.Colors.emeraldGreen
        }
    }
}

struct ContentOptionButton: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(StyleGuide.Typography.captionBold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? StyleGuide.Colors.roseQuartzPink : Color(.systemGray6))
            )
        }
        .buttonStyle(EnhancedScaleButtonStyle(scaleAmount: 0.97))
    }
}

// MARK: - Preview

struct EnhancedShareSheet_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock data for preview
        let mockPhysicalProperties = PhysicalProperties(
            color: "Purple to violet",
            hardness: "7 (Mohs scale)",
            luster: "Vitreous"
        )
        
        let mockChemicalProperties = ChemicalProperties(
            formula: "SiO₂",
            composition: "Silicon dioxide",
            elements: [
                Element(name: "Silicon", symbol: "Si", percentage: 46.7),
                Element(name: "Oxygen", symbol: "O", percentage: 53.3)
            ]
        )
        
        let mockFormation = Formation(
            formationType: "Mineral",
            environment: "Igneous rocks",
            formationProcess: "Crystallization"
        )
        
        let mockUses = Uses(
            industrial: ["Jewelry"],
            historical: ["Ancient Egyptian jewelry"],
            modern: ["Gemstone jewelry"],
            funFacts: ["February birthstone"]
        )
        
        let mockResult = RockIdentificationResult(
            image: UIImage(systemName: "photo"),
            name: "Amethyst",
            category: "Quartz Variety",
            confidence: 0.92,
            physicalProperties: mockPhysicalProperties,
            chemicalProperties: mockChemicalProperties,
            formation: mockFormation,
            uses: mockUses
        )
        
        return EnhancedShareSheet(
            result: mockResult,
            isPresented: .constant(true)
        )
    }
}
