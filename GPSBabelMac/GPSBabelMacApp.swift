//
//  GPSBabelMacApp.swift
//  GPSBabelMac
//
//  App entry point
//

import SwiftUI

@main
struct GPSBabelMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.automatic)
        .commands {
            CommandGroup(replacing: .help) {
                Button("GPSBabel Documentation") {
                    if let url = URL(string: "https://www.gpsbabel.org/htmldoc-development/") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }

        // Settings window
        Settings {
            SettingsView()
        }
    }
}
