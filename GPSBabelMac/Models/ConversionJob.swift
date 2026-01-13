//
//  ConversionJob.swift
//  GPSBabelMac
//
//  Represents a GPS file conversion job
//

import Foundation

struct ConversionJob: Identifiable, Hashable {
    let id: UUID
    let inputURL: URL
    let inputFormat: GPSFormat?  // nil for auto-detect
    let outputURL: URL
    let outputFormat: GPSFormat
    let filters: [GPSBabelFilter]
    var status: ConversionStatus

    init(
        id: UUID = UUID(),
        inputURL: URL,
        inputFormat: GPSFormat?,
        outputURL: URL,
        outputFormat: GPSFormat,
        filters: [GPSBabelFilter] = [],
        status: ConversionStatus = .pending
    ) {
        self.id = id
        self.inputURL = inputURL
        self.inputFormat = inputFormat
        self.outputURL = outputURL
        self.outputFormat = outputFormat
        self.filters = filters
        self.status = status
    }
}

enum ConversionStatus: Hashable {
    case pending
    case running
    case completed(ConversionResult)
    case failed(String)  // Error message
    case cancelled
}

/// Filter options for GPSBabel
enum GPSBabelFilter: Hashable, Codable {
    case simplify(errorDistance: String)  // e.g., "0.001k"
    case removeDuplicates
    case mergeTracks

    /// Get the command-line argument for this filter
    var argument: String {
        switch self {
        case .simplify(let distance):
            return "-x simplify,error=\(distance)"
        case .removeDuplicates:
            return "-x duplicate,location"
        case .mergeTracks:
            return "-x track,merge"
        }
    }

    var displayName: String {
        switch self {
        case .simplify(let distance):
            return "Simplify track (error: \(distance))"
        case .removeDuplicates:
            return "Remove duplicate waypoints"
        case .mergeTracks:
            return "Merge all tracks"
        }
    }
}
