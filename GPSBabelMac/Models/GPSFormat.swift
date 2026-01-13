//
//  GPSFormat.swift
//  GPSBabelMac
//
//  Represents a GPS file format supported by GPSBabel
//

import Foundation

struct GPSFormat: Identifiable, Hashable, Codable {
    let id: String           // gpsbabel format code, e.g., "gpx"
    let name: String         // Human readable name
    let extensions: [String] // File extensions, e.g., [".gpx"]
    let supportsRead: Bool
    let supportsWrite: Bool
    let description: String

    init(
        id: String,
        name: String,
        extensions: [String] = [],
        supportsRead: Bool = true,
        supportsWrite: Bool = true,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.extensions = extensions
        self.supportsRead = supportsRead
        self.supportsWrite = supportsWrite
        self.description = description
    }
}

extension GPSFormat {
    /// Common GPS formats prominently displayed
    static let commonFormats: [GPSFormat] = [
        GPSFormat(
            id: "gpx",
            name: "GPX - GPS Exchange Format",
            extensions: [".gpx"],
            description: "GPS Exchange Format - the standard for GPS data exchange"
        ),
        GPSFormat(
            id: "kml",
            name: "KML - Google Earth",
            extensions: [".kml"],
            description: "Google Earth KML format"
        ),
        GPSFormat(
            id: "garmin_fit",
            name: "FIT - Garmin",
            extensions: [".fit"],
            description: "Garmin FIT activity files"
        ),
        GPSFormat(
            id: "gtrnctr",
            name: "TCX - Training Center XML",
            extensions: [".tcx"],
            description: "Garmin Training Center XML"
        ),
        GPSFormat(
            id: "csv",
            name: "CSV - Comma Separated Values",
            extensions: [".csv"],
            description: "Comma-separated values"
        ),
        GPSFormat(
            id: "gdb",
            name: "GDB - Garmin Database",
            extensions: [".gdb"],
            description: "Garmin GPS database"
        ),
    ]

    /// Auto-detect option for input format
    static let autoDetect = GPSFormat(
        id: "auto",
        name: "Auto-detect",
        description: "Automatically detect the input format"
    )

    /// Check if a file extension matches this format
    func matchesExtension(_ fileExtension: String) -> Bool {
        let normalized = fileExtension.lowercased()
        return extensions.contains { ext in
            ext.lowercased() == normalized || ext.lowercased() == ".\(normalized)"
        }
    }

    /// Try to detect format from file extension
    static func detectFromExtension(_ url: URL) -> GPSFormat? {
        let fileExtension = url.pathExtension.lowercased()
        return commonFormats.first { format in
            format.matchesExtension(fileExtension)
        }
    }
}

extension GPSFormat {
    /// Parse format information from gpsbabel -^2 output
    /// This parses the machine-readable format list
    static func parseFromMachineOutput(_ output: String) -> [GPSFormat] {
        var formats: [GPSFormat] = []

        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            // Format: type	id	parent	description
            // Example: file	gpx	gpx	GPX XML
            let components = line.components(separatedBy: "\t")
            guard components.count >= 4 else { continue }

            let type = components[0]
            let formatId = components[1]
            let description = components[3]

            // Determine capabilities based on type
            let supportsRead = type == "file" || type == "serial"
            let supportsWrite = type == "file"

            // Try to infer extensions from the ID or description
            let extensions = inferExtensions(from: formatId, description: description)

            let format = GPSFormat(
                id: formatId,
                name: description,
                extensions: extensions,
                supportsRead: supportsRead,
                supportsWrite: supportsWrite,
                description: description
            )

            formats.append(format)
        }

        return formats
    }

    /// Infer file extensions from format ID and description
    private static func inferExtensions(from id: String, description: String) -> [String] {
        // Common mappings
        let knownExtensions: [String: [String]] = [
            "gpx": [".gpx"],
            "kml": [".kml"],
            "garmin_fit": [".fit"],
            "gtrnctr": [".tcx"],
            "csv": [".csv"],
            "gdb": [".gdb"],
            "nmea": [".nmea", ".txt"],
            "gtm": [".gtm"],
            "an1": [".an1"],
            "gpsman": [".gpsman"],
        ]

        if let extensions = knownExtensions[id] {
            return extensions
        }

        // Try to use the ID as the extension if it looks like one
        if id.count <= 4 && !id.contains("_") {
            return [".\(id)"]
        }

        return []
    }
}
