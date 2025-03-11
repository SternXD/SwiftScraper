//
//  LinksListView.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import SwiftUI

struct LinksListView: View {
    let links: [Link]
    var filter: ContentFilter?
    @EnvironmentObject var viewModel: ScraperViewModel
    @State private var selectedLink: URL?
    
    var body: some View {
        List {
            ForEach(links, id: \.id) { link in
                VStack(alignment: .leading, spacing: 8) {
                    if let filter = filter {
                        Text(viewModel.highlightMatches(in: link.text,
                                                  searchTerm: filter.searchTerm,
                                                  caseSensitive: filter.caseSensitive))
                            .font(.headline)
                    } else {
                        Text(link.text)
                            .font(.headline)
                    }
                    
                    Text(link.url)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let url = URL(string: link.url) {
                        selectedLink = url
                    }
                }
            }
        }
        .navigationBarTitle("Links", displayMode: .inline)
        .sheet(item: $selectedLink) { url in
            SafariView(url: url)
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String {
        return self.absoluteString
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

import SafariServices
