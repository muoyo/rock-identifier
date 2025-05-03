// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import SwiftUI
import Combine

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
    
    private let connectionRequest = ConnectionRequest()
    
    // URL to the OpenAI proxy PHP script
    private let apiUrl = "https://appquestions.co/gem/openai_proxy.php" // Make sure this matches the actual deployed script location
    
    // Shared secret key for securing API requests
    private let sharedSecretKey = "pEDaZ/K0ITlKb8KALrm73TeNTZXZFEQl3jvIVFNgbEZ4WEjUO6y+gFM6SNKHjxlP"
    
    // System prompt specifically designed for rock and mineral identification
    private let systemPrompt = """
    You are a specialized AI assistant for RockIdentifier, an app that identifies rocks, minerals, crystals, and gemstones from images. Analyze the image and provide detailed rock/mineral identification with high confidence.

    Respond ONLY in this exact JSON format:
    {
      "name": "Full scientific name",
      "category": "Rock, Mineral, Crystal, or Gemstone type",
      "confidence": "0.0-1.0 numeric value representing identification confidence",
      "physicalProperties": {
        "color": "Common colors",
        "hardness": "Mohs scale value or range",
        "luster": "e.g., Vitreous, Metallic, etc.",
        "streak": "Color when scraped",
        "transparency": "Transparent, Translucent, Opaque",
        "crystalSystem": "If applicable",
        "cleavage": "If applicable",
        "fracture": "Type of fracture if relevant",
        "specificGravity": "Density relative to water"
      },
      "chemicalProperties": {
        "formula": "Chemical formula if applicable",
        "composition": "Main chemical components",
        "elements": [
          {"name": "Element name", "symbol": "Element symbol", "percentage": "approximate % if known"}
        ]
      },
      "formation": {
        "formationType": "Igneous, Sedimentary, Metamorphic, etc.",
        "environment": "Where it typically forms",
        "geologicalAge": "When it commonly formed",
        "commonLocations": ["Location 1", "Location 2"],
        "formationProcess": "Brief description of how it forms"
      },
      "uses": {
        "industrial": ["Industrial use 1", "Industrial use 2"],
        "historical": ["Historical use 1"],
        "modern": ["Modern use 1"],
        "metaphysical": ["Metaphysical property 1"],
        "funFacts": ["Interesting fact 1", "Interesting fact 2"]
      }
    }

    If you can't identify the specimen with reasonable confidence, or if the image isn't a rock/mineral, respond with:
    {
      "error": "Specific reason for identification failure",
      "suggestions": ["Suggestion 1", "Suggestion 2"]
    }

    IMPORTANT: Always respond with valid, parseable JSON only. No conversational text.
    """
    
    // Function to identify a rock from an image
    func identifyRock(from image: UIImage) {
        state = .processing
        
        // Encode the image data - reduce size for better reliability and API compatibility
        // OpenAI Vision API works best with images around 512-1024px
        guard let resizedImage = image.resized(toHeight: 600),
              let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            state = .error("Failed to process image")
            return
        }
        
        // Make sure the image size is not too large (OpenAI has limits)
        if imageData.count > 5_000_000 { // 5MB max
            // If still too large, resize further
            guard let furtherResized = resizedImage.resized(toHeight: 400),
                  let smallerData = furtherResized.jpegData(compressionQuality: 0.6) else {
                state = .error("Image too large for processing")
                return
            }
            print("Image was too large (\(imageData.count) bytes), reduced to \(smallerData.count) bytes")
            // Use the smaller image data instead
            self.identifyWithPreparedImage(smallerData, originalImage: image)
            return
        }
        
        // Process with the standard-sized image
        identifyWithPreparedImage(imageData, originalImage: image)
    }
    
    // Helper function that handles the actual API request with prepared image data
    private func identifyWithPreparedImage(_ imageData: Data, originalImage: UIImage) {
        
        // Create the message payload with the image and system prompt
        // Debug the image size
        print("Image data size before encoding: \(imageData.count) bytes")
        let encodedImageString = encodeToPercentEncodedString(imageData)
        print("Encoded image string length: \(encodedImageString.count) characters")
        print("First 100 chars of encoded image: \(String(encodedImageString.prefix(100)))")
        
        let messages = [
            [
                "role": "system", 
                "content": systemPrompt,
                "message": ""
            ],
            [
                "role": "user",
                "content": "Please identify this rock or mineral",
                "message": "Please identify this rock or mineral",
                "image": encodedImageString
            ]
        ]
        
        // Try to encode the messages to JSON
        guard let messagesJSON = try? JSONEncoder().encode(messages),
              let messagesString = String(data: messagesJSON, encoding: .utf8) else {
            state = .error("Failed to encode request")
            return
        }
        
        // Create the hash for security
        let hash = "\(messagesString)\(sharedSecretKey)".hash()
        
        // Build parameters for API request
        let parameters: [String: String] = [
            "messages": messagesString,
            "hash": hash
        ]
        
        // Make the API request
        connectionRequest.fetchData(apiUrl, parameters: parameters) { [weak self] data, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error, !error.isEmpty {
                    self.state = .error("Network error: \(error)")
                    return
                }
                
                guard let data = data, data.count > 0 else {
                    self.state = .error("Empty response received from server. Please try again.")
                    return
                }
                
                // Parse the response
                self.parseResponse(data, originalImage: originalImage)
            }
        }
    }
    
    // Helper function to parse the API response and create a RockIdentificationResult
    private func parseResponse(_ data: Data, originalImage: UIImage) {
        // Print the raw response for debugging
        let jsonString = String(data: data, encoding: .utf8) ?? "Unable to decode data to string"
        print("Raw API response: \(jsonString)")
        
        // First check if we received a valid string response
        guard !jsonString.isEmpty else {
            state = .error("Empty response received from server")
            return
        }
        
        // Make sure we're dealing with actual data, not PHP errors
        if (jsonString.contains("Notice:") || jsonString.contains("Warning:") || 
            (jsonString.contains("<") && !jsonString.contains("```"))) {
            print("Server returned an error: \(jsonString)")
            state = .error("Server error, please try again. Check logs for details.")
            return
        }
        
        // Check for error response format first
        if let errorResponse = try? JSONDecoder().decode(IdentificationErrorResponse.self, from: data) {
            if let errorMessage = errorResponse.error {
                // Create a user-friendly error message
                var friendlyError = errorMessage
                if let suggestions = errorResponse.suggestions, !suggestions.isEmpty {
                    friendlyError += "\n\nSuggestions:\n"
                    for suggestion in suggestions {
                        friendlyError += "• " + suggestion + "\n"
                    }
                }
                state = .error(friendlyError)
                return
            }
        }
        
        // Extract JSON from markdown code blocks if needed
        var processedJsonString = jsonString
        
        // Clean up any HTML comments
        if let regex = try? NSRegularExpression(pattern: "<!--.*?-->", options: .dotMatchesLineSeparators) {
            let range = NSRange(processedJsonString.startIndex..., in: processedJsonString)
            processedJsonString = regex.stringByReplacingMatches(in: processedJsonString, options: [], range: range, withTemplate: "")
        }
        
        // Extract JSON from markdown code blocks
        if processedJsonString.contains("```") {
            let pattern = "```[\\s\\S]*?\\n([\\s\\S]*?)\\n```"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: processedJsonString, range: NSRange(processedJsonString.startIndex..., in: processedJsonString)) {
                if let range = Range(match.range(at: 1), in: processedJsonString) {
                    processedJsonString = String(processedJsonString[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        // Try to parse the JSON
        do {
            print("Processed JSON string: \(processedJsonString.prefix(200))")
            
            // First try standard parsing - extract just the JSON object
            if let startIdx = processedJsonString.firstIndex(of: "{"),
               let endIdx = processedJsonString.lastIndex(of: "}") {
                let jsonSubstring = processedJsonString[startIdx...endIdx]
                print("Extracted JSON substring: \(jsonSubstring.prefix(200))")
                let jsonData = Data(jsonSubstring.utf8)
                
                let decoder = JSONDecoder()
                do {
                    print("Attempting standard JSON parsing...")
                    let response = try decoder.decode(IdentificationResponse.self, from: jsonData)
                    print("Standard parsing successful! Rock identified as: \(response.name)")
                    createSuccessResult(response: response, originalImage: originalImage)
                    return
                } catch {
                    print("Standard parsing failed: \(error.localizedDescription)")
                }
            } else {
                print("Could not find JSON object delimiters in the processed string")
            }
            
            // First try cleaning up the JSON
            let cleanedJson = cleanJsonString(processedJsonString)
            
            // Try to decode with the cleaned JSON
            let decoder = JSONDecoder()
            if let jsonData = cleanedJson.data(using: .utf8),
               let response = try? decoder.decode(IdentificationResponse.self, from: jsonData) {
                // Successfully parsed
                createSuccessResult(response: response, originalImage: originalImage)
                return
            }
            
            // Try to extract basic info manually
            if let extractedData = extractRockData(from: processedJsonString) {
                // We could extract partial data
                createPartialResult(extractedData: extractedData, originalImage: originalImage)
                return
            }
            
            // If all parsing attempts failed
            state = .error("Could not parse the rock identification data. Please try again with a clearer image.")
        } catch {
            state = .error("Failed to process result: \(error.localizedDescription)")
        }
    }
    
    // Helper function to clean up common JSON issues
    private func cleanJsonString(_ jsonString: String) -> String {
        var cleanedJson = jsonString
        
        // Fix missing quotes around property names
        let propertyNamePattern = "([{,])\\s*(\\w+)\\s*:"
        cleanedJson = cleanedJson.replacingOccurrences(of: propertyNamePattern, with: "$1\"$2\":", options: .regularExpression)
        
        // Fix missing quotes around property values
        let valuePattern = ":\\s*([^{\\[\\]}\"\\s][^{\\[\\]}\",]*)\\s*(,|\\}|\\])"
        cleanedJson = cleanedJson.replacingOccurrences(of: valuePattern, with: ":\"$1\"$2", options: .regularExpression)
        
        // Fix single quotes
        cleanedJson = cleanedJson.replacingOccurrences(of: "'", with: "\"")
        
        // Fix unicode quotes
        cleanedJson = cleanedJson.replacingOccurrences(of: "\u{201C}", with: "\"", options: .regularExpression)
        cleanedJson = cleanedJson.replacingOccurrences(of: "\u{201D}", with: "\"", options: .regularExpression)
        
        return cleanedJson
    }
    
    // Helper function to extract rock data even from malformed JSON
    private func extractRockData(from jsonString: String) -> [String: Any]? {
        // Use regex to extract key pieces of information
        var extractedData: [String: Any] = [:]
        
        // Extract rock name
        do {
            let namePattern = "\"name\"\\s*:\\s*\"([^\"]+)\""
            let nameRegex = try NSRegularExpression(pattern: namePattern)
            let nameRange = NSRange(jsonString.startIndex..., in: jsonString)
            
            if let match = nameRegex.firstMatch(in: jsonString, range: nameRange),
               let valueRange = Range(match.range(at: 1), in: jsonString) {
                extractedData["name"] = String(jsonString[valueRange])
            }
        } catch {
            print("Error extracting rock name: \(error)")
        }
        
        // Extract rock category
        do {
            let categoryPattern = "\"category\"\\s*:\\s*\"([^\"]+)\""
            let categoryRegex = try NSRegularExpression(pattern: categoryPattern)
            let categoryRange = NSRange(jsonString.startIndex..., in: jsonString)
            
            if let match = categoryRegex.firstMatch(in: jsonString, range: categoryRange),
               let valueRange = Range(match.range(at: 1), in: jsonString) {
                extractedData["category"] = String(jsonString[valueRange])
            }
        } catch {
            print("Error extracting rock category: \(error)")
        }
        
        // Extract confidence if available
        do {
            let confidencePattern = "\"confidence\"\\s*:\\s*([0-9.]+)"
            let confidenceRegex = try NSRegularExpression(pattern: confidencePattern)
            let confidenceRange = NSRange(jsonString.startIndex..., in: jsonString)
            
            if let match = confidenceRegex.firstMatch(in: jsonString, range: confidenceRange),
               let valueRange = Range(match.range(at: 1), in: jsonString) {
                if let confidence = Double(jsonString[valueRange]) {
                    extractedData["confidence"] = confidence
                }
            }
        } catch {
            print("Error extracting confidence: \(error)")
        }
        
        // Return extracted data if we at least have the name
        return extractedData["name"] != nil ? extractedData : nil
    }
    
    // Create a result with partial data when full parsing fails
    private func createPartialResult(extractedData: [String: Any], originalImage: UIImage) {
        let rockName = extractedData["name"] as? String ?? "Unknown Rock"
        let category = extractedData["category"] as? String ?? "Rock"
        let confidence = extractedData["confidence"] as? Double ?? 0.7
        
        // Create minimal physical properties
        let physicalProperties = PhysicalProperties(
            color: "Varies",
            hardness: "Unknown",
            luster: "Unknown",
            streak: nil,
            transparency: nil,
            crystalSystem: nil,
            cleavage: nil,
            fracture: nil,
            specificGravity: nil
        )
        
        // Create minimal chemical properties
        let chemicalProperties = ChemicalProperties(
            formula: nil,
            composition: "Information not available",
            elements: nil
        )
        
        // Create minimal formation info
        let formation = Formation(
            formationType: "Unknown",
            environment: "Information not available",
            geologicalAge: nil,
            commonLocations: nil,
            associatedMinerals: nil,
            formationProcess: "Information not available"
        )
        
        // Create minimal uses
        let uses = Uses(
            industrial: nil,
            historical: nil,
            modern: nil,
            metaphysical: nil,
            funFacts: ["This rock has been identified as \(rockName) with limited information available."]
        )
        
        // Create the final result
        let result = RockIdentificationResult(
            image: originalImage,
            name: rockName,
            category: category,
            confidence: confidence,
            physicalProperties: physicalProperties,
            chemicalProperties: chemicalProperties,
            formation: formation,
            uses: uses
        )
        
        state = .success(result)
    }
    
    // Helper function to create a success result from a parsed response
    private func createSuccessResult(response: IdentificationResponse, originalImage: UIImage) {
        let physicalProperties = PhysicalProperties(
            color: response.physicalProperties.color,
            hardness: response.physicalProperties.hardness,
            luster: response.physicalProperties.luster,
            streak: response.physicalProperties.streak,
            transparency: response.physicalProperties.transparency,
            crystalSystem: response.physicalProperties.crystalSystem,
            cleavage: response.physicalProperties.cleavage,
            fracture: response.physicalProperties.fracture,
            specificGravity: response.physicalProperties.specificGravity
        )
        
        let elements = response.chemicalProperties.elements?.map { element in
            Element(
                name: element.name,
                symbol: element.symbol,
                percentage: element.percentage
            )
        }
        
        let chemicalProperties = ChemicalProperties(
            formula: response.chemicalProperties.formula,
            composition: response.chemicalProperties.composition,
            elements: elements
        )
        
        let formation = Formation(
            formationType: response.formation.formationType,
            environment: response.formation.environment,
            geologicalAge: response.formation.geologicalAge,
            commonLocations: response.formation.commonLocations,
            associatedMinerals: response.formation.associatedMinerals,
            formationProcess: response.formation.formationProcess
        )
        
        let uses = Uses(
            industrial: response.uses.industrial,
            historical: response.uses.historical,
            modern: response.uses.modern,
            metaphysical: response.uses.metaphysical,
            funFacts: response.uses.funFacts
        )
        
        let result = RockIdentificationResult(
            image: originalImage,
            name: response.name,
            category: response.category,
            confidence: response.confidence,
            physicalProperties: physicalProperties,
            chemicalProperties: chemicalProperties,
            formation: formation,
            uses: uses
        )
        
        state = .success(result)
    }
    
    // Helper function to encode image data as a percent-encoded string
    private func encodeToPercentEncodedString(_ data: Data) -> String {
        // Encode each byte as a percent-encoded character
        return data.map { String(format: "%%%02hhX", $0) }.joined()
    }
}

// Response structures for parsing the API response

struct IdentificationResponse: Codable {
    let name: String
    let category: String
    let confidence: Double
    let physicalProperties: PhysicalPropertiesResponse
    let chemicalProperties: ChemicalPropertiesResponse
    let formation: FormationResponse
    let uses: UsesResponse
}

struct PhysicalPropertiesResponse: Codable {
    let color: String
    let hardness: String
    let luster: String
    let streak: String?
    let transparency: String?
    let crystalSystem: String?
    let cleavage: String?
    let fracture: String?
    let specificGravity: String?
}

struct ChemicalPropertiesResponse: Codable {
    let formula: String?
    let composition: String
    let elements: [ElementResponse]?
}

struct ElementResponse: Codable {
    let name: String
    let symbol: String
    let percentage: Double?
}

struct FormationResponse: Codable {
    let formationType: String
    let environment: String
    let geologicalAge: String?
    let commonLocations: [String]?
    let associatedMinerals: [String]?
    let formationProcess: String
}

struct UsesResponse: Codable {
    let industrial: [String]?
    let historical: [String]?
    let modern: [String]?
    let metaphysical: [String]?
    let funFacts: [String]
}

struct IdentificationErrorResponse: Codable {
    let error: String?
    let suggestions: [String]?
    let rawResponse: String?
    let debugInfo: String?
    
    enum CodingKeys: String, CodingKey {
        case error
        case suggestions
        case rawResponse = "raw_response"
        case debugInfo = "debug_info"
    }
}

// String extension for creating MD5 hash
extension String {
    func hash() -> String {
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes.baseAddress, CC_LONG(messageData.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}

// Import CommonCrypto for MD5 hashing
import CommonCrypto
