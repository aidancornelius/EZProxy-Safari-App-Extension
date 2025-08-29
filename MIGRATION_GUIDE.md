# EZProxy Web Extension Migration Guide

## Overview

This branch contains a modernised version of the EZProxy Safari extension that uses Safari Web Extensions instead of the deprecated Safari App Extensions API. This enables cross-platform support for macOS, iOS, and iPadOS.

## What's Changed

### Architecture Changes

1. **Extension Type**: Migrated from Safari App Extensions to Safari Web Extensions
2. **Cross-Platform**: Single extension works on macOS, iOS, and iPadOS
3. **Modern APIs**: Uses Manifest V3 and standard WebExtensions APIs
4. **Simplified Codebase**: JavaScript-based extension logic instead of Swift

### New Project Structure

```
EZProxy-Safari-App-Extension/
├── EZProxy Universal/          # Cross-platform SwiftUI app
│   ├── EZProxyApp.swift       # App entry point
│   ├── SettingsView.swift     # Settings UI
│   └── SettingsViewModel.swift # Settings logic
│
├── EZProxy Web Extension/      # Safari Web Extension
│   ├── Info.plist
│   ├── SafariWebExtensionHandler.swift
│   └── Resources/
│       ├── manifest.json      # Extension manifest
│       ├── background.js      # Background script
│       ├── content.js         # Content script
│       ├── _locales/          # Localisation
│       └── images/            # Extension icons
│
└── EZProxy Safari/            # Legacy Safari App Extension (deprecated)
```

## Features Preserved

- ✅ One-click proxy redirection
- ✅ EZProxy and OpenAthens support
- ✅ HTTPS/HTTP configuration
- ✅ New tab vs replace tab options
- ✅ Browser history preservation
- ✅ Settings sync between app and extension

## New Features

- 📱 iOS and iPadOS support
- 🎨 Modern SwiftUI interface
- 🔄 Real-time settings sync
- 🌐 Standard WebExtensions API

## Building the Project

### Requirements

- Xcode 14.0 or later
- macOS 12.0 or later (for development)
- iOS 15.0 or later (for iOS deployment)

### Setup Instructions

1. Open `EZProxy.xcodeproj` in Xcode
2. Select the "EZProxy Universal" scheme
3. Build and run for your target platform

### Adding Extension Icons

Before distribution, add the following icon files to `EZProxy Web Extension/Resources/images/`:

- `icon-48.png` (48x48)
- `icon-96.png` (96x96)
- `icon-128.png` (128x128)
- `icon-256.png` (256x256)
- `icon-512.png` (512x512)
- `toolbar-icon-16.png` (16x16)
- `toolbar-icon-19.png` (19x19)
- `toolbar-icon-32.png` (32x32)
- `toolbar-icon-38.png` (38x38)
- `toolbar-icon-48.png` (48x48)
- `toolbar-icon-72.png` (72x72)

## Testing

1. **macOS**: Build and run, then enable the extension in Safari > Settings > Extensions
2. **iOS**: Build and run, then enable in Settings > Safari > Extensions
3. **Test proxy redirection** with academic journal sites
4. **Verify settings sync** between app and extension

## Migration from Old Version

Users upgrading from the Safari App Extension version will need to:

1. Disable the old extension in Safari settings
2. Enable the new Web Extension
3. Settings will be automatically migrated

## Distribution

The app can be distributed through:

- Mac App Store (macOS)
- iOS App Store (iOS/iPadOS)
- TestFlight (beta testing)
- Direct distribution (macOS only, with Developer ID)

## Known Limitations

- Web Extensions have slightly less system integration than App Extensions
- Some advanced tab management features may be limited on iOS
- Extension popup UI not available (uses toolbar button action instead)

## Support

For issues or questions about the migration, please open an issue on GitHub.