# App Icon - Replace Placeholder

## Current Status

✅ A placeholder orange icon with "GPS" text has been installed so the app builds successfully.

🎨 **To use your custom GPS/navigation icon**, follow these steps:

## Replace with Your Icon

### Option 1: Use the script (Easiest)

Save your icon image to the project root, then run:

```bash
cd /Users/DTassara/Projects/GPSBabelMac
./generate-icons.sh path/to/your-icon.png
```

### Option 2: Use Xcode (Visual)

1. Open GPSBabelMac.xcodeproj in Xcode
2. Navigate to Resources → Assets.xcassets → AppIcon
3. Drag and drop your 1024x1024 icon image into the AppIcon set
4. Xcode will handle the rest automatically

### Option 3: Manual replacement

Navigate to this directory and run:

```bash
# From project root
cd GPSBabelMac/Resources/Assets.xcassets/AppIcon.appiconset

# Generate all sizes from your icon (replace path)
sips -z 16 16     ~/Desktop/your-icon.png --out icon-16.png
sips -z 32 32     ~/Desktop/your-icon.png --out icon-32.png
sips -z 64 64     ~/Desktop/your-icon.png --out icon-64.png
sips -z 128 128   ~/Desktop/your-icon.png --out icon-128.png
sips -z 256 256   ~/Desktop/your-icon.png --out icon-256.png
sips -z 512 512   ~/Desktop/your-icon.png --out icon-512.png
sips -z 1024 1024 ~/Desktop/your-icon.png --out icon-1024.png
```

## Icon Files

All required icon sizes are present:
- icon-16.png (16x16)
- icon-32.png (32x32 and 16x16@2x)
- icon-64.png (32x32@2x)
- icon-128.png (128x128)
- icon-256.png (256x256 and 128x128@2x)
- icon-512.png (512x512 and 256x256@2x)
- icon-1024.png (1024x1024 and 512x512@2x)

After replacing the icons, clean and rebuild:
```bash
cd /Users/DTassara/Projects/GPSBabelMac
xcodebuild -project GPSBabelMac.xcodeproj -scheme GPSBabelMac clean build
```

Or in Xcode: Product → Clean Build Folder (⌘⇧K), then Build (⌘B)
