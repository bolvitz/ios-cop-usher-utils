# Xcode Project Setup Guide

This document provides instructions for setting up the Xcode project for Event Monitor iOS app.

## Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later
- iOS 17.0+ deployment target

## Creating the Xcode Project

Since Xcode project files are binary/complex XML and best created by Xcode IDE, follow these steps:

### Option 1: Create Project in Xcode (Recommended)

1. **Open Xcode**

2. **Create New Project**
   - File → New → Project
   - Choose "iOS" → "App"
   - Click "Next"

3. **Project Configuration**
   - Product Name: `EventMonitor`
   - Team: Select your team
   - Organization Identifier: `com.bolvitz` (or your identifier)
   - Bundle Identifier: `com.bolvitz.EventMonitor`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData**
   - Include Tests: Yes
   - Click "Next"

4. **Save Location**
   - Navigate to `ios-cop-usher-utils` directory
   - Click "Create"

5. **Configure Project Settings**
   - Select the project in navigator
   - Under "General" tab:
     - Deployment Target: iOS 17.0
     - Supported Destinations: iPhone, iPad
   - Under "Build Settings":
     - Swift Language Version: Swift 5
     - Enable Swift Concurrency: Yes

### Option 2: Import Source Files

If the project was already created elsewhere:

1. **Clone the repository**
```bash
git clone https://github.com/bolvitz/ios-cop-usher-utils.git
cd ios-cop-usher-utils
```

2. **Create new Xcode project** (as above) in a temporary location

3. **Copy source files** to the Xcode project:
   - Delete the default `ContentView.swift` and sample files
   - Add groups matching the repository structure
   - Drag and drop files from repository into Xcode

4. **Add Info.plist**
   - Copy the Info.plist from `EventMonitor/EventMonitor/Resources/Info.plist`
   - Set it as the app's Info.plist in project settings

## File Organization in Xcode

Organize files in Xcode to match this structure:

```
EventMonitor
├── App
│   └── EventMonitorApp.swift
├── Screens
│   ├── VenueListScreen.swift
│   ├── VenueSetupScreen.swift
│   ├── AreaManagementScreen.swift
│   ├── ReportsScreen.swift
│   └── SettingsScreen.swift
├── Resources
│   ├── Info.plist
│   └── Assets.xcassets
└── Preview Content
    └── Preview Assets.xcassets

Core (Group)
├── Common
│   ├── Theme
│   │   └── AppTheme.swift
│   └── Extensions
│       └── Color+Hex.swift
├── Data
│   └── Models
│       ├── Venue.swift
│       ├── AreaTemplate.swift
│       ├── Event.swift
│       ├── EventType.swift
│       ├── AreaCount.swift
│       ├── LostItem.swift
│       └── Incident.swift
└── Domain
    └── Enums
        ├── ItemStatus.swift
        ├── ItemCategory.swift
        ├── IncidentSeverity.swift
        ├── IncidentStatus.swift
        └── ZoneType.swift

Features (Group)
├── HeadCounter
│   └── Screens
│       ├── HistoryScreen.swift
│       └── CountingScreen.swift
├── LostAndFound
│   └── Screens
│       ├── LostAndFoundScreen.swift
│       └── AddEditLostItemScreen.swift
└── Incidents
    └── Screens
        ├── IncidentListScreen.swift
        └── AddEditIncidentScreen.swift
```

## Project Settings

### General

- **Display Name**: Event Monitor
- **Bundle Identifier**: com.bolvitz.EventMonitor
- **Version**: 1.0.0
- **Build**: 1
- **Minimum Deployments**: iOS 17.0

### Capabilities

Enable these capabilities if needed in future:
- [ ] iCloud (for cloud sync)
- [ ] Push Notifications
- [ ] Background Modes

### Build Settings

Key settings to verify:

- **Swift Language Version**: Swift 5
- **Swift Compiler - Code Generation**:
  - Optimization Level (Debug): No Optimization [-Onone]
  - Optimization Level (Release): Optimize for Speed [-O]
- **Enable Testability (Debug)**: Yes
- **User Script Sandboxing**: No (if needed)

### Info.plist Keys

Already configured in `Info.plist`:

- `NSPhotoLibraryUsageDescription`: For attaching photos
- `NSCameraUsageDescription`: For taking photos
- `UILaunchScreen`: Launch screen configuration
- `UISupportedInterfaceOrientations`: Portrait and landscape

## Dependencies

This project uses **zero external dependencies**. Everything is built with native iOS frameworks:

- SwiftUI (UI framework)
- SwiftData (persistence)
- Combine (reactive programming)
- PhotosUI (photo picker)
- Foundation (core utilities)

No CocoaPods, SPM packages, or Carthage needed!

## Asset Catalog

Create an `Assets.xcassets` with:

### App Icon
- Create app icon set (1024x1024 for App Store)
- Use Material Design 3 purple theme (#6200EE)

### Colors (Optional)
Add these color sets for better theme management:
- PrimaryColor: #6200EE
- SecondaryColor: #03DAC6
- BackgroundColor: #FFFFFF
- SurfaceColor: #FFFFFF

## Build Phases

Standard build phases should include:

1. **Compile Sources** - All .swift files
2. **Link Binary with Frameworks** - System frameworks only
3. **Copy Bundle Resources** - Assets, Info.plist

## Signing

For development:
- Team: Your Apple Developer team
- Signing: Automatic
- Provisioning Profile: Automatic

For distribution:
- Configure as needed for App Store or enterprise distribution

## Running the App

1. Select a simulator or connected device
2. Press ⌘R or click the Run button
3. The app will build and launch

### First Run

The app will:
- Initialize SwiftData model container
- Show empty venue list
- Prompt to add first venue

## Troubleshooting

### SwiftData Model Errors
- Ensure iOS deployment target is 17.0+
- Check that all models have `@Model` macro
- Verify relationships are properly defined

### Build Errors
- Clean build folder: ⇧⌘K
- Delete derived data
- Restart Xcode

### Missing Files
- Ensure all files are added to the target
- Check file membership in File Inspector

### Preview Errors
- Make sure preview device is iOS 17.0+
- Provide mock model container in preview

## Testing

### Unit Tests
Create unit tests for:
- Business logic (180-day rule, capacity calculations)
- ViewModel logic
- Data model validation

### UI Tests
Test critical user flows:
- Creating venues and areas
- Head counting workflow
- Lost item registration
- Incident reporting

## Next Steps

After setting up the project:

1. ✅ Verify all files compile
2. ✅ Run on simulator to test basic functionality
3. ✅ Create app icon
4. ✅ Test on physical device
5. ✅ Set up code signing for distribution
6. ✅ Submit to App Store (when ready)

## Support

For issues with setup:
- Check this guide
- Review README.md
- Open an issue on GitHub

---

**Note**: This project structure follows iOS best practices and SwiftUI/SwiftData patterns. The architecture mirrors the Android app while following iOS conventions.
