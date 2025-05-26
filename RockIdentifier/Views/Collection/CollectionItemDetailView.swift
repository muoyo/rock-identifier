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
    @State private var editedLocation = ""
    @State private var showingShareSheet = false
    @State private var showingDeleteConfirmation = false
    
    // Haptic feedback generators
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    let notificationGenerator = UINotificationFeedbackGenerator()
    
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
                
                // Enhanced Notes section
                EnhancedNotesSection(
                    title: "Notes",
                    content: rock.notes,
                    placeholder: "No notes yet. Tap Edit to add notes.",
                    isEditMode: isEditMode,
                    editedText: $editedNotes,
                    iconName: "note.text",
                    iconColor: StyleGuide.Colors.amethystPurple
                )
                .padding(.horizontal)
                .padding(.top)
                
                // Enhanced Location section
                EnhancedLocationSection(
                    title: "Location Found",
                    content: rock.location,
                    placeholder: "No location information",
                    textFieldPlaceholder: "Where was this found?",
                    isEditMode: isEditMode,
                    editedText: $editedLocation,
                    iconName: "location",
                    iconColor: StyleGuide.Colors.emeraldGreen
                )
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
                            collectionManager.updateLocation(for: rock.id, location: editedLocation)
                            
                            // Success feedback
                            notificationGenerator.notificationOccurred(.success)
                        } else {
                            // Enter edit mode
                            editedName = rock.name
                            editedNotes = rock.notes ?? ""
                            editedLocation = rock.location ?? ""
                            
                            // Light haptic feedback
                            impactGenerator.impactOccurred(intensity: 0.5)
                        }
                        
                        isEditMode.toggle()
                    }) {
                        Text(isEditMode ? "Save" : "Edit")
                    }
                    
                    Button(action: {
                        impactGenerator.impactOccurred()
                        collectionManager.toggleFavorite(for: rock.id)
                    }) {
                        Image(systemName: rock.isFavorite ? "star.fill" : "star")
                            .foregroundColor(rock.isFavorite ? .yellow : .primary)
                    }
                    
                    Menu {
                        Button(action: {
                            // Share functionality
                            shareRock()
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: {
                            // Delete functionality
                            impactGenerator.impactOccurred(intensity: 0.7)
                            showingDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            createShareSheet()
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete \(rock.name)?"),
                message: Text("This will permanently remove this item from your collection."),
                primaryButton: .destructive(Text("Delete")) {
                    // Delete the rock
                    notificationGenerator.notificationOccurred(.success)
                    collectionManager.removeRock(withID: rock.id)
                    
                    // Navigate back (this will be handled by NavigationLink)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // Create a share sheet with rock information
    private func createShareSheet() -> ShareSheet {
        var items: [Any] = [
            "Check out this \(rock.name) I identified with Rock Identifier!"
        ]
        
        // Add image if available
        if let image = rock.image {
            items.append(image)
        }
        
        // Add detailed information
        var detailText = "Name: \(rock.name)\n"
        detailText += "Category: \(rock.category)\n"
        
        // Add physical properties
        detailText += "Color: \(rock.physicalProperties.color)\n"
        detailText += "Hardness: \(rock.physicalProperties.hardness)\n"
        detailText += "Luster: \(rock.physicalProperties.luster)\n"
        
        // Add location if available
        if let location = rock.location, !location.isEmpty {
            detailText += "Found at: \(location)\n"
        }
        
        items.append(detailText)
        
        return ShareSheet(items: items)
    }
    
    // Share the rock information
    private func shareRock() {
        impactGenerator.impactOccurred(intensity: 0.6)
        showingShareSheet = true
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
                    PhysicalPropertiesContentView(properties: rock.physicalProperties)
                case 1:
                    ChemicalPropertiesContentView(properties: rock.chemicalProperties)
                case 2:
                    FormationContentView(formation: rock.formation)
                case 3:
                    EnhancedFactDisplayView(uses: rock.uses, rockName: rock.name, confidence: rock.confidence)
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

// MARK: - Property Content Views

struct PhysicalPropertiesContentView: View {
    let properties: PhysicalProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with icon
            HStack {
                Text("Physical Properties")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "ruler")
                    .font(.title3)
                    .foregroundColor(StyleGuide.Colors.sapphireBlue)
            }
            .padding(.bottom, 4)
            
            // Main properties section
            VStack(spacing: 16) {
                // Color with enhanced styling
                EnhancedPropertyRow(
                    label: "Color",
                    value: properties.color,
                    iconName: "circle.fill",
                    showDivider: true
                )
                
                // Hardness with Mohs scale context
                EnhancedPropertyRow(
                    label: "Hardness",
                    value: properties.hardness,
                    iconName: "hammer",
                    showDivider: true
                )
                
                // Luster property
                EnhancedPropertyRow(
                    label: "Luster",
                    value: properties.luster,
                    iconName: "sparkles",
                    showDivider: true
                )
                
                // Optional properties
                Group {
                    if let streak = properties.streak {
                        EnhancedPropertyRow(
                            label: "Streak",
                            value: streak,
                            iconName: "scribble",
                            showDivider: true
                        )
                    }
                    
                    if let transparency = properties.transparency {
                        EnhancedPropertyRow(
                            label: "Transparency",
                            value: transparency,
                            iconName: "eye",
                            showDivider: true
                        )
                    }
                    
                    if let crystalSystem = properties.crystalSystem {
                        EnhancedPropertyRow(
                            label: "Crystal System",
                            value: crystalSystem,
                            iconName: "cube",
                            showDivider: true
                        )
                    }
                    
                    if let cleavage = properties.cleavage {
                        EnhancedPropertyRow(
                            label: "Cleavage",
                            value: cleavage,
                            iconName: "scissors",
                            showDivider: true
                        )
                    }
                    
                    if let fracture = properties.fracture {
                        EnhancedPropertyRow(
                            label: "Fracture",
                            value: fracture,
                            iconName: "bolt.fill",
                            showDivider: true
                        )
                    }
                    
                    if let specificGravity = properties.specificGravity {
                        EnhancedPropertyRow(
                            label: "Specific Gravity",
                            value: specificGravity,
                            iconName: "scalemass",
                            showDivider: false
                        )
                    }
                }
            }
        }
    }
}

struct ChemicalPropertiesContentView: View {
    let properties: ChemicalProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with icon
            HStack {
                Text("Chemical Properties")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "atom")
                    .font(.title3)
                    .foregroundColor(StyleGuide.Colors.emeraldGreen)
            }
            .padding(.bottom, 4)
            
            // Formula section with special styling
            if let formula = properties.formula {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chemical Formula")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Text(formula)
                        .font(.system(size: 22, weight: .medium, design: .monospaced))
                        .foregroundColor(StyleGuide.Colors.emeraldGreen)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                                .fill(StyleGuide.Colors.emeraldGreen.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                                        .stroke(StyleGuide.Colors.emeraldGreen.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                .padding(.bottom, 6)
            }
            
            // Composition
            EnhancedPropertyRow(
                label: "Composition",
                value: properties.composition,
                iconName: "doc.plaintext",
                showDivider: true
            )
            
            // Elements section with enhanced cards
            if let elements = properties.elements, !elements.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Elements")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    ForEach(elements, id: \.symbol) { element in
                        HStack(alignment: .center, spacing: 14) {
                            // Element symbol in a styled circle
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                StyleGuide.Colors.amethystPurple.opacity(0.8),
                                                StyleGuide.Colors.sapphireBlue.opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Text(element.symbol)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(element.name)
                                    .font(.system(size: 16, weight: .medium))
                                
                                if let percentage = element.percentage {
                                    HStack(spacing: 8) {
                                        Text("\(String(format: "%.1f", percentage))%")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(StyleGuide.Colors.emeraldGreen)
                                        
                                        // Percentage bar
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(height: 4)
                                                    .cornerRadius(2)
                                                
                                                Rectangle()
                                                    .fill(StyleGuide.Colors.emeraldGreen)
                                                    .frame(
                                                        width: max(0, min(percentage, 100)) * geometry.size.width / 100,
                                                        height: 4
                                                    )
                                                    .cornerRadius(2)
                                            }
                                        }
                                        .frame(height: 4)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                                        .stroke(StyleGuide.Colors.amethystPurple.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
    }
}

struct FormationContentView: View {
    let formation: Formation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with icon
            HStack {
                Text("Formation")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "mountain.2")
                    .font(.title3)
                    .foregroundColor(StyleGuide.Colors.citrineGold)
            }
            .padding(.bottom, 4)
            
            // Formation properties
            VStack(spacing: 16) {
                EnhancedPropertyRow(
                    label: "Type",
                    value: formation.formationType,
                    iconName: "square.stack.3d.up",
                    showDivider: true
                )
                
                EnhancedPropertyRow(
                    label: "Environment",
                    value: formation.environment,
                    iconName: "globe",
                    showDivider: true
                )
                
                if let geologicalAge = formation.geologicalAge {
                    EnhancedPropertyRow(
                        label: "Geological Age",
                        value: geologicalAge,
                        iconName: "clock",
                        showDivider: true
                    )
                }
                
                EnhancedPropertyRow(
                    label: "Formation Process",
                    value: formation.formationProcess,
                    iconName: "arrow.triangle.merge",
                    showDivider: false
                )
            }
            
            // Common locations with enhanced styling
            if let locations = formation.commonLocations, !locations.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common Locations")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    // Enhanced location cards
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(locations, id: \.self) { location in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(StyleGuide.Colors.roseQuartzPink.opacity(0))
                                        .frame(width: 10, height: 32)
                                    
                                    Image(systemName: "mappin")
                                        .foregroundColor(StyleGuide.Colors.roseQuartzPink)
                                        .font(.system(size: 16))
                                }
                                
                                Text(location)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.small)
                                    .fill(StyleGuide.Colors.roseQuartzPink.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.small)
                                            .stroke(StyleGuide.Colors.roseQuartzPink.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Enhanced Notes & Location Components

struct EnhancedNotesSection: View {
    let title: String
    let content: String?
    let placeholder: String
    let isEditMode: Bool
    @Binding var editedText: String
    let iconName: String
    let iconColor: Color
    
    @State private var hasAnimated = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Enhanced header with icon
            HStack(spacing: 12) {
                // Beautiful icon with animation
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.08)) // Reduced opacity for better icon visibility
                        .frame(width: 36, height: 36)
                    
                    // Subtle pulse ring
                    Circle()
                        .stroke(iconColor.opacity(hasAnimated ? 0.0 : 0.25), lineWidth: 1.5) // Thinner, less prominent
                        .frame(width: 34, height: 34)
                        .scaleEffect(hasAnimated ? 1.15 : 1.0) // Less dramatic scaling
                        .opacity(hasAnimated ? 0.0 : 1.0)
                        .animation(
                            Animation.easeOut(duration: 1.0).delay(0.2),
                            value: hasAnimated
                        )
                    
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.system(size: 18, weight: .semibold)) // Larger, bolder icon
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Enhanced content area
            if isEditMode {
                TextEditor(text: $editedText)
                    .font(.subheadline)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                                    .stroke(iconColor.opacity(0.3), lineWidth: 1.5)
                            )
                    )
                    .frame(minHeight: 100)
            } else {
                Text(content ?? placeholder)
                    .font(.subheadline)
                    .foregroundColor(content == nil ? .secondary : .primary)
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
                    .background(
                        RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(.systemBackground),
                                        iconColor.opacity(0.02)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                iconColor.opacity(0.2),
                                                iconColor.opacity(0.1)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .shadow(color: iconColor.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                hasAnimated = true
            }
        }
    }
}

struct EnhancedLocationSection: View {
    let title: String
    let content: String?
    let placeholder: String
    let textFieldPlaceholder: String
    let isEditMode: Bool
    @Binding var editedText: String
    let iconName: String
    let iconColor: Color
    
    @State private var hasAnimated = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Enhanced header with icon
            HStack(spacing: 12) {
                // Beautiful icon with animation
                ZStack {
                Circle()
                .fill(iconColor.opacity(0.08)) // Reduced opacity for better icon visibility
                .frame(width: 36, height: 36)
                
                // Subtle pulse ring
                Circle()
                .stroke(iconColor.opacity(hasAnimated ? 0.0 : 0.25), lineWidth: 1.5) // Thinner, less prominent
                .frame(width: 34, height: 34)
                .scaleEffect(hasAnimated ? 1.15 : 1.0) // Less dramatic scaling
                .opacity(hasAnimated ? 0.0 : 1.0)
                .animation(
                Animation.easeOut(duration: 1.0).delay(0.3),
                value: hasAnimated
                )
                
                Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.system(size: 18, weight: .semibold)) // Larger, bolder icon
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Enhanced content area
            if isEditMode {
                TextField(textFieldPlaceholder, text: $editedText)
                    .font(.subheadline)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                                    .stroke(iconColor.opacity(0.3), lineWidth: 1.5)
                            )
                    )
            } else {
                HStack(spacing: 12) {
                    // Location pin icon for visual context
                    if content != nil {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(iconColor.opacity(0.6))
                            .font(.system(size: 16))
                    }
                    
                    Text(content ?? placeholder)
                        .font(.subheadline)
                        .foregroundColor(content == nil ? .secondary : .primary)
                    
                    Spacer()
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(.systemBackground),
                                    iconColor.opacity(0.02)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            iconColor.opacity(0.2),
                                            iconColor.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: iconColor.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                hasAnimated = true
            }
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
