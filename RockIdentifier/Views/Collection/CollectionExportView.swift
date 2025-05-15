// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import PDFKit
import UIKit

struct CollectionExportView: View {
    @EnvironmentObject var collectionManager: CollectionManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isExporting = false
    @State private var exportType: ExportType = .pdf
    @State private var showShareSheet = false
    @State private var exportedFileURL: URL?
    
    // Generation status
    @State private var generationProgress = 0.0
    @State private var isGenerating = false
    @State private var errorMessage: String?
    
    enum ExportType: String, CaseIterable, Identifiable {
        case pdf = "PDF Document"
        case csv = "CSV Spreadsheet"
        
        var id: String { self.rawValue }
        
        var description: String {
            switch self {
            case .pdf:
                return "Creates a detailed document with photos and complete information"
            case .csv:
                return "Creates a simple spreadsheet with basic information"
            }
        }
        
        var iconName: String {
            switch self {
            case .pdf:
                return "doc.richtext"
            case .csv:
                return "tablecells"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up.on.square")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Export Your Rock Collection")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Create a shareable document with all your identified specimens")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Export type selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Export Format")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(ExportType.allCases) { type in
                        Button(action: {
                            exportType = type
                        }) {
                            HStack {
                                Image(systemName: type.iconName)
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(type.rawValue)
                                        .font(.headline)
                                    
                                    Text(type.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if exportType == type {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(exportType == type ? Color.blue.opacity(0.1) : Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(exportType == type ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    
                    if collectionManager.collection.isEmpty {
                        // Empty state
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.6))
                                
                                Text("Your collection is empty")
                                    .font(.headline)
                                
                                Text("Identify some rocks to add them to your collection")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 30)
                            
                            Spacer()
                        }
                    } else if isGenerating {
                        // Progress indicator
                        VStack(spacing: 16) {
                            ProgressView(value: generationProgress, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle())
                            
                            Text("Generating your collection export...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                    } else if let error = errorMessage {
                        // Error message
                        VStack(spacing: 8) {
                            Text("Error")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                
                Spacer()
                
                // Export button
                Button(action: {
                    if exportType == .pdf {
                        generatePDF()
                    } else {
                        generateCSV()
                    }
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export \(collectionManager.collection.count) Items")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        collectionManager.collection.isEmpty 
                            ? Color.blue.opacity(0.5) 
                            : Color.blue
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(collectionManager.collection.isEmpty || isGenerating)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Export Collection", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
            )
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    // Generate a PDF of the collection
    private func generatePDF() {
        isGenerating = true
        generationProgress = 0.0
        errorMessage = nil
        
        // Create a temporary URL for the PDF
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Rock Collection \(formattedDate()).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        // Use a background thread to avoid blocking the UI
        DispatchQueue.global(qos: .userInitiated).async {
            // Create a PDF document
            let pdfDocument = PDFDocument()
            let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
            
            // Create a title page
            if let titlePage = createTitlePage(pageSize: pageSize) {
                pdfDocument.insert(titlePage, at: 0)
            }
            
            // Create pages for each rock
            let totalRocks = collectionManager.collection.count
            
            for (index, rock) in collectionManager.collection.enumerated() {
                // Update progress on main thread
                DispatchQueue.main.async {
                    generationProgress = Double(index) / Double(totalRocks)
                }
                
                if let page = createRockPage(rock: rock, pageSize: pageSize) {
                    pdfDocument.insert(page, at: pdfDocument.pageCount)
                }
            }
            
            // Save the PDF
            if pdfDocument.write(to: fileURL) {
                // Success - update the UI on the main thread
                DispatchQueue.main.async {
                    exportedFileURL = fileURL
                    showShareSheet = true
                    isGenerating = false
                    generationProgress = 1.0
                }
            } else {
                // Failure
                DispatchQueue.main.async {
                    errorMessage = "Failed to create PDF. Please try again."
                    isGenerating = false
                }
            }
        }
    }
    
    // Generate a CSV of the collection
    private func generateCSV() {
        isGenerating = true
        generationProgress = 0.0
        errorMessage = nil
        
        // Create a temporary URL for the CSV
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Rock Collection \(formattedDate()).csv"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        // Use a background thread to avoid blocking the UI
        DispatchQueue.global(qos: .userInitiated).async {
            // Create CSV header
            var csvString = "Name,Category,Date Added,Favorite,Color,Hardness,Luster,Location,Notes\n"
            
            // Add each rock to the CSV
            let totalRocks = collectionManager.collection.count
            
            for (index, rock) in collectionManager.collection.enumerated() {
                // Update progress on main thread
                DispatchQueue.main.async {
                    generationProgress = Double(index) / Double(totalRocks)
                }
                
                // Format date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let dateString = dateFormatter.string(from: rock.identificationDate)
                
                // Escape and quote CSV fields
                let row = [
                    csvEscape(rock.name),
                    csvEscape(rock.category),
                    csvEscape(dateString),
                    rock.isFavorite ? "Yes" : "No",
                    csvEscape(rock.physicalProperties.color),
                    csvEscape(rock.physicalProperties.hardness),
                    csvEscape(rock.physicalProperties.luster),
                    csvEscape(rock.location ?? ""),
                    csvEscape(rock.notes ?? "")
                ].joined(separator: ",")
                
                csvString.append(row + "\n")
            }
            
            // Write CSV to file
            do {
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                
                // Success - update the UI on the main thread
                DispatchQueue.main.async {
                    exportedFileURL = fileURL
                    showShareSheet = true
                    isGenerating = false
                    generationProgress = 1.0
                }
            } catch {
                // Failure
                DispatchQueue.main.async {
                    errorMessage = "Failed to create CSV: \(error.localizedDescription)"
                    isGenerating = false
                }
            }
        }
    }
    
    // Helper function to escape CSV fields
    private func csvEscape(_ field: String) -> String {
        // Replace quotes with double quotes and wrap in quotes
        var escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        
        // If field contains comma, newline, or quotes, wrap in quotes
        if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
            escaped = "\"\(escaped)\""
        }
        
        return escaped
    }
    
    // Create a formatted date string
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // Create the title page for the PDF
    private func createTitlePage(pageSize: CGRect) -> PDFPage? {
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        
        // Create PDF data
        guard let data = try? renderer.pdfData(actions: { context in
            context.beginPage()
            
            // Add title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let titleRect = CGRect(x: 50, y: 100, width: pageSize.width - 100, height: 40)
            "Rock Identifier Collection".draw(in: titleRect, withAttributes: titleAttributes)
            
            // Add date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = "Generated on \(dateFormatter.string(from: Date()))"
            
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.darkGray
            ]
            let dateRect = CGRect(x: 50, y: 150, width: pageSize.width - 100, height: 30)
            dateString.draw(in: dateRect, withAttributes: dateAttributes)
            
            // Add collection info
            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]
            let infoRect = CGRect(x: 50, y: 250, width: pageSize.width - 100, height: 30)
            "Total Items: \(collectionManager.collection.count)".draw(in: infoRect, withAttributes: infoAttributes)
            
            // Count favorites
            let favoritesCount = collectionManager.collection.filter { $0.isFavorite }.count
            let favoritesRect = CGRect(x: 50, y: 280, width: pageSize.width - 100, height: 30)
            "Favorites: \(favoritesCount)".draw(in: favoritesRect, withAttributes: infoAttributes)
            
            // Add categories
            let categories = Array(Set(collectionManager.collection.map { $0.category }))
            let categoriesRect = CGRect(x: 50, y: 330, width: pageSize.width - 100, height: 30)
            "Categories: \(categories.joined(separator: ", "))".draw(in: categoriesRect, withAttributes: infoAttributes)
            
            // Add footer
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.darkGray
            ]
            let footerRect = CGRect(x: 50, y: pageSize.height - 50, width: pageSize.width - 100, height: 20)
            "Generated by Rock Identifier App".draw(in: footerRect, withAttributes: footerAttributes)
        }) else {
            return nil
        }
        
        // Create a PDF page from the image data
        if let image = UIImage(data: data) {
            return PDFPage(image: image)
        }
        
        return nil
    }
    
    // Create a PDF page for a rock
    private func createRockPage(rock: RockIdentificationResult, pageSize: CGRect) -> PDFPage? {
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        
        // Create PDF data
        guard let data = try? renderer.pdfData(actions: { context in
            context.beginPage()
            
            // Add title (rock name)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let titleRect = CGRect(x: 50, y: 50, width: pageSize.width - 100, height: 40)
            rock.name.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Add category and date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: rock.identificationDate)
            
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.darkGray
            ]
            let subtitleRect = CGRect(x: 50, y: 90, width: pageSize.width - 100, height: 30)
            "\(rock.category) • Identified on \(dateString)".draw(in: subtitleRect, withAttributes: subtitleAttributes)
            
            // Add image if available
            var yPosition = 140.0
            if let image = rock.image {
                let maxWidth: CGFloat = 250
                let maxHeight: CGFloat = 250
                
                let aspectRatio = image.size.width / image.size.height
                let width = min(maxWidth, image.size.width)
                let height = width / aspectRatio
                
                let imageRect = CGRect(x: 50, y: yPosition, width: width, height: min(height, maxHeight))
                image.draw(in: imageRect)
                
                yPosition += imageRect.height + 30
            }
            
            // Section title font
            let sectionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            
            // Property font
            let propertyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            
            // Add physical properties
            let physicalTitleRect = CGRect(x: 50, y: yPosition, width: pageSize.width - 100, height: 30)
            "Physical Properties".draw(in: physicalTitleRect, withAttributes: sectionAttributes)
            
            yPosition += 30
            
            // Add each property
            let properties: [(String, String)] = [
                ("Color", rock.physicalProperties.color),
                ("Hardness", rock.physicalProperties.hardness),
                ("Luster", rock.physicalProperties.luster)
            ]
            
            for (label, value) in properties {
                let labelRect = CGRect(x: 70, y: yPosition, width: 100, height: 20)
                "\(label):".draw(in: labelRect, withAttributes: propertyAttributes)
                
                let valueRect = CGRect(x: 180, y: yPosition, width: pageSize.width - 230, height: 20)
                value.draw(in: valueRect, withAttributes: propertyAttributes)
                
                yPosition += 22
            }
            
            // Add location if available
            if let location = rock.location, !location.isEmpty {
                yPosition += 10
                
                let locationTitleRect = CGRect(x: 50, y: yPosition, width: pageSize.width - 100, height: 30)
                "Location".draw(in: locationTitleRect, withAttributes: sectionAttributes)
                
                yPosition += 30
                
                let locationRect = CGRect(x: 70, y: yPosition, width: pageSize.width - 120, height: 20)
                location.draw(in: locationRect, withAttributes: propertyAttributes)
                
                yPosition += 30
            }
            
            // Add notes if available
            if let notes = rock.notes, !notes.isEmpty {
                let notesTitleRect = CGRect(x: 50, y: yPosition, width: pageSize.width - 100, height: 30)
                "Notes".draw(in: notesTitleRect, withAttributes: sectionAttributes)
                
                yPosition += 30
                
                let notesRect = CGRect(x: 70, y: yPosition, width: pageSize.width - 120, height: 100)
                notes.draw(in: notesRect, withAttributes: propertyAttributes)
            }
            
            // Add footer with page number
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.darkGray
            ]
            let footerRect = CGRect(x: pageSize.width - 100, y: pageSize.height - 30, width: 80, height: 20)
            "Rock Identifier".draw(in: footerRect, withAttributes: footerAttributes)
        }) else {
            return nil
        }
        
        // Create a PDF page from the image data
        if let image = UIImage(data: data) {
            return PDFPage(image: image)
        }
        
        return nil
    }
}

struct CollectionExportView_Previews: PreviewProvider {
    static var previews: some View {
        let collectionManager = CollectionManager()
        
        return CollectionExportView()
            .environmentObject(collectionManager)
    }
}
