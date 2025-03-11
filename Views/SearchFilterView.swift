//
//  SearchFilterView.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import SwiftUI

struct SearchFilterView: View {
    @Binding var filter: ContentFilter
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Search Term")) {
                    TextField("Enter search term", text: $filter.searchTerm)
                }
                
                Section(header: Text("Search In")) {
                    Toggle("Headings", isOn: $filter.searchInHeadings)
                    Toggle("Paragraphs", isOn: $filter.searchInParagraphs)
                    Toggle("Link Text", isOn: $filter.searchInLinks)
                    Toggle("Image Alt Text", isOn: $filter.searchInImageAlt)
                }
                
                Section(header: Text("Options")) {
                    Toggle("Case Sensitive", isOn: $filter.caseSensitive)
                }
            }
            .navigationTitle("Search Filters")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Apply") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
