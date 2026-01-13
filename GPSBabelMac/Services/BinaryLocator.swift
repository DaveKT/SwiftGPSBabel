//
//  BinaryLocator.swift
//  GPSBabelMac
//
//  Locates the gpsbabel binary on the system
//

import Foundation

enum BinaryLocatorError: LocalizedError {
    case binaryNotFound
    case invalidBinary(path: String)

    var errorDescription: String? {
        switch self {
        case .binaryNotFound:
            return """
            GPSBabel not found. Install it using Homebrew:

                brew install gpsbabel

            Or download from: https://www.gpsbabel.org/download.html
            """
        case .invalidBinary(let path):
            return "Found gpsbabel at \(path), but it doesn't appear to be valid or executable."
        }
    }
}

actor BinaryLocator {
    private var cachedBinaryPath: URL?

    /// Locate the gpsbabel binary using the search strategy defined in the spec
    func locateBinary() async throws -> URL {
        // Return cached path if we've already found it
        if let cached = cachedBinaryPath {
            return cached
        }

        // Define search locations in priority order
        let searchPaths = [
            // 1. Bundled within the app
            Bundle.main.resourceURL?.appendingPathComponent("gpsbabel"),

            // 2. Homebrew Apple Silicon
            URL(fileURLWithPath: "/opt/homebrew/bin/gpsbabel"),

            // 3. Homebrew Intel
            URL(fileURLWithPath: "/usr/local/bin/gpsbabel"),

            // 4. User-specified location (stored in UserDefaults)
            getUserSpecifiedPath(),
        ]
        .compactMap { $0 }

        // Try each location
        for path in searchPaths {
            if await isValidBinary(at: path) {
                cachedBinaryPath = path
                return path
            }
        }

        // 5. Try to find in system PATH
        if let pathFromEnvironment = try? await findInPath() {
            cachedBinaryPath = pathFromEnvironment
            return pathFromEnvironment
        }

        throw BinaryLocatorError.binaryNotFound
    }

    /// Check if a binary exists and is executable at the given path
    private func isValidBinary(at url: URL) async -> Bool {
        let fileManager = FileManager.default
        let path = url.path

        // Check if file exists
        guard fileManager.fileExists(atPath: path) else {
            return false
        }

        // Check if file is executable
        guard fileManager.isExecutableFile(atPath: path) else {
            return false
        }

        // Verify it's actually gpsbabel by running with --version
        do {
            let process = Process()
            process.executableURL = url
            process.arguments = ["--version"]

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            try process.run()
            process.waitUntilExit()

            // If it runs successfully, it's likely the right binary
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    /// Search for gpsbabel in the system PATH
    private func findInPath() async throws -> URL? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["gpsbabel"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            return nil
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !output.isEmpty else {
            return nil
        }

        let url = URL(fileURLWithPath: output)
        return await isValidBinary(at: url) ? url : nil
    }

    /// Get user-specified binary path from UserDefaults
    private func getUserSpecifiedPath() -> URL? {
        guard let pathString = UserDefaults.standard.string(forKey: "customGPSBabelPath"),
              !pathString.isEmpty else {
            return nil
        }
        return URL(fileURLWithPath: pathString)
    }

    /// Set a custom binary path (to be called from Settings)
    func setCustomBinaryPath(_ path: URL?) {
        if let path = path {
            UserDefaults.standard.set(path.path, forKey: "customGPSBabelPath")
        } else {
            UserDefaults.standard.removeObject(forKey: "customGPSBabelPath")
        }
        // Clear cache to force re-validation
        cachedBinaryPath = nil
    }

    /// Get the version of gpsbabel
    func getVersion() async throws -> String {
        let binaryURL = try await locateBinary()

        let process = Process()
        process.executableURL = binaryURL
        process.arguments = ["--version"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
