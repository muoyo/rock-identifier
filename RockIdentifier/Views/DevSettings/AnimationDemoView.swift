// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

/// Animation demo view for testing the enhanced result reveal animation system
/// This allows developers to preview different timing profiles without going through
/// the full identification process.
struct AnimationDemoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isAnimating = false
    
    // Mock result data for the demo
    private let mockResult: RockIdentificationResult = {
        let mockPhysicalProperties = PhysicalProperties(
            color: "Deep purple to violet",
            hardness: "7 (Mohs scale)",
            luster: "Vitreous to sub-vitreous",
            streak: "White",
            transparency: "Transparent to Translucent",
            crystalSystem: "Hexagonal",
            cleavage: "None",
            fracture: "Conchoidal to uneven",
            specificGravity: "2.65"
        )
        
        let mockChemicalProperties = ChemicalProperties(
            formula: "SiO₂",
            composition: "Silicon dioxide with trace iron and aluminum",
            elements: [
                Element(name: "Silicon", symbol: "Si", percentage: 46.7),
                Element(name: "Oxygen", symbol: "O", percentage: 53.3)
            ],
            mineralsPresent: ["Quartz", "Iron oxide traces"],
            reactivity: "Inert under normal conditions"
        )
        
        let mockFormation = Formation(
            formationType: "Igneous/Metamorphic",
            environment: "Forms in vugs and cavities in igneous rocks, geodes",
            geologicalAge: "Various geological ages",
            commonLocations: ["Brazil", "Uruguay", "Zambia", "South Korea", "Russia", "Mexico"],
            associatedMinerals: ["Quartz", "Calcite", "Fluorite", "Goethite"],
            formationProcess: "Crystallizes from silicon-rich hydrothermal fluids at moderate temperatures"
        )
        
        let mockUses = Uses(
            industrial: ["Jewelry and ornamental objects", "Decorative stones", "Sometimes used in electronics"],
            historical: ["Used by ancient Egyptians for jewelry and amulets", "Believed by Greeks to protect against intoxication", "Medieval Europeans thought it promoted clarity of mind"],
            modern: ["Gemstone jewelry", "Ornamental objects", "Feng shui and crystal healing", "Collector specimens"],
            metaphysical: ["Associated with spiritual awareness and higher consciousness", "Said to promote calm, balance, and peace", "Believed to enhance meditation and intuition"],
            funFacts: [
                "The name 'amethyst' comes from Ancient Greek 'amethystos' meaning 'not intoxicated'",
                "It's the birthstone for February and the 6th anniversary gemstone",
                "Amethyst loses its color when heated, turning yellow or orange (becoming citrine)",
                "The largest amethyst geode ever found weighs over 13,000 pounds and is displayed in Australia",
                "Ancient Romans made drinking vessels from amethyst believing it would prevent drunkenness"
            ]
        )
        
        return RockIdentificationResult(
            id: UUID(),
            image: UIImage(systemName: "sparkles"), // Placeholder image
            name: "Amethyst",
            category: "Quartz Variety",
            confidence: 0.94,
            physicalProperties: mockPhysicalProperties,
            chemicalProperties: mockChemicalProperties,
            formation: mockFormation,
            uses: mockUses
        )
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        StyleGuide.Colors.amethystBackground
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Animation Preview")
                            .textStyle(.title)
                        
                        Text("Testing: \(ResultRevealAnimations.currentProfile.rawValue) Profile")
                            .textStyle(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Control buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            startAnimation()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Animation")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(StyleGuide.Colors.emeraldGradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .disabled(isAnimating)
                        }
                        
                        Button(action: {
                            resetAnimation()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(StyleGuide.Colors.sapphireGradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Animation preview area
                    if isAnimating {
                        EnhancedRockResultView(
                            isPresented: .constant(true),
                            result: mockResult,
                            collectionManager: CollectionManager()
                        )
                        .transition(.opacity)
                    } else {
                        // Placeholder when not animating
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(StyleGuide.Colors.amethystPurple.opacity(0.5))
                            
                            Text("Tap 'Start Animation' to preview")
                                .textStyle(.headline)
                                .foregroundColor(.secondary)
                            
                            // Timing info
                            VStack(spacing: 8) {
                                let timing = ResultRevealAnimations.timing
                                
                                HStack {
                                    Text("Total Duration:")
                                    Spacer()
                                    Text("\(String(format: "%.1f", timing.actionsStartTime + 0.5))s")
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Dramatic Pause:")
                                    Spacer()
                                    Text("\(String(format: "%.1f", timing.dramaticPause))s")
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Name Focus:")
                                    Spacer()
                                    Text("\(String(format: "%.1f", timing.nameFocus))s")
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Sparkles Duration:")
                                    Spacer()
                                    Text("\(String(format: "%.1f", timing.sparklesDuration))s")
                                        .fontWeight(.medium)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .font(.caption)
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Animation Demo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isAnimating = true
        }
        
        // Reset after the full animation duration
        let totalDuration = ResultRevealAnimations.timing.actionsStartTime + 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            // Auto-reset after animation completes
            resetAnimation()
        }
    }
    
    private func resetAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isAnimating = false
        }
    }
}

struct AnimationDemoView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationDemoView()
    }
}
