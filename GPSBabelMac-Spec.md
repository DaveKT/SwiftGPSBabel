# GPSBabel for macOS - Application Specification

## Overview

Build a native macOS application using SwiftUI that provides a graphical interface for the GPSBabel command-line tool. The app wraps the `gpsbabel` CLI binary, providing an intuitive drag-and-drop interface for converting GPS data files between formats.

## Target Platform

- macOS 14.0+ (Sonoma)
- Swift 5.9+
- SwiftUI
- Xcode 15+

## Core Features

### 1. File Input
- Drag-and-drop zone for input files
- Standard file picker dialog as alternative
- Support for selecting multiple files for batch conversion
- Display file name, size, and detected format after selection

### 2. Format Selection
- Dropdown menu for input format (with auto-detect option)
- Dropdown menu for output format
- Common formats prominently displayed:
  - GPX (GPS Exchange Format)
  - KML (Google Earth)
  - FIT (Garmin)
  - TCX (Training Center XML)
  - CSV (Comma Separated Values)
  - Garmin GDB
- Full format list available via "More Formats..." option

### 3. Conversion Options
- Output file location picker
- Option to convert in place (same directory as input)
- Preserve original file option (always on by default)
- Basic filter options:
  - Simplify tracks (reduce points)
  - Remove duplicates
  - Merge tracks

### 4. Conversion Execution
- Convert button with progress indication
- Real-time log output display
- Cancel button for long operations
- Success/failure notification
- Quick "Open in Finder" button for output file

### 5. Batch Operations
- Queue multiple conversions
- Progress bar showing overall batch progress
- Summary report on completion

## Architecture

### Project Structure

```
GPSBabelMac/
├── GPSBabelMac.xcodeproj
├── GPSBabelMac/
│   ├── GPSBabelMacApp.swift          # App entry point
│   ├── ContentView.swift              # Main window view
│   ├── Models/
│   │   ├── GPSFormat.swift            # Format enum/struct
│   │   ├── ConversionJob.swift        # Conversion job model
│   │   └── ConversionResult.swift     # Result model
│   ├── Services/
│   │   ├── GPSBabelService.swift      # CLI wrapper
│   │   ├── FormatDetector.swift       # Auto-detect input format
│   │   └── BinaryLocator.swift        # Find gpsbabel binary
│   ├── Views/
│   │   ├── DropZoneView.swift         # Drag-and-drop area
│   │   ├── FormatPickerView.swift     # Format selection UI
│   │   ├── ConversionLogView.swift    # Log output display
│   │   ├── BatchProgressView.swift    # Batch conversion progress
│   │   └── SettingsView.swift         # App preferences
│   ├── ViewModels/
│   │   ├── ConversionViewModel.swift  # Main conversion logic
│   │   └── BatchViewModel.swift       # Batch operations
│   ├── Resources/
│   │   └── gpsbabel                   # Bundled binary (optional)
│   └── Assets.xcassets
├── GPSBabelMacTests/
│   ├── GPSBabelServiceTests.swift
│   └── FormatDetectorTests.swift
└── README.md
```

### Key Classes

#### GPSBabelService

```swift
/// Wrapper for the gpsbabel command-line tool
actor GPSBabelService {
    /// Locate the gpsbabel binary
    func locateBinary() async throws -> URL
    
    /// Get list of supported input formats
    func supportedInputFormats() async throws -> [GPSFormat]
    
    /// Get list of supported output formats
    func supportedOutputFormats() async throws -> [GPSFormat]
    
    /// Convert a file from one format to another
    func convert(
        input: URL,
        inputFormat: GPSFormat?,  // nil for auto-detect
        output: URL,
        outputFormat: GPSFormat,
        filters: [GPSBabelFilter]
    ) async throws -> ConversionResult
    
    /// Cancel the current operation
    func cancel()
}
```

#### GPSFormat

```swift
struct GPSFormat: Identifiable, Hashable {
    let id: String           // gpsbabel format code, e.g., "gpx"
    let name: String         // Human readable name
    let extensions: [String] // File extensions, e.g., [".gpx"]
    let supportsRead: Bool
    let supportsWrite: Bool
    let description: String
}
```

#### ConversionJob

```swift
struct ConversionJob: Identifiable {
    let id: UUID
    let inputURL: URL
    let inputFormat: GPSFormat?
    let outputURL: URL
    let outputFormat: GPSFormat
    let filters: [GPSBabelFilter]
    var status: ConversionStatus
}

enum ConversionStatus {
    case pending
    case running
    case completed(ConversionResult)
    case failed(Error)
    case cancelled
}
```

#### ConversionResult

```swift
struct ConversionResult {
    let job: ConversionJob
    let exitCode: Int32
    let stdout: String
    let stderr: String
    let duration: TimeInterval
    let outputFileSize: Int64?
    
    var isSuccess: Bool { exitCode == 0 }
}
```

## GPSBabel Binary Location Strategy

Search for the gpsbabel binary in this order:

1. Bundled within the app: `Bundle.main.resourceURL/gpsbabel`
2. Homebrew Apple Silicon: `/opt/homebrew/bin/gpsbabel`
3. Homebrew Intel: `/usr/local/bin/gpsbabel`
4. System PATH
5. User-specified location (stored in UserDefaults)

If not found, display a helpful message with installation instructions:

```
GPSBabel not found. Install it using Homebrew:

    brew install gpsbabel

Or download from: https://www.gpsbabel.org/download.html
```

## Command-Line Interface Reference

### Basic conversion syntax

```bash
gpsbabel -i <input_format> -f <input_file> -o <output_format> -F <output_file>
```

### Auto-detect input format

Omit the `-i` flag to let gpsbabel auto-detect:

```bash
gpsbabel -f <input_file> -o <output_format> -F <output_file>
```

### List supported formats

```bash
gpsbabel -h          # Brief help with format list
gpsbabel --help      # Full help
gpsbabel -^2         # Machine-readable format list
```

### Common filters

```bash
# Simplify track (remove points within X distance)
-x simplify,error=0.001k

# Remove duplicate waypoints
-x duplicate,location

# Merge all tracks into one
-x track,merge
```

### Example conversions

```bash
# GPX to KML
gpsbabel -i gpx -f input.gpx -o kml -F output.kml

# FIT to GPX
gpsbabel -i garmin_fit -f activity.fit -o gpx -F activity.gpx

# KML to CSV with simplification
gpsbabel -i kml -f route.kml -x simplify,error=0.01k -o csv -F route.csv
```

## UI Mockup (Text Description)

### Main Window Layout

```
┌─────────────────────────────────────────────────────────────┐
│  GPSBabel for Mac                              [─] [□] [×]  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │         Drop GPS files here                         │   │
│  │              or                                     │   │
│  │         [Choose Files...]                           │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Input:   track.fit                          [Auto-detect ▼]│
│  Output:  [GPX - GPS Exchange Format          ▼]            │
│                                                             │
│  Save to: ~/Downloads/track.gpx              [Browse...]    │
│                                                             │
│  Options: □ Simplify track   □ Remove duplicates            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Conversion Log                                      │   │
│  │ ─────────────────────────────────────────────────── │   │
│  │ > Ready                                             │   │
│  │                                                     │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                              [Convert]  [Open Output Folder]│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Settings/Preferences

- Default output directory
- Default output format
- Custom gpsbabel binary path
- Keep conversion history
- Show advanced filters

## Error Handling

### User-Facing Error Messages

| Condition | Message |
|-----------|---------|
| gpsbabel not found | "GPSBabel is not installed. [Install Instructions]" |
| Invalid input file | "Cannot read file: {filename}. The file may be corrupted or in an unsupported format." |
| Permission denied | "Cannot write to {path}. Please choose a different location." |
| Conversion failed | "Conversion failed: {stderr output}" |
| Unknown format | "Could not detect the format of {filename}. Please select the format manually." |

## Testing Requirements

### Unit Tests

- `GPSBabelService` binary location logic
- Format parsing from gpsbabel output
- Command-line argument building
- Result parsing

### Integration Tests

- End-to-end conversion with sample files
- Batch conversion
- Cancellation

### Sample Test Files

Include small sample files in the test bundle:
- `sample.gpx` - Simple GPX with one track
- `sample.kml` - Simple KML with waypoints
- `sample.fit` - Garmin FIT file

## Implementation Phases

### Phase 1: Foundation (MVP)
1. Create Xcode project with SwiftUI
2. Implement `BinaryLocator` to find gpsbabel
3. Implement basic `GPSBabelService` with convert method
4. Create simple UI with file picker, format dropdowns, convert button
5. Display conversion output in log view

### Phase 2: Polish
1. Add drag-and-drop support
2. Implement format auto-detection
3. Add progress indication
4. Improve error messages
5. Add "Open in Finder" for output

### Phase 3: Advanced Features
1. Batch conversion support
2. Filter options (simplify, dedupe, merge)
3. Settings/preferences window
4. Conversion history
5. Menu bar integration

### Phase 4: Distribution
1. Bundle gpsbabel binary (check licensing)
2. Code signing
3. Notarization
4. DMG creation for distribution

## Notes for Claude Code

- Start with Phase 1 and get a working MVP before adding features
- Use Swift concurrency (async/await) throughout
- Follow Apple Human Interface Guidelines for macOS
- Use SF Symbols for icons where appropriate
- The gpsbabel CLI is the source of truth - parse its output rather than hardcoding format lists where practical
- Handle the case where gpsbabel outputs to stderr even on success (it often does)
- Test with real GPS files - the format detection can be tricky

## Resources

- GPSBabel documentation: https://www.gpsbabel.org/htmldoc-development/
- GPSBabel source code: https://github.com/GPSBabel/gpsbabel
- Format reference: https://www.gpsbabel.org/capabilities.html
