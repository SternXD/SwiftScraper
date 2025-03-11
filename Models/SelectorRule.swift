//
//  SelectorRule.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import Foundation

struct SelectorRule: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var selector: String
    var extractAttribute: String?
    var isEnabled: Bool = true
    
    static func == (lhs: SelectorRule, rhs: SelectorRule) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SelectorResult: Identifiable {
    var id = UUID()
    var ruleName: String
    var selector: String
    var elements: [ExtractedElement]
}

struct ExtractedElement: Identifiable {
    var id = UUID()
    var content: String
    var sourceHTML: String
}
