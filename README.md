# GPSBabel for macOS

A native macOS application providing a graphical interface for the GPSBabel command-line tool.

## Overview

GPSBabel for macOS is a SwiftUI application that wraps the `gpsbabel` CLI binary, providing an intuitive interface for converting GPS data files between formats.

## Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15+
- Swift 5.9+
- GPSBabel installed (via Homebrew or manual installation)

## Installation

### Installing GPSBabel

The app requires the `gpsbabel` command-line tool. Install it using Homebrew:

```bash
brew install gpsbabel
```

Or download from: https://www.gpsbabel.org/download.html

### Building the App

✅ **Build Status: SUCCESS**

1. Open `GPSBabelMac.xcodeproj` in Xcode
2. Select your development team in the project settings (if needed)
3. Build and run (⌘R)

The project builds successfully with no errors or warnings!

## Project Structure

```
GPSBabelMac/
├── GPSBabelMac.xcodeproj
├── GPSBabelMac/
│   ├── GPSBabelMacApp.swift          # App entry point
│   ├── ContentView.swift              # Main window view
│   ├── Models/
│   │   ├── GPSFormat.swift            # Format definitions
│   │   ├── ConversionJob.swift        # Job model
│   │   └── ConversionResult.swift     # Result model
│   ├── Services/
│   │   ├── GPSBabelService.swift      # CLI wrapper
│   │   └── BinaryLocator.swift        # Find gpsbabel binary
│   ├── Views/
│   │   ├── FormatPickerView.swift     # Format selection UI
│   │   └── ConversionLogView.swift    # Log output display
│   ├── ViewModels/
│   │   └── ConversionViewModel.swift  # Main conversion logic
│   └── Resources/
└── README.md
```

## Current Implementation Status

### Phase 1 - Foundation (Complete! ✅)

- ✅ Project structure created
- ✅ BinaryLocator implemented (searches for gpsbabel binary)
- ✅ Models created (GPSFormat, ConversionJob, ConversionResult)
- ✅ GPSBabelService implemented (core conversion functionality)
- ✅ ConversionViewModel implemented (state management)
- ✅ UI components completed (ContentView, FormatPickerView, ConversionLogView)
- ✅ All source files compile successfully

### Features Implemented

#### BinaryLocator

Searches for the `gpsbabel` binary in the following order:

1. Bundled within the app
2. Homebrew Apple Silicon: `/opt/homebrew/bin/gpsbabel`
3. Homebrew Intel: `/usr/local/bin/gpsbabel`
4. System PATH
5. User-specified location (UserDefaults)

#### GPSBabelService

- `locateBinary()` - Find the gpsbabel binary
- `supportedInputFormats()` - Get list of supported input formats
- `supportedOutputFormats()` - Get list of supported output formats
- `convert()` - Convert a file between formats
- `cancel()` - Cancel current operation
- `getVersion()` - Get GPSBabel version

#### Models

- **GPSFormat**: Represents a GPS file format with metadata
- **ConversionJob**: Represents a conversion task with input/output settings
- **ConversionResult**: Contains the result of a conversion operation
- **GPSBabelFilter**: Enum for common filters (simplify, dedupe, merge)

#### ConversionViewModel

- File selection (picker and drag-and-drop)
- Format selection with auto-detect
- Filter options (simplify, remove duplicates, merge tracks)
- Conversion execution with progress tracking
- Real-time logging
- Error handling and user feedback

#### UI Components

- **ContentView**: Complete main window with all conversion features
- **FormatPickerView**: Format selection dropdowns
- **ConversionLogView**: Real-time log display with auto-scrolling
- Drag-and-drop zone for file input
- File info display with size formatting
- Action buttons (Convert, Cancel, Open Output Folder)

## Features

### Current Features (Phase 1 MVP)

- ✅ File selection via picker or drag-and-drop
- ✅ Format selection (input/output) with common formats
- ✅ Auto-detect input format option
- ✅ Filter options: simplify tracks, remove duplicates, merge tracks
- ✅ Real-time conversion log with auto-scroll
- ✅ Progress indication during conversion
- ✅ Error handling with user-friendly messages
- ✅ Open output file in Finder
- ✅ File size display
- ✅ GPSBabel version detection
- ✅ Comprehensive binary location search

## Next Steps (Phase 2)

1. Test with real GPS files
2. Improve format auto-detection
3. Add batch conversion support
4. Add conversion history
5. Settings/preferences window
6. Advanced filter options
7. Menu bar commands

## Architecture

The app uses:

- **SwiftUI** for the user interface
- **Swift Concurrency** (async/await) throughout
- **Actor** pattern for thread-safe service access (GPSBabelService, BinaryLocator)
- **MVVM** architecture with ObservableObject ViewModels
- **@MainActor** for UI-bound ViewModels

## License

To be determined

## Resources

- [GPSBabel Documentation](https://www.gpsbabel.org/htmldoc-development/)
- [GPSBabel GitHub](https://github.com/GPSBabel/gpsbabel)
- [Format Reference](https://www.gpsbabel.org/capabilities.html)
