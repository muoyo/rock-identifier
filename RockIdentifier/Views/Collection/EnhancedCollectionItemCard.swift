// Rock Identifier: Crystal ID
// Enhanced Collection Item Card with delightful aesthetics
// Muoyo Okome
//

import SwiftUI

struct EnhancedCollectionItemCard: View {
    let rock: RockIdentificationResult
    let isSelected: Bool
    let isEditMode: Bool
    let onToggleSelect: () -> Void
    
    @EnvironmentObject var collectionManager: CollectionManager
    @State private var showingDeleteConfirmation = false
    @State private var isHovering = false
    @State private var hasAnimated = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var showFavoriteAnimation = false
    
    // Animation states for entrance
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0
    @State private var imageOffset: CGFloat = 20
    @State private var textOffset: CGFloat = 10
    
    var body: some View {
        NavigationLink(destination: CollectionItemDetailView(rock: rock)) {
            ZStack {
                // Main card with dynamic background
                cardBackground
                
                // Card content
                VStack(alignment: .leading, spacing: 0) {
                    // Image section with enhancements
                    imageSection
                    
                    // Content section with better typography and layout
                    contentSection
                }
                .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large))
                
                // Selection overlay for edit mode
                if isEditMode {
                    selectionOverlay
                }
                
                // Shimmer effect for premium feel
                if !isEditMode {
                    shimmerEffect
                }
            }
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovering)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: cardScale)
            .animation(.easeOut(duration: 0.6), value: cardOpacity)
            .onAppear {
                animateEntrance()
            }
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    if !isEditMode {
                        HapticManager.shared.lightImpact()
                    }
                }
            )
            .contextMenu {
                contextMenuItems
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                deleteAlert
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isEditMode)
    }
    
    // MARK: - Card Background with Gradient
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        mineralColor.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                mineralColor.opacity(0.3),
                                mineralColor.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: mineralColor.opacity(0.15),
                radius: isHovering ? 12 : 8,
                x: 0,
                y: isHovering ? 6 : 4
            )
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 2,
                x: 0,
                y: 1
            )
    }
    
    // MARK: - Enhanced Image Section
    private var imageSection: some View {
        ZStack {
            // Image container with gradient overlay
            GeometryReader { geometry in
                ZStack {
                    if let thumbnail = rock.thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: 120)
                            .clipped()
                            .overlay(
                                // Subtle gradient overlay for better text readability
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.clear,
                                        Color.black.opacity(0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } else {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        mineralColor.opacity(0.1),
                                        mineralColor.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geometry.size.width, height: 120)
                        
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundColor(mineralColor.opacity(0.4))
                    }
                }
            }
            .frame(height: 120)
            .offset(y: imageOffset)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: imageOffset)
            
            // Favorite indicator with enhanced styling
            if rock.isFavorite {
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 14, weight: .bold))
                                .scaleEffect(showFavoriteAnimation ? 1.3 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: showFavoriteAnimation)
                        }
                        .padding(8)
                    }
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Enhanced Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Rock name with gradient text effect
            Text(rock.name)
                .font(StyleGuide.Typography.headlineMedium)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .primary,
                            mineralColor
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            // Category with mineral-themed styling
            HStack(spacing: 4) {
                Circle()
                    .fill(mineralColor)
                    .frame(width: 6, height: 6)
                
                Text(rock.category)
                    .font(StyleGuide.Typography.captionMedium)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Confidence indicator as a subtle progress bar
            if rock.confidence > 0 {
                HStack(spacing: 6) {
                    Text("Confidence")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.8))
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 3)
                                .cornerRadius(1.5)
                            
                            Rectangle()
                                .fill(mineralColor)
                                .frame(width: geometry.size.width * CGFloat(rock.confidence), height: 3)
                                .cornerRadius(1.5)
                        }
                    }
                    .frame(height: 3)
                    
                    Text("\(Int(rock.confidence * 100))%")
                        .font(.caption2)
                        .foregroundColor(mineralColor)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .offset(y: textOffset)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: textOffset)
    }
    
    // MARK: - Selection Overlay for Edit Mode
    private var selectionOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
                .fill(Color.black.opacity(isSelected ? 0.3 : 0.0))
            
            VStack {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? StyleGuide.Colors.emeraldGreen : .gray)
                            .font(.title3)
                    }
                    .padding(8)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .onTapGesture {
            HapticManager.shared.selectionChanged()
            onToggleSelect()
        }
    }
    
    // MARK: - Shimmer Effect
    private var shimmerEffect: some View {
        RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .rotationEffect(.degrees(30))
            .offset(x: shimmerOffset)
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    shimmerOffset = 200
                }
            }
            .allowsHitTesting(false)
    }
    
    // MARK: - Context Menu Items
    private var contextMenuItems: some View {
        Group {
            Button(action: {
                HapticManager.shared.mediumImpact()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showFavoriteAnimation = true
                }
                collectionManager.toggleFavorite(for: rock.id)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showFavoriteAnimation = false
                }
            }) {
                Label(
                    rock.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    systemImage: rock.isFavorite ? "star.slash" : "star"
                )
            }
            
            Button(action: {
                HapticManager.shared.mediumImpact()
                showingDeleteConfirmation = true
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Delete Alert
    private var deleteAlert: Alert {
        Alert(
            title: Text("Delete \(rock.name)?"),
            message: Text("This action cannot be undone."),
            primaryButton: .destructive(Text("Delete")) {
                HapticManager.shared.heavyImpact()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    cardScale = 0.8
                    cardOpacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    collectionManager.removeRock(withID: rock.id)
                }
            },
            secondaryButton: .cancel()
        )
    }
    
    // MARK: - Helper Properties
    
    /// Dynamic mineral color based on rock type
    private var mineralColor: Color {
        switch rock.category.lowercased() {
        case let cat where cat.contains("crystal"):
            return StyleGuide.Colors.amethystPurple
        case let cat where cat.contains("mineral"):
            return StyleGuide.Colors.emeraldGreen
        case let cat where cat.contains("gemstone"):
            return StyleGuide.Colors.roseQuartzPink
        case let cat where cat.contains("rock"):
            return StyleGuide.Colors.sapphireBlue
        default:
            return StyleGuide.Colors.citrineGold
        }
    }
    
    // MARK: - Animation Functions
    
    private func animateEntrance() {
        guard !hasAnimated else { return }
        hasAnimated = true
        
        // Stagger the animations for a more organic feel
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
            imageOffset = 0
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
            textOffset = 0
        }
    }
}

struct EnhancedCollectionItemCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRock = RockIdentificationResult(
            image: nil,
            name: "Amethyst Crystal",
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
            // Normal state
            EnhancedCollectionItemCard(
                rock: sampleRock,
                isSelected: false,
                isEditMode: false,
                onToggleSelect: {}
            )
            .environmentObject(collectionManager)
            .frame(width: 180, height: 220)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Normal State")
            
            // Edit mode selected
            EnhancedCollectionItemCard(
                rock: sampleRock,
                isSelected: true,
                isEditMode: true,
                onToggleSelect: {}
            )
            .environmentObject(collectionManager)
            .frame(width: 180, height: 220)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Edit Mode Selected")
            
            // Grid layout
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 160), spacing: 16)
            ], spacing: 16) {
                ForEach(0..<4) { _ in
                    EnhancedCollectionItemCard(
                        rock: sampleRock,
                        isSelected: false,
                        isEditMode: false,
                        onToggleSelect: {}
                    )
                    .environmentObject(collectionManager)
                }
            }
            .padding()
            .previewDisplayName("Grid Layout")
        }
    }
}
