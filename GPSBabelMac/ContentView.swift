//
//  ContentView.swift
//  GPSBabelMac
//
//  Main window view
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ConversionViewModel()

    var body: some View {
        VStack(spacing: 20) {
            // Header
            headerSection

            // File Selection Area
            fileSelectionSection

            // Format Selection
            formatSelectionSection

            // Output Location
            outputLocationSection

            // Filter Options
            filterOptionsSection

            // Conversion Log
            ConversionLogView(
                log: viewModel.conversionLog,
                isConverting: viewModel.isConverting
            )
            .frame(height: 180)

            // Action Buttons
            actionButtonsSection
        }
        .padding(20)
        .frame(minWidth: 700, minHeight: 600)
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { _ in
            Button("OK") {
                viewModel.showError = false
            }
        } message: { message in
            Text(message)
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack {
            Image(systemName: "map.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text("GPSBabel for Mac")
                    .font(.title2)
                    .fontWeight(.semibold)

                if viewModel.isBinaryAvailable {
                    Text("Ready to convert GPS files")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("GPSBabel not found - please install it")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            }

            Spacer()
        }
    }

    private var fileSelectionSection: some View {
        VStack(spacing: 12) {
            // Drop zone or file info
            if let inputURL = viewModel.inputFileURL {
                fileInfoView(url: inputURL)
            } else {
                dropZoneView
            }
        }
    }

    private var dropZoneView: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.down.doc")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("Drop GPS files here")
                .font(.headline)

            Text("or")
                .foregroundStyle(.secondary)

            Button("Choose Files...") {
                viewModel.selectInputFile()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundStyle(Color(nsColor: .separatorColor))
        )
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }

            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    return
                }

                DispatchQueue.main.async {
                    viewModel.setInputFile(url)
                }
            }

            return true
        }
    }

    private func fileInfoView(url: URL) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .font(.system(size: 32))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(url.lastPathComponent)
                    .font(.headline)

                if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                   let fileSize = attributes[.size] as? Int64 {
                    Text(formatFileSize(fileSize))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button("Change") {
                viewModel.selectInputFile()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    private var formatSelectionSection: some View {
        VStack(spacing: 8) {
            FormatPickerView(
                label: "Input:",
                formats: viewModel.availableInputFormats,
                selectedFormat: $viewModel.inputFormat
            )

            FormatPickerView(
                label: "Output:",
                formats: viewModel.availableOutputFormats,
                selectedFormat: Binding(
                    get: { viewModel.outputFormat },
                    set: { viewModel.updateOutputFormat($0) }
                )
            )
        }
    }

    private var outputLocationSection: some View {
        HStack {
            Text("Save to:")
                .frame(width: 80, alignment: .trailing)

            Text(viewModel.outputFileName)
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Browse...") {
                viewModel.selectOutputLocation()
            }
        }
    }

    private var filterOptionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Options:")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                Toggle("Simplify track", isOn: $viewModel.simplifyTrack)

                if viewModel.simplifyTrack {
                    TextField("Error distance", text: $viewModel.simplifyDistance)
                        .frame(width: 80)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle("Remove duplicates", isOn: $viewModel.removeDuplicates)

                Toggle("Merge tracks", isOn: $viewModel.mergeTracks)

                Spacer()
            }
        }
    }

    private var actionButtonsSection: some View {
        HStack {
            Spacer()

            if let outputURL = viewModel.outputFileURL,
               FileManager.default.fileExists(atPath: outputURL.path) {
                Button("Open Output Folder") {
                    viewModel.revealOutputFile()
                }
            }

            if viewModel.isConverting {
                Button("Cancel") {
                    Task {
                        await viewModel.cancelConversion()
                    }
                }
                .buttonStyle(.bordered)
            }

            Button("Convert") {
                Task {
                    await viewModel.convert()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canConvert)
        }
    }

    // MARK: - Helper Functions

    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview {
    ContentView()
}
