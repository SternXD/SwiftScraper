//
//  MetadataView.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//


import SwiftUI

struct MetadataView: View {
    let metadata: [String: String]
    
    var body: some View {
        List {
            ForEach(metadata.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                VStack(alignment: .leading) {
                    Text(key)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(value)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Page Metadata")
    }
}
