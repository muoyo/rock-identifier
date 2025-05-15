// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

struct CollectionItemDetailView: View {
    let rock: RockIdentificationResult
    @EnvironmentObject var collectionManager: CollectionManager
    @State private var isEditMode = false
    @State private var editedName = ""
    @State private var editedNotes = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image section
                if let image = rock.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                        .shadow(radius: 5)
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                            .cornerRadius(16)
                        
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                }
                
                // Title section
                VStack(alignment: .leading, spacing: 4) {
                    if isEditMode {
                        TextField("Rock name", text: $editedName)
                            .font(.title)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    } else {
                        Text(rock.name)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Text(rock.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Confidence indicator
                ConfidenceBar(confidence: rock.confidence)
                    .padding(.horizontal)
                
                // Information tabs
                DetailTabsView(rock: rock)
                    .padding(.top)
                
                // Notes section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                    
                    if isEditMode {
                        TextEditor(text: $editedNotes)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .frame(minHeight: 100)
                    } else {
                        Text(rock.notes ?? "No notes yet. Tap Edit to add notes.")
                            .foregroundColor(rock.notes == nil ? .secondary : .primary)
                            .padding(8)
                            .frame(minHeight: 60, alignment: .topLeading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .padding(.bottom, 30)
        }
        .navigationTitle(rock.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button(action: {
                        if isEditMode {
                            // Save changes
                            if !editedName.isEmpty {
                                // In a real implementation, we would need to update the name
                                // and save the collection. For now, we'll just update notes.
                            }
                            
                            collectionManager.updateNotes(for: rock.id, notes: editedNotes)
                        } else {
                            // Enter edit mode
                            editedName = rock.name
                            editedNotes = rock.notes ?? ""
                        }
                        
                        isEditMode.toggle()
                    }) {
                        Text(isEditMode ? "Save" : "Edit")
                    }
                    
                    Button(action: {
                        collectionManager.toggleFavorite(for: rock.id)
                    }) {
                        Image(systemName: rock.isFavorite ? "star.fill" : "star")
                            .foregroundColor(rock.isFavorite ? .yellow : .primary)
                    }
                    
                    Menu {
                        Button(action: {
                            // Share functionality would go here
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: {
                            // Delete functionality would go here
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

// This is a placeholder for the tabs view
struct DetailTabsView: View {
    let rock: RockIdentificationResult
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            Picker("Information", selection: $selectedTab) {
                Text("Physical").tag(0)
                Text("Chemical").tag(1)
                Text("Formation").tag(2)
                Text("Uses").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 16) {
                switch selectedTab {
                case 0:
                    EnhancedPhysicalPropertiesView(properties: rock.physicalProperties)
                case 1:
                    EnhancedChemicalPropertiesView(properties: rock.chemicalProperties)
                case 2:
                    EnhancedFormationView(formation: rock.formation)
                case 3:
                    EnhancedUsesView(uses: rock.uses)
                default:
                    EmptyView()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

// Confidence indicator bar
struct ConfidenceBar: View {
    let confidence: Double
    
    var color: Color {
        switch confidence {
        case 0.8...1.0:
            return .green
        case 0.6..<0.8:
            return .yellow
        default:
            return .orange
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Identification Confidence")
                .font(.caption)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(confidence), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(confidence * 100))%")
                .font(.caption)
                .foregroundColor(color)
        }
    }
}

struct CollectionItemDetailView_Previews: PreviewProvider {
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
        
        return NavigationView {
            CollectionItemDetailView(rock: sampleRock)
                .environmentObject(collectionManager)
        }
    }
}
