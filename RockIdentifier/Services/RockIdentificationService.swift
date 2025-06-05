// Rock Identifier: Crystal ID - Improved Single-Step System
// Muoyo Okome
//

import Foundation
import SwiftUI
import Combine
import CommonCrypto
import UIKit

enum IdentificationState: Equatable {
    case idle
    case processing
    case success(RockIdentificationResult)
    case error(String)
    
    static func == (lhs: IdentificationState, rhs: IdentificationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.processing, .processing):
            return true
        case (.success(let lhsResult), .success(let rhsResult)):
            return lhsResult.id == rhsResult.id
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

class RockIdentificationService: ObservableObject {
    @Published var state: IdentificationState = .idle
    @Published var currentImage: UIImage?
    @Published var useMockData: Bool = false
    
    private let connectionRequest = ConnectionRequest()
    private let apiUrl = "https://appquestions.co/gem/openai_proxy.php"
    private let sharedSecretKey = "pEDaZ/K0ITlKb8KALrm73TeNTZXZFEQl3jvIVFNgbEZ4WEjUO6y+gFM6SNKHjxlP"
    
    // Improved single-step prompt - much shorter but comprehensive
    private let systemPrompt = """
    You are a world-class mineralogist and geologist. Identify this rock or mineral from the image.

    VISUAL ANALYSIS:
    Examine systematically: color, texture, luster, crystal structure, grain size, and distinctive features.

    IDENTIFICATION APPROACH:
    Always attempt identification unless the image is completely unidentifiable. Make your best expert assessment based on visual cues.

    RESPONSE FORMAT (Key-Value):
    NAME: [Rock/Mineral Name]
    CATEGORY: [Igneous/Sedimentary/Metamorphic/Mineral]
    CONFIDENCE: [0.50-0.99]
    COLOR: [Detailed color description]
    HARDNESS: [Mohs scale value]
    LUSTER: [Type of luster]
    STREAK: [Streak color]
    TRANSPARENCY: [Transparent/Translucent/Opaque]
    CRYSTAL_SYSTEM: [Crystal system if applicable]
    CLEAVAGE: [Cleavage description]
    FRACTURE: [Fracture type]
    SPECIFIC_GRAVITY: [Density relative to water]
    FORMULA: [Chemical formula]
    COMPOSITION: [Primary chemical composition]
    FORMATION_TYPE: [Formation process type]
    ENVIRONMENT: [Where it typically forms]
    GEOLOGICAL_AGE: [When it commonly formed]
    COMMON_LOCATIONS: [Location1, Location2, Location3]
    FORMATION_PROCESS: [How it forms]
    INDUSTRIAL_USES: [Use1, Use2]
    HISTORICAL_USES: [Use1, Use2]
    METAPHYSICAL_PROPERTIES: [Property1, Property2]
    FUN_FACT1: [Interesting geological fact]
    FUN_FACT2: [Another fascinating detail]
    FUN_FACT3: [Third notable characteristic]

    CONFIDENCE SCALE:
    0.90-0.99: Excellent specimen with clear features
    0.80-0.89: Good specimen with several characteristics
    0.70-0.79: Fair specimen with basic features
    0.60-0.69: Limited but identifiable
    0.50-0.59: Poor quality but best guess

    ERROR FORMAT (only if completely unidentifiable):
    ERROR: [Specific reason]
    SUGGESTION1: [Improvement suggestion]
    SUGGESTION2: [Another suggestion]
    """
    
    // Function to identify a rock from an image
    func identifyRock(from image: UIImage) {
        state = .processing
        currentImage = image
        
        if useMockData {
            print("Using mock data for rock identification")
            createMockIdentificationResult(for: image)
            return
        }
        
        // Prepare image data
        guard let resizedImage = image.resized(toHeight: 600),
              let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            state = .error("Failed to process image")
            return
        }
        
        if imageData.count > 5_000_000 {
            guard let furtherResized = resizedImage.resized(toHeight: 400),
                  let smallerData = furtherResized.jpegData(compressionQuality: 0.6) else {
                state = .error("Image too large for processing")
                return
            }
            print("Image was too large (\(imageData.count) bytes), reduced to \(smallerData.count) bytes")
            identifyWithPreparedImage(smallerData, originalImage: image)
        } else {
            identifyWithPreparedImage(imageData, originalImage: image)
        }
    }
    
    // Create a mock rock identification result for testing
    private func createMockIdentificationResult(for image: UIImage) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Create mock elements
            let siliconElement = Element(name: "Silicon", symbol: "Si", percentage: 46.7)
            let oxygenElement = Element(name: "Oxygen", symbol: "O", percentage: 53.3)
            
            // Create mock physical properties
            let physicalProperties = PhysicalProperties(
                color: "Purple to violet",
                hardness: "7 (Mohs scale)",
                luster: "Vitreous",
                streak: "White",
                transparency: "Transparent to Translucent",
                crystalSystem: "Hexagonal",
                cleavage: "None",
                fracture: "Conchoidal",
                specificGravity: "2.65"
            )
            
            // Create mock chemical properties
            let chemicalProperties = ChemicalProperties(
                formula: "SiO₂",
                composition: "Silicon dioxide",
                elements: [siliconElement, oxygenElement],
                mineralsPresent: ["Quartz"],
                reactivity: "None"
            )
            
            // Create mock formation details
            let formation = Formation(
                formationType: "Mineral",
                environment: "Forms in vugs and cavities in igneous rocks",
                geologicalAge: "Various ages",
                commonLocations: ["Brazil", "Uruguay", "Zambia", "South Korea", "Russia"],
                associatedMinerals: ["Quartz", "Calcite", "Fluorite"],
                formationProcess: "Crystallizes from silicon-rich fluids"
            )
            
            // Create mock uses
            let uses = Uses(
                industrial: ["Decorative stones", "Jewelry making", "Ornamental objects"],
                historical: ["Used by ancient Egyptians for jewelry and amulets", "Believed to protect against intoxication and harm"],
                modern: ["Decorative gemstone", "Jewelry", "Ornamental objects"],
                metaphysical: ["Associated with spiritual awareness", "Said to promote calm and balance"],
                funFacts: [
                    "The name comes from Ancient Greek 'amethystos' meaning 'not intoxicated'",
                    "It's the birthstone for February",
                    "Amethyst loses its color when heated, turning yellow or orange"
                ]
            )
            
            // Create the final result
            let result = RockIdentificationResult(
                image: image,
                name: "Amethyst",
                category: "Quartz Variety",
                confidence: 0.92,
                physicalProperties: physicalProperties,
                chemicalProperties: chemicalProperties,
                formation: formation,
                uses: uses
            )
            
            self.state = .success(result)
        }
    }
    
    // Helper function that handles the actual API request with prepared image data
    private func identifyWithPreparedImage(_ imageData: Data, originalImage: UIImage) {
        let encodedImageString = encodeToPercentEncodedString(imageData)
        
        let messages = [
            [
                "role": "system",
                "content": systemPrompt,
                "message": ""
            ],
            [
                "role": "user",
                "content": "Identify this rock or mineral using the key-value format. Make your best identification attempt.",
                "message": "Identify this rock or mineral using the key-value format. Make your best identification attempt.",
                "image": encodedImageString
            ]
        ]
        
        guard let messagesJSON = try? JSONEncoder().encode(messages),
              let messagesString = String(data: messagesJSON, encoding: .utf8) else {
            state = .error("Failed to encode request")
            return
        }
        
        let hash = createHash(from: messagesString + sharedSecretKey)
        let parameters: [String: String] = [
            "messages": messagesString,
            "hash": hash
        ]
        
        connectionRequest.fetchData(apiUrl, parameters: parameters) { [weak self] data, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error, !error.isEmpty {
                    self.state = .error("Network error: \(error)")
                    HapticManager.shared.errorFeedback()
                    return
                }
                
                guard let data = data, data.count > 0 else {
                    self.state = .error("Empty response received from server. Please try again.")
                    HapticManager.shared.errorFeedback()
                    return
                }
                
                self.parseResponse(data, originalImage: originalImage)
            }
        }
    }
    
    // Helper function to parse the API response and create a RockIdentificationResult
    private func parseResponse(_ data: Data, originalImage: UIImage) {
        let responseText = String(data: data, encoding: .utf8) ?? ""
        print("API response: \(responseText.prefix(500))")
        
        guard !responseText.isEmpty else {
            state = .error("Empty response received from server")
            return
        }
        
        // Check for server errors
        if (responseText.contains("Notice:") || responseText.contains("Warning:") ||
            (responseText.contains("<") && !responseText.contains("```"))) {
            print("Server returned an error: \(responseText)")
            state = .error("Server error, please try again.")
            return
        }
        
        // Parse key-value response
        parseKeyValueResponse(responseText, originalImage: originalImage)
    }
    
    // Parse key-value format response
    private func parseKeyValueResponse(_ responseText: String, originalImage: UIImage) {
        print("Parsing key-value response: \(responseText.prefix(500))")
        
        // Check for error response format
        if responseText.contains("ERROR:") {
            let components = responseText.components(separatedBy: "\n")
            var errorMessage = "Unknown error"
            var suggestions = [String]()
            
            for line in components {
                if line.starts(with: "ERROR:") {
                    errorMessage = line.replacingOccurrences(of: "ERROR:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "SUGGESTION") {
                    let suggestion = line.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespacesAndNewlines)
                    suggestions.append(suggestion)
                }
            }
            
            var friendlyError = errorMessage
            if !suggestions.isEmpty {
                friendlyError += "\n\nSuggestions:\n"
                for suggestion in suggestions {
                    friendlyError += "• " + suggestion + "\n"
                }
            }
            
            state = .error(friendlyError)
            return
        }
        
        // Split the response into lines and create a dictionary
        let lines = responseText.components(separatedBy: "\n")
        var valueDict = [String: String]()
        
        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            let parts = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            if parts.count == 2 {
                let key = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                let value = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                valueDict[key] = value
            }
        }
        
        print("Parsed values: \(valueDict)")
        
        // Extract basic info
        guard let name = valueDict["NAME"],
              let category = valueDict["CATEGORY"] else {
            state = .error("Missing required rock information. Please try again with a clearer image.")
            return
        }
        
        let confidence = Double(valueDict["CONFIDENCE"] ?? "0.7") ?? 0.7
        
        // Create PhysicalProperties
        let physicalProperties = PhysicalProperties(
            color: valueDict["COLOR"] ?? "Various",
            hardness: valueDict["HARDNESS"] ?? "Unknown",
            luster: valueDict["LUSTER"] ?? "Unknown",
            streak: valueDict["STREAK"],
            transparency: valueDict["TRANSPARENCY"],
            crystalSystem: valueDict["CRYSTAL_SYSTEM"],
            cleavage: valueDict["CLEAVAGE"],
            fracture: valueDict["FRACTURE"],
            specificGravity: valueDict["SPECIFIC_GRAVITY"]
        )
        
        // Create ChemicalProperties
        let chemicalProperties = ChemicalProperties(
            formula: valueDict["FORMULA"],
            composition: valueDict["COMPOSITION"] ?? "Information not available",
            elements: nil // We'll skip elements parsing for now to keep it simple
        )
        
        // Extract locations
        let commonLocations = valueDict["COMMON_LOCATIONS"]?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Create Formation
        let formation = Formation(
            formationType: valueDict["FORMATION_TYPE"] ?? "Unknown",
            environment: valueDict["ENVIRONMENT"] ?? "Information not available",
            geologicalAge: valueDict["GEOLOGICAL_AGE"],
            commonLocations: commonLocations,
            associatedMinerals: nil,
            formationProcess: valueDict["FORMATION_PROCESS"] ?? "Information not available"
        )
        
        // Extract uses
        let industrialUses = valueDict["INDUSTRIAL_USES"]?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let historicalUses = valueDict["HISTORICAL_USES"]?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let metaphysicalProps = valueDict["METAPHYSICAL_PROPERTIES"]?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Extract fun facts
        var funFacts = [String]()
        if let fact1 = valueDict["FUN_FACT1"], !fact1.isEmpty && fact1 != "Unknown" && fact1 != "Not applicable" {
            funFacts.append(fact1)
        }
        if let fact2 = valueDict["FUN_FACT2"], !fact2.isEmpty && fact2 != "Unknown" && fact2 != "Not applicable" {
            funFacts.append(fact2)
        }
        if let fact3 = valueDict["FUN_FACT3"], !fact3.isEmpty && fact3 != "Unknown" && fact3 != "Not applicable" {
            funFacts.append(fact3)
        }
        
        // Ensure we have at least one meaningful fun fact
        if funFacts.isEmpty {
            funFacts.append("\(name) is a fascinating specimen with unique geological properties.")
            if category.lowercased().contains("igneous") {
                funFacts.append("This igneous rock formed from molten magma cooling and solidifying.")
            } else if category.lowercased().contains("sedimentary") {
                funFacts.append("This sedimentary rock formed from layers of compressed sediments.")
            } else if category.lowercased().contains("metamorphic") {
                funFacts.append("This metamorphic rock formed under intense heat and pressure.")
            } else if category.lowercased().contains("mineral") {
                funFacts.append("This mineral formed through natural crystallization processes.")
            }
        }
        
        // Create Uses
        let uses = Uses(
            industrial: industrialUses?.isEmpty == false ? industrialUses : nil,
            historical: historicalUses?.isEmpty == false ? historicalUses : nil,
            modern: industrialUses?.isEmpty == false ? industrialUses : nil, // Use industrial for modern
            metaphysical: metaphysicalProps?.isEmpty == false ? metaphysicalProps : nil,
            funFacts: funFacts
        )
        
        // Create the final result
        let result = RockIdentificationResult(
            image: originalImage,
            name: name,
            category: category,
            confidence: confidence,
            physicalProperties: physicalProperties,
            chemicalProperties: chemicalProperties,
            formation: formation,
            uses: uses
        )
        
        state = .success(result)
        HapticManager.shared.successFeedback()
    }
    
    // Helper functions
    private func createHash(from string: String) -> String {
        let messageData = string.data(using: .utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes.baseAddress, CC_LONG(messageData.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
    
    private func encodeToPercentEncodedString(_ data: Data) -> String {
        return data.map { String(format: "%%%02hhX", $0) }.joined()
    }
    
    func setUseMockData(_ useMock: Bool) {
        useMockData = useMock
        print("Rock identification mode: \(useMock ? "MOCK DATA" : "REAL API")")
    }
}

// Extension to get error message from identification state
extension IdentificationState {
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}