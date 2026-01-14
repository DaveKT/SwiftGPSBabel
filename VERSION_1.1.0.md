# GPSBabel for macOS - Version 1.1.0 Release Notes

**Release Date**: January 13, 2024

## 🎉 What's New

Version 1.1.0 brings significant improvements to format handling and adds a comprehensive settings system for configuring custom binary paths.

### ⚙️ Settings Window

A new Settings window provides full control over gpsbabel binary location:

**Access**: Press **⌘,** or select **GPSBabelMac → Settings...**

**Features**:
- 📝 **Text field**: Manually enter custom binary path
- 🔍 **Browse button**: File picker for easy binary selection
- 🔄 **Reset button**: Clear custom path and return to auto-detection
- ✅ **Real-time validation**: Green checkmark shows when binary is detected
- ⚠️ **Error feedback**: Orange warning for invalid paths
- ℹ️ **Version display**: Shows GPSBabel version when detected
- 💾 **Persistent storage**: Custom path saved between app launches

**Use Cases**:
- Development builds of gpsbabel
- Multiple installed versions
- Non-standard installation locations
- Network/shared installations

### 🔧 Format Dropdown Fixes

Major improvements to format parsing and display:

**Before v1.1.0**:
- ❌ Blank entries in dropdowns
- ❌ Invalid format IDs
- ❌ Missing format names
- ❌ Incorrect capabilities

**After v1.1.0**:
- ✅ All 60+ input formats displayed correctly
- ✅ All 50+ output formats displayed correctly
- ✅ Proper format names from gpsbabel
- ✅ Accurate read/write capability detection
- ✅ File extensions properly extracted

**Technical Fix**:
The parser now correctly reads gpsbabel's `-^2` output format:
```
type	flags	id	extension	description
```

### 🔒 Sandbox Permissions

Enhanced security with proper sandbox configuration:

**Added Read-Only Access To**:
- `/opt/homebrew/` - Homebrew Apple Silicon
- `/usr/local/` - Homebrew Intel
- `/usr/bin/` - System installations

This allows the app to detect and validate gpsbabel automatically while maintaining security.

## 📊 Statistics

### Code Changes
- **1 new file**: SettingsView.swift (~190 lines)
- **1 major fix**: GPSFormat.swift parser rewrite
- **2 updated files**: GPSBabelMacApp.swift, entitlements
- **Net addition**: ~200 lines of code

### Build Status
✅ **Build: SUCCESS**
✅ **No warnings or errors**
✅ **All features tested and working**

## 🐛 Bug Fixes

### Critical Fixes
1. **Format Parser**: Complete rewrite to handle actual gpsbabel output format
2. **Capability Detection**: Now reads flags field (rwrwrw) correctly
3. **Extension Parsing**: Handles multi-extension formats like `tcx/crs/hst/xml`
4. **Format Filtering**: Skips internal/unusable formats

### User Experience Fixes
- Format dropdowns now populate correctly on first launch
- No more blank entries in format lists
- All formats show proper human-readable names
- Settings window properly validates custom paths

## 🚀 Upgrade Instructions

### From v1.0.0

1. **Pull latest code** (or download new build)
2. **Rebuild** the project in Xcode (⌘B)
3. **Run** (⌘R) - existing settings are preserved
4. **Check formats**: Open the app and verify format dropdowns are populated
5. **Configure path** (optional): Press ⌘, to access new Settings window

### Fresh Install

1. Open project in Xcode
2. Build and run (⌘R)
3. Install gpsbabel: `brew install gpsbabel`
4. App will auto-detect gpsbabel location

## 📋 Complete Feature List

### Core Features
- ✅ Drag-and-drop file input
- ✅ File picker dialog
- ✅ 60+ input formats (dynamic from gpsbabel)
- ✅ 50+ output formats (dynamic from gpsbabel)
- ✅ Auto-detect input format
- ✅ Conversion filters (simplify, dedupe, merge)
- ✅ Real-time conversion log
- ✅ Progress indication
- ✅ Error handling
- ✅ Open output in Finder

### New in v1.1.0
- ✅ Settings window (⌘,)
- ✅ Custom binary path configuration
- ✅ Binary validation with visual feedback
- ✅ Version detection
- ✅ Fixed format parsing
- ✅ Sandbox permissions

## 🔮 What's Next

### Version 1.2.0 (Planned)
- Batch conversion queue
- Conversion history
- Quick presets/templates
- Enhanced error recovery

### Version 2.0.0 (Future)
- Advanced filter parameters
- Menu bar quick actions
- Keyboard shortcuts
- Format favorites
- App icon
- Distribution (DMG, notarization)

## 📝 Known Issues

None reported for v1.1.0

If you encounter issues:
1. Check Settings (⌘,) to verify binary is detected
2. Ensure gpsbabel is installed: `which gpsbabel`
3. Check Console.app for error messages
4. Reset custom path if configured

## 🙏 Acknowledgments

Built with:
- Swift 5.9+ & SwiftUI
- GPSBabel CLI tool
- macOS 14.0+ SDK

## 📄 License

To be determined

---

**Full Changelog**: See [CHANGELOG.md](./CHANGELOG.md)
**Documentation**: See [README.md](./README.md)
**Settings Guide**: See [SETTINGS_FEATURE.md](./SETTINGS_FEATURE.md)
