//
//  SavedContentManager.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//


import Foundation
import CoreData
import SwiftUI

class SavedContentManager: ObservableObject {
    @Published var savedItems: [SavedContent] = []
    private let viewContext = PersistenceController.shared.container.viewContext
    
    init() {
        fetchSavedItems()
    }
    
    func fetchSavedItems() {
        let request = NSFetchRequest<SavedContent>(entityName: "SavedContent")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            savedItems = try viewContext.fetch(request)
        } catch {
            print("Error fetching saved items: \(error)")
        }
    }
    
    func saveContent(_ content: ScrapedContent, from url: String) {
        let newSavedContent = SavedContent(context: viewContext)
        newSavedContent.id = UUID()
        newSavedContent.url = url
        newSavedContent.title = content.title
        newSavedContent.createdAt = Date()
        
        newSavedContent.headingsData = try? JSONEncoder().encode(content.headings)
        newSavedContent.paragraphsData = try? JSONEncoder().encode(content.paragraphs)
        
        if let linksData = try? JSONEncoder().encode(content.links) {
            newSavedContent.linksData = linksData
        }
        
        if let imagesData = try? JSONEncoder().encode(content.images) {
            newSavedContent.imagesData = imagesData
        }
        
        if let metadataData = try? JSONEncoder().encode(content.metadata) {
            newSavedContent.metadataData = metadataData
        }
        
        // Optionally save the original HTML content
        // newSavedContent.htmlContent = htmlContent
        
        do {
            try viewContext.save()
            fetchSavedItems()
        } catch {
            print("Error saving content: \(error)")
        }
    }
    
    func deleteContent(_ content: SavedContent) {
        viewContext.delete(content)
        
        do {
            try viewContext.save()
            fetchSavedItems()
        } catch {
            print("Error deleting content: \(error)")
        }
    }
    
    func loadContent(_ savedContent: SavedContent) -> ScrapedContent {
        var content = ScrapedContent()
        content.title = savedContent.title ?? "No Title"
        
        if let headingsData = savedContent.headingsData {
            content.headings = (try? JSONDecoder().decode([String].self, from: headingsData)) ?? []
        }
        
        if let paragraphsData = savedContent.paragraphsData {
            content.paragraphs = (try? JSONDecoder().decode([String].self, from: paragraphsData)) ?? []
        }
        
        if let linksData = savedContent.linksData {
            content.links = (try? JSONDecoder().decode([Link].self, from: linksData)) ?? []
        }
        
        if let imagesData = savedContent.imagesData {
            content.images = (try? JSONDecoder().decode([ScrapedImage].self, from: imagesData)) ?? []
        }
        
        if let metadataData = savedContent.metadataData {
            content.metadata = (try? JSONDecoder().decode([String: String].self, from: metadataData)) ?? [:]
        }
        
        return content
    }
    
    func isURLAlreadySaved(_ url: String) -> Bool {
        let request = NSFetchRequest<SavedContent>(entityName: "SavedContent")
        request.predicate = NSPredicate(format: "url == %@", url)
        request.fetchLimit = 1
        
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            print("Error checking if URL exists: \(error)")
            return false
        }
    }
    
    func updateContent(_ savedContent: SavedContent, with newContent: ScrapedContent) {
        savedContent.title = newContent.title
        savedContent.headingsData = try? JSONEncoder().encode(newContent.headings)
        savedContent.paragraphsData = try? JSONEncoder().encode(newContent.paragraphs)
        savedContent.linksData = try? JSONEncoder().encode(newContent.links)
        savedContent.imagesData = try? JSONEncoder().encode(newContent.images)
        savedContent.metadataData = try? JSONEncoder().encode(newContent.metadata)
        
        do {
            try viewContext.save()
            fetchSavedItems()
        } catch {
            print("Error updating content: \(error)")
        }
    }
}
