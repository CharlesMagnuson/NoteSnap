# NoteSnap 📱✨

**NoteSnap** is a powerful iOS app that converts text notes into perfectly-sized images optimized for Bluetooth photo printers, with advanced QR code integration for OmniFocus task management.

## Features

### Core Functionality
- **Instant Launch**: Opens directly to text input for quick note creation
- **Smart Sizing**: Automatically optimizes text size to fit perfectly in your chosen format
- **One-Touch Save**: Single button saves directly to Photos library
- **Print Optimized**: Generates high-resolution images at 300 DPI for crisp printing
- **Clean Interface**: Minimal, focused design with essential features

### Advanced Features
- **Customizable Dimensions**: Choose any size from 1.0"×1.0" up to 6.0"×6.0"
- **QR Code Integration**: Automatically embeds OmniFocus task links as QR codes
- **Smart Clipboard Detection**: Recognizes OmniFocus URLs and offers QR code embedding
- **Dynamic Layout**: QR codes intelligently position to maximize text space

## Technical Specifications

### Image Output
- **Default Dimensions**: 600×900 pixels (2"×3" at 300 DPI)
- **Customizable Range**: 300-1800 pixels per dimension (1.0-6.0 inches at 300 DPI)
- **Orientation**: Supports both portrait and landscape formats
- **Background**: Pure white (#FFFFFF)
- **Text**: Black (#000000), center-aligned with optimal spacing
- **QR Codes**: 20% of image's smaller dimension for reliable scanning
- **Format**: PNG for lossless quality

### Requirements
- iOS 15.0 or later
- Xcode 15.0 or later for building
- iPhone or iPad for installation
- Optional: OmniFocus for QR code task integration

## Building & Installation

### Prerequisites
1. **Xcode**: Download from the Mac App Store
2. **Apple Developer Account**: Free account sufficient for device testing
3. **iPhone/iPad**: Connected via USB or WiFi

### Build Steps

1. **Open Project**
   ```bash
   cd "XCode app/NoteSnap"
   open NoteSnap.xcodeproj
   ```

2. **Configure Signing**
   - Select your project in Xcode
   - Go to "Signing & Capabilities"
   - Set your Team (Apple Developer Account)
   - Change Bundle Identifier to something unique:
     ```
     com.yourname.notesnap
     ```

3. **Connect Device**
   - Connect your iPhone/iPad via USB
   - Trust the device when prompted
   - Select your device as the build target

4. **Build & Install**
   - Press `⌘ + R` or click the "Play" button
   - App will build and install on your device
   - Trust the developer profile in Settings if prompted

### Permanent Installation

The app installs permanently on your device (not a temporary beta). Once installed:
- App remains on device indefinitely
- Works offline without computer connection
- Can be moved/organized like any App Store app

## Usage

### Basic Note Creation
1. **Launch**: App opens directly to text input
2. **Type**: Enter your note text in the text field
3. **Create**: Tap "Create & Save" button
4. **Print**: Open Photos app and print the generated image

### Size Customization
1. **Access Settings**: Tap the "NoteSnap" title at the top
2. **Adjust Dimensions**: Set width and height (1.0-6.0 inches)
3. **Preview**: See pixel dimensions in real-time
4. **Save**: Apply changes to current and future notes

### QR Code Integration
1. **Copy OmniFocus Link**: Copy any OmniFocus task or project link
2. **Enable QR Code**: Toggle "Include QR Code" when clipboard is detected
3. **Info**: Tap the info button to learn about QR code functionality
4. **Generate**: QR code automatically embeds in bottom-right corner

## Code Structure

```
NoteSnap/
├── NoteSnapApp.swift          # App entry point
├── ContentView.swift          # Main UI and user interaction
├── ImageGenerator.swift       # Text-to-image conversion with QR support
├── PhotosManager.swift        # Photos library integration
├── SizeSettingsView.swift     # Customizable dimension interface
├── QRCodeGenerator.swift      # QR code creation and embedding
├── QRCodeInfoView.swift       # QR feature explanation UI
├── QRCodeError.swift          # QR code error handling
├── OmniFocusLinkValidator.swift # Clipboard URL validation
├── ClipboardManager.swift     # System clipboard integration
└── Assets.xcassets/           # App icons and assets
```

## Key Components

### ImageGenerator
- **Binary Search Algorithm**: Finds optimal font size for any text length and image size
- **Dynamic Sizing**: Automatically adjusts text to fit perfectly in custom dimensions
- **QR Code Integration**: Intelligently positions QR codes to maximize text space
- **Core Graphics**: Precise text rendering with proper spacing and alignment

### SizeSettingsView
- **Interactive Configuration**: Real-time dimension adjustment with live preview
- **Validation**: Ensures dimensions stay within 1.0-6.0 inch range
- **Pixel Calculation**: Shows exact output resolution for any size setting
- **User-Friendly Interface**: Clear labeling and intuitive controls

### QR Code System
- **Smart Detection**: Automatically recognizes OmniFocus URLs in clipboard
- **Validation**: Ensures links are properly formatted before embedding
- **Optimal Sizing**: QR codes sized for reliable scanning across different printers
- **Error Handling**: Graceful fallback when QR generation fails

### PhotosManager
- **Permission Handling**: Requests and manages Photos library access
- **Error Management**: Comprehensive error handling and user feedback
- **Async Operations**: Non-blocking save operations with completion callbacks

### ContentView
- **Auto-Focus**: Text field automatically gains focus on app launch
- **Real-time Validation**: Button states reflect input validity and QR code status
- **Visual Feedback**: Loading states, success confirmations, and error messages
- **Settings Integration**: Seamless access to size customization

## Troubleshooting

### Build Issues
- **"No Developer Account"**: Sign up for free Apple Developer account
- **"Bundle ID Already Exists"**: Change bundle identifier to unique value
- **"Code Signing Error"**: Ensure device is trusted and developer account is set

### Runtime Issues
- **"Photos Access Denied"**: Grant Photos permission in iOS Settings
- **"Save Failed"**: Check device storage space
- **"App Won't Open"**: Trust developer profile in Settings > General > VPN & Device Management

### Print Quality Issues
- **Blurry Text**: Ensure printer is set to highest quality mode
- **Text Too Small**: Use larger dimensions or shorter text
- **Cut-off Content**: Verify printer paper size matches your chosen dimensions
- **QR Code Won't Scan**: Ensure adequate lighting and proper focus when scanning

### QR Code Issues
- **QR Not Appearing**: Ensure OmniFocus URL is copied to clipboard before toggling
- **Link Won't Open**: Verify OmniFocus is installed and URL format is correct
- **QR Too Small**: Use larger image dimensions for better QR code scanning

## Development Notes

### Font Sizing Algorithm
The app uses a sophisticated binary search algorithm to find the optimal font size:
1. Measures text at various font sizes within available content area
2. Accounts for QR code space when present
3. Finds largest size that fits within margins
4. Ensures text is readable while maximizing space usage

### Image Generation
- Uses Core Graphics for pixel-perfect rendering
- Pure white background ensures clean printing across all printer types
- Adaptive margins (5% of smallest dimension) prevent content cutoff
- QR codes positioned to minimize text interference

### QR Code Implementation
- Uses Core Image's CIQRCodeGenerator for standard-compliant codes
- Automatic error correction level optimization
- Validates OmniFocus URL format before generation
- Scales QR codes appropriately for image dimensions

### Size Customization
- Real-time pixel calculation and preview
- Maintains aspect ratio awareness for optimal printing
- Validates input ranges to prevent rendering issues
- Persistent settings across app launches

### Photos Integration
- Requests minimal permissions (add-only access)
- Saves as PNG for lossless quality
- Includes proper error handling and user feedback
- Compatible with all photo printing workflows

## OmniFocus Integration

### Supported URL Formats
- Task links: `omnifocus:///task/[ID]`
- Project links: `omnifocus:///folder/[ID]`
- Perspective links: `omnifocus:///perspective/[ID]`

### Workflow Benefits
1. **Physical Task Reference**: Print notes with embedded task links
2. **Quick Access**: Scan QR code to jump directly to related OmniFocus item
3. **Offline Notes**: Reference task details even when device is offline
4. **Archive Integration**: Create physical backup of digital task information

## Future Enhancements

- **Custom Fonts**: Additional font options for different styles
- **Templates**: Pre-designed layouts for specific use cases
- **Batch Creation**: Generate multiple notes at once
- **Custom Albums**: Organize NoteSnap images in dedicated album
- **Share Extension**: Create notes from other apps
- **Multiple QR Codes**: Support for multiple links per note
- **Color Themes**: Alternative background and text color schemes

## License

MIT License - Feel free to modify and distribute.

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review device and iOS version compatibility
3. Ensure latest version of Xcode is installed
4. Verify OmniFocus installation for QR code features

---

**Note**: This app provides complete control over text rendering, sizing, and QR code integration for perfect photo printing. The QR code feature creates a powerful bridge between physical notes and digital task management in OmniFocus.