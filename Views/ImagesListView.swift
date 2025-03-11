//
//  ImagesListView.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import SwiftUI

struct ImagesListView: View {
    let images: [ScrapedImage]
    var filter: ContentFilter?
    
    @EnvironmentObject private var viewModel: ScraperViewModel
    
    var body: some View {
        List {
            ForEach(images, id: \.id) { image in
                VStack(alignment: .leading, spacing: 8) {
                    AsyncImage(url: URL(string: image.url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                                .foregroundColor(.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    if let filter = filter {
                        Text(viewModel.highlightMatches(in: image.alt,
                                                  searchTerm: filter.searchTerm,
                                                  caseSensitive: filter.caseSensitive))
                            .font(.caption)
                    } else {
                        Text(image.alt)
                            .font(.caption)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationBarTitle("Images", displayMode: .inline)
    }
}
