//
//  ScraperViewModel+Selectors.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import Foundation
import SwiftUI
import SwiftSoup

extension ScraperViewModel {
    func loadExampleSelectors() {
        selectorRules = [
            SelectorRule(name: "Article Titles", selector: "h1, h2.article-title", extractAttribute: nil),
            SelectorRule(name: "Product Prices", selector: ".price, span.amount", extractAttribute: nil),
            SelectorRule(name: "All Images", selector: "img", extractAttribute: "src"),
            SelectorRule(name: "Navigation Links", selector: "nav a, .main-menu a", extractAttribute: "href")
        ]
    }
    
    func scrapeWithSelectors() async {
        guard !url.isEmpty, !selectorRules.isEmpty else { return }
        
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
            self.selectorResults = []
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
                let results = try parseWithSelectors(htmlContent: htmlString, rules: selectorRules)
                
                await MainActor.run {
                    self.selectorResults = results
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
    
    // MARK: - Private Methods
    
    private func parseWithSelectors(htmlContent: String, rules: [SelectorRule]) throws -> [SelectorResult] {
        let document: Document
        do {
            document = try SwiftSoup.parse(htmlContent)
        } catch {
            throw NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse HTML content"])
        }
        
        var results: [SelectorResult] = []
        
        for rule in rules where rule.isEnabled {
            do {
                let elements = try document.select(rule.selector)
                var extractedElements: [ExtractedElement] = []
                
                for element in elements {
                    let content: String
                    if let attribute = rule.extractAttribute {
                        content = try element.attr(attribute)
                    } else {
                        content = try element.text()
                    }
                    
                    let html = try element.outerHtml()
                    extractedElements.append(ExtractedElement(content: content, sourceHTML: html))
                }
                
                results.append(SelectorResult(
                    ruleName: rule.name,
                    selector: rule.selector,
                    elements: extractedElements
                ))
            } catch {
                print("Error applying selector '\(rule.selector)': \(error.localizedDescription)")
            }
        }
        
        return results
    }
}
