// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

struct CollectionItemCard: View {
    let rock: RockIdentificationResult
    let isSelected: Bool
    let isEditMode: Bool
    let onToggleSelect: () -> Void
    
    @EnvironmentObject var collectionManager: CollectionManager
    @State private var showingDeleteConfirmation = false
    
    // Haptic feedback generators
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    let selectionGenerator = UISelectionFeedbackGenerator()
    
    var body: some View {
        NavigationLink(destination: CollectionItemDetailView(rock: rock)) {
            ZStack {
                // Card content
                VStack(alignment: .leading) {
                    // Image
                    ZStack {
                        if let thumbnail = rock.thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 150, height: 150)
                            
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.largeTitle)
                        }
                        
                        // Favorite indicator
                        if rock.isFavorite {
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .padding(6)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                        .padding(8)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Text info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rock.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(rock.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                // Edit mode selection overlay
                if isEditMode {
                    ZStack {
                        Color.black.opacity(isSelected ? 0.5 : 0.0)
                            .cornerRadius(12)
                        
                        VStack {
                            HStack {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isSelected ? .blue : .white)
                                    .font(.title2)
                                    .padding(8)
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                    .onTapGesture {
                        // Provide haptic feedback
                        selectionGenerator.selectionChanged()
                        
                        onToggleSelect()
                    }
                }
            }
            .frame(width: 150, height: 200)
            .contextMenu {
                Button(action: {
                    impactGenerator.impactOccurred()
                    collectionManager.toggleFavorite(for: rock.id)
                }) {
                    Label(
                        rock.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                        systemImage: rock.isFavorite ? "star.slash" : "star"
                    )
                }
                
                Button(action: {
                    impactGenerator.impactOccurred()
                    showingDeleteConfirmation = true
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Delete \(rock.name)?"),
                    message: Text("This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        impactGenerator.impactOccurred(intensity: 0.8)
                        collectionManager.removeRock(withID: rock.id)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isEditMode)
    }
}

struct CollectionItemCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRock = RockIdentificationResult(
            image: nil,
            name: "Amethyst",
            category: "Crystal",
            confidence: 0.95,
            physicalProperties: PhysicalProperties(
                color: "Purple",
                hardness: "7",
                luster: "Vitreous",
                crystalSystem: "Hexagonal",
                cleavage: "None"
            ),
            chemicalProperties: ChemicalProperties(
                formula: "SiO2",
                composition: "Silicon dioxide",
                elements: [Element(name: "Silicon", symbol: "Si"), Element(name: "Oxygen", symbol: "O")]
            ),
            formation: Formation(
                formationType: "Metamorphic",
                environment: "Volcanic rocks",
                commonLocations: ["Brazil", "Uruguay", "United States"],
                formationProcess: "Forms within volcanic cavities"
            ),
            uses: Uses(
                historical: ["Ancient Greeks believed it prevented intoxication"],
                modern: ["Jewelry and decorative items"],
                metaphysical: ["Believed to promote calmness and clarity"],
                funFacts: ["The name comes from Greek 'amethystos', meaning 'not drunk'"]
            ),
            isFavorite: true
        )
        
        let collectionManager = CollectionManager()
        
        return Group {
            CollectionItemCard(
                rock: sampleRock,
                isSelected: false,
                isEditMode: false,
                onToggleSelect: {}
            )
            .environmentObject(collectionManager)
            .previewLayout(.sizeThatFits)
            .padding()
            
            CollectionItemCard(
                rock: sampleRock,
                isSelected: true,
                isEditMode: true,
                onToggleSelect: {}
            )
            .environmentObject(collectionManager)
            .previewLayout(.sizeThatFits)
            .padding()
        }
    }
}
