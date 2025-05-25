// Rock Identifier: Crystal ID
// Enhanced Collection View with delightful aesthetics and micro-interactions
// Muoyo Okome
//

import SwiftUI
import UIKit

struct EnhancedCollectionView: View {
    @EnvironmentObject var collectionManager: CollectionManager
    @State private var isShowingSortOptions = false
    @State private var showingEmptyState = false
    @State private var isEditMode = false
    @State private var selectedItems = Set<UUID>()
    @State private var showingExportView = false
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    
    // Enhanced animation states
    @State private var headerOffset: CGFloat = -50
    @State private var filterTabsOffset: CGFloat = -30
    @State private var searchBarOffset: CGFloat = -20
    @State private var gridAnimated = false
    @State private var toolbarAnimated = false
    
    // Grid configuration with adaptive sizing for better aesthetics
    private let columns = [
        GridItem(.adaptive(minimum: 170, maximum: 200), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            // Enhanced background with subtle gradient
            backgroundGradient
            
            // Main content with staggered animations
            VStack(spacing: 0) {
                // Enhanced filter tabs
                enhancedFilterTabs
                    .offset(y: filterTabsOffset)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: filterTabsOffset)
                
                // Enhanced search bar
                enhancedSearchBar
                    .offset(y: searchBarOffset)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: searchBarOffset)
                
                // Collection content
                if showingEmptyState {
                    EnhancedCollectionEmptyState {
                        // Navigate to camera - this would be handled by the parent
                        // For now, just provide haptic feedback
                        HapticManager.shared.mediumImpact()
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                } else {
                    enhancedCollectionGrid
                        .opacity(gridAnimated ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: gridAnimated)
                }
            }
            
            // Enhanced edit mode toolbar
            if isEditMode {
                enhancedEditModeToolbar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .opacity(toolbarAnimated ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: toolbarAnimated)
            }
        }
        .navigationTitle("My Collection")
        .offset(y: headerOffset)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: headerOffset)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                enhancedToolbarButtons
            }
        }
        .actionSheet(isPresented: $isShowingSortOptions) {
            sortActionSheet
        }
        .onAppear {
            animateEntrance()
            checkEmptyState()
        }
        .onChange(of: collectionManager.collection) { _ in
            checkEmptyState()
        }
        .onChange(of: collectionManager.selectedFilter) { _ in
            checkEmptyState()
        }
        .onChange(of: collectionManager.searchText) { _ in
            checkEmptyState()
        }
        .sheet(isPresented: $showingExportView) {
            CollectionExportView()
                .environmentObject(collectionManager)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems)
        }
    }
    
    // MARK: - Enhanced Background
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                StyleGuide.Colors.amethystPurple.opacity(0.02)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Enhanced Filter Tabs
    private var enhancedFilterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(CollectionFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            collectionManager.selectedFilter = filter
                        }
                        HapticManager.shared.selectionChanged()
                    }) {
                        Text(filter.rawValue)
                            .font(StyleGuide.Typography.captionBold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(
                                Capsule()
                                    .fill(
                                        collectionManager.selectedFilter == filter ?
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                StyleGuide.Colors.amethystPurple,
                                                StyleGuide.Colors.roseQuartzPink
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(.systemGray6),
                                                Color(.systemGray5)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(
                                        color: collectionManager.selectedFilter == filter ?
                                        StyleGuide.Colors.amethystPurple.opacity(0.25) :
                                        Color.clear,
                                        radius: 4,
                                        x: 0,
                                        y: 2
                                    )
                            )
                            .foregroundColor(
                                collectionManager.selectedFilter == filter ?
                                .white : .primary
                            )
                    }
                    .buttonStyle(EnhancedScaleButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(
            Rectangle()
                .fill(Color(.systemBackground).opacity(0.95))
                .blur(radius: 10)
        )
    }
    
    // MARK: - Enhanced Search Bar
    private var enhancedSearchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(StyleGuide.Colors.amethystPurple.opacity(0.6))
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search your collection", text: $collectionManager.searchText)
                    .font(StyleGuide.Typography.body)
                    .foregroundColor(.primary)
                
                if !collectionManager.searchText.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            collectionManager.searchText = ""
                        }
                        HapticManager.shared.lightImpact()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.medium)
                            .stroke(StyleGuide.Colors.amethystPurple.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    // MARK: - Enhanced Collection Grid
    private var enhancedCollectionGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(Array(collectionManager.displayedCollection.enumerated()), id: \.element.id) { index, rock in
                    EnhancedCollectionItemCard(
                        rock: rock,
                        isSelected: selectedItems.contains(rock.id),
                        isEditMode: isEditMode,
                        onToggleSelect: {
                            toggleItemSelection(rock.id)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05)),
                        removal: .scale.combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8))
                    ))
                    .id(rock.id)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: collectionManager.displayedCollection)
        }
    }
    
    // MARK: - Enhanced Toolbar Buttons
    private var enhancedToolbarButtons: some View {
        HStack(spacing: 12) {
            if !collectionManager.collection.isEmpty {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isEditMode.toggle()
                        toolbarAnimated = isEditMode
                        if !isEditMode {
                            selectedItems.removeAll()
                        }
                    }
                    HapticManager.shared.mediumImpact()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isEditMode ? "checkmark" : "checkmark.circle")
                            .font(.system(size: 14, weight: .semibold))
                        Text(isEditMode ? "Done" : "Select")
                            .font(StyleGuide.Typography.captionBold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isEditMode ? 
                                  StyleGuide.Colors.emeraldGreen : 
                                  StyleGuide.Colors.amethystPurple.opacity(0.1))
                    )
                    .foregroundColor(isEditMode ? .white : StyleGuide.Colors.amethystPurple)
                }
                .buttonStyle(EnhancedScaleButtonStyle())
            }
            
            Menu {
                menuItems
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(StyleGuide.Colors.amethystPurple)
            }
            .buttonStyle(EnhancedScaleButtonStyle())
        }
    }
    
    // MARK: - Menu Items
    private var menuItems: some View {
        Group {
            Button(action: { 
                HapticManager.shared.lightImpact()
                isShowingSortOptions = true 
            }) {
                Label("Sort Collection", systemImage: "arrow.up.arrow.down")
            }
            
            Divider()
            
            Button(action: {
                HapticManager.shared.lightImpact()
                showingExportView = true
            }) {
                Label("Export Collection", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    // MARK: - Enhanced Edit Mode Toolbar
    private var enhancedEditModeToolbar: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 20) {
                // Selection count with enhanced styling
                VStack(spacing: 2) {
                    Text("\(selectedItems.count)")
                        .font(StyleGuide.Typography.headlineMedium)
                        .foregroundColor(.white)
                    Text("selected")
                        .font(StyleGuide.Typography.captionMedium)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Enhanced action buttons
                HStack(spacing: 16) {
                    toolbarButton(
                        icon: "star.fill",
                        action: toggleFavoriteForSelectedItems
                    )
                    
                    toolbarButton(
                        icon: "square.and.arrow.up",
                        action: shareSelectedItems
                    )
                    
                    toolbarButton(
                        icon: "trash.fill",
                        action: deleteSelectedItems,
                        isDestructive: true
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                StyleGuide.Colors.amethystPurple,
                                StyleGuide.Colors.roseQuartzPink
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(
                        color: StyleGuide.Colors.amethystPurple.opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }
    
    // MARK: - Toolbar Button Helper
    private func toolbarButton(icon: String, action: @escaping () -> Void, isDestructive: Bool = false) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(isDestructive ? 0.2 : 0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isDestructive ? .red.opacity(0.9) : .white)
            }
        }
        .buttonStyle(EnhancedScaleButtonStyle())
    }
    
    // MARK: - Sort Action Sheet
    private var sortActionSheet: ActionSheet {
        ActionSheet(
            title: Text("Sort Collection"),
            buttons: SortOrder.allCases.map { order in
                .default(Text(order.rawValue)) {
                    collectionManager.setSortOrder(order)
                }
            } + [.cancel()]
        )
    }
    
    // MARK: - Animation Functions
    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            headerOffset = 0
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
            filterTabsOffset = 0
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
            searchBarOffset = 0
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            gridAnimated = true
        }
    }
    
    // MARK: - Helper Functions
    private func checkEmptyState() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingEmptyState = collectionManager.displayedCollection.isEmpty
        }
    }
    
    private func toggleItemSelection(_ id: UUID) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if selectedItems.contains(id) {
                selectedItems.remove(id)
            } else {
                selectedItems.insert(id)
            }
        }
    }
    
    private func toggleFavoriteForSelectedItems() {
        HapticManager.shared.mediumImpact()
        for id in selectedItems {
            collectionManager.toggleFavorite(for: id)
        }
        HapticManager.shared.successFeedback()
    }
    
    private func deleteSelectedItems() {
        HapticManager.shared.heavyImpact()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            for id in selectedItems {
                collectionManager.removeRock(withID: id)
            }
            selectedItems.removeAll()
        }
        HapticManager.shared.successFeedback()
    }
    
    private func shareSelectedItems() {
        HapticManager.shared.mediumImpact()
        
        shareItems = []
        let selectedRocks = selectedItems.compactMap { id in
            collectionManager.getRock(by: id)
        }
        
        if selectedRocks.isEmpty { return }
        
        shareItems.append("\(selectedRocks.count) rocks from my Rock Identifier collection:\n\n\(selectedRocks.map { "• \($0.name) (\($0.category))" }.joined(separator: "\n"))")
        
        for rock in selectedRocks.prefix(5) {
            if let image = rock.image {
                shareItems.append(image)
            }
        }
        
        showingShareSheet = true
    }
}

struct EnhancedCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        let collectionManager = CollectionManager()
        return EnhancedCollectionView()
            .environmentObject(collectionManager)
    }
}
