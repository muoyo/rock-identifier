# Animated SVG Resources

This directory contains animated SVG versions of the illustrations used in the app's onboarding flow.

## Why are these here?
These animated SVGs can't be used directly in an Xcode asset catalog because:
1. Asset catalogs convert SVGs to PDFs during build time
2. The animations and interactive elements in SVGs are lost in this conversion
3. Only the static appearance (first frame) is preserved

## How to use these resources:
When you're ready to implement animations in the app:

1. **Option 1: SwiftUI Native Animations**
   - Use these files as reference for recreating the illustrations in SwiftUI
   - Implement animations using SwiftUI's native animation system
   - This provides the best performance and most control

2. **Option 2: WebView Implementation**
   - Load these SVGs into a WKWebView if you want to preserve all SVG animations
   - This approach requires more setup but maintains all SVG features

3. **Option 3: Lottie Animation**
   - Convert these SVGs to Lottie format using tools like LottieFiles
   - Use the Lottie iOS library to play the animations
   - This is a good middle-ground for complex animations

## File Descriptions:
- `onboarding-discover-animated.svg` - Magnifying glass with crystal animation for the first onboarding screen
- `onboarding-details-animated.svg` - Crystal with information cards for the second onboarding screen
- `onboarding-collection-animated.svg` - Collection grid with crystals for the third onboarding screen
- `onboarding-camera-animated.svg` - Camera with scanning effect for the fourth onboarding screen

Simplified versions of these SVGs (without animations) are in the app's asset catalog for use as static images.
