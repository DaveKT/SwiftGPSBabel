# Changelog

All notable changes to GPSBabel for macOS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2024-01-13

### Added
- **Settings Window**: New preferences window accessible via ⌘, or menu
  - Custom binary path configuration with text field
  - Browse button to select gpsbabel binary via file picker
  - Reset button to clear custom path and use auto-detection
  - Real-time binary validation with visual feedback (green checkmark/orange warning)
  - GPSBabel version display when binary is detected
- **Sandbox Permissions**: Added entitlements for read-only access to:
  - `/opt/homebrew/` (Homebrew Apple Silicon)
  - `/usr/local/` (Homebrew Intel)
  - `/usr/bin/` (System installations)
- **SettingsView.swift**: Complete settings UI with SettingsViewModel (~190 lines)
- **Settings Scene**: Integrated with SwiftUI's Settings API for native macOS experience

### Fixed
- **Format Dropdown Parsing**: Corrected parsing of gpsbabel `-^2` output
  - Now correctly reads column structure: `type	flags	id	extension	description`
  - Previously was reading wrong columns causing blank/invalid entries
- **Format Capabilities**: Properly parse flags field (rwrwrw) to determine read/write support
- **File Extensions**: Extract extensions from gpsbabel output, including multi-extension formats (e.g., `tcx/crs/hst/xml`)
- **Format Filtering**: Skip internal formats that don't support reading or writing
- **Dropdown Display**: All format dropdowns now show valid entries with proper names
  - Input dropdown: ~60+ formats with read support
  - Output dropdown: ~50+ formats with write support

### Changed
- **GPSFormat.swift**: Complete rewrite of `parseFromMachineOutput()` method
- **Entitlements**: Updated to allow access to common binary installation directories
- **GPSBabelMacApp.swift**: Added Settings scene to app structure

### Technical
- Fixed async/await issues in SettingsViewModel with actor-based BinaryLocator
- Improved error handling for binary path validation
- Added persistent storage for custom binary path via UserDefaults
- Enhanced format extension inference with better fallback logic

## [1.0.0] - 2024-01-13

### Added
- **Initial Release**: Complete Phase 1 implementation
- **Core Conversion Features**:
  - File selection via picker dialog
  - Drag-and-drop file input support
  - Format selection dropdowns (input/output)
  - Auto-detect input format option
  - Real-time conversion log with auto-scrolling
  - Progress indication during conversion
  - Conversion filters: simplify tracks, remove duplicates, merge tracks
- **UI Components**:
  - ContentView: Main conversion interface
  - FormatPickerView: Format selection component
  - ConversionLogView: Real-time log display
  - Drop zone with visual feedback
  - File info display with size formatting
- **Services**:
  - BinaryLocator: Intelligent gpsbabel binary detection
  - GPSBabelService: Complete async/await CLI wrapper
- **Models**:
  - GPSFormat: Format definitions with metadata
  - ConversionJob: Job tracking with status management
  - ConversionResult: Rich result data with timing and file size
  - GPSBabelFilter: Filter options enum
- **ViewModels**:
  - ConversionViewModel: Complete MVVM state management
- **Binary Detection**: Automatic search across multiple locations:
  1. Bundled within app
  2. Homebrew Apple Silicon (`/opt/homebrew/bin`)
  3. Homebrew Intel (`/usr/local/bin`)
  4. System PATH
  5. User-specified location (UserDefaults)
- **Error Handling**: User-friendly error messages and validation
- **File Operations**:
  - Open output file in Finder
  - Conversion cancellation support
- **Architecture**:
  - SwiftUI for UI
  - Swift Concurrency (async/await)
  - Actor pattern for thread safety
  - MVVM architecture

### Technical Details
- macOS 14.0+ (Sonoma) target
- Swift 5.9+
- App sandboxing with file access permissions
- ~1,384 lines of Swift code across 10 source files
- Zero warnings or errors on build

## Future Plans

### [1.2.0] - Planned
- Batch conversion support
- Conversion history tracking
- Quick conversion presets
- Enhanced error recovery

### [2.0.0] - Planned
- Advanced filter options with custom parameters
- Menu bar quick actions
- Keyboard shortcuts for common operations
- Format favorites/bookmarks
- App icon design
- Code signing and notarization
- Distribution via DMG

---

[1.1.0]: https://github.com/yourusername/GPSBabelMac/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/yourusername/GPSBabelMac/releases/tag/v1.0.0
