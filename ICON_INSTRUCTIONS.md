# App Icon Instructions

## Quick Setup

To add your app icon to GPSBabelMac, follow these steps:

### Method 1: Using the provided script (Recommended)

1. Save your app icon image (the GPS/navigation themed icon) to the project root directory
2. Run the icon generation script:
   ```bash
   ./generate-icons.sh your-icon-image.png
   ```
3. Open GPSBabelMac.xcodeproj in Xcode
4. Build and run - your icon should now appear!

### Method 2: Manual setup in Xcode

1. Save your app icon image (1024x1024 recommended size) to your Desktop
2. Open GPSBabelMac.xcodeproj in Xcode
3. In the Project Navigator, navigate to:
   - GPSBabelMac → Resources → Assets.xcassets → AppIcon
4. Drag and drop your icon image into the AppIcon set
5. Xcode will automatically generate all required sizes
6. Build and run to see your new icon

### Method 3: Command-line generation

If you have your icon saved as `app-icon.png`, you can manually generate all sizes:

```bash
cd GPSBabelMac/Resources/Assets.xcassets/AppIcon.appiconset

# Generate all required sizes
sips -z 16 16     ~/Desktop/app-icon.png --out icon-16.png
sips -z 32 32     ~/Desktop/app-icon.png --out icon-32.png
sips -z 64 64     ~/Desktop/app-icon.png --out icon-64.png
sips -z 128 128   ~/Desktop/app-icon.png --out icon-128.png
sips -z 256 256   ~/Desktop/app-icon.png --out icon-256.png
sips -z 512 512   ~/Desktop/app-icon.png --out icon-512.png
sips -z 1024 1024 ~/Desktop/app-icon.png --out icon-1024.png
```

## Icon Specifications

The app icon has been configured for macOS with the following sizes:
- 16x16 (@1x and @2x)
- 32x32 (@1x and @2x)
- 128x128 (@1x and @2x)
- 256x256 (@1x and @2x)
- 512x512 (@1x and @2x)

## What's Been Set Up

✅ Assets.xcassets catalog created in Resources/
✅ AppIcon.appiconset configured with proper Contents.json
✅ Xcode project updated to reference the asset catalog
✅ Icon generation script created (generate-icons.sh)

## Verification

After adding your icon, you can verify it's working by:
1. Building the app in Xcode (⌘B)
2. Checking the app in Applications or in Finder
3. The GPS/navigation icon should appear in the menu bar, dock, and Finder

## Troubleshooting

**Icon not appearing?**
- Clean build folder in Xcode: Product → Clean Build Folder (⌘⇧K)
- Rebuild the project
- Check that icon files exist in: `GPSBabelMac/Resources/Assets.xcassets/AppIcon.appiconset/`

**Script not working?**
- Ensure the script is executable: `chmod +x generate-icons.sh`
- Verify the source image path is correct
- Make sure you have `sips` available (comes with macOS)
