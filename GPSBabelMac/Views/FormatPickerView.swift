//
//  FormatPickerView.swift
//  GPSBabelMac
//
//  Format selection picker with search and grouping
//

import SwiftUI

struct FormatPickerView: View {
    let label: String
    let formats: [GPSFormat]
    @Binding var selectedFormat: GPSFormat

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 80, alignment: .trailing)

            Picker("", selection: $selectedFormat) {
                ForEach(formats) { format in
                    Text(format.name)
                        .tag(format)
                }
            }
            .labelsHidden()
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    @Previewable @State var selectedFormat = GPSFormat.commonFormats[0]

    FormatPickerView(
        label: "Output:",
        formats: GPSFormat.commonFormats,
        selectedFormat: $selectedFormat
    )
    .padding()
    .frame(width: 400)
}
