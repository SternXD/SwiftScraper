//
//  ContentView+Selectors.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import SwiftUI

extension ContentView {
    var selectorScrapeButton: some View {
        Button(action: {
            dismissKeyboard()
            isProcessing = true
            
            Task {
                await viewModel.scrapeWithSelectors()
                isProcessing = false
            }
        }) {
            Text("Scrape with Selectors")
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(viewModel.url.isEmpty || isProcessing || viewModel.selectorRules.isEmpty)
    }
}

