// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

struct CollectionView: View {
    @EnvironmentObject var collectionManager: CollectionManager
    @State private var isShowingSortOptions = false
    @State private var showingEmptyState = false
    @State private var isEditMode = false
    @State private var selectedItems = Set<UUID>()
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    // Filter tabs
                    filterTabs
                    
                    // Search bar
                    searchBar
                    
                    // Collection grid or empty state
                    if showingEmptyState {
                        emptyStateView
                    } else {
                        collectionGrid
                    }
                }
                .background(Color(.systemBackground))
                
                // Edit mode toolbar if active
                if isEditMode {
                    editModeToolbar
                }
            }
            .navigationTitle("My Collection")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        if !collectionManager.collection.isEmpty {
                            Button(action: {
                                isEditMode.toggle()
                                if !isEditMode {
                                    selectedItems.removeAll()
                                }
                            }) {
                                Text(isEditMode ? "Done" : "Select")
                            }
                        }
                        
                        Menu {
                            Button(action: { isShowingSortOptions = true }) {
                                Label("Sort", systemImage: "arrow.up.arrow.down")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .actionSheet(isPresented: $isShowingSortOptions) {
                ActionSheet(
                    title: Text("Sort Collection"),
                    buttons: SortOrder.allCases.map { order in
                        .default(Text(order.rawValue)) {
                            collectionManager.setSortOrder(order)
                        }
                    } + [.cancel()]
                )
            }
        }
        .onAppear {
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
    }
    
    // Filter tabs at the top
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(CollectionFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        collectionManager.selectedFilter = filter
                    }) {
                        Text(filter.rawValue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                Capsule()
                                    .fill(collectionManager.selectedFilter == filter ?
                                         Color.accentColor :
                                         Color.accentColor.opacity(0.1))
                            )
                            .foregroundColor(collectionManager.selectedFilter == filter ?
                                           Color.white :
                                           Color.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // Search bar
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search your collection", text: $collectionManager.searchText)
                    .foregroundColor(.primary)
                
                if !collectionManager.searchText.isEmpty {
                    Button(action: {
                        collectionManager.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // Collection grid
    private var collectionGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(collectionManager.displayedCollection) { rock in
                    CollectionItemCard(
                        rock: rock,
                        isSelected: selectedItems.contains(rock.id),
                        isEditMode: isEditMode,
                        onToggleSelect: {
                            toggleItemSelection(rock.id)
                        }
                    )
                    .padding(8)
                    .id(rock.id) // Add explicit ID to force refresh
                }
            }
            .padding()
            .animation(.default, value: collectionManager.displayedCollection)
        }
    }
    
    // Empty state view
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image("onboarding-collection") // Use the existing illustration
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Text("Your Collection is Empty")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Identify rocks, minerals, crystals, and gemstones to add them to your collection.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Button(action: {
                // Navigate to camera view - this will need to be implemented
            }) {
                Text("Identify a Specimen")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
    }
    
    // Edit mode toolbar at the bottom
    private var editModeToolbar: some View {
        VStack {
            Spacer()
            
            HStack {
                Text("\(selectedItems.count) selected")
                    .foregroundColor(.white)
                
                Spacer()
                
                // Favorite/unfavorite button
                Button(action: {
                    toggleFavoriteForSelectedItems()
                }) {
                    Image(systemName: "star")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                
                // Delete button
                Button(action: {
                    deleteSelectedItems()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
            }
            .padding()
            .background(Color.accentColor)
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    // Check if we should show the empty state
    private func checkEmptyState() {
        showingEmptyState = collectionManager.displayedCollection.isEmpty
    }
    
    // Toggle selection of an item in edit mode
    private func toggleItemSelection(_ id: UUID) {
        if selectedItems.contains(id) {
            selectedItems.remove(id)
        } else {
            selectedItems.insert(id)
        }
    }
    
    // Toggle favorite status for all selected items
    private func toggleFavoriteForSelectedItems() {
        for id in selectedItems {
            collectionManager.toggleFavorite(for: id)
        }
    }
    
    // Delete all selected items
    private func deleteSelectedItems() {
        for id in selectedItems {
            collectionManager.removeRock(withID: id)
        }
        selectedItems.removeAll()
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        let collectionManager = CollectionManager()
        return CollectionView()
            .environmentObject(collectionManager)
    }
}
