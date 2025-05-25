// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

/// Enhanced fact display with intelligent selection and visual styling
struct EnhancedFactDisplayView: View {
    @StateObject private var factManager = FactSelectionManager()
    @State private var showAllFacts = false
    @State private var currentFactIndex = 0
    
    let uses: Uses
    let rockName: String
    let confidence: Double
    
    // Auto-rotation timer
    @State private var rotationTimer: Timer?
    private let rotationInterval: TimeInterval = 6.0 // Slightly longer for better reading
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with statistics
            factSectionHeader
            
            // Main fact display
            if factManager.availableFacts.isEmpty {
                emptyFactState
            } else {
                VStack(spacing: 12) {
                    // Current fact card
                    if let currentFact = factManager.currentFact {
                        EnhancedFactCard(
                            fact: currentFact,
                            onFavoriteToggle: { factManager.toggleFavorite(for: currentFact.id) },
                            onNextFact: { selectNextFact() }
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                        .id(currentFact.id) // Force view recreation for smooth transitions
                    }
                    
                    // Fact navigation controls
                    factNavigationControls
                }
            }
            
            // Browse all facts button
            browseAllFactsButton
            
            // Traditional uses sections (non-facts)
            traditionalUsesSection
        }
        .onAppear {
            setupFacts()
            startAutoRotation()
        }
        .onDisappear {
            stopAutoRotation()
        }
        .sheet(isPresented: $showAllFacts) {
            FactBrowserView(factManager: factManager)
        }
    }
    
    // MARK: - Header Section
    
    private var factSectionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    
                    Text("Did You Know?")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                if !factManager.availableFacts.isEmpty {
                    let stats = factManager.getFactStatistics()
                    FactStatisticsView(statistics: stats)
                }
            }
            
            Spacer()
            
            // Quality indicator
            if !factManager.availableFacts.isEmpty {
                QualityIndicatorView(statistics: factManager.getFactStatistics())
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyFactState: some View {
        VStack(spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No facts available for this confidence level")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Navigation Controls
    
    private var factNavigationControls: some View {
        HStack(spacing: 16) {
            // Previous fact button
            Button(action: selectPreviousFact) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .disabled(factManager.availableFacts.count <= 1)
            
            // Fact indicator dots
            if factManager.availableFacts.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<min(factManager.availableFacts.count, 5), id: \.self) { index in
                        Circle()
                            .fill(index == currentFactIndex ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentFactIndex ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: currentFactIndex)
                    }
                    
                    if factManager.availableFacts.count > 5 {
                        Text("+\(factManager.availableFacts.count - 5)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Next fact button
            Button(action: selectNextFact) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .disabled(factManager.availableFacts.count <= 1)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Browse All Facts Button
    
    private var browseAllFactsButton: some View {
        Button(action: { showAllFacts = true }) {
            HStack {
                Image(systemName: "list.bullet")
                Text("Browse All Facts (\(factManager.availableFacts.count))")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.subheadline)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Traditional Uses Section
    
    private var traditionalUsesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let historical = uses.historical, !historical.isEmpty {
                TraditionalUseSection(title: "Historical Uses", items: historical, icon: "scroll")
            }
            
            if let industrial = uses.industrial, !industrial.isEmpty {
                TraditionalUseSection(title: "Industrial Uses", items: industrial, icon: "gear")
            }
            
            if let modern = uses.modern, !modern.isEmpty {
                TraditionalUseSection(title: "Modern Uses", items: modern, icon: "sparkles")
            }
            
            if let metaphysical = uses.metaphysical, !metaphysical.isEmpty {
                TraditionalUseSection(title: "Metaphysical Properties", items: metaphysical, icon: "star.circle")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupFacts() {
        let facts = uses.funFacts
        factManager.setFacts(facts, for: rockName, confidence: confidence)
    }
    
    private func selectNextFact() {
        guard !factManager.availableFacts.isEmpty else { return }
        
        stopAutoRotation()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            factManager.selectNextFact()
            updateCurrentIndex()
        }
        
        // Restart auto-rotation after manual selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            startAutoRotation()
        }
        
        HapticManager.shared.lightImpact()
    }
    
    private func selectPreviousFact() {
        guard factManager.availableFacts.count > 1 else { return }
        
        stopAutoRotation()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            factManager.selectPreviousFact()
            updateCurrentIndex()
        }
        
        // Restart auto-rotation after manual selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            startAutoRotation()
        }
        
        HapticManager.shared.lightImpact()
    }
    
    private func updateCurrentIndex() {
        if let currentFact = factManager.currentFact,
           let index = factManager.availableFacts.firstIndex(where: { $0.id == currentFact.id }) {
            currentFactIndex = index
        }
    }
    
    private func startAutoRotation() {
        stopAutoRotation()
        
        rotationTimer = Timer.scheduledTimer(withTimeInterval: rotationInterval, repeats: true) { _ in
            if factManager.availableFacts.count > 1 {
                selectNextFact()
            }
        }
    }
    
    private func stopAutoRotation() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }
}

// MARK: - Traditional Use Section

struct TraditionalUseSection: View {
    let title: String
    let items: [String]
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, 20)
        }
    }
}

// MARK: - Enhanced Fact Card

struct EnhancedFactCard: View {
    let fact: EnhancedFact
    let onFavoriteToggle: () -> Void
    let onNextFact: () -> Void
    
    @State private var isGlowing = false
    @State private var cardRotation = 0.0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main card background with dynamic styling
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: borderColors),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), 
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: shadowColor.opacity(fact.visualStyle.glowIntensity), 
                    radius: isGlowing ? 8 : 4, 
                    x: 0, 
                    y: 0
                )
                .scaleEffect(isGlowing ? 1.02 : 1.0)
                .rotationEffect(.degrees(cardRotation))
                .animation(
                    Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), 
                    value: isGlowing
                )
                .onAppear {
                    isGlowing = true
                    
                    // Special effect for exceptional facts
                    if fact.interestingnessRating == .exceptional {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            cardRotation = 2
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                cardRotation = -1
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    cardRotation = 0
                                }
                            }
                        }
                    }
                }
            
            // Card content
            VStack(alignment: .leading, spacing: 12) {
                // Header with category and rating
                HStack {
                    categoryIndicator
                    
                    Spacer()
                    
                    ratingIndicator
                }
                
                // Main fact text
                Text(fact.text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                
                Spacer()
                
                // Footer with favorite and next buttons
                HStack {
                    // Favorite button
                    Button(action: onFavoriteToggle) {
                        Image(systemName: fact.isFavorited ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(fact.isFavorited ? .red : .secondary)
                            .scaleEffect(fact.isFavorited ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: fact.isFavorited)
                    }
                    
                    Spacer()
                    
                    // Next fact button
                    Button(action: onNextFact) {
                        HStack(spacing: 4) {
                            Text("Next")
                                .font(.caption)
                            Image(systemName: "arrow.right")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 140)
    }
    
    // MARK: - Visual Components
    
    private var categoryIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: fact.category.icon)
                .font(.caption)
            Text(fact.category.rawValue.capitalized)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
        .foregroundColor(.secondary)
    }
    
    private var ratingIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<Int(fact.interestingnessRating.rawValue), id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
        }
    }
    
    // MARK: - Dynamic Styling
    
    private var cardBackgroundGradient: LinearGradient {
        let colors = backgroundColorsForStyle(fact.visualStyle)
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var borderColors: [Color] {
        switch fact.visualStyle {
        case .favorited:
            return [.red.opacity(0.6), .pink.opacity(0.4)]
        case .exceptional:
            return [.purple.opacity(0.8), .blue.opacity(0.6)]
        case .high:
            return [.blue.opacity(0.6), .cyan.opacity(0.4)]
        case .medium:
            return [.green.opacity(0.5), .mint.opacity(0.3)]
        case .low:
            return [.orange.opacity(0.4), .yellow.opacity(0.3)]
        }
    }
    
    private var shadowColor: Color {
        switch fact.visualStyle {
        case .favorited: return .red
        case .exceptional: return .purple
        case .high: return .blue
        case .medium: return .green
        case .low: return .orange
        }
    }
    
    private func backgroundColorsForStyle(_ style: FactVisualStyle) -> [Color] {
        switch style {
        case .favorited:
            return [
                Color(.systemPink).opacity(0.15),
                Color(.systemRed).opacity(0.10),
                Color(.systemPink).opacity(0.05)
            ]
        case .exceptional:
            return [
                Color(.systemPurple).opacity(0.20),
                Color(.systemIndigo).opacity(0.15),
                Color(.systemPurple).opacity(0.10)
            ]
        case .high:
            return [
                Color(.systemBlue).opacity(0.15),
                Color(.systemCyan).opacity(0.10),
                Color(.systemBlue).opacity(0.05)
            ]
        case .medium:
            return [
                Color(.systemGreen).opacity(0.15),
                Color(.systemMint).opacity(0.10),
                Color(.systemGreen).opacity(0.05)
            ]
        case .low:
            return [
                Color(.systemOrange).opacity(0.15),
                Color(.systemYellow).opacity(0.10),
                Color(.systemOrange).opacity(0.05)
            ]
        }
    }
}

// MARK: - Statistics Views

struct FactStatisticsView: View {
    let statistics: FactStatistics
    
    var body: some View {
        HStack(spacing: 12) {
            StatPill(icon: "heart.fill", count: statistics.favoriteFacts, color: .red)
            StatPill(icon: "star.fill", count: statistics.exceptionalFacts, color: .purple)
            StatPill(icon: "sparkles", count: statistics.highInterestFacts, color: .blue)
        }
    }
}

struct StatPill: View {
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.15))
        .cornerRadius(6)
    }
}

struct QualityIndicatorView: View {
    let statistics: FactStatistics
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 4) {
                ForEach(0..<qualityStars, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
                
                ForEach(0..<(5-qualityStars), id: \.self) { _ in
                    Image(systemName: "star")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            
            Text("Quality")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var qualityStars: Int {
        let score = statistics.qualityScore
        return max(1, min(5, Int(score)))
    }
}

// MARK: - Preview

struct EnhancedFactDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        let mockUses = Uses(
            funFacts: [
                "The name 'amethyst' comes from ancient Greek meaning 'not intoxicated'",
                "Ancient Romans believed amethyst could prevent drunkenness when worn",
                "The largest amethyst geode ever found weighs over 13,000 pounds",
                "Amethyst is the birthstone for February and the 6th wedding anniversary gem"
            ]
        )
        
        EnhancedFactDisplayView(
            uses: mockUses,
            rockName: "Amethyst",
            confidence: 0.92
        )
        .padding()
    }
}
