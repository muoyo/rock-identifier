// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI
import PhotosUI
import Photos
import UniformTypeIdentifiers

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    @Binding var filename: String?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        // Configure for better performance with rock photos
        configuration.preferredAssetRepresentationMode = .current // Use current version, not original
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        
        init(parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            guard let result = results.first else {
                print("==> PhotoPicker: No results selected")
                return
            }
            
            let itemProvider = result.itemProvider
            
            // Handle filename extraction first (if needed)
            if let assetId = result.assetIdentifier {
                // Use a background queue for asset operations to avoid blocking main thread
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    // Configure fetch options to prefetch the required properties
                    let fetchOptions = PHFetchOptions()
                    // Don't prefetch metadata properties unless absolutely necessary
                    // This avoids the warning and improves performance
                    
                    let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: fetchOptions)
                    
                    if let firstAsset = fetchResult.firstObject {
                        // Get resources without accessing metadata properties that cause the warning
                        let resources = PHAssetResource.assetResources(for: firstAsset)
                        let filename = resources.first?.originalFilename ?? "photo.jpg"
                        
                        DispatchQueue.main.async {
                            self?.parent.filename = filename
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.parent.filename = "photo.jpg"
                        }
                    }
                }
            }
            
            // Handle image loading - this is the critical part
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                print("==> PhotoPicker: Loading image from item provider")
                
                // Add a timeout mechanism to prevent hanging
                let loadingStartTime = Date()
                let timeoutInterval: TimeInterval = 10.0 // 10 seconds timeout
                
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                    let loadingDuration = Date().timeIntervalSince(loadingStartTime)
                    print("==> PhotoPicker: Image loading took \(String(format: "%.2f", loadingDuration)) seconds")
                    
                    if let error = error {
                        print("==> PhotoPicker ERROR: Failed to load image - \(error.localizedDescription)")
                        return
                    }
                    
                    guard let image = object as? UIImage else {
                        print("==> PhotoPicker ERROR: Loaded object is not a UIImage")
                        return
                    }
                    
                    print("==> PhotoPicker: Successfully loaded image with size \(image.size.width) x \(image.size.height)")
                    
                    DispatchQueue.main.async {
                        guard let self = self else {
                            print("==> PhotoPicker ERROR: Coordinator was deallocated")
                            return
                        }
                        
                        print("==> PhotoPicker: Setting selectedImage on main thread")
                        self.parent.selectedImage = image
                        
                        // Provide haptic feedback to confirm selection
                        HapticManager.shared.lightImpact()
                    }
                }
                
                // Set up timeout mechanism
                DispatchQueue.main.asyncAfter(deadline: .now() + timeoutInterval) { [weak self] in
                    if self?.parent.selectedImage == nil {
                        print("==> PhotoPicker WARNING: Image loading timed out after \(timeoutInterval) seconds")
                        // Could potentially show an error to the user here
                    }
                }
                
            } else {
                print("==> PhotoPicker ERROR: Item provider cannot load UIImage")
                
                // Try alternative loading method using data representation
                if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    print("==> PhotoPicker: Attempting alternative loading via data representation")
                    
                    itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] (data, error) in
                        if let error = error {
                            print("==> PhotoPicker ERROR: Failed to load image data - \(error.localizedDescription)")
                            return
                        }
                        
                        guard let data = data, let image = UIImage(data: data) else {
                            print("==> PhotoPicker ERROR: Could not create UIImage from data")
                            return
                        }
                        
                        print("==> PhotoPicker: Successfully loaded image via data representation - size \(image.size.width) x \(image.size.height)")
                        
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            self.parent.selectedImage = image
                            HapticManager.shared.lightImpact()
                        }
                    }
                }
            }
        }
    }
}
