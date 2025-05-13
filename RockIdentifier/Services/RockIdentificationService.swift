// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import SwiftUI
import Combine
// Import CommonCrypto for MD5 hashing
import CommonCrypto

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
    
    // System prompt specifically designed for rock and mineral identification with strict JSON formatting
    private let systemPrompt = """
    You are a specialized AI assistant for RockIdentifier, an app that identifies rocks, minerals, crystals, and gemstones from images. Analyze the image and provide detailed rock/mineral identification.

    IMPORTANT - YOUR RESPONSE MUST BE ONLY VALID JSON IN THIS EXACT FORMAT:
    {
      "name": "Full scientific name",
      "category": "Rock/Mineral/Crystal/Gemstone",
      "confidence": 0.95,
      "physicalProperties": {
        "color": "Common colors and variants",
        "hardness": "Mohs scale value or range (e.g., 6-7)",
        "luster": "Type of luster (e.g., Vitreous, Metallic)",
        "streak": "Color when scraped on unglazed porcelain",
        "transparency": "Transparent, Translucent, or Opaque",
        "crystalSystem": "If applicable (e.g., Cubic, Hexagonal)",
        "cleavage": "If applicable (e.g., Perfect in one direction)",
        "fracture": "Type of fracture if relevant (e.g., Conchoidal)",
        "specificGravity": "Density relative to water (e.g., 2.65)"
      },
      "chemicalProperties": {
        "formula": "Chemical formula if applicable (e.g., SiO2)",
        "composition": "Main chemical components in plain text",
        "elements": [
          {
            "name": "Element name",
            "symbol": "Element symbol",
            "percentage": 80
          }
        ],
        "mineralsPresent": ["Mineral 1", "Mineral 2"],
        "reactivity": "Any notable chemical reactions"
      },
      "formation": {
        "formationType": "Igneous, Sedimentary, Metamorphic, etc.",
        "environment": "Where it typically forms",
        "geologicalAge": "When it commonly formed",
        "commonLocations": ["Location 1", "Location 2"],
        "associatedMinerals": ["Associated Mineral 1", "Associated Mineral 2"],
        "formationProcess": "Brief description of how it forms"
      },
      "uses": {
        "industrial": ["Industrial use 1", "Industrial use 2"],
        "historical": ["Historical use 1", "Historical use 2"],
        "modern": ["Modern use 1", "Modern use 2"],
        "metaphysical": ["Metaphysical property 1", "Metaphysical property 2"],
        "funFacts": ["Interesting fact 1", "Interesting fact 2"]
      }
    }

    STRICT JSON FORMATTING RULES:
    1. Your response MUST be PURE JSON with NO explanatory text, markdown, or code blocks
    2. All property names must be in double quotes: "property": value
    3. All string values must be in double quotes: "property": "value"
    4. Numeric values should not have quotes: "confidence": 0.95
    5. No trailing commas at the end of arrays or objects
    6. If a property has no value, use null instead of an empty string: "formula": null
    7. Always use "uses" for the uses object
    8. Ensure that all nested objects and arrays are properly closed

    If you can't identify the specimen with reasonable confidence, or if the image isn't a rock/mineral, respond with:
    {
      "error": "Specific reason for identification failure",
      "suggestions": ["Suggestion 1", "Suggestion 2"]
    }
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
                "content": "Identify this rock or mineral and provide all details in the required JSON format.",
                "message": "Identify this rock or mineral and provide all details in the required JSON format.",
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
        let hash = createHash(from: messagesString + sharedSecretKey)
        
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
    
    // Helper function to create MD5 hash
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
        
        // Extract JSON from markdown code blocks or any surrounding text
        let processedJsonString = extractJsonFromResponse(jsonString)
        
        do {
            print("Attempting to parse JSON: \(processedJsonString.prefix(200))")
            
            // Try to decode with the standard decoder first
            let decoder = JSONDecoder()
            
            if let jsonData = processedJsonString.data(using: .utf8) {
                do {
                    let response = try decoder.decode(IdentificationResponse.self, from: jsonData)
                    print("Successfully parsed complete JSON response")
                    // Successfully parsed
                    createSuccessResult(response: response, originalImage: originalImage)
                    return
                } catch let error {
                    print("Standard JSON parsing failed: \(error)")
                }
            }
            
            // If standard parsing fails, try with various fallback methods
            
            // Method 1: Try to clean the JSON string
            let cleanedJson = cleanJsonString(processedJsonString)
            if let jsonData = cleanedJson.data(using: .utf8),
               let response = try? decoder.decode(IdentificationResponse.self, from: jsonData) {
                // Successfully parsed with cleaned JSON
                print("Parsed successfully after cleaning JSON")
                createSuccessResult(response: response, originalImage: originalImage)
                return
            }
            
            // Method 2: Try to extract basic info manually
            if let extractedData = extractRockData(from: processedJsonString) {
                // We could extract partial data
                print("Creating partial result from extracted data")
                createPartialResult(extractedData: extractedData, originalImage: originalImage)
                return
            }
            
            // If all parsing attempts failed
            state = .error("Could not parse the rock identification data. Please try again with a clearer image.")
        } catch {
            state = .error("Failed to process result: \(error.localizedDescription)")
        }
    }
    
    // Helper function to extract JSON from response, eliminating markdown blocks or other text
    private func extractJsonFromResponse(_ response: String) -> String {
        var processedResponse = response
        
        // Remove HTML comments
        if let regex = try? NSRegularExpression(pattern: "<!--.*?-->", options: .dotMatchesLineSeparators) {
            let range = NSRange(processedResponse.startIndex..., in: processedResponse)
            processedResponse = regex.stringByReplacingMatches(in: processedResponse, options: [], range: range, withTemplate: "")
        }
        
        // Extract JSON from markdown code blocks
        if processedResponse.contains("```") {
            let pattern = "```(?:json)?\\s*([\\s\\S]*?)\\s*```"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: processedResponse, range: NSRange(processedResponse.startIndex..., in: processedResponse)) {
                if let range = Range(match.range(at: 1), in: processedResponse) {
                    processedResponse = String(processedResponse[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        // Extract just the JSON object if the response contains other text
        if let startIdx = processedResponse.firstIndex(of: "{"),
           let endIdx = processedResponse.lastIndex(of: "}") {
            let jsonSubstring = processedResponse[startIdx...endIdx]
            processedResponse = String(jsonSubstring)
        }
        
        return processedResponse.trimmingCharacters(in: .whitespacesAndNewlines)
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
        
        // Fix "usees" typo to "uses"
        cleanedJson = cleanedJson.replacingOccurrences(of: "\"usees\"", with: "\"uses\"")
        
        // Fix extra escaped quotes in property names
        cleanedJson = cleanedJson.replacingOccurrences(of: "\\\"", with: "\"")
        
        // Fix trailing commas
        cleanedJson = cleanedJson.replacingOccurrences(of: ",\\s*}", with: "}", options: .regularExpression)
        cleanedJson = cleanedJson.replacingOccurrences(of: ",\\s*]\\s*,", with: "]", options: .regularExpression)
        cleanedJson = cleanedJson.replacingOccurrences(of: ",\\s*]", with: "]", options: .regularExpression)
        
        // Fix trailing commas in arrays (problem in the logs: "elements": [],)
        cleanedJson = cleanedJson.replacingOccurrences(of: "\\[\\s*]\\s*,", with: "[]", options: .regularExpression)
        
        // Fix malformed environment strings (from log: "environment": ": Forms from the...")
        let environmentPattern = "\"environment\"\\s*:\\s*\":\\s*([^\"]+)\""
        cleanedJson = cleanedJson.replacingOccurrences(of: environmentPattern, with: "\"environment\":\"$1\"", options: .regularExpression)
        
        // Fix geologicalAge strings that start with colon
        let geologicalAgePattern = "\"geologicalAge\"\\s*:\\s*\":\\s*([^\"]+)\""
        cleanedJson = cleanedJson.replacingOccurrences(of: geologicalAgePattern, with: "\"geologicalAge\":\"$1\"", options: .regularExpression)
        
        // Fix specificGravity with ~ prefix (make it a string to prevent parsing issues)
        let specificGravityPattern = "\"specificGravity\"\\s*:\\s*\"~([0-9.]+)\""
        cleanedJson = cleanedJson.replacingOccurrences(of: specificGravityPattern, with: "\"specificGravity\":\"~$1\"", options: .regularExpression)
        
        // Fix "null" as strings instead of actual null values
        cleanedJson = cleanedJson.replacingOccurrences(of: ":\\s*\"null\"", with: ":null", options: .regularExpression)
        
        // Fix empty arrays with nulls [null] -> []
        cleanedJson = cleanedJson.replacingOccurrences(of: "\\[\\s*null\\s*]", with: "[]", options: .regularExpression)
        
        // Fix string values for numbers (confidence should be a number)
        let numberValuePattern = "\"confidence\"\\s*:\\s*\"([0-9.]+)\""
        cleanedJson = cleanedJson.replacingOccurrences(of: numberValuePattern, with: "\"confidence\":$1", options: .regularExpression)
        
        // Remove any special invisible characters that might cause issues
        let cleanString = cleanedJson.components(separatedBy: CharacterSet.controlCharacters).joined()
        cleanedJson = cleanString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Log the cleaned JSON for debugging
        print("Cleaned JSON: \(cleanedJson.prefix(500))")
        
        // Final attempt to sanitize the JSON through JSONSerialization
        if let jsonData = cleanedJson.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
           let sanitizedData = try? JSONSerialization.data(withJSONObject: jsonObject),
           let sanitizedString = String(data: sanitizedData, encoding: .utf8) {
            print("Sanitized through JSONSerialization successfully")
            return sanitizedString
        }
        
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
            } else {
                // Try alternative regex pattern
                let altNamePattern = "name[\"']?\\s*:\\s*[\"']([^\"']+)[\"']"
                let altNameRegex = try NSRegularExpression(pattern: altNamePattern)
                
                if let match = altNameRegex.firstMatch(in: jsonString, range: nameRange),
                   let valueRange = Range(match.range(at: 1), in: jsonString) {
                    extractedData["name"] = String(jsonString[valueRange])
                }
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
            } else {
                // Try alternative regex pattern
                let altCategoryPattern = "category[\"']?\\s*:\\s*[\"']([^\"']+)[\"']"
                let altCategoryRegex = try NSRegularExpression(pattern: altCategoryPattern)
                
                if let match = altCategoryRegex.firstMatch(in: jsonString, range: categoryRange),
                   let valueRange = Range(match.range(at: 1), in: jsonString) {
                    extractedData["category"] = String(jsonString[valueRange])
                } else {
                    // Default category if not found
                    extractedData["category"] = "Rock"
                }
            }
        } catch {
            print("Error extracting rock category: \(error)")
            // Default category if extraction fails
            extractedData["category"] = "Rock"
        }
        
        // Extract confidence if available
        do {
            let confidencePattern = "\"confidence\"\\s*:\\s*([0-9.]+)"
            let confidenceRegex = try NSRegularExpression(pattern: confidencePattern)
            let confidenceRange = NSRange(jsonString.startIndex..., in: jsonString)
            
            if let match = confidenceRegex.firstMatch(in: jsonString, range: confidenceRange),
               let valueRange = Range(match.range(at: 1), in: jsonString),
               let confidence = Double(jsonString[valueRange]) {
                extractedData["confidence"] = confidence
            } else {
                // Default confidence if not found
                extractedData["confidence"] = 0.7
            }
        } catch {
            print("Error extracting confidence: \(error)")
            // Default confidence if extraction fails
            extractedData["confidence"] = 0.7
        }
        
        // Try to extract color information
        do {
            let colorPattern = "\"color\"\\s*:\\s*\"([^\"]+)\""
            let colorRegex = try NSRegularExpression(pattern: colorPattern)
            let colorRange = NSRange(jsonString.startIndex..., in: jsonString)
            
            if let match = colorRegex.firstMatch(in: jsonString, range: colorRange),
               let valueRange = Range(match.range(at: 1), in: jsonString) {
                extractedData["color"] = String(jsonString[valueRange])
            } else {
                extractedData["color"] = "Various"
            }
        } catch {
            print("Error extracting color: \(error)")
            extractedData["color"] = "Various"
        }
        
        // Try to extract at least one fun fact
        do {
            let funFactsPattern = "\"funFacts\"\\s*:\\s*\\[\\s*\"([^\"]+)\""
            let funFactsRegex = try NSRegularExpression(pattern: funFactsPattern)
            let funFactsRange = NSRange(jsonString.startIndex..., in: jsonString)
            
            if let match = funFactsRegex.firstMatch(in: jsonString, range: funFactsRange),
               let valueRange = Range(match.range(at: 1), in: jsonString) {
                extractedData["funFact"] = String(jsonString[valueRange])
            }
        } catch {
            print("Error extracting fun fact: \(error)")
        }
        
        // Return extracted data if we at least have the name
        return extractedData["name"] != nil ? extractedData : nil
    }
    
    // Create a result with partial data when full parsing fails
    private func createPartialResult(extractedData: [String: Any], originalImage: UIImage) {
        let rockName = extractedData["name"] as? String ?? "Unknown Rock"
        let category = extractedData["category"] as? String ?? "Rock"
        let confidence = extractedData["confidence"] as? Double ?? 0.7
        let color = extractedData["color"] as? String ?? "Varies"
        let funFact = extractedData["funFact"] as? String
        
        // Create minimal physical properties
        let physicalProperties = PhysicalProperties(
            color: color,
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
        var funFacts = ["This rock has been identified as \(rockName) with limited information available."]
        if let fact = funFact {
            funFacts.append(fact)
        }
        
        let uses = Uses(
            industrial: nil,
            historical: nil,
            modern: nil,
            metaphysical: nil,
            funFacts: funFacts
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
        // Create PhysicalProperties from response
        let physicalProperties = PhysicalProperties(
            color: response.physicalProperties.color,
            hardness: response.physicalProperties.hardness,
            luster: response.physicalProperties.luster,
            streak: response.physicalProperties.streak,
            transparency: response.physicalProperties.transparency,
            crystalSystem: response.physicalProperties.crystalSystem,
            cleavage: response.physicalProperties.cleavage,
            fracture: response.physicalProperties.fracture,
            specificGravity: response.physicalProperties.specificGravity,
            additionalProperties: response.physicalProperties.additionalProperties
        )
        
        // Create Elements from response
        let elements = response.chemicalProperties.elements?.compactMap { element in
            // Only create elements with valid data
            if let name = element.name, let symbol = element.symbol {
                return Element(
                    name: name,
                    symbol: symbol,
                    percentage: element.percentage
                )
            }
            return nil
        }
        
        // Create ChemicalProperties from response
        let chemicalProperties = ChemicalProperties(
            formula: response.chemicalProperties.formula,
            composition: response.chemicalProperties.composition,
            elements: elements,
            mineralsPresent: response.chemicalProperties.mineralsPresent,
            reactivity: response.chemicalProperties.reactivity,
            additionalProperties: response.chemicalProperties.additionalProperties
        )
        
        // Create Formation from response
        let formation = Formation(
            formationType: response.formation.formationType,
            environment: response.formation.environment,
            geologicalAge: response.formation.geologicalAge,
            commonLocations: response.formation.commonLocations,
            associatedMinerals: response.formation.associatedMinerals,
            formationProcess: response.formation.formationProcess,
            additionalInfo: response.formation.additionalInfo
        )
        
        // Create Uses from response
        let uses = Uses(
            industrial: response.uses.industrial,
            historical: response.uses.historical,
            modern: response.uses.modern,
            metaphysical: response.uses.metaphysical,
            funFacts: response.uses.funFacts,
            additionalUses: response.uses.additionalUses
        )
        
        // Create the final RockIdentificationResult
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
        
        // Update state with success
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
    let additionalProperties: [String: String]?
}

struct ChemicalPropertiesResponse: Codable {
    let formula: String?
    let composition: String
    let elements: [ElementResponse]?
    let mineralsPresent: [String]?
    let reactivity: String?
    let additionalProperties: [String: String]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        formula = try container.decodeIfPresent(String.self, forKey: .formula)
        composition = try container.decode(String.self, forKey: .composition)
        reactivity = try container.decodeIfPresent(String.self, forKey: .reactivity)
        additionalProperties = try container.decodeIfPresent([String: String].self, forKey: .additionalProperties)
        
        // Handle minerals present array which might contain nulls
        if let mineralsArray = try? container.decodeIfPresent([String?].self, forKey: .mineralsPresent) {
            mineralsPresent = mineralsArray.compactMap { $0 } // Filter out nil values
        } else {
            mineralsPresent = nil
        }
        
        // Handle elements array which might be empty or malformed
        do {
            elements = try container.decodeIfPresent([ElementResponse].self, forKey: .elements)
        } catch {
            print("Error decoding elements array: \(error)")
            elements = []
        }
    }
}

struct ElementResponse: Codable {
    let name: String?
    let symbol: String?
    let percentage: Double?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle optional name and symbol
        name = try container.decodeIfPresent(String.self, forKey: .name)
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
        
        // Handle percentage that might be a string or double
        if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: .percentage) {
            percentage = doubleValue
        } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .percentage) {
            // Try to convert string to double
            percentage = Double(stringValue.replacingOccurrences(of: "~", with: "").trimmingCharacters(in: .whitespaces))
        } else {
            percentage = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name, symbol, percentage
    }
}

struct FormationResponse: Codable {
    let formationType: String
    let environment: String
    let geologicalAge: String?
    let commonLocations: [String]?
    let associatedMinerals: [String]?
    let formationProcess: String
    let additionalInfo: [String: String]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        formationType = try container.decode(String.self, forKey: .formationType)
        environment = try container.decode(String.self, forKey: .environment)
        geologicalAge = try container.decodeIfPresent(String.self, forKey: .geologicalAge)
        formationProcess = try container.decode(String.self, forKey: .formationProcess)
        additionalInfo = try container.decodeIfPresent([String: String].self, forKey: .additionalInfo)
        
        // Handle commonLocations array which might contain nulls
        if let locationsArray = try? container.decodeIfPresent([String?].self, forKey: .commonLocations) {
            commonLocations = locationsArray.compactMap { $0 } // Filter out nil values
        } else {
            commonLocations = nil
        }
        
        // Handle associatedMinerals array which might contain nulls
        if let mineralsArray = try? container.decodeIfPresent([String?].self, forKey: .associatedMinerals) {
            associatedMinerals = mineralsArray.compactMap { $0 } // Filter out nil values
        } else {
            associatedMinerals = nil
        }
    }
}

struct UsesResponse: Codable {
    let industrial: [String]?
    let historical: [String]?
    let modern: [String]?
    let metaphysical: [String]?
    let funFacts: [String]
    let additionalUses: [String: String]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle arrays that might contain nulls
        if let industrialArray = try? container.decodeIfPresent([String?].self, forKey: .industrial) {
            industrial = industrialArray.compactMap { $0 }
        } else {
            industrial = nil
        }
        
        if let historicalArray = try? container.decodeIfPresent([String?].self, forKey: .historical) {
            historical = historicalArray.compactMap { $0 }
        } else {
            historical = nil
        }
        
        if let modernArray = try? container.decodeIfPresent([String?].self, forKey: .modern) {
            modern = modernArray.compactMap { $0 }
        } else {
            modern = nil
        }
        
        if let metaphysicalArray = try? container.decodeIfPresent([String?].self, forKey: .metaphysical) {
            metaphysical = metaphysicalArray.compactMap { $0 }
        } else {
            metaphysical = nil
        }
        
        additionalUses = try container.decodeIfPresent([String: String].self, forKey: .additionalUses)
        
        // Required field with no nulls allowed - handle this last to avoid multiple initialization
        if let factsArray = try? container.decode([String?].self, forKey: .funFacts) {
            let filtered = factsArray.compactMap { $0 }
            funFacts = filtered.isEmpty ? ["No additional information available."] : filtered
        } else {
            funFacts = ["No additional information available."]
        }
    }
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
