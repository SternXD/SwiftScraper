//
//  ParagraphsView.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import SwiftUI

struct ParagraphsView: View {
    let paragraphs: [String]
    var filter: ContentFilter?
    
    @EnvironmentObject private var viewModel: ScraperViewModel
    
    var body: some View {
        List {
            ForEach(paragraphs, id: \.self) { paragraph in
                VStack(alignment: .leading, spacing: 8) {
                    if let filter = filter {
                        Text(viewModel.highlightMatches(in: paragraph,
                                                    searchTerm: filter.searchTerm,
                                                    caseSensitive: filter.caseSensitive))
                    } else {
                        Text(paragraph)
                    }                }
                .padding(.vertical, 4)
            }
        }
        .navigationBarTitle("Paragraphs", displayMode: .inline)
    }
}

struct ParagraphsView_Previews: PreviewProvider {
    static var previews: some View {
        ParagraphsView(paragraphs: ["Example paragraph"])
            .environmentObject(ScraperViewModel())
    }
}
