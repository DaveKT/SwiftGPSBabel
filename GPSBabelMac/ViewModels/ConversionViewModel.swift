//
//  ConversionViewModel.swift
//  GPSBabelMac
//
//  Manages the conversion workflow and UI state
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class ConversionViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var inputFileURL: URL?
    @Published var inputFormat: GPSFormat = .autoDetect
    @Published var outputFormat: GPSFormat = GPSFormat.commonFormats[0] // GPX
    @Published var outputFileURL: URL?
    @Published var isConverting: Bool = false
    @Published var conversionLog: String = "> Ready"
    @Published var lastResult: ConversionResult?
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // Filter options
    @Published var simplifyTrack: Bool = false
    @Published var simplifyDistance: String = "0.001k"
    @Published var removeDuplicates: Bool = false
    @Published var mergeTracks: Bool = false

    // Format lists
    @Published var availableInputFormats: [GPSFormat] = [.autoDetect] + GPSFormat.commonFormats
    @Published var availableOutputFormats: [GPSFormat] = GPSFormat.commonFormats

    // GPSBabel status
    @Published var isBinaryAvailable: Bool = false
    @Published var gpsBabelVersion: String = ""

    private let service = GPSBabelService()

    // MARK: - Initialization

    init() {
        Task {
            await checkBinaryAvailability()
            await loadFormats()
        }
    }

    // MARK: - Binary Detection

    func checkBinaryAvailability() async {
        isBinaryAvailable = await service.testBinary()

        if isBinaryAvailable {
            do {
                gpsBabelVersion = try await service.getVersion()
                appendLog("GPSBabel found: \(gpsBabelVersion.components(separatedBy: "\n").first ?? gpsBabelVersion)")
            } catch {
                appendLog("GPSBabel found but version check failed")
            }
        } else {
            showErrorMessage("""
            GPSBabel not found. Install it using Homebrew:

                brew install gpsbabel

            Or download from: https://www.gpsbabel.org/download.html
            """)
        }
    }

    // MARK: - Format Management

    func loadFormats() async {
        do {
            let inputFormats = try await service.supportedInputFormats()
            let outputFormats = try await service.supportedOutputFormats()

            availableInputFormats = [.autoDetect] + inputFormats
            availableOutputFormats = outputFormats

            appendLog("Loaded \(inputFormats.count) input formats and \(outputFormats.count) output formats")
        } catch {
            // Fall back to common formats
            appendLog("Using built-in format list")
        }
    }

    // MARK: - File Selection

    func selectInputFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            UTType(filenameExtension: "gpx") ?? .data,
            UTType(filenameExtension: "kml") ?? .data,
            UTType(filenameExtension: "fit") ?? .data,
            UTType(filenameExtension: "tcx") ?? .data,
            UTType(filenameExtension: "csv") ?? .data,
            .data
        ]
        panel.message = "Select a GPS data file to convert"

        if panel.runModal() == .OK, let url = panel.url {
            setInputFile(url)
        }
    }

    func setInputFile(_ url: URL) {
        inputFileURL = url

        // Try to detect format from extension
        if let detectedFormat = GPSFormat.detectFromExtension(url) {
            appendLog("Selected: \(url.lastPathComponent) (detected as \(detectedFormat.name))")
        } else {
            appendLog("Selected: \(url.lastPathComponent)")
        }

        // Generate default output filename
        generateOutputFilename()
    }

    func selectOutputLocation() {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = outputFileURL?.lastPathComponent ?? "output.\(outputFormat.extensions.first?.dropFirst() ?? "gpx")"
        panel.message = "Choose where to save the converted file"

        if panel.runModal() == .OK, let url = panel.url {
            outputFileURL = url
            appendLog("Output: \(url.lastPathComponent)")
        }
    }

    private func generateOutputFilename() {
        guard let inputURL = inputFileURL else { return }

        let baseName = inputURL.deletingPathExtension().lastPathComponent
        let outputExtension = outputFormat.extensions.first?.dropFirst() ?? "gpx"
        let outputDirectory = inputURL.deletingLastPathComponent()

        outputFileURL = outputDirectory.appendingPathComponent("\(baseName).\(outputExtension)")
    }

    // MARK: - Format Selection

    func updateOutputFormat(_ format: GPSFormat) {
        outputFormat = format
        generateOutputFilename()
        appendLog("Output format: \(format.name)")
    }

    // MARK: - Conversion

    func convert() async {
        guard !isConverting else { return }
        guard isBinaryAvailable else {
            showErrorMessage("GPSBabel is not installed or not found.")
            return
        }
        guard let inputURL = inputFileURL else {
            showErrorMessage("Please select an input file.")
            return
        }
        guard let outputURL = outputFileURL else {
            showErrorMessage("Please specify an output location.")
            return
        }

        isConverting = true
        conversionLog = ""
        lastResult = nil
        errorMessage = nil

        appendLog("Starting conversion...")
        appendLog("Input: \(inputURL.path)")
        appendLog("Output: \(outputURL.path)")
        appendLog("Format: \(inputFormat.name) → \(outputFormat.name)")

        // Build filter list
        var filters: [GPSBabelFilter] = []
        if simplifyTrack {
            filters.append(.simplify(errorDistance: simplifyDistance))
            appendLog("Filter: Simplify track (error: \(simplifyDistance))")
        }
        if removeDuplicates {
            filters.append(.removeDuplicates)
            appendLog("Filter: Remove duplicates")
        }
        if mergeTracks {
            filters.append(.mergeTracks)
            appendLog("Filter: Merge tracks")
        }

        appendLog("\nRunning gpsbabel...\n")

        do {
            let result = try await service.convert(
                input: inputURL,
                inputFormat: inputFormat.id == "auto" ? nil : inputFormat,
                output: outputURL,
                outputFormat: outputFormat,
                filters: filters
            )

            lastResult = result

            if !result.stdout.isEmpty {
                appendLog("Output:\n\(result.stdout)")
            }
            if !result.stderr.isEmpty {
                appendLog("Messages:\n\(result.stderr)")
            }

            appendLog("\n✓ \(result.statusMessage)")
            appendLog("Duration: \(String(format: "%.2f", result.duration))s")

        } catch {
            appendLog("\n✗ Conversion failed")
            showErrorMessage(error.localizedDescription)
        }

        isConverting = false
    }

    func cancelConversion() async {
        await service.cancel()
        appendLog("\n✗ Conversion cancelled")
        isConverting = false
    }

    // MARK: - Output Actions

    func openOutputInFinder() {
        guard let outputURL = outputFileURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([outputURL])
    }

    func revealOutputFile() {
        guard let outputURL = outputFileURL else { return }
        guard FileManager.default.fileExists(atPath: outputURL.path) else {
            showErrorMessage("Output file does not exist yet. Run the conversion first.")
            return
        }
        NSWorkspace.shared.selectFile(outputURL.path, inFileViewerRootedAtPath: outputURL.deletingLastPathComponent().path)
    }

    // MARK: - Logging

    private func appendLog(_ message: String) {
        if conversionLog.isEmpty || conversionLog == "> Ready" {
            conversionLog = message
        } else {
            conversionLog += "\n" + message
        }
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        appendLog("Error: \(message)")
    }

    // MARK: - Computed Properties

    var canConvert: Bool {
        inputFileURL != nil && outputFileURL != nil && !isConverting && isBinaryAvailable
    }

    var inputFileName: String {
        inputFileURL?.lastPathComponent ?? "No file selected"
    }

    var outputFileName: String {
        outputFileURL?.lastPathComponent ?? "Not set"
    }
}
