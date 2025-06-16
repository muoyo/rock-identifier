# **Rules-Based Rock Identification - Implementation Guide**

## **Overview**
This guide outlines how to implement a rules-based rock identification system using basic computer vision and expert geological knowledge. This approach uses image analysis combined with rule-based matching against a comprehensive rock characteristics database.

## **Architecture Overview**

```
Identification Pipeline:
User Image → Image Analysis → Feature Extraction → Rule-Based Matching → Confidence Scoring → Result Display

Database Structure:
Rock Database → Physical Characteristics → Visual Features → Identification Rules → Matching Algorithm
```

---

## **Phase 1: Database Design & Rock Characteristics**

### **1.1 Rock Database Schema**

```swift
// LocalRock.swift - Core data structure
struct LocalRock: Codable {
    let id: UUID
    let name: String
    let category: RockCategory
    let alternateNames: [String]
    
    // Physical characteristics for identification
    let identificationFeatures: IdentificationFeatures
    let physicalProperties: PhysicalProperties
    let chemicalProperties: ChemicalProperties
    let formation: Formation
    let uses: Uses
}

struct IdentificationFeatures: Codable {
    // Color analysis
    let primaryColors: [ColorRange]
    let secondaryColors: [ColorRange]
    let colorVariations: [String]
    
    // Texture characteristics
    let textureType: TextureType
    let grainSize: GrainSize
    let surfaceFinish: SurfaceFinish
    
    // Visual patterns
    let hasLayering: Bool
    let hasBanding: Bool
    let hasSpeckles: Bool
    let hasCrystals: Bool
    let hasGlossyAreas: Bool
    
    // Shape and form
    let commonShapes: [RockShape]
    let breakagePattern: BreakagePattern
    
    // Distinguishing features
    let uniqueFeatures: [String]
    let commonMistakes: [String] // What it's often confused with
    
    // Identification confidence modifiers
    let easyToIdentify: Bool
    let requiresExpertise: Bool
    let variableAppearance: Bool
}

enum ColorRange: String, Codable {
    case black, darkGray, lightGray, white
    case darkBrown, lightBrown, tan, beige
    case darkRed, lightRed, pink, orange
    case darkGreen, lightGreen, olive
    case darkBlue, lightBlue, purple
    case yellow, gold, silver, metallic
}

enum TextureType: String, Codable {
    case smooth, rough, granular, crystalline
    case layered, foliated, vesicular, glassy
    case fibrous, massive, porous, dense
}

enum GrainSize: String, Codable {
    case finegrained, mediumgrained, coarsegrained
    case veryfine, verycorse, mixed
}
```

### **1.2 Rock Categories & Common Types**

```swift
// RockDatabase.swift - Comprehensive rock database
class LocalRockDatabase {
    static let shared = LocalRockDatabase()
    private var rocks: [LocalRock] = []
    
    private init() {
        loadRockDatabase()
    }
    
    private func loadRockDatabase() {
        rocks = [
            // IGNEOUS ROCKS
            createGranite(),
            createBasalt(),
            createObsidian(),
            createPumice(),
            createAndesite(),
            createRhyolite(),
            createGabbro(),
            createDiorite(),
            createPegmatite(),
            createTuff(),
            
            // SEDIMENTARY ROCKS  
            createLimestone(),
            createSandstone(),
            createShale(),
            createConglomerate(),
            createMudstone(),
            createSiltstone(),
            createBreccia(),
            createChalk(),
            createTravertine(),
            createCoal(),
            
            // METAMORPHIC ROCKS
            createMarble(),
            createQuartzite(),
            createSlate(),
            createGneiss(),
            createSchist(),
            createPhyllite(),
            createHornfels(),
            createSerpentine(),
            createAmphibolite(),
            createMetaquartzite(),
            
            // COMMON MINERALS
            createQuartz(),
            createCalcite(),
            createPyrite(),
            createHematite(),
            createMagnetite(),
            createFeldspar(),
            createMica(),
            createGypsum(),
            createFluorite(),
            createGarnet()
            // ... continue for all 300 rocks
        ]
    }
    
    // Example implementation for Granite
    private func createGranite() -> LocalRock {
        return LocalRock(
            id: UUID(),
            name: "Granite",
            category: .igneous,
            alternateNames: ["Granitic Rock", "Granite Gneiss"],
            identificationFeatures: IdentificationFeatures(
                primaryColors: [.lightGray, .darkGray, .white, .pink],
                secondaryColors: [.black, .darkBrown, .silver],
                colorVariations: ["Pink granite", "Gray granite", "White granite", "Black granite"],
                textureType: .granular,
                grainSize: .coarsegrained,
                surfaceFinish: .rough,
                hasLayering: false,
                hasBanding: false,
                hasSpeckles: true,
                hasCrystals: true,
                hasGlossyAreas: true,
                commonShapes: [.angular, .blocky, .irregular],
                breakagePattern: .irregular,
                uniqueFeatures: [
                    "Visible quartz crystals",
                    "Dark mica flakes",
                    "Feldspar crystals",
                    "Salt and pepper appearance",
                    "Hard and durable"
                ],
                commonMistakes: ["Gneiss", "Quartzite", "Light-colored sandstone"],
                easyToIdentify: true,
                requiresExpertise: false,
                variableAppearance: true
            ),
            physicalProperties: PhysicalProperties(
                color: "Gray, pink, white, or black with speckled appearance",
                hardness: "6-7 (Hard)",
                luster: "Vitreous to dull",
                // ... other properties
            ),
            // ... other data
        )
    }
}
```

---

## **Phase 2: Image Analysis Engine**

### **2.1 Core Image Analysis**

```swift
// ImageAnalyzer.swift - Extract features from rock images
import UIKit
import CoreImage
import Accelerate

class ImageAnalyzer {
    
    func analyzeImage(_ image: UIImage) -> ImageFeatures {
        guard let ciImage = CIImage(image: image) else {
            return ImageFeatures.default
        }
        
        // Extract multiple types of features
        let colorFeatures = extractColorFeatures(ciImage)
        let textureFeatures = extractTextureFeatures(ciImage)
        let shapeFeatures = extractShapeFeatures(ciImage)
        let brightnessFeatures = extractBrightnessFeatures(ciImage)
        
        return ImageFeatures(
            dominantColors: colorFeatures.dominantColors,
            colorDistribution: colorFeatures.distribution,
            textureMetrics: textureFeatures,
            brightness: brightnessFeatures.average,
            contrast: brightnessFeatures.contrast,
            sharpness: calculateSharpness(ciImage),
            hasReflectiveAreas: detectReflectiveAreas(ciImage),
            hasLayeredStructure: detectLayers(ciImage),
            surfaceRoughness: calculateSurfaceRoughness(textureFeatures)
        )
    }
}

struct ImageFeatures {
    let dominantColors: [DetectedColor]
    let colorDistribution: ColorDistribution
    let textureMetrics: TextureMetrics
    let brightness: Float
    let contrast: Float
    let sharpness: Float
    let hasReflectiveAreas: Bool
    let hasLayeredStructure: Bool
    let surfaceRoughness: Float
    
    static let `default` = ImageFeatures(
        dominantColors: [],
        colorDistribution: ColorDistribution(),
        textureMetrics: TextureMetrics(),
        brightness: 0.5,
        contrast: 0.5,
        sharpness: 0.5,
        hasReflectiveAreas: false,
        hasLayeredStructure: false,
        surfaceRoughness: 0.5
    )
}
```

### **2.2 Color Analysis**

```swift
extension ImageAnalyzer {
    
    func extractColorFeatures(_ image: CIImage) -> ColorFeatures {
        // Convert to RGB histogram
        let histogram = createColorHistogram(image)
        
        // Find dominant colors
        let dominantColors = findDominantColors(histogram, maxColors: 5)
        
        // Classify colors into geological categories
        let classifiedColors = dominantColors.map { classifyGeologicalColor($0) }
        
        // Calculate color distribution metrics
        let distribution = calculateColorDistribution(histogram)
        
        return ColorFeatures(
            dominantColors: classifiedColors,
            distribution: distribution
        )
    }
    
    private func classifyGeologicalColor(_ color: UIColor) -> DetectedColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Convert to HSV for better geological color classification
        let hsv = rgbToHSV(red: red, green: green, blue: blue)
        
        let geologicalColor = determineGeologicalColor(hsv: hsv, rgb: (red, green, blue))
        
        return DetectedColor(
            color: color,
            geologicalCategory: geologicalColor,
            prominence: calculateColorProminence(color, in: image),
            confidence: calculateColorConfidence(hsv: hsv)
        )
    }
    
    private func determineGeologicalColor(hsv: HSV, rgb: (CGFloat, CGFloat, CGFloat)) -> ColorRange {
        let (h, s, v) = (hsv.hue, hsv.saturation, hsv.value)
        
        // High saturation, low value -> dark colors
        if v < 0.3 {
            if s < 0.2 { return .black }
            if h < 30 || h > 330 { return .darkRed }
            if h < 60 { return .darkBrown }
            if h < 180 { return .darkGreen }
            return .darkBlue
        }
        
        // Low saturation -> grays and whites
        if s < 0.2 {
            if v > 0.8 { return .white }
            if v > 0.6 { return .lightGray }
            if v > 0.4 { return .darkGray }
            return .black
        }
        
        // Color classification by hue
        switch h {
        case 0..<15, 345..<360:   return v > 0.6 ? .lightRed : .darkRed
        case 15..<45:             return v > 0.6 ? .orange : .darkBrown
        case 45..<75:             return v > 0.6 ? .yellow : .darkBrown
        case 75..<165:            return v > 0.6 ? .lightGreen : .darkGreen
        case 165..<255:           return v > 0.6 ? .lightBlue : .darkBlue
        case 255..<285:           return .purple
        case 285..<345:           return v > 0.6 ? .pink : .darkRed
        default:                  return .lightGray
        }
    }
}
```

### **2.3 Texture Analysis**

```swift
extension ImageAnalyzer {
    
    func extractTextureFeatures(_ image: CIImage) -> TextureMetrics {
        // Convert to grayscale for texture analysis
        let grayscaleImage = convertToGrayscale(image)
        
        // Extract texture metrics using multiple approaches
        let glcmMetrics = calculateGLCMFeatures(grayscaleImage)
        let lbpMetrics = calculateLBPFeatures(grayscaleImage)
        let gradientMetrics = calculateGradientFeatures(grayscaleImage)
        
        return TextureMetrics(
            roughness: calculateRoughness(glcmMetrics),
            uniformity: glcmMetrics.uniformity,
            contrast: glcmMetrics.contrast,
            entropy: glcmMetrics.entropy,
            correlation: glcmMetrics.correlation,
            graininess: lbpMetrics.graininess,
            directionality: gradientMetrics.directionality,
            regularity: calculateRegularity(lbpMetrics),
            crystallinity: detectCrystallinePatterns(grayscaleImage)
        )
    }
    
    private func calculateGLCMFeatures(_ image: CIImage) -> GLCMMetrics {
        // Implement Gray-Level Co-occurrence Matrix analysis
        // This analyzes spatial relationships between pixel intensities
        
        let pixels = extractPixelData(image)
        let glcm = computeGLCM(pixels)
        
        return GLCMMetrics(
            contrast: computeContrast(glcm),
            correlation: computeCorrelation(glcm),
            entropy: computeEntropy(glcm),
            uniformity: computeUniformity(glcm),
            homogeneity: computeHomogeneity(glcm)
        )
    }
    
    private func calculateLBPFeatures(_ image: CIImage) -> LBPMetrics {
        // Local Binary Pattern analysis for texture classification
        let lbpHistogram = computeLBPHistogram(image)
        
        return LBPMetrics(
            graininess: calculateGraininess(lbpHistogram),
            directionality: calculateDirectionality(lbpHistogram),
            uniformPatterns: countUniformPatterns(lbpHistogram)
        )
    }
    
    private func detectCrystallinePatterns(_ image: CIImage) -> Float {
        // Look for regular, crystalline structures
        let edgeMap = detectEdges(image)
        let lineSegments = detectLineSegments(edgeMap)
        
        let regularityScore = calculatePatternRegularity(lineSegments)
        let angularityScore = calculateAngularityScore(lineSegments)
        
        return (regularityScore + angularityScore) / 2.0
    }
}
```

### **2.4 Shape and Structure Analysis**

```swift
extension ImageAnalyzer {
    
    func extractShapeFeatures(_ image: CIImage) -> ShapeFeatures {
        // Edge detection for shape analysis
        let edges = detectEdges(image)
        let contours = findContours(edges)
        
        return ShapeFeatures(
            hasAngularFeatures: detectAngularFeatures(contours),
            hasRoundedFeatures: detectRoundedFeatures(contours),
            hasLayering: detectLayeredStructure(image),
            hasBanding: detectBanding(image),
            hasCrystalFaces: detectCrystalFaces(edges),
            surfaceComplexity: calculateSurfaceComplexity(contours)
        )
    }
    
    private func detectLayeredStructure(_ image: CIImage) -> Bool {
        // Look for parallel lines/bands indicating sedimentary layers
        let horizontalLines = detectHorizontalLines(image)
        let parallelSets = findParallelLineSets(horizontalLines)
        
        return parallelSets.count >= 3 // At least 3 parallel layers
    }
    
    private func detectBanding(_ image: CIImage) -> Bool {
        // Look for alternating light/dark bands (metamorphic banding)
        let intensityProfile = calculateVerticalIntensityProfile(image)
        let bands = detectAlternatingBands(intensityProfile)
        
        return bands.count >= 4 // At least 2 complete light-dark cycles
    }
    
    private func detectCrystalFaces(_ edges: CIImage) -> Bool {
        // Look for straight edges and angular intersections
        let lines = detectStraightLines(edges)
        let intersections = findLineIntersections(lines)
        let angles = calculateIntersectionAngles(intersections)
        
        // Crystal faces often meet at specific angles (60°, 90°, 120°)
        let crystallineAngles = angles.filter { angle in
            return isNearCrystallineAngle(angle)
        }
        
        return crystallineAngles.count >= 3
    }
}
```

---

## **Phase 3: Rules-Based Matching Engine**

### **3.1 Core Matching Algorithm**

```swift
// RockMatcher.swift - Main matching logic
class RockMatcher {
    
    func findMatches(for features: ImageFeatures) -> [RockMatch] {
        let allRocks = LocalRockDatabase.shared.getAllRocks()
        
        var matches: [RockMatch] = []
        
        for rock in allRocks {
            let score = calculateMatchScore(features: features, rock: rock)
            let confidence = calculateConfidence(score: score, rock: rock, features: features)
            
            if confidence > 0.3 { // Minimum threshold
                matches.append(RockMatch(
                    rock: rock,
                    score: score,
                    confidence: confidence,
                    matchingFeatures: identifyMatchingFeatures(features, rock),
                    contradictingFeatures: identifyContradictingFeatures(features, rock)
                ))
            }
        }
        
        // Sort by confidence and return top matches
        return matches.sorted { $0.confidence > $1.confidence }
    }
    
    private func calculateMatchScore(features: ImageFeatures, rock: LocalRock) -> Float {
        var totalScore: Float = 0.0
        var weightSum: Float = 0.0
        
        // Color matching (40% weight)
        let colorScore = calculateColorMatch(features.dominantColors, rock.identificationFeatures.primaryColors)
        totalScore += colorScore * 0.4
        weightSum += 0.4
        
        // Texture matching (30% weight)
        let textureScore = calculateTextureMatch(features.textureMetrics, rock.identificationFeatures)
        totalScore += textureScore * 0.3
        weightSum += 0.3
        
        // Structure matching (20% weight)
        let structureScore = calculateStructureMatch(features, rock.identificationFeatures)
        totalScore += structureScore * 0.2
        weightSum += 0.2
        
        // Special features matching (10% weight)
        let specialScore = calculateSpecialFeaturesMatch(features, rock.identificationFeatures)
        totalScore += specialScore * 0.1
        weightSum += 0.1
        
        return totalScore / weightSum
    }
}
```

### **3.2 Color Matching Rules**

```swift
extension RockMatcher {
    
    private func calculateColorMatch(_ detectedColors: [DetectedColor], _ expectedColors: [ColorRange]) -> Float {
        var matchScore: Float = 0.0
        
        // Primary color match
        let primaryMatches = detectedColors.compactMap { detected in
            expectedColors.contains(detected.geologicalCategory) ? detected.prominence : nil
        }
        
        if !primaryMatches.isEmpty {
            matchScore += primaryMatches.max()! * 0.7 // Primary color is 70% of color score
        }
        
        // Secondary color presence
        let secondaryMatches = detectedColors.filter { detected in
            expectedColors.contains(detected.geologicalCategory)
        }
        
        let secondaryBonus = min(Float(secondaryMatches.count) / Float(expectedColors.count), 1.0) * 0.3
        matchScore += secondaryBonus
        
        return matchScore
    }
    
    private func calculateTextureMatch(_ textureMetrics: TextureMetrics, _ rockFeatures: IdentificationFeatures) -> Float {
        var textureScore: Float = 0.0
        
        // Grain size matching
        let grainSizeScore = matchGrainSize(textureMetrics, rockFeatures.grainSize)
        textureScore += grainSizeScore * 0.4
        
        // Surface roughness matching
        let roughnessScore = matchSurfaceRoughness(textureMetrics.roughness, rockFeatures.surfaceFinish)
        textureScore += roughnessScore * 0.3
        
        // Crystallinity matching
        let crystalScore = matchCrystallinity(textureMetrics.crystallinity, rockFeatures.hasCrystals)
        textureScore += crystalScore * 0.3
        
        return textureScore
    }
    
    private func matchGrainSize(_ metrics: TextureMetrics, _ expectedGrainSize: GrainSize) -> Float {
        // Correlate texture analysis results with expected grain size
        switch expectedGrainSize {
        case .finegrained:
            return metrics.uniformity > 0.7 && metrics.graininess < 0.3 ? 1.0 : 0.2
        case .mediumgrained:
            return metrics.graininess > 0.3 && metrics.graininess < 0.7 ? 1.0 : 0.4
        case .coarsegrained:
            return metrics.graininess > 0.7 && metrics.crystallinity > 0.5 ? 1.0 : 0.3
        default:
            return 0.5 // Mixed or unknown
        }
    }
}
```

### **3.3 Structure and Pattern Matching**

```swift
extension RockMatcher {
    
    private func calculateStructureMatch(_ features: ImageFeatures, _ rockFeatures: IdentificationFeatures) -> Float {
        var structureScore: Float = 0.0
        var featureCount = 0
        
        // Layering detection
        if rockFeatures.hasLayering {
            structureScore += features.hasLayeredStructure ? 1.0 : 0.0
            featureCount += 1
        } else {
            structureScore += features.hasLayeredStructure ? 0.0 : 1.0
            featureCount += 1
        }
        
        // Banding detection (metamorphic rocks)
        if rockFeatures.hasBanding {
            structureScore += features.hasBanding ? 1.0 : 0.0
            featureCount += 1
        }
        
        // Crystal visibility
        if rockFeatures.hasCrystals {
            let crystalVisibility = features.textureMetrics.crystallinity
            structureScore += crystalVisibility > 0.6 ? 1.0 : crystalVisibility
            featureCount += 1
        }
        
        // Reflective areas (metallic minerals, glossy surfaces)
        if rockFeatures.hasGlossyAreas {
            structureScore += features.hasReflectiveAreas ? 1.0 : 0.3
            featureCount += 1
        }
        
        return featureCount > 0 ? structureScore / Float(featureCount) : 0.5
    }
    
    private func calculateSpecialFeaturesMatch(_ features: ImageFeatures, _ rockFeatures: IdentificationFeatures) -> Float {
        // Check for unique identifying features
        var specialScore: Float = 0.0
        let uniqueFeatures = rockFeatures.uniqueFeatures
        
        for feature in uniqueFeatures {
            let featureScore = evaluateSpecialFeature(feature, features)
            specialScore += featureScore
        }
        
        return min(specialScore / Float(max(uniqueFeatures.count, 1)), 1.0)
    }
    
    private func evaluateSpecialFeature(_ feature: String, _ imageFeatures: ImageFeatures) -> Float {
        switch feature.lowercased() {
        case "visible quartz crystals":
            return imageFeatures.textureMetrics.crystallinity > 0.7 ? 1.0 : 0.0
            
        case "metallic luster":
            return imageFeatures.hasReflectiveAreas ? 1.0 : 0.0
            
        case "salt and pepper appearance":
            // Look for high contrast speckled pattern
            return imageFeatures.textureMetrics.contrast > 0.6 && imageFeatures.hasSpeckledPattern ? 1.0 : 0.0
            
        case "glassy texture":
            return imageFeatures.surfaceRoughness < 0.3 && imageFeatures.hasReflectiveAreas ? 1.0 : 0.0
            
        case "layered structure":
            return imageFeatures.hasLayeredStructure ? 1.0 : 0.0
            
        case "porous texture":
            return imageFeatures.textureMetrics.porosity > 0.5 ? 1.0 : 0.0
            
        default:
            return 0.5 // Unknown feature
        }
    }
}
```

---

## **Phase 4: Confidence Calculation**

### **4.1 Dynamic Confidence Scoring**

```swift
// ConfidenceCalculator.swift
class ConfidenceCalculator {
    
    func calculateConfidence(score: Float, rock: LocalRock, features: ImageFeatures) -> Float {
        var baseConfidence = score
        
        // Apply rock-specific modifiers
        baseConfidence = applyRockSpecificModifiers(baseConfidence, rock)
        
        // Apply image quality modifiers
        baseConfidence = applyImageQualityModifiers(baseConfidence, features)
        
        // Apply disambiguation logic
        baseConfidence = applyDisambiguationLogic(baseConfidence, rock, features)
        
        // Ensure confidence is within valid range
        return max(0.0, min(1.0, baseConfidence))
    }
    
    private func applyRockSpecificModifiers(_ confidence: Float, _ rock: LocalRock) -> Float {
        var modifiedConfidence = confidence
        
        // Easy to identify rocks get confidence boost
        if rock.identificationFeatures.easyToIdentify {
            modifiedConfidence *= 1.2
        }
        
        // Variable appearance rocks get confidence penalty
        if rock.identificationFeatures.variableAppearance {
            modifiedConfidence *= 0.8
        }
        
        // Rocks requiring expertise get penalty for basic analysis
        if rock.identificationFeatures.requiresExpertise {
            modifiedConfidence *= 0.7
        }
        
        return modifiedConfidence
    }
    
    private func applyImageQualityModifiers(_ confidence: Float, _ features: ImageFeatures) -> Float {
        var modifiedConfidence = confidence
        
        // Poor lighting reduces confidence
        if features.brightness < 0.2 || features.brightness > 0.9 {
            modifiedConfidence *= 0.7
        }
        
        // Low contrast reduces confidence
        if features.contrast < 0.3 {
            modifiedConfidence *= 0.8
        }
        
        // Blurry images reduce confidence
        if features.sharpness < 0.4 {
            modifiedConfidence *= 0.6
        }
        
        // Good image quality boosts confidence
        if features.sharpness > 0.7 && features.contrast > 0.6 {
            modifiedConfidence *= 1.1
        }
        
        return modifiedConfidence
    }
}
```

### **4.2 Common Mistakes Prevention**

```swift
extension ConfidenceCalculator {
    
    private func applyDisambiguationLogic(_ confidence: Float, _ rock: LocalRock, _ features: ImageFeatures) -> Float {
        var adjustedConfidence = confidence
        
        // Check for common misidentifications
        for commonMistake in rock.identificationFeatures.commonMistakes {
            if let mistakeRock = LocalRockDatabase.shared.getRock(named: commonMistake) {
                let mistakeScore = RockMatcher().calculateMatchScore(features: features, rock: mistakeRock)
                
                // If the "mistake" rock scores nearly as well, reduce confidence
                if mistakeScore > (confidence * 0.8) {
                    adjustedConfidence *= 0.8
                }
            }
        }
        
        // Apply specific disambiguation rules
        adjustedConfidence = applySpecificDisambiguationRules(adjustedConfidence, rock, features)
        
        return adjustedConfidence
    }
    
    private func applySpecificDisambiguationRules(_ confidence: Float, _ rock: LocalRock, _ features: ImageFeatures) -> Float {
        var adjustedConfidence = confidence
        
        switch rock.name.lowercased() {
        case "granite":
            // Granite should have visible crystals
            if features.textureMetrics.crystallinity < 0.5 {
                adjustedConfidence *= 0.7
            }
            
        case "marble":
            // Marble should be relatively uniform and have crystalline structure
            if features.textureMetrics.uniformity < 0.6 || features.textureMetrics.crystallinity < 0.4 {
                adjustedConfidence *= 0.8
            }
            
        case "slate":
            // Slate should show clear layering
            if !features.hasLayeredStructure {
                adjustedConfidence *= 0.5
            }
            
        case "obsidian":
            // Obsidian should be very smooth and reflective
            if features.surfaceRoughness > 0.3 || !features.hasReflectiveAreas {
                adjustedConfidence *= 0.6
            }
            
        case "pumice":
            // Pumice should be very porous and light-colored
            if features.textureMetrics.porosity < 0.7 {
                adjustedConfidence *= 0.7
            }
            
        default:
            break
        }
        
        return adjustedConfidence
    }
}
```

---

## **Phase 5: Integration with Identification Service**

### **5.1 Enhanced Identification Service**

```swift
// Enhanced RockIdentificationService.swift
class RockIdentificationService: ObservableObject {
    @Published var state: IdentificationState = .idle
    @Published var currentImage: UIImage?
    
    private let imageAnalyzer = ImageAnalyzer()
    private let rockMatcher = RockMatcher()
    private let confidenceCalculator = ConfidenceCalculator()
    
    func identifyRock(from image: UIImage) {
        state = .processing
        currentImage = image
        
        let subscriptionStatus = SubscriptionManager.shared?.status
        
        switch subscriptionStatus?.plan {
        case .free:
            identifyWithRulesEngine(image, allowAPIFallback: false)
        case .premium:
            identifyWithRulesEngine(image, allowAPIFallback: false)
        case .premiumPlus:
            identifyWithRulesEngine(image, allowAPIFallback: true)
        default:
            identifyWithRulesEngine(image, allowAPIFallback: false)
        }
    }
    
    private func identifyWithRulesEngine(_ image: UIImage, allowAPIFallback: Bool) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Step 1: Analyze image features
            let features = self.imageAnalyzer.analyzeImage(image)
            
            // Step 2: Find matching rocks
            let matches = self.rockMatcher.findMatches(for: features)
            
            DispatchQueue.main.async {
                if let bestMatch = matches.first {
                    if bestMatch.confidence > 0.6 || !allowAPIFallback {
                        // Use rules-based result
                        let result = self.createRockResult(from: bestMatch, image: image, source: .rulesEngine)
                        self.state = .success(result)
                        HapticManager.shared.successFeedback()
                    } else {
                        // Fallback to OpenAI API for low confidence
                        print("Low confidence (\(bestMatch.confidence)), falling back to OpenAI API")
                        self.identifyWithOpenAI(image)
                    }
                } else {
                    // No matches found
                    if allowAPIFallback {
                        self.identifyWithOpenAI(image)
                    } else {
                        self.state = .error("Unable to identify this specimen. Try taking a photo with better lighting or from a different angle.")
                    }
                }
            }
        }
    }
    
    private func createRockResult(from match: RockMatch, image: UIImage, source: IdentificationSource) -> RockIdentificationResult {
        return RockIdentificationResult(
            image: image,
            name: match.rock.name,
            category: match.rock.category.rawValue,
            confidence: Double(match.confidence),
            physicalProperties: match.rock.physicalProperties,
            chemicalProperties: match.rock.chemicalProperties,
            formation: match.rock.formation,
            uses: match.rock.uses,
            identificationSource: source,
            matchingFeatures: match.matchingFeatures,
            alternativeNames: match.rock.alternateNames
        )
    }
}
```

### **5.2 Result Enhancement**

```swift
// Enhanced result with explanation
extension RockIdentificationResult {
    var identificationExplanation: String {
        guard let matchingFeatures = matchingFeatures else {
            return "Identified based on visual characteristics."
        }
        
        var explanation = "Identified based on: "
        let features = matchingFeatures.prefix(3).map { $0.description }
        explanation += features.joined(separator: ", ")
        
        if confidence < 0.8 {
            explanation += ". Consider taking additional photos from different angles for better accuracy."
        }
        
        return explanation
    }
    
    var confidenceDescription: String {
        switch confidence {
        case 0.9...1.0:
            return "Very High Confidence"
        case 0.75..<0.9:
            return "High Confidence"
        case 0.6..<0.75:
            return "Moderate Confidence"
        case 0.4..<0.6:
            return "Low Confidence"
        default:
            return "Very Low Confidence"
        }
    }
}
```

---

## **Phase 6: Performance Optimization**

### **6.1 Image Processing Optimization**

```swift
// OptimizedImageProcessor.swift
class OptimizedImageProcessor {
    
    private let processingQueue = DispatchQueue(label: "image.processing", qos: .userInitiated)
    private let imageCache = NSCache<NSString, CIImage>()
    
    func processImageOptimized(_ image: UIImage, completion: @escaping (ImageFeatures) -> Void) {
        processingQueue.async {
            // Step 1: Optimize image size
            let optimizedImage = self.optimizeImageSize(image)
            
            // Step 2: Cache intermediate results
            let cacheKey = self.generateCacheKey(optimizedImage)
            
            if let cachedFeatures = self.getCachedFeatures(cacheKey) {
                DispatchQueue.main.async {
                    completion(cachedFeatures)
                }
                return
            }
            
            // Step 3: Process with optimized algorithms
            let features = self.extractFeaturesOptimized(optimizedImage)
            
            // Step 4: Cache results
            self.cacheFeatures(features, forKey: cacheKey)
            
            DispatchQueue.main.async {
                completion(features)
            }
        }
    }
    
    private func optimizeImageSize(_ image: UIImage) -> UIImage {
        // Resize to optimal size for analysis (smaller = faster)
        let targetSize = CGSize(width: 512, height: 512)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
}
```

### **6.2 Database Query Optimization**

```swift
// Optimized database queries
extension LocalRockDatabase {
    
    private var colorIndex: [ColorRange: [LocalRock]] = [:]
    private var textureIndex: [TextureType: [LocalRock]] = [:]
    private var categoryIndex: [RockCategory: [LocalRock]] = [:]
    
    func buildIndices() {
        // Build lookup indices for faster querying
        for rock in rocks {
            // Color index
            for color in rock.identificationFeatures.primaryColors {
                colorIndex[color, default: []].append(rock)
            }
            
            // Texture index
            textureIndex[rock.identificationFeatures.textureType, default: []].append(rock)
            
            // Category index
            categoryIndex[rock.category, default: []].append(rock)
        }
    }
    
    func getCandidateRocks(for features: ImageFeatures) -> [LocalRock] {
        var candidates = Set<LocalRock>()
        
        // Get rocks matching dominant colors
        for detectedColor in features.dominantColors {
            if let colorMatches = colorIndex[detectedColor.geologicalCategory] {
                candidates.formUnion(colorMatches)
            }
        }
        
        // If too few candidates, expand search
        if candidates.count < 10 {
            // Add all rocks from relevant categories
            for category in RockCategory.allCases {
                if let categoryMatches = categoryIndex[category] {
                    candidates.formUnion(categoryMatches.prefix(50))
                }
            }
        }
        
        return Array(candidates)
    }
}
```

---

## **Phase 7: Testing & Validation**

### **7.1 Accuracy Testing Framework**

```swift
// RulesEngineTestSuite.swift
class RulesEngineTestSuite {
    
    func runAccuracyTests() {
        let testCases = loadTestCases()
        var results: [TestResult] = []
        
        for testCase in testCases {
            let prediction = identifyRock(testCase.image)
            let result = TestResult(
                testCase: testCase,
                prediction: prediction,
                isCorrect: prediction.name == testCase.expectedName,
                confidence: prediction.confidence
            )
            results.append(result)
        }
        
        printAccuracyReport(results)
    }
    
    private func printAccuracyReport(_ results: [TestResult]) {
        let totalTests = results.count
        let correctPredictions = results.filter { $0.isCorrect }.count
        let accuracy = Double(correctPredictions) / Double(totalTests)
        
        print("=== Rules Engine Accuracy Report ===")
        print("Total Tests: \(totalTests)")
        print("Correct Predictions: \(correctPredictions)")
        print("Overall Accuracy: \(String(format: "%.2f%%", accuracy * 100))")
        
        // Accuracy by rock category
        let categoryAccuracy = calculateCategoryAccuracy(results)
        for (category, acc) in categoryAccuracy {
            print("\(category): \(String(format: "%.2f%%", acc * 100))")
        }
        
        // Confidence analysis
        let highConfidenceResults = results.filter { $0.confidence > 0.7 }
        let highConfidenceAccuracy = Double(highConfidenceResults.filter { $0.isCorrect }.count) / Double(highConfidenceResults.count)
        print("High Confidence Accuracy: \(String(format: "%.2f%%", highConfidenceAccuracy * 100))")
    }
}
```

### **7.2 Performance Benchmarking**

```swift
class PerformanceBenchmark {
    
    func runPerformanceTests() {
        let testImages = loadTestImages()
        var totalTime: TimeInterval = 0
        
        for image in testImages {
            let startTime = CFAbsoluteTimeGetCurrent()
            let _ = identifyRock(image)
            let endTime = CFAbsoluteTimeGetCurrent()
            
            totalTime += (endTime - startTime)
        }
        
        let averageTime = totalTime / Double(testImages.count)
        
        print("=== Performance Benchmark ===")
        print("Test Images: \(testImages.count)")
        print("Total Time: \(String(format: "%.2f", totalTime))s")
        print("Average Time: \(String(format: "%.2f", averageTime))s per identification")
        print("Target: < 3.0s per identification")
        
        if averageTime < 3.0 {
            print("✅ Performance target met")
        } else {
            print("❌ Performance optimization needed")
        }
    }
}
```

---

## **Expected Outcomes**

### **Performance Targets:**
- **Accuracy**: 70-80% for common rocks, 60-70% overall
- **Speed**: <3 seconds per identification
- **Database Size**: ~2-5MB total
- **Cost**: Zero variable costs for identification

### **Advantages:**
- **Fast implementation**: 4-6 weeks vs 10-14 weeks for AI model
- **Small storage footprint**: <5MB vs 50-60MB
- **Instant processing**: No model loading delays
- **Transparent logic**: Can explain why identifications were made
- **Easy to debug**: Clear rule-based logic

### **Limitations:**
- **Lower accuracy**: 70-80% vs 85-90% for AI model
- **Limited to common features**: Cannot detect subtle patterns
- **Brittle**: May fail on unusual lighting or angles
- **Maintenance intensive**: Rules need manual tuning

### **Best Use Cases:**
- **Common rocks**: Granite, limestone, quartz, etc.
- **Distinctive features**: Strong color/texture differences
- **Good lighting conditions**: Clear, well-lit photos
- **Educational use**: Learning about rock characteristics

---

## **Implementation Timeline**

| Week | Phase | Deliverables |
|------|-------|-------------|
| 1 | Database Design | Rock characteristics database, 100 core rocks |
| 2 | Image Analysis | Color, texture, shape analysis algorithms |
| 3 | Matching Engine | Rules-based matching and confidence calculation |
| 4 | Integration | Service integration, UI updates |
| 5 | Testing | Accuracy testing, performance optimization |
| 6 | Polish | Edge case handling, user experience refinement |

---

## **Next Steps**

1. **Create rock characteristics database** for 100 most common rocks
2. **Implement basic image analysis** for color and texture
3. **Build matching algorithm** with confidence scoring
4. **Test with sample images** and refine rules
5. **Integrate with existing app** architecture

This rules-based approach provides a fast, cost-effective solution that delivers good accuracy for common rocks while maintaining zero variable costs for the Premium tier.
