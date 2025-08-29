# EZProxy Safari Web Extension

A modern, cross-platform Safari extension for accessing academic resources through institutional proxy services (EZProxy and OpenAthens). Works on macOS, iOS, and iPadOS.

## Features

- Cross-platform on macOS, iOS, and iPadOS
- Supports both EZProxy and OpenAthens
- Instantly redirect any academic resource through your proxy
- Optional mode to maintain back button functionality

## Installation

### From Source

1. Clone this repository
2. Open `EZProxy.xcodeproj` in Xcode
3. Select your target device (Mac or iOS device/simulator)
4. Build and run (⌘R)
5. Enable the extension:
   - **macOS**: Safari → Settings → Extensions → Enable EZProxy
   - **iOS**: Settings → Safari → Extensions → Enable EZProxy

### From App Store

[Download from the App Store](https://apps.apple.com/au/app/ezproxy-for-safari/id1542011791?mt=12)

## Configuration

1. Open the EZProxy app from your Applications folder (macOS) or home screen (iOS)
2. Enter your institution's proxy domain (e.g., `ezproxy.university.edu.au`)
3. Configure options:
   - **Use HTTPS**: Enable if your proxy uses secure connections
   - **Use OpenAthens**: Enable if your institution uses OpenAthens instead of EZProxy
   - **Open in new tab**: Choose whether to open proxied pages in a new tab
   - **Preserve browser history**: Enable to maintain back button functionality
4. Click "Save settings"

## Usage

1. Navigate to any academic resource website
2. Click the EZProxy button in Safari's toolbar
3. The page will reload through your institution's proxy
4. Log in with your institutional credentials when prompted

## Technical Details

This extension uses Safari Web Extensions (Manifest V3) for cross-platform compatibility. The architecture includes:

- **Web Extension**: JavaScript-based extension logic using standard WebExtensions APIs
- **Native App**: SwiftUI app for settings management
- **Shared Storage**: App Groups for settings synchronisation

## Support

If you encounter issues or have questions:

- Create an [issue on GitHub](https://github.com/aidancornelius/EZProxy-Safari-App-Extension/issues)
- Email: aidan@cornelius-bell.com

## License

[MIT](https://github.com/aidancornelius/EZProxy-Safari-App-Extension/blob/master/LICENSE)
