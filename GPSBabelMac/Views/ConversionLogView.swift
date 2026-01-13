//
//  ConversionLogView.swift
//  GPSBabelMac
//
//  Displays conversion output and logs
//

import SwiftUI

struct ConversionLogView: View {
    let log: String
    let isConverting: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Conversion Log")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                if isConverting {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 16, height: 16)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    Text(log)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .textSelection(.enabled)
                        .id("logBottom")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .textBackgroundColor))
                .onChange(of: log) { _, _ in
                    withAnimation {
                        proxy.scrollTo("logBottom", anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
        )
    }
}

#Preview {
    ConversionLogView(
        log: """
        > Ready
        Starting conversion...
        Input: /Users/test/track.fit
        Output: /Users/test/track.gpx
        Format: FIT - Garmin → GPX - GPS Exchange Format

        Running gpsbabel...

        ✓ Conversion successful. Output file size: 245 KB
        Duration: 0.34s
        """,
        isConverting: false
    )
    .frame(width: 600, height: 200)
    .padding()
}
