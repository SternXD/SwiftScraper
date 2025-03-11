//
//  ContentFilter.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import Foundation

struct ContentFilter {
    var searchTerm: String = ""
    var searchInHeadings: Bool = true
    var searchInParagraphs: Bool = true
    var searchInLinks: Bool = true
    var searchInImageAlt: Bool = false
    var caseSensitive: Bool = false
    
    var isSearchActive: Bool {
        return searchInHeadings || searchInParagraphs || searchInLinks || searchInImageAlt
    }
    
    var hasValidSearchTerm: Bool {
        return !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
