//
//  ExportOptionsView.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import SwiftUI

struct ExportOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedFormat: DataExporterService.ExportFormat = .json
    let onExport: (DataExporterService.ExportFormat) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Export Format")) {
                    ForEach(DataExporterService.ExportFormat.allCases) { format in
                        Button(action: {
                            selectedFormat = format
                            onExport(format)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text(format.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: formatIcon(format))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section(header: Text("Format Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        formatDescription(selectedFormat)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationBarTitle("Export Options", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func formatIcon(_ format: DataExporterService.ExportFormat) -> String {
        switch format {
        case .json: return "curlybraces"
        case .csv: return "tablecells"
        case .text: return "doc.text"
        case .html: return "safari"
        }
    }
    
    private func formatDescription(_ format: DataExporterService.ExportFormat) -> some View {
        switch format {
        case .json:
            return VStack(alignment: .leading) {
                Text("JSON Format").font(.headline)
                Text("Structured data format that's easy to parse programmatically. Great for developers or importing into other applications.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        case .csv:
            return VStack(alignment: .leading) {
                Text("CSV Format").font(.headline)
                Text("Comma-separated values format that can be opened in spreadsheet applications like Excel or Google Sheets.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        case .text:
            return VStack(alignment: .leading) {
                Text("Plain Text Format").font(.headline)
                Text("Simple text format that can be opened in any text editor. Easy to read but without formatting.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        case .html:
            return VStack(alignment: .leading) {
                Text("HTML Format").font(.headline)
                Text("Formatted HTML document that can be viewed in any web browser with proper styling and layout.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
