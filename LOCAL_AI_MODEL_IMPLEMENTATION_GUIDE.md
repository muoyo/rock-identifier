# **Local AI Model for Rock Identification - Implementation Guide**

## **Overview**
This guide outlines how to train, deploy, and integrate a local AI model for rock identification in the Rock Identifier app. The model will be stored locally using Core ML, providing accurate identification without API costs.

## **Architecture Overview**

```
Training Pipeline:
Raw Images → Data Preprocessing → Model Training → Core ML Conversion → iOS Integration

Runtime Pipeline:
User Image → Preprocessing → Core ML Model → Confidence Scores → Result Display
```

---

## **Phase 1: Data Collection & Preparation**

### **1.1 Data Requirements**
**Target Dataset Size:**
- **300 rock types** × **200-500 images each** = **60,000-150,000 images**
- **Minimum viable**: 100 images per rock type
- **Optimal**: 300-500 images per rock type

**Image Diversity Requirements:**
- **Lighting conditions**: Natural light, artificial light, shadows
- **Angles**: Multiple viewpoints, close-ups, distant shots
- **Backgrounds**: Different surfaces, hands, collection trays
- **Conditions**: Fresh, weathered, broken surfaces
- **Sizes**: Various specimen sizes from pebbles to boulders

### **1.2 Data Sources**

**Primary Sources:**
- **Geological surveys**: USGS, state geological surveys
- **Museum collections**: Smithsonian, university collections
- **Academic databases**: Mindat.org, university geology departments
- **Rock collecting communities**: Forums, Facebook groups, Reddit
- **Personal collection**: Crowdsourced from beta users

**Secondary Sources:**
- **Scientific papers**: Figures and photos from research
- **Educational websites**: Geology.com, university resources
- **Stock photo sites**: Getty Images, Shutterstock (with proper licensing)

### **1.3 Data Preparation Pipeline**

**Step 1: Image Collection**
```python
# Automated web scraping script
import requests
from bs4 import BeautifulSoup
import json

def collect_rock_images(rock_name, max_images=500):
    """
    Collect images for a specific rock type from multiple sources
    """
    images = []
    
    # Source 1: Mindat.org
    mindat_images = scrape_mindat(rock_name)
    images.extend(mindat_images)
    
    # Source 2: USGS collections
    usgs_images = scrape_usgs(rock_name)
    images.extend(usgs_images)
    
    # Source 3: University databases
    edu_images = scrape_edu_databases(rock_name)
    images.extend(edu_images)
    
    return images[:max_images]
```

**Step 2: Image Preprocessing**
```python
import cv2
import numpy as np
from PIL import Image

def preprocess_image(image_path, target_size=(224, 224)):
    """
    Standardize images for training
    """
    # Load image
    image = cv2.imread(image_path)
    
    # Resize while maintaining aspect ratio
    image = resize_with_padding(image, target_size)
    
    # Normalize pixel values
    image = image.astype(np.float32) / 255.0
    
    # Data augmentation
    augmented_images = apply_augmentation(image)
    
    return augmented_images

def apply_augmentation(image):
    """
    Generate multiple variations of each image
    """
    variations = []
    
    # Original
    variations.append(image)
    
    # Rotation
    for angle in [-15, -10, -5, 5, 10, 15]:
        rotated = rotate_image(image, angle)
        variations.append(rotated)
    
    # Brightness adjustment
    for factor in [0.7, 0.8, 1.2, 1.3]:
        brightened = adjust_brightness(image, factor)
        variations.append(brightened)
    
    # Color temperature adjustment
    for temp in ['warm', 'cool']:
        adjusted = adjust_color_temperature(image, temp)
        variations.append(adjusted)
    
    return variations
```

**Step 3: Data Validation & Cleaning**
```python
def validate_dataset():
    """
    Ensure data quality and remove problematic images
    """
    issues = []
    
    for rock_type in rock_types:
        images = get_images_for_type(rock_type)
        
        # Check minimum count
        if len(images) < 100:
            issues.append(f"{rock_type}: Only {len(images)} images")
        
        # Check for duplicates
        duplicates = find_duplicates(images)
        if duplicates:
            issues.append(f"{rock_type}: {len(duplicates)} duplicates found")
        
        # Check image quality
        low_quality = check_image_quality(images)
        if low_quality:
            issues.append(f"{rock_type}: {len(low_quality)} low quality images")
    
    return issues
```

---

## **Phase 2: Model Training**

### **2.1 Model Architecture Options**

**Option 1: Transfer Learning (Recommended)**
```python
import tensorflow as tf
from tensorflow.keras import layers, models

def create_rock_classifier(num_classes=300):
    """
    Create model using transfer learning with MobileNetV3
    """
    # Use MobileNetV3 as base (optimized for mobile)
    base_model = tf.keras.applications.MobileNetV3Large(
        input_shape=(224, 224, 3),
        include_top=False,
        weights='imagenet'
    )
    
    # Freeze base model initially
    base_model.trainable = False
    
    # Add custom classification head
    model = models.Sequential([
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.Dropout(0.2),
        layers.Dense(512, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(num_classes, activation='softmax')
    ])
    
    return model
```

**Option 2: Custom CNN Architecture**
```python
def create_custom_rock_cnn(num_classes=300):
    """
    Custom CNN optimized for rock texture and color analysis
    """
    model = models.Sequential([
        # Color analysis branch
        layers.Conv2D(32, (3, 3), activation='relu', input_shape=(224, 224, 3)),
        layers.MaxPooling2D((2, 2)),
        
        # Texture analysis branch
        layers.Conv2D(64, (3, 3), activation='relu'),
        layers.MaxPooling2D((2, 2)),
        
        # Pattern recognition
        layers.Conv2D(128, (3, 3), activation='relu'),
        layers.MaxPooling2D((2, 2)),
        
        # Feature combination
        layers.Flatten(),
        layers.Dense(512, activation='relu'),
        layers.Dropout(0.5),
        layers.Dense(num_classes, activation='softmax')
    ])
    
    return model
```

### **2.2 Training Pipeline**

**Step 1: Data Loading**
```python
def create_data_generators():
    """
    Create training and validation data generators
    """
    train_datagen = tf.keras.preprocessing.image.ImageDataGenerator(
        rescale=1./255,
        rotation_range=20,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='nearest'
    )
    
    validation_datagen = tf.keras.preprocessing.image.ImageDataGenerator(
        rescale=1./255
    )
    
    train_generator = train_datagen.flow_from_directory(
        'data/train',
        target_size=(224, 224),
        batch_size=32,
        class_mode='categorical'
    )
    
    validation_generator = validation_datagen.flow_from_directory(
        'data/validation',
        target_size=(224, 224),
        batch_size=32,
        class_mode='categorical'
    )
    
    return train_generator, validation_generator
```

**Step 2: Training Configuration**
```python
def train_model():
    """
    Complete training pipeline
    """
    # Create model
    model = create_rock_classifier(num_classes=300)
    
    # Compile model
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
        loss='categorical_crossentropy',
        metrics=['accuracy', 'top_5_accuracy']
    )
    
    # Setup callbacks
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_accuracy',
            patience=10,
            restore_best_weights=True
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.2,
            patience=5,
            min_lr=0.0001
        ),
        tf.keras.callbacks.ModelCheckpoint(
            'models/rock_classifier_best.h5',
            monitor='val_accuracy',
            save_best_only=True
        )
    ]
    
    # Load data
    train_gen, val_gen = create_data_generators()
    
    # Train model
    history = model.fit(
        train_gen,
        epochs=50,
        validation_data=val_gen,
        callbacks=callbacks
    )
    
    return model, history
```

**Step 3: Fine-tuning**
```python
def fine_tune_model(model, train_gen, val_gen):
    """
    Fine-tune the pre-trained layers for better accuracy
    """
    # Unfreeze base model
    model.layers[0].trainable = True
    
    # Use lower learning rate for fine-tuning
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
        loss='categorical_crossentropy',
        metrics=['accuracy', 'top_5_accuracy']
    )
    
    # Continue training
    fine_tune_history = model.fit(
        train_gen,
        epochs=20,
        validation_data=val_gen,
        initial_epoch=50
    )
    
    return model, fine_tune_history
```

### **2.3 Model Evaluation**

```python
def evaluate_model(model, test_generator):
    """
    Comprehensive model evaluation
    """
    # Basic metrics
    test_loss, test_accuracy, test_top5 = model.evaluate(test_generator)
    
    # Confusion matrix
    predictions = model.predict(test_generator)
    y_pred = np.argmax(predictions, axis=1)
    y_true = test_generator.classes
    
    cm = confusion_matrix(y_true, y_pred)
    
    # Per-class accuracy
    class_accuracy = cm.diagonal() / cm.sum(axis=1)
    
    # Identify problematic classes
    low_accuracy_classes = np.where(class_accuracy < 0.7)[0]
    
    return {
        'test_accuracy': test_accuracy,
        'test_top5_accuracy': test_top5,
        'confusion_matrix': cm,
        'class_accuracy': class_accuracy,
        'problematic_classes': low_accuracy_classes
    }
```

---

## **Phase 3: Core ML Conversion**

### **3.1 Model Conversion Pipeline**

```python
import coremltools as ct

def convert_to_coreml(keras_model):
    """
    Convert trained Keras model to Core ML format
    """
    # Convert to Core ML
    coreml_model = ct.convert(
        keras_model,
        inputs=[ct.ImageType(
            name="input_image",
            shape=(1, 224, 224, 3),
            bias=[-1, -1, -1],
            scale=1/127.5
        )],
        classifier_config=ct.ClassifierConfig(
            class_labels=get_class_labels()
        )
    )
    
    # Add metadata
    coreml_model.short_description = "Rock and Mineral Identification Model"
    coreml_model.input_description["input_image"] = "Rock image to identify"
    coreml_model.output_description["classLabel"] = "Predicted rock type"
    coreml_model.output_description["classLabelProbs"] = "Confidence scores"
    
    # Add version info
    coreml_model.version = "1.0"
    coreml_model.author = "Rock Identifier Team"
    
    return coreml_model
```

### **3.2 Model Optimization**

```python
def optimize_for_mobile(coreml_model):
    """
    Optimize model for mobile deployment
    """
    # Quantize model to reduce size
    quantized_model = ct.models.neural_network.quantization_utils.quantize_weights(
        coreml_model, 
        nbits=8  # 8-bit quantization
    )
    
    # Compress model
    compressed_model = ct.compression_utils.compress_weights(
        quantized_model,
        compression_type='sparsity'
    )
    
    return compressed_model
```

### **3.3 Testing Core ML Model**

```python
def test_coreml_model(model_path, test_images):
    """
    Test Core ML model performance
    """
    import coremltools as ct
    
    # Load model
    model = ct.models.MLModel(model_path)
    
    results = []
    
    for image_path, true_label in test_images:
        # Preprocess image
        image = preprocess_for_coreml(image_path)
        
        # Make prediction
        prediction = model.predict({'input_image': image})
        
        # Extract results
        predicted_label = prediction['classLabel']
        confidence = prediction['classLabelProbs'][predicted_label]
        
        results.append({
            'image': image_path,
            'true_label': true_label,
            'predicted_label': predicted_label,
            'confidence': confidence,
            'correct': predicted_label == true_label
        })
    
    # Calculate accuracy
    accuracy = sum(r['correct'] for r in results) / len(results)
    
    return results, accuracy
```

---

## **Phase 4: iOS Integration**

### **4.1 Core ML Integration**

```swift
// RockClassifierModel.swift
import CoreML
import Vision
import UIKit

class RockClassifierModel {
    private var model: VNCoreMLModel?
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        guard let modelURL = Bundle.main.url(forResource: "RockClassifier", withExtension: "mlmodelc") else {
            print("Failed to find RockClassifier.mlmodelc")
            return
        }
        
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            model = try VNCoreMLModel(for: mlModel)
        } catch {
            print("Failed to load Core ML model: \(error)")
        }
    }
    
    func classify(_ image: UIImage, completion: @escaping (RockClassificationResult?) -> Void) {
        guard let model = model else {
            completion(nil)
            return
        }
        
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Classification error: \(error)")
                completion(nil)
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                completion(nil)
                return
            }
            
            let classificationResult = self.processResults(results)
            completion(classificationResult)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform classification: \(error)")
            completion(nil)
        }
    }
    
    private func processResults(_ observations: [VNClassificationObservation]) -> RockClassificationResult {
        let topPredictions = Array(observations.prefix(5))
        
        return RockClassificationResult(
            topPrediction: topPredictions.first!,
            allPredictions: topPredictions,
            confidence: topPredictions.first!.confidence
        )
    }
}
```

### **4.2 Results Processing**

```swift
// RockClassificationResult.swift
import Vision

struct RockClassificationResult {
    let topPrediction: VNClassificationObservation
    let allPredictions: [VNClassificationObservation]
    let confidence: Float
    
    var rockName: String {
        return topPrediction.identifier
    }
    
    var isHighConfidence: Bool {
        return confidence > 0.7
    }
    
    var shouldFallbackToAPI: Bool {
        return confidence < 0.6
    }
}
```

### **4.3 Enhanced Identification Service**

```swift
// Enhanced RockIdentificationService.swift
class RockIdentificationService: ObservableObject {
    @Published var state: IdentificationState = .idle
    @Published var currentImage: UIImage?
    
    private let localModel = RockClassifierModel()
    private let connectionRequest = ConnectionRequest()
    
    func identifyRock(from image: UIImage) {
        state = .processing
        currentImage = image
        
        let subscriptionStatus = SubscriptionManager.shared?.status
        
        switch subscriptionStatus?.plan {
        case .free:
            identifyWithLocalModel(image, allowAPIFallback: false)
        case .premium:
            identifyWithLocalModel(image, allowAPIFallback: false)
        case .premiumPlus:
            identifyWithLocalModel(image, allowAPIFallback: true)
        default:
            identifyWithLocalModel(image, allowAPIFallback: false)
        }
    }
    
    private func identifyWithLocalModel(_ image: UIImage, allowAPIFallback: Bool) {
        localModel.classify(image) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let result = result {
                    if result.isHighConfidence || !allowAPIFallback {
                        // Use local model result
                        let rockResult = self.createRockResult(from: result, image: image)
                        self.state = .success(rockResult)
                        HapticManager.shared.successFeedback()
                    } else {
                        // Fallback to OpenAI API for low confidence
                        print("Low confidence (\(result.confidence)), falling back to OpenAI API")
                        self.identifyWithOpenAI(image)
                    }
                } else {
                    // Model failed, fallback if allowed
                    if allowAPIFallback {
                        self.identifyWithOpenAI(image)
                    } else {
                        self.state = .error("Unable to identify rock. Please try with better lighting or a clearer image.")
                    }
                }
            }
        }
    }
    
    private func createRockResult(from classification: RockClassificationResult, image: UIImage) -> RockIdentificationResult {
        // Get detailed rock information from local database
        let rockInfo = LocalRockDatabase.shared.getRockInfo(for: classification.rockName)
        
        return RockIdentificationResult(
            image: image,
            name: rockInfo?.name ?? classification.rockName,
            category: rockInfo?.category ?? "Unknown",
            confidence: Double(classification.confidence),
            physicalProperties: rockInfo?.physicalProperties ?? PhysicalProperties.default,
            chemicalProperties: rockInfo?.chemicalProperties ?? ChemicalProperties.default,
            formation: rockInfo?.formation ?? Formation.default,
            uses: rockInfo?.uses ?? Uses.default,
            identificationSource: .localAI
        )
    }
}
```

---

## **Phase 5: Performance Optimization**

### **5.1 Model Size Optimization**

**Target Specifications:**
- **Model size**: <50MB (acceptable for app distribution)
- **Inference time**: <2 seconds on iPhone 12 or newer
- **Memory usage**: <200MB during inference
- **Accuracy**: >85% top-1, >95% top-5

### **5.2 Optimization Techniques**

```python
# Model compression techniques
def optimize_model_for_mobile(model):
    """
    Apply multiple optimization techniques
    """
    # 1. Quantization
    quantized_model = quantize_model(model, target_bits=8)
    
    # 2. Pruning
    pruned_model = prune_model(quantized_model, sparsity=0.3)
    
    # 3. Knowledge distillation
    distilled_model = distill_model(pruned_model, teacher_model=model)
    
    # 4. Neural architecture search
    optimized_model = neural_architecture_search(distilled_model)
    
    return optimized_model
```

### **5.3 Runtime Optimization**

```swift
// Optimize image preprocessing
extension UIImage {
    func optimizedForClassification() -> UIImage? {
        // Resize to exact model input size
        let targetSize = CGSize(width: 224, height: 224)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

// Batch processing for multiple images
class BatchClassifier {
    func classifyBatch(_ images: [UIImage]) -> [RockClassificationResult] {
        // Process multiple images efficiently
        return images.compactMap { image in
            // Synchronous classification for batch processing
            return classifySync(image)
        }
    }
}
```

---

## **Phase 6: Testing & Validation**

### **6.1 Accuracy Testing**

```swift
// Automated testing suite
class ModelValidationTests: XCTestCase {
    func testModelAccuracy() {
        let testImages = loadTestDataset()
        var correct = 0
        var total = 0
        
        for (image, expectedLabel) in testImages {
            let result = classifyImage(image)
            if result.rockName == expectedLabel {
                correct += 1
            }
            total += 1
        }
        
        let accuracy = Double(correct) / Double(total)
        XCTAssertGreaterThan(accuracy, 0.85, "Model accuracy should be > 85%")
    }
    
    func testInferenceTime() {
        let testImage = UIImage(named: "granite_sample")!
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let _ = classifyImage(testImage)
        let inferenceTime = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertLessThan(inferenceTime, 2.0, "Inference should complete within 2 seconds")
    }
}
```

### **6.2 A/B Testing Framework**

```swift
// Compare local model vs API accuracy
class ABTestingManager {
    func runAccuracyComparison() {
        let testImages = loadBalancedTestSet()
        
        var localModelResults: [String] = []
        var apiResults: [String] = []
        
        for image in testImages {
            // Test local model
            let localResult = localModel.classify(image)
            localModelResults.append(localResult.rockName)
            
            // Test API
            let apiResult = apiService.identify(image)
            apiResults.append(apiResult.name)
        }
        
        // Compare results
        analyzeResults(localModelResults, apiResults, testImages)
    }
}
```

---

## **Phase 7: Deployment Strategy**

### **7.1 Rollout Plan**

**Phase 7.1: Internal Testing (Week 1)**
- Deploy to TestFlight internal team
- Test model accuracy against known specimens
- Validate performance on different device types

**Phase 7.2: Beta Testing (Week 2)**
- Release to external beta testers
- Collect feedback on identification accuracy
- Monitor crash reports and performance issues

**Phase 7.3: Gradual Rollout (Week 3)**
- Release to 25% of users initially
- Monitor server load and user feedback
- Gradually increase to 100% based on metrics

### **7.2 Monitoring & Analytics**

```swift
// Track model performance in production
class ModelAnalytics {
    func trackIdentification(result: RockClassificationResult, userFeedback: UserFeedback?) {
        let event = AnalyticsEvent(
            type: "rock_identification",
            properties: [
                "rock_name": result.rockName,
                "confidence": result.confidence,
                "inference_time": result.inferenceTime,
                "user_feedback": userFeedback?.rating ?? "none",
                "model_version": getCurrentModelVersion()
            ]
        )
        
        AnalyticsManager.shared.track(event)
    }
}
```

---

## **Expected Outcomes**

### **Performance Targets:**
- **Accuracy**: 85-90% top-1 accuracy on common rocks
- **Speed**: <2 second identification time
- **Size**: 40-60MB model file
- **Cost Savings**: 95%+ reduction in API costs

### **Business Impact:**
- **Premium tier**: Viable for AppsGoneFree promotion
- **User experience**: Instant offline identification
- **Scalability**: Handle unlimited identifications
- **Differentiation**: Most accurate local rock ID app

### **Technical Benefits:**
- **Offline capability**: Works without internet
- **Privacy**: No images sent to servers
- **Reliability**: No API dependencies
- **Performance**: Consistent identification speed

---

## **Next Steps**

1. **Start data collection** for 300 most common rocks
2. **Set up training pipeline** using transfer learning
3. **Create validation dataset** with expert-verified labels
4. **Begin model training** with iterative improvement
5. **Implement Core ML integration** in parallel
6. **Plan comprehensive testing** strategy

This approach will create the most accurate and comprehensive local rock identification system available on mobile devices while maintaining zero variable costs for identification.
