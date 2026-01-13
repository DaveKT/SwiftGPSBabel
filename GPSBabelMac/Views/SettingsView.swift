//
//  SettingsView.swift
//  GPSBabelMac
//
//  Settings and preferences for the application
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "gear")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)

                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()
            }

            Divider()

            // GPSBabel Binary Path Section
            VStack(alignment: .leading, spacing: 12) {
                Text("GPSBabel Binary")
                    .font(.headline)

                Text("Specify a custom path to the gpsbabel binary if it's not automatically detected.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    TextField("Custom binary path (optional)", text: $viewModel.customBinaryPath)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)

                    Button("Browse...") {
                        viewModel.selectBinaryPath()
                    }

                    Button("Reset") {
                        viewModel.resetBinaryPath()
                    }
                    .disabled(viewModel.customBinaryPath.isEmpty)
                }

                if let detectedPath = viewModel.detectedBinaryPath {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Detected: \(detectedPath)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else if !viewModel.customBinaryPath.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Binary not found at this path")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                if let version = viewModel.binaryVersion {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                        Text("Version: \(version)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)

            Spacer()

            // Action Buttons
            HStack {
                Spacer()

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 600, height: 350)
        .onAppear {
            Task {
                await viewModel.loadCurrentSettings()
            }
        }
    }
}

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var customBinaryPath: String = ""
    @Published var detectedBinaryPath: String?
    @Published var binaryVersion: String?

    private let binaryLocator = BinaryLocator()

    func loadCurrentSettings() async {
        // Load custom path from UserDefaults
        if let savedPath = UserDefaults.standard.string(forKey: "customGPSBabelPath") {
            customBinaryPath = savedPath
        }

        // Try to detect the binary
        await detectBinary()
    }

    func selectBinaryPath() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = []
        panel.allowsOtherFileTypes = true
        panel.message = "Select the gpsbabel binary"
        panel.prompt = "Select"

        // Start in common locations
        if FileManager.default.fileExists(atPath: "/opt/homebrew/bin") {
            panel.directoryURL = URL(fileURLWithPath: "/opt/homebrew/bin")
        } else if FileManager.default.fileExists(atPath: "/usr/local/bin") {
            panel.directoryURL = URL(fileURLWithPath: "/usr/local/bin")
        }

        if panel.runModal() == .OK, let url = panel.url {
            customBinaryPath = url.path
            Task {
                await saveCustomPath(url)
                await detectBinary()
            }
        }
    }

    func resetBinaryPath() {
        customBinaryPath = ""
        UserDefaults.standard.removeObject(forKey: "customGPSBabelPath")
        detectedBinaryPath = nil
        binaryVersion = nil

        Task {
            await binaryLocator.setCustomBinaryPath(nil)
            await detectBinary()
        }
    }

    private func saveCustomPath(_ url: URL) async {
        UserDefaults.standard.set(url.path, forKey: "customGPSBabelPath")
        await binaryLocator.setCustomBinaryPath(url)
    }

    private func detectBinary() async {
        do {
            let binaryURL = try await binaryLocator.locateBinary()
            detectedBinaryPath = binaryURL.path

            // Get version
            let version = try await binaryLocator.getVersion()
            // Extract just the version line
            if let firstLine = version.components(separatedBy: "\n").first {
                binaryVersion = firstLine
            } else {
                binaryVersion = version
            }
        } catch {
            detectedBinaryPath = nil
            binaryVersion = nil
        }
    }
}

#Preview {
    SettingsView()
}
