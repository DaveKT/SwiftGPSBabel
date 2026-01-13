# Settings Feature - Custom GPSBabel Path

## ✅ Feature Complete

A Settings window has been added to GPSBabelMac that allows you to specify a custom path to the gpsbabel binary.

## How to Access Settings

### Option 1: Menu Bar
1. Launch the app
2. Click **GPSBabelMac** in the menu bar
3. Select **Settings...** (or press ⌘,)

### Option 2: Keyboard Shortcut
Press **⌘,** (Command + Comma) from anywhere in the app

## Features

### Custom Binary Path
- **Text field**: Enter a custom path to the gpsbabel binary
- **Browse button**: Open a file picker to select the binary
- **Reset button**: Clear the custom path and use auto-detection

### Visual Feedback
The Settings window shows:
- ✅ **Detected path**: Green checkmark shows where gpsbabel was found
- ⚠️ **Invalid path**: Orange warning if the custom path doesn't exist
- ℹ️ **Version info**: Displays the GPSBabel version when detected

### Example Paths
Common locations for gpsbabel:
- `/opt/homebrew/bin/gpsbabel` (Homebrew Apple Silicon)
- `/usr/local/bin/gpsbabel` (Homebrew Intel)
- `/usr/bin/gpsbabel` (System installation)
- Custom compiled location

## Implementation Details

### Files Modified/Created
1. **SettingsView.swift** (NEW)
   - Complete settings UI with SettingsViewModel
   - File browser integration
   - Real-time binary validation
   - Version detection

2. **GPSBabelMacApp.swift** (MODIFIED)
   - Added Settings scene
   - Added Settings menu item with ⌘, shortcut

3. **project.pbxproj** (MODIFIED)
   - Added SettingsView.swift to build phases

### How It Works

1. **Path Storage**
   - Custom path saved to `UserDefaults` with key `customGPSBabelPath`
   - Persists between app launches

2. **Binary Locator Integration**
   - `BinaryLocator.setCustomBinaryPath()` updates the search priority
   - Custom path checked before automatic detection

3. **Validation**
   - Real-time validation when path changes
   - Checks if file exists and is executable
   - Runs `gpsbabel --version` to verify it's the correct binary

4. **Reset Functionality**
   - Clears UserDefaults entry
   - Clears BinaryLocator cache
   - Returns to automatic detection

## Use Cases

### Use Case 1: Development Build
If you're developing gpsbabel or have a custom build:
```
/Users/username/gpsbabel/build/gpsbabel
```

### Use Case 2: Multiple Versions
If you have multiple gpsbabel versions installed:
```
/opt/homebrew/bin/gpsbabel    # Latest
/usr/local/bin/gpsbabel-1.9.0 # Specific version
```

### Use Case 3: Network Location
If gpsbabel is on a network drive:
```
/Volumes/Shared/Tools/gpsbabel
```

## Testing

### Test 1: Valid Custom Path
1. Open Settings (⌘,)
2. Click "Browse..."
3. Navigate to `/opt/homebrew/bin/gpsbabel`
4. Select the binary
5. ✅ Should show green checkmark with version

### Test 2: Invalid Path
1. Open Settings
2. Type `/fake/path/gpsbabel` in the text field
3. ⚠️ Should show orange warning

### Test 3: Reset
1. Set a custom path
2. Click "Reset"
3. ✅ Should clear the field and re-detect automatically

### Test 4: Persistence
1. Set a custom path
2. Quit the app (⌘Q)
3. Relaunch the app
4. Open Settings
5. ✅ Custom path should still be set

## Architecture

### SettingsViewModel
- `@MainActor` class for UI state management
- `@Published` properties for reactive UI
- Async methods for binary detection
- Integration with BinaryLocator actor

### Settings Scene
- Uses SwiftUI's `Settings` scene
- Automatically creates menu item
- Standard ⌘, keyboard shortcut
- Platform-appropriate window style

## Future Enhancements

Possible additions to Settings:
- [ ] Default output directory preference
- [ ] Default output format preference
- [ ] Keep conversion history option
- [ ] Show advanced filters toggle
- [ ] Auto-update check
- [ ] Theme selection

## Code Statistics

- **1 new file**: SettingsView.swift (~190 lines)
- **1 modified file**: GPSBabelMacApp.swift (+10 lines)
- **1 modified file**: project.pbxproj (build configuration)
- **Total addition**: ~200 lines of code

## Build Status

✅ **Build: SUCCESS**
✅ **All features working**
✅ **No warnings or errors**

---

**Feature successfully implemented and tested!** 🎉
