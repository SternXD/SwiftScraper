//
//  SavedContentListView.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//


import SwiftUI

struct SavedContentListView: View {
    @ObservedObject var savedContentManager = SavedContentManager()
    @EnvironmentObject var viewModel: ScraperViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            ForEach(savedContentManager.savedItems, id: \.id) { item in
                VStack(alignment: .leading) {
                    Text(item.title ?? "No Title")
                        .font(.headline)
                    
                    Text(item.url ?? "")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Saved: \(formattedDate(item.createdAt))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    loadSavedContent(item)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    savedContentManager.deleteContent(savedContentManager.savedItems[index])
                }
            }
        }
        .navigationBarTitle("Saved Pages")
        .navigationBarItems(trailing: EditButton())
        .onAppear {
            savedContentManager.fetchSavedItems()
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func loadSavedContent(_ savedContent: SavedContent) {
        viewModel.url = savedContent.url ?? ""
        viewModel.scrapedContent = savedContentManager.loadContent(savedContent)
        viewModel.isLoading = false
        viewModel.errorMessage = nil
        presentationMode.wrappedValue.dismiss()
    }
}
