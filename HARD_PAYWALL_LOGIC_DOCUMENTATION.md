# Hard Paywall Logic Documentation

## Overview

The Rock Identifier app implements a two-tier paywall system:
- **Hard Paywall**: Cannot be dismissed by the user, requires purchase or app becomes unusable
- **Soft Paywall**: Can be dismissed after a delay, allows continued use of free features

This document focuses on the **Hard Paywall** logic and when it's triggered.

## Core Logic

### Primary Trigger: App Version Updates

The hard paywall is primarily triggered when the app version changes. This is managed by the `PaywallManager` service.

#### Key Method: `showHardPaywallIfNeeded()`

```swift
func showHardPaywallIfNeeded() -> Bool {
    // 1. Never show to subscribed users
    if hasActiveSubscription() {
        return false
    }
    
    // 2. Get the last version where we showed a paywall
    let lastVersionShown = defaults.string(forKey: lastVersionShownKey) ?? ""
    
    // 3. Compare with current app version
    if lastVersionShown != currentAppVersion {
        // Show the hard paywall
        AppState.shared.showHardPaywall = true
        
        // Save this version as shown
        defaults.set(currentAppVersion, forKey: lastVersionShownKey)
        
        return true
    }
    
    return false
}
```

### Version Tracking

- **Current Version**: Retrieved from `CFBundleShortVersionString` in `Info.plist`
- **Last Shown Version**: Stored in UserDefaults with key `"lastVersionShownPaywall"`
- **Comparison**: If versions don't match → Show hard paywall

## Trigger Conditions

### 1. App Version Change ✅
- Primary trigger condition
- Occurs when user updates the app to a new version
- Only shows once per version update

### 2. Non-Premium User ✅
- Hard paywall never shows to users with active subscriptions
- Checked via `SubscriptionManager.shared.status.isActive`
- Premium users bypass all paywall logic

### 3. Once Per Version ✅
- After showing hard paywall, current version is saved to UserDefaults
- Subsequent launches with same version skip hard paywall
- Reset only occurs with next version update

## Trigger Points in App Flow

### 1. App Launch (Post-Onboarding)

**Location**: `RockIdentifierApp.swift` → `.onAppear`

```swift
.onAppear {
    if hasCompletedOnboarding {
        print("RockIdentifierApp: Onboarding completed, checking for hard paywall")
        let showedHardPaywall = PaywallManager.shared.showHardPaywallIfNeeded()
        
        // If hard paywall wasn't shown, show soft paywall
        if !showedHardPaywall {
            print("RockIdentifierApp: No hard paywall shown, showing soft paywall on launch")
            PaywallManager.shared.showSoftPaywall()
        }
    }
}
```

### 2. After Onboarding Completion

**Location**: `RockIdentifierApp.swift` → onboarding sheet dismissal

```swift
.sheet(isPresented: $showOnboarding, onDismiss: {
    hasCompletedOnboarding = true
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        checkAndShowPaywall()
    }
})

private func checkAndShowPaywall() {
    let showedHardPaywall = PaywallManager.shared.showHardPaywallIfNeeded()
    
    // If hard paywall wasn't shown, always show soft paywall after onboarding
    if !showedHardPaywall {
        PaywallManager.shared.showSoftPaywall()
    }
}
```

## Implementation Details

### File Structure

- **PaywallManager**: `/RockIdentifier/Services/PaywallManager.swift`
- **AppState**: `/RockIdentifier/Models/AppState.swift`
- **Main App**: `/RockIdentifier/RockIdentifierApp.swift`

### UserDefaults Keys

```swift
private let lastVersionShownKey = "lastVersionShownPaywall"
```

### App State Management

```swift
// Show hard paywall
AppState.shared.showHardPaywall = true

// Dismiss all paywalls (when user subscribes)
AppState.shared.dismissPaywalls()
```

### Subscription Integration

```swift
// Automatic dismissal when user subscribes
@objc private func subscriptionStatusChanged() {
    if hasActiveSubscription() {
        AppState.shared.dismissPaywalls()
    }
}
```

## Testing & Development

### Temporary Disable

Hard paywalls can be temporarily disabled by uncommenting these lines in `PaywallManager.swift`:

```swift
// HARD PAYWALLS DISABLED (when 2 lines below are uncommented) - always return false
// print("PaywallManager: Hard paywalls disabled - NOT showing hard paywall")
// return false
```

### Reset for Testing

```swift
// Reset version tracking to test hard paywall again
PaywallManager.shared.resetVersionForTesting()
```

### Debug Information

```swift
// Log current paywall state
PaywallManager.shared.logState()
```

## Fallback Behavior

### No Hard Paywall → Soft Paywall

If hard paywall conditions aren't met, the app **always** shows a soft paywall:

- At app launch (for returning users)
- After onboarding completion (for new users)
- When free tier limits are reached

This ensures all non-premium users see a subscription prompt.

## Business Logic Summary

**Strategy**: Use app version updates as re-engagement opportunities

1. **New Users**: See hard paywall after onboarding
2. **Returning Users**: See hard paywall only after app updates
3. **Premium Users**: Never see paywalls
4. **Free Users**: Always see soft paywall if no hard paywall

This approach:
- ✅ Maximizes subscription conversion opportunities
- ✅ Doesn't annoy existing subscribers
- ✅ Creates urgency around app updates
- ✅ Maintains good user experience for premium users

## Troubleshooting

### Hard Paywall Not Showing

1. Check if user has active subscription
2. Verify app version hasn't been shown before
3. Confirm `hasCompletedOnboarding = true`
4. Check for disabled paywall code

### Hard Paywall Showing Too Often

1. Version tracking may be broken
2. UserDefaults may be clearing
3. Check for multiple calls to `showHardPaywallIfNeeded()`

### Debug Commands

```swift
// Check current state
PaywallManager.shared.logState()

// Check subscription status
subscriptionManager.debugSubscriptionState()

// Reset for testing
PaywallManager.shared.resetVersionForTesting()
```

---

## Related Documentation

- Soft Paywall Logic: (See `FreeTierManager.swift`)
- Subscription Management: (See `SubscriptionManager.swift`)
- Free Tier Limits: (See `IdentificationCounter.swift`)
