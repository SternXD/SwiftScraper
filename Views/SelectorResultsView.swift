//
//  SelectorResultsView.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import SwiftUI

struct SelectorResultsView: View {
    @EnvironmentObject private var viewModel: ScraperViewModel
    @State private var selectedResult: SelectorResult?
    @State private var showingHTML = false
    @State private var selectedElement: ExtractedElement?
    
    var body: some View {
        if viewModel.selectorResults.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                
                Text("No selector results")
                    .font(.headline)
                
                Text("Add CSS selectors and scrape a website to see results here.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Button(action: {
                    viewModel.showingSelectorEditor = true
                }) {
                    Text("Add Selectors")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .padding()
        } else {
            List {
                ForEach(viewModel.selectorResults) { result in
                    Section(header: 
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.ruleName)
                                .font(.headline)
                            
                            Text(result.selector)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Found \(result.elements.count) matches")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    ) {
                        ForEach(result.elements) { element in
                            VStack(alignment: .leading) {
                                if element.content.isEmpty {
                                    Text("[Empty content]")
                                        .italic()
                                        .foregroundColor(.gray)
                                } else {
                                    Text(element.content)
                                }
                            }
                            .padding(.vertical, 2)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedElement = element
                                showingHTML = true
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .sheet(isPresented: $showingHTML) {
                if let element = selectedElement {
                    HTMLSourceView(html: element.sourceHTML, content: element.content)
                }
            }
        }
    }
}

struct HTMLSourceView: View {
    let html: String
    let content: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Extracted Content")
                            .font(.headline)
                        
                        Text(content)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    Group {
                        Text("HTML Source")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(html)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    Button(action: {
                        UIPasteboard.general.string = html
                    }) {
                        Label("Copy HTML to Clipboard", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.vertical)
                }
                .padding()
            }
            .navigationBarTitle("Element Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
