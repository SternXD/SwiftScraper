//
//  ScraperError.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import Foundation

enum ScraperError: Error {
    case invalidURL
    case networkError(String)
    case parsingError(String)
    case parsingFailed(String)
    case noContentError
    case encodingError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL provided."
        case .networkError(let details):
            return "Network error: \(details)"
        case .parsingError(let details):
            return "HTML parsing error: \(details)"
        case .parsingFailed(let details):
            return "Failed to parse HTML: \(details)"
        case .noContentError:
            return "No content found at the requested URL."
        case .encodingError(let details):
            return "Encoding error: \(details)"
        }
    }
}
