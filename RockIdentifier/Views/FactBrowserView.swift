// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

/// Comprehensive fact browser with filtering and favorites management
struct FactBrowserView: View {
    @ObservedObject var factManager: FactSelectionManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedFilter: FactFilter = .all
    @State private var searchText = ""
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter bar
                searchAndFilterBar
                
                // Fact list
                factList
            }
            .navigationTitle("All Facts")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: { showFilterSheet = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title3)
                }
            )
        }
        .sheet(isPresented: $showFilterSheet) {
            FactFilterSheet(selectedFilter: $selectedFilter)
        }
    }
    
    // MARK: - Search and Filter Bar
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search facts...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Filter pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FactFilter.allCases, id: \.self) { filter in
                        FilterPill(
                            filter: filter,
                            isSelected: selectedFilter == filter,
                            count: filteredFacts.filter { matchesFilter($0, filter: filter) }.count
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = filter
                            }
                            HapticManager.shared.selectionChanged()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Fact List
    
    private var factList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredFacts) { fact in
                    FactBrowserCard(
                        fact: fact,
                        searchText: searchText,
                        onFavoriteToggle: {
                            factManager.toggleFavorite(for: fact.id)
                        }
                    )
                }
                
                if filteredFacts.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(emptyStateMessage)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if !searchText.isEmpty {
                Button("Clear Search") {
                    searchText = ""
                }
                .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }
    
    // MARK: - Computed Properties
    
    private var filteredFacts: [EnhancedFact] {
        let factsForBrowsing = factManager.getFactsForBrowsing()
        
        return factsForBrowsing.filter { fact in
            // Apply text search filter
            let matchesSearch = searchText.isEmpty || 
                               fact.text.localizedCaseInsensitiveContains(searchText)
            
            // Apply category/type filter
            let matchesFilter = self.matchesFilter(fact, filter: selectedFilter)
            
            return matchesSearch && matchesFilter
        }
    }
    
    private func matchesFilter(_ fact: EnhancedFact, filter: FactFilter) -> Bool {
        switch filter {
        case .all:
            return true
        case .favorites:
            return fact.isFavorited
        case .exceptional:
            return fact.interestingnessRating == .exceptional
        case .high:
            return fact.interestingnessRating == .high
        case .category(let category):
            return fact.category == category
        }
    }
    
    private var emptyStateIcon: String {
        if !searchText.isEmpty {
            return "magnifyingglass"
        } else {
            switch selectedFilter {
            case .favorites: return "heart"
            case .exceptional: return "star"
            case .high: return "sparkles"
            default: return "info.circle"
            }
        }
    }
    
    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "No facts found matching '\(searchText)'"
        } else {
            switch selectedFilter {
            case .favorites: return "No favorite facts yet\nTap the heart icon to save facts"
            case .exceptional: return "No exceptional facts available"
            case .high: return "No highly interesting facts available"
            default: return "No facts available"
            }
        }
    }
}

// MARK: - Fact Browser Card

struct FactBrowserCard: View {
    let fact: EnhancedFact
    let searchText: String
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with category and rating
            HStack {
                // Category badge
                HStack(spacing: 4) {
                    Image(systemName: fact.category.icon)
                        .font(.caption)
                    Text(fact.category.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(6)
                .foregroundColor(.secondary)
                
                Spacer()
                
                // Rating stars
                HStack(spacing: 2) {
                    ForEach(0..<Int(fact.interestingnessRating.rawValue), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                    
                    Text(fact.interestingnessRating.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }
            }
            
            // Fact text with search highlighting
            HighlightedText(
                text: fact.text,
                searchText: searchText
            )
            .font(.subheadline)
            .fixedSize(horizontal: false, vertical: true)
            
            // Footer with stats and favorite button
            HStack {
                // Display statistics
                HStack(spacing: 12) {
                    if fact.displayCount > 0 {
                        StatBadge(
                            icon: "eye",
                            text: "\(fact.displayCount)",
                            color: .blue
                        )
                    }
                    
                    if let lastShown = fact.lastShown {
                        StatBadge(
                            icon: "clock",
                            text: timeAgoString(from: lastShown),
                            color: .green
                        )
                    }
                }
                
                Spacer()
                
                // Favorite button
                Button(action: onFavoriteToggle) {
                    Image(systemName: fact.isFavorited ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(fact.isFavorited ? .red : .secondary)
                        .scaleEffect(fact.isFavorited ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: fact.isFavorited)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    fact.isFavorited ? Color.red.opacity(0.3) : Color.clear,
                    lineWidth: 2
                )
        )
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        
        if hours < 1 {
            return "<1h"
        } else if hours < 24 {
            return "\(hours)h"
        } else {
            let days = hours / 24
            return "\(days)d"
        }
    }
}

// MARK: - Supporting Views

struct FilterPill: View {
    let filter: FactFilter
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: filter.icon)
                    .font(.caption)
                
                Text(filter.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.15))
        .cornerRadius(4)
    }
}

struct HighlightedText: View {
    let text: String
    let searchText: String
    
    var body: some View {
        if searchText.isEmpty {
            Text(text)
        } else {
            // Simple highlighting - in a real app, you might want more sophisticated highlighting
            Text(highlightedAttributedString())
        }
    }
    
    private func highlightedAttributedString() -> AttributedString {
        var attributedString = AttributedString(text)
        
        if let range = text.range(of: searchText, options: .caseInsensitive) {
            let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
            attributedString[attributedRange].backgroundColor = .yellow.opacity(0.3)
            attributedString[attributedRange].foregroundColor = .primary
        }
        
        return attributedString
    }
}

// MARK: - Filter Types

enum FactFilter: Hashable, CaseIterable {
    case all
    case favorites
    case exceptional
    case high
    case category(FactCategory)
    
    static var allCases: [FactFilter] {
        var cases: [FactFilter] = [.all, .favorites, .exceptional, .high]
        cases.append(contentsOf: FactCategory.allCases.map { .category($0) })
        return cases
    }
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        case .exceptional: return "Exceptional"
        case .high: return "High Interest"
        case .category(let category): return category.rawValue.capitalized
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .favorites: return "heart.fill"
        case .exceptional: return "star.fill"
        case .high: return "sparkles"
        case .category(let category): return category.icon
        }
    }
}

// MARK: - Filter Sheet

struct FactFilterSheet: View {
    @Binding var selectedFilter: FactFilter
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section("Quick Filters") {
                    ForEach([FactFilter.all, .favorites, .exceptional, .high], id: \.self) { filter in
                        filterRow(filter)
                    }
                }
                
                Section("Categories") {
                    ForEach(FactCategory.allCases, id: \.self) { category in
                        filterRow(.category(category))
                    }
                }
            }
            .navigationTitle("Filter Facts")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func filterRow(_ filter: FactFilter) -> some View {
        Button(action: {
            selectedFilter = filter
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: filter.icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(filter.displayName)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if selectedFilter == filter {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Preview

struct FactBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        FactBrowserView(factManager: FactSelectionManager.withMockData())
    }
}
