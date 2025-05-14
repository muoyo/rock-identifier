// Rock Identifier: Crystal ID
// Muoyo Okome
//

import AVFoundation
import UIKit

class PermissionManager {
    static let shared = PermissionManager()
    
    private init() {}
    
    // Check current camera permission status
    func checkCameraPermission() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    // Request camera permission with completion handler
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Permission already granted
            completion(true)
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            // Permission denied, prompt to go to settings
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    // Open settings if permission was denied
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
