# Smart Parking

SwiftUI iOS app for browsing parking, booking slots, wallet top-ups, and digital passes. Uses MVVM with mock data only (no Firebase, maps SDK, or real payments).

## Requirements

- Xcode 15+
- iOS 17+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Setup

```bash
xcodegen generate
open SmartParking.xcodeproj
```

## Demo login

Any non-empty email + password works.

Seeded user: `alex@example.com`

## Features

- Splash → onboarding → login / register / guest
- Home, bookings, wallet, vehicles, profile (custom tab bar)
- Parking list, filters, details, reserve flow
- Wallet top-up / charge / refund (UserDefaults)
- Parking pass with QR
- Guest mode (browse only on locked tabs)

## Structure

```
SmartParking/
├── App/
├── Models/
├── Views/
├── ViewModels/
├── Repositories/
├── Services/
├── Components/
├── Utilities/
└── Assets.xcassets
```

## Stack

SwiftUI · MVVM · `@Observable` · XcodeGen · mock repositories
