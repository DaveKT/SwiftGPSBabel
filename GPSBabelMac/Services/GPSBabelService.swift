//
//  GPSBabelService.swift
//  GPSBabelMac
//
//  Wrapper for the gpsbabel command-line tool
//

import Foundation

enum GPSBabelServiceError: LocalizedError {
    case binaryNotFound
    case invalidInputFile(URL)
    case invalidOutputPath(URL)
    case conversionFailed(exitCode: Int32, stderr: String)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .binaryNotFound:
            return "GPSBabel binary not found. Please install GPSBabel."
        case .invalidInputFile(let url):
            return "Cannot read input file: \(url.lastPathComponent)"
        case .invalidOutputPath(let url):
            return "Cannot write to output location: \(url.path)"
        case .conversionFailed(let code, let stderr):
            return "Conversion failed with exit code \(code): \(stderr)"
        case .cancelled:
            return "Conversion was cancelled"
        }
    }
}

actor GPSBabelService {
    private let binaryLocator = BinaryLocator()
    private var currentProcess: Process?

    /// Locate the gpsbabel binary
    func locateBinary() async throws -> URL {
        try await binaryLocator.locateBinary()
    }

    /// Get list of supported input formats
    func supportedInputFormats() async throws -> [GPSFormat] {
        let formats = try await fetchAllFormats()
        return formats.filter { $0.supportsRead }
    }

    /// Get list of supported output formats
    func supportedOutputFormats() async throws -> [GPSFormat] {
        let formats = try await fetchAllFormats()
        return formats.filter { $0.supportsWrite }
    }

    /// Fetch all formats from gpsbabel using the -^2 flag
    private func fetchAllFormats() async throws -> [GPSFormat] {
        let binaryURL = try await locateBinary()

        let process = Process()
        process.executableURL = binaryURL
        process.arguments = ["-^2"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe() // Ignore stderr

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            return GPSFormat.commonFormats
        }

        let parsedFormats = GPSFormat.parseFromMachineOutput(output)
        return parsedFormats.isEmpty ? GPSFormat.commonFormats : parsedFormats
    }

    /// Convert a file from one format to another
    func convert(
        input: URL,
        inputFormat: GPSFormat?,
        output: URL,
        outputFormat: GPSFormat,
        filters: [GPSBabelFilter] = []
    ) async throws -> ConversionResult {
        // Validate input file exists
        guard FileManager.default.fileExists(atPath: input.path) else {
            throw GPSBabelServiceError.invalidInputFile(input)
        }

        // Validate output directory exists
        let outputDirectory = output.deletingLastPathComponent()
        guard FileManager.default.fileExists(atPath: outputDirectory.path) else {
            throw GPSBabelServiceError.invalidOutputPath(output)
        }

        // Start accessing security-scoped resources for input
        let inputAccess = input.startAccessingSecurityScopedResource()
        defer {
            if inputAccess { input.stopAccessingSecurityScopedResource() }
        }

        let binaryURL = try await locateBinary()
        let startTime = Date()

        // Create a temporary file for output that we have full access to
        let tempDir = FileManager.default.temporaryDirectory
        let tempOutput = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension(output.pathExtension)

        defer {
            // Clean up temporary file
            try? FileManager.default.removeItem(at: tempOutput)
        }

        // Build command-line arguments
        var arguments: [String] = []

        // Input format and file
        if let inputFormat = inputFormat, inputFormat.id != "auto" {
            arguments.append("-i")
            arguments.append(inputFormat.id)
        }
        arguments.append("-f")
        arguments.append(input.path)

        // Filters
        for filter in filters {
            let filterArgs = filter.argument.split(separator: " ").map(String.init)
            arguments.append(contentsOf: filterArgs)
        }

        // Output format and file (use temp file)
        arguments.append("-o")
        arguments.append(outputFormat.id)
        arguments.append("-F")
        arguments.append(tempOutput.path)

        // Create and configure process
        let process = Process()
        process.executableURL = binaryURL
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        // Store process reference for cancellation
        currentProcess = process

        // Run the process
        try process.run()
        process.waitUntilExit()

        // Clear current process reference
        currentProcess = nil

        // Calculate duration
        let duration = Date().timeIntervalSince(startTime)

        // Read output
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""

        // Check if cancelled
        if process.terminationReason == .uncaughtSignal {
            throw GPSBabelServiceError.cancelled
        }

        // Get output file size and copy to final destination if successful
        var outputFileSize: Int64?
        if process.terminationStatus == 0 {
            // Start accessing security-scoped resources for output
            let outputAccess = output.startAccessingSecurityScopedResource()
            let outputDirAccess = outputDirectory.startAccessingSecurityScopedResource()

            defer {
                if outputAccess { output.stopAccessingSecurityScopedResource() }
                if outputDirAccess { outputDirectory.stopAccessingSecurityScopedResource() }
            }

            // Copy from temp location to final destination
            do {
                // Remove existing file if it exists
                if FileManager.default.fileExists(atPath: output.path) {
                    try FileManager.default.removeItem(at: output)
                }

                // Copy temp file to final destination
                try FileManager.default.copyItem(at: tempOutput, to: output)

                // Get file size
                if let attributes = try? FileManager.default.attributesOfItem(atPath: output.path),
                   let size = attributes[.size] as? Int64 {
                    outputFileSize = size
                }
            } catch {
                throw GPSBabelServiceError.conversionFailed(
                    exitCode: -1,
                    stderr: "Failed to copy output file to destination: \(error.localizedDescription)"
                )
            }
        }

        let result = ConversionResult(
            jobId: UUID(), // This will be replaced by the job's ID
            exitCode: process.terminationStatus,
            stdout: stdout,
            stderr: stderr,
            duration: duration,
            outputFileSize: outputFileSize
        )

        // Throw error if conversion failed
        if !result.isSuccess {
            throw GPSBabelServiceError.conversionFailed(
                exitCode: result.exitCode,
                stderr: stderr.isEmpty ? stdout : stderr
            )
        }

        return result
    }

    /// Cancel the current conversion operation
    func cancel() {
        if let process = currentProcess, process.isRunning {
            process.terminate()
        }
    }

    /// Get the version of GPSBabel
    func getVersion() async throws -> String {
        try await binaryLocator.getVersion()
    }

    /// Test if GPSBabel is available and working
    func testBinary() async -> Bool {
        do {
            _ = try await locateBinary()
            return true
        } catch {
            return false
        }
    }
}
