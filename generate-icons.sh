#!/bin/bash

# Script to generate all required icon sizes from a source image
# Usage: ./generate-icons.sh source-icon.png

if [ $# -eq 0 ]; then
    echo "Usage: $0 <source-icon-image>"
    echo "Example: $0 app-icon.png"
    exit 1
fi

SOURCE_IMAGE="$1"
ICONSET_PATH="GPSBabelMac/Assets.xcassets/AppIcon.appiconset"

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image '$SOURCE_IMAGE' not found"
    exit 1
fi

echo "Generating icon sizes from $SOURCE_IMAGE..."

# Generate all required sizes using sips
sips -z 16 16     "$SOURCE_IMAGE" --out "$ICONSET_PATH/icon-16.png" > /dev/null
sips -z 32 32     "$SOURCE_IMAGE" --out "$ICONSET_PATH/icon-32.png" > /dev/null
sips -z 64 64     "$SOURCE_IMAGE" --out "$ICONSET_PATH/icon-64.png" > /dev/null
sips -z 128 128   "$SOURCE_IMAGE" --out "$ICONSET_PATH/icon-128.png" > /dev/null
sips -z 256 256   "$SOURCE_IMAGE" --out "$ICONSET_PATH/icon-256.png" > /dev/null
sips -z 512 512   "$SOURCE_IMAGE" --out "$ICONSET_PATH/icon-512.png" > /dev/null
sips -z 1024 1024 "$SOURCE_IMAGE" --out "$ICONSET_PATH/icon-1024.png" > /dev/null

echo "✓ Generated all icon sizes"
echo "Icon files created in $ICONSET_PATH/"
echo ""
echo "Next steps:"
echo "1. Open GPSBabelMac.xcodeproj in Xcode"
echo "2. The app icon should now appear in Assets.xcassets"
echo "3. Build and run to see the new icon"
