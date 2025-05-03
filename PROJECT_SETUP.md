# Rock Identifier: Xcode Project Setup Instructions

Follow these steps to set up the Xcode project for Rock Identifier:

## 1. Create New Xcode Project

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "App" under iOS templates
4. Click "Next"

## 2. Configure Project Settings

Set the following options:
- **Product Name**: Rock Identifier
- **Team**: Your Developer Account
- **Organization Identifier**: com.appmagic
- **Bundle Identifier**: com.appmagic.RockIdentifier
- **Interface**: SwiftUI
- **Life Cycle**: UIKit App Delegate
- **Language**: Swift

## 3. Choose Project Location

Select `/Users/mokome/Dev/rock-identifier` as the project location.

## 4. Replace Default Files

After the project is created, replace the default files with our pre-created files:

1. **Delete** the auto-generated ContentView.swift, AppDelegate.swift, and SceneDelegate.swift
2. **Move** our pre-created Swift files into the project
3. **Organize** files into appropriate groups in the Xcode project navigator:
   - Models
   - Views
   - Services
   - Extensions

## 5. Copy Assets

1. Replace the default Assets.xcassets with our pre-created Assets.xcassets directory
2. Make sure all color sets are properly imported

## 6. Update Info.plist

Replace the default Info.plist with our pre-created version that includes:
- Camera usage description
- Photo library usage description
- Launch screen configuration
- App display name

## 7. Configure Build Settings

1. Set deployment target to iOS 14.0 or higher
2. Configure signing & capabilities
3. Ensure SwiftUI previews are working

## 8. Clean and Build

1. Clean the build folder (Shift+Cmd+K)
2. Build the project (Cmd+B)
3. Run the app in the simulator (Cmd+R)

## Directory Structure Reference

```
RockIdentifier/
├── Assets.xcassets/
│   ├── AppIcon.appiconset/
│   ├── Colors/
│   └── ...
├── Info.plist
├── AppDelegate.swift
├── SceneDelegate.swift
├── Models/
│   ├── RockIdentificationResult.swift
│   ├── PhysicalProperties.swift
│   ├── ChemicalProperties.swift
│   ├── Formation.swift
│   └── Uses.swift
├── Views/
│   ├── ContentView.swift
│   ├── CameraView.swift
│   ├── OnboardingView.swift
│   └── PhotoPicker.swift
├── Services/
│   ├── RockIdentificationService.swift
│   ├── CollectionManager.swift
│   └── ConnectionRequest.swift
└── Extensions/
    ├── UIImage+Extension.swift
    └── Color+Theme.swift
```

## Notes

- The project is configured to use UIKit App Delegate lifecycle for better integration with camera functionality
- The UI is implemented in SwiftUI for modern, declarative interface design
- Make sure camera permissions are properly requested at runtime
- The app is designed for portrait orientation only on iPhones
