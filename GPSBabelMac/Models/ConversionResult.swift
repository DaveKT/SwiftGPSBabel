//
//  ConversionResult.swift
//  GPSBabelMac
//
//  Represents the result of a GPS file conversion
//

import Foundation

struct ConversionResult: Hashable {
    let jobId: UUID
    let exitCode: Int32
    let stdout: String
    let stderr: String
    let duration: TimeInterval
    let outputFileSize: Int64?

    var isSuccess: Bool {
        exitCode == 0
    }

    /// Get a user-friendly status message
    var statusMessage: String {
        if isSuccess {
            if let size = outputFileSize {
                let formatter = ByteCountFormatter()
                formatter.countStyle = .file
                let sizeString = formatter.string(fromByteCount: size)
                return "Conversion successful. Output file size: \(sizeString)"
            } else {
                return "Conversion successful."
            }
        } else {
            return "Conversion failed with exit code \(exitCode)."
        }
    }

    /// Get detailed error message from stderr if available
    var errorMessage: String? {
        guard !isSuccess else { return nil }

        // GPSBabel often writes to stderr even on success, so we check exit code first
        if !stderr.isEmpty {
            return stderr
        } else if !stdout.isEmpty {
            return stdout
        } else {
            return "Conversion failed with exit code \(exitCode)"
        }
    }

    /// Get the full output log (stdout + stderr)
    var fullLog: String {
        var log = ""
        if !stdout.isEmpty {
            log += "STDOUT:\n\(stdout)\n"
        }
        if !stderr.isEmpty {
            if !log.isEmpty { log += "\n" }
            log += "STDERR:\n\(stderr)"
        }
        if log.isEmpty {
            log = "No output from gpsbabel"
        }
        return log
    }
}
