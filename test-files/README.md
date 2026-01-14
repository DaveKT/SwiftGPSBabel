# Test GPS Files

This directory contains sample GPX files for testing the GPSBabelMac application.

## Files Included

### 1. sample-track.gpx
**Type**: Track (Activity Recording)
**Points**: 10 track points
**Location**: San Francisco, CA
**Description**: A simulated morning run with elevation changes
**Use Cases**:
- Test track conversion
- Test simplify filter
- Test GPX → KML conversion
- Test time-series data

**Data Includes**:
- Latitude/Longitude coordinates
- Elevation (10.0m to 14.5m)
- Timestamps (1-minute intervals)
- Track metadata (name, type)

### 2. sample-waypoints.gpx
**Type**: Waypoints (Points of Interest)
**Points**: 10 waypoints
**Location**: San Francisco, CA
**Description**: A collection of named points of interest
**Use Cases**:
- Test waypoint conversion
- Test CSV export with names
- Test symbol/icon preservation
- Test duplicate removal filter

**Data Includes**:
- Named locations (Coffee Shop, Viewpoint, Summit, etc.)
- Descriptions
- Symbols/Icons
- Elevation data
- Timestamps

### 3. sample-route.gpx
**Type**: Route (Planned Navigation)
**Points**: 10 route points
**Location**: San Francisco Downtown
**Description**: A planned walking tour route
**Use Cases**:
- Test route vs track distinction
- Test route point conversion
- Test navigation format exports
- Test GPX → TCX conversion

**Data Includes**:
- Route points with names
- Descriptions for each point
- Elevation data
- Route metadata

### 4. sample-bike-ride.gpx
**Type**: Track (Cycling Activity)
**Points**: 10 track points
**Location**: San Francisco, CA
**Description**: A simulated afternoon bike ride
**Use Cases**:
- Test cycling-specific conversions
- Test FIT format export
- Test track merging
- Test time-based filtering

**Data Includes**:
- Longer time intervals (3 minutes)
- Varying elevation profile
- Activity type metadata

## Testing Scenarios

### Basic Conversion
1. Open GPSBabelMac
2. Drag `sample-track.gpx` into the app
3. Select output format (e.g., KML)
4. Click "Convert"
5. Verify output file is created

### Filter Testing

**Simplify Track**:
- Use `sample-track.gpx` or `sample-bike-ride.gpx`
- Enable "Simplify track" filter
- Set error distance: 0.001k
- Should reduce some points while maintaining shape

**Remove Duplicates**:
- Use `sample-waypoints.gpx`
- Enable "Remove duplicates" filter
- Should detect any duplicate locations

**Merge Tracks**:
- Requires multiple tracks (not in these samples)
- Can test by converting the same file twice and combining

### Format Conversion Matrix

| Input File | Output Format | Expected Result |
|------------|---------------|-----------------|
| sample-track.gpx | KML | Google Earth viewable track |
| sample-waypoints.gpx | CSV | Spreadsheet with coordinates |
| sample-route.gpx | TCX | Garmin training format |
| sample-bike-ride.gpx | FIT | Garmin activity file |
| Any GPX | GPX | Should preserve all data |

### Auto-Detection Testing
- Select "Auto-detect" for input format
- All files should be recognized as GPX
- Conversion should work without manual format selection

## File Characteristics

All test files:
- ✅ Valid GPX 1.1 format
- ✅ 10 data points each (small for quick testing)
- ✅ Include elevation data
- ✅ Include timestamps
- ✅ Include metadata
- ✅ Use realistic coordinates (San Francisco Bay Area)
- ✅ Include proper XML namespaces

## Expected Output

When converting these files, you should see:
- No errors in conversion log
- Output file created successfully
- File size appropriate for 10 points
- Proper format conversion maintaining data integrity

## Troubleshooting

**If conversion fails**:
1. Check Settings (⌘,) to verify gpsbabel is detected
2. Check the conversion log for error messages
3. Try with auto-detect input format
4. Verify output directory is writable

**If output is empty**:
- Some formats may not support all data types
- Routes may not convert well to track-only formats
- Check gpsbabel capabilities for format combination

## Creating Your Own Test Files

To create additional test files:
1. Use these files as templates
2. Modify coordinates to match your test location
3. Add/remove points as needed
4. Ensure XML is well-formed
5. Validate against GPX 1.1 schema if possible

## Real GPS Data

For testing with actual GPS data:
- Export from your GPS device
- Export from fitness apps (Strava, Garmin Connect, etc.)
- Download sample files from GPSBabel website
- Use OpenStreetMap GPS traces

## License

These test files are in the public domain and can be used freely for testing purposes.
