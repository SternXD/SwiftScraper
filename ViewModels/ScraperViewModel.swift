//
//  ScraperViewModel.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//


import Foundation
import SwiftUI
import Combine
import SwiftSoup

class ScraperViewModel: ObservableObject {
    @Published var url: String = ""
    @Published var scrapedContent: ScrapedContent?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var selectorRules: [SelectorRule] = []
    @Published var selectorResults: [SelectorResult] = []
    @Published var showingSelectorEditor = false
    @Published var activeScrapingMode: ScrapingMode = .general
    
    enum ScrapingMode: String, CaseIterable {
        case general = "General"
        case selectors = "CSS Selectors"
    }
    
    private let parser = HTMLParserService()
    
    func scrapeWebsite() async {
        guard !url.isEmpty else { return }
        
        var formattedURL = url
        if !formattedURL.hasPrefix("http://") && !formattedURL.hasPrefix("https://") {
            formattedURL = "https://" + formattedURL
        }
        
        guard let url = URL(string: formattedURL) else {
            await MainActor.run {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: nil)
            }
            var encoding = String.Encoding.utf8
            if let encodingName = (response as? HTTPURLResponse)?.textEncodingName {
                let cfEncoding = CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)
                if cfEncoding != kCFStringEncodingInvalidId {
                    encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(cfEncoding))
                }
            }
            
            if let htmlString = String(data: data, encoding: encoding) {
                let parsedContent = parser.parseHTML(htmlContent: htmlString, baseURL: formattedURL)
                
                await MainActor.run {
                    self.scrapedContent = parsedContent
                    self.isLoading = false
                }
            } else {
                throw NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode HTML content"])
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Error: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Search and Filtering Methods
    
    func highlightMatches(in text: String, searchTerm: String, caseSensitive: Bool) -> AttributedString {
        let nsAttributedString = NSMutableAttributedString(string: text)
        
        guard !searchTerm.isEmpty else {
            return AttributedString(nsAttributedString)
        }
        let options: NSString.CompareOptions = caseSensitive ? [] : .caseInsensitive
        
        let fullRange = NSRange(location: 0, length: nsAttributedString.length)
        let nsText = text as NSString
        
        var searchRange = fullRange
        var foundRange = NSRange(location: NSNotFound, length: 0)
        
        repeat {
            foundRange = nsText.range(of: searchTerm, options: options, range: searchRange)
            
            if foundRange.location != NSNotFound {
                let yellowBackground = [NSAttributedString.Key.backgroundColor: UIColor.yellow,
                                       NSAttributedString.Key.foregroundColor: UIColor.black]
                nsAttributedString.addAttributes(yellowBackground, range: foundRange)
                
                searchRange = NSRange(location: foundRange.location + foundRange.length,
                                     length: nsText.length - (foundRange.location + foundRange.length))
            }
        } while foundRange.location != NSNotFound && searchRange.length > 0
        
        return AttributedString(nsAttributedString)
    }
    
    func filteredContent(using filter: ContentFilter) -> ScrapedContent? {
        guard let content = scrapedContent,
              filter.hasValidSearchTerm,
              filter.isSearchActive else {
            return scrapedContent
        }
        
        var filteredContent = ScrapedContent()
        filteredContent.title = content.title
        filteredContent.metadata = content.metadata
        
        let searchTerm = filter.caseSensitive ? filter.searchTerm : filter.searchTerm.lowercased()
        
        if filter.searchInHeadings {
            filteredContent.headings = content.headings.filter { heading in
                let text = filter.caseSensitive ? heading : heading.lowercased()
                return text.contains(searchTerm)
            }
        }
        
        if filter.searchInParagraphs {
            filteredContent.paragraphs = content.paragraphs.filter { paragraph in
                let text = filter.caseSensitive ? paragraph : paragraph.lowercased()
                return text.contains(searchTerm)
            }
        }
        
        if filter.searchInLinks {
            filteredContent.links = content.links.filter { link in
                let text = filter.caseSensitive ? link.text : link.text.lowercased()
                return text.contains(searchTerm)
            }
        }
        
        if filter.searchInImageAlt {
            filteredContent.images = content.images.filter { image in
                let text = filter.caseSensitive ? image.alt : image.alt.lowercased()
                return text.contains(searchTerm)
            }
        }
        
        return filteredContent
    }
}
