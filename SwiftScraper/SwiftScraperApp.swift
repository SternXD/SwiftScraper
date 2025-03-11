//
//  SwiftScraperApp.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import SwiftUI

@main
struct SwiftScraperApp: App {
    @StateObject private var scraperViewModel = ScraperViewModel()
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scraperViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
