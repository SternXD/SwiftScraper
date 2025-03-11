//
//  HTMLProcessor.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//


import Foundation

class HTMLProcessor {
    private let html: String
    
    init(html: String) {
        self.html = html
    }
    
    func extractContent() async throws -> ScrapedContent {
        var content = ScrapedContent()
        content.title = extractTitle()
        content.headings = try extractHeadings()
        content.links = try extractLinks()
        content.images = try extractImages()
        content.paragraphs = try extractElements(tagName: "p")
        return content
    }
    
    private func extractTitle() -> String {
        let pattern = "<title>(.*?)</title>"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let nsString = html as NSString
            if let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: nsString.length)) {
                let titleRange = Range(match.range(at: 1), in: html)!
                return String(html[titleRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("Regex error: \(error)")
        }
        return "No title found"
    }
    
    private func extractHeadings() throws -> [String] {
        let h1s = try extractElements(tagName: "h1")
        let h2s = try extractElements(tagName: "h2")
        let h3s = try extractElements(tagName: "h3")
        return h1s + h2s + h3s
    }
    
    private func extractElements(tagName: String) throws -> [String] {
        var elements: [String] = []
        let pattern = "<\(tagName)[^>]*>(.*?)</\(tagName)>"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let nsString = html as NSString
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: html) {
                    let content = String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !content.isEmpty {
                        elements.append(content)
                    }
                }
            }
            
            return elements
        } catch {
            throw ScraperError.parsingFailed("Failed to extract \(tagName) elements: \(error.localizedDescription)")
        }
    }
    
    private func extractLinks() throws -> [Link] {
        var links: [Link] = []
        let pattern = #"<a\s+[^>]*href="([^"]*)"[^>]*>(.*?)</a>"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let nsString = html as NSString
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if let urlRange = Range(match.range(at: 1), in: html),
                   let textRange = Range(match.range(at: 2), in: html) {
                    let url = String(html[urlRange])
                    let text = String(html[textRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !url.isEmpty {
                        links.append(Link(url: url, text: text.isEmpty ? url : text))
                    }
                }
            }
        } catch {
            throw ScraperError.parsingFailed("Failed to extract links: \(error.localizedDescription)")
        }
        
        return links
    }
    
    private func extractImages() throws -> [ScrapedImage] {
        var images: [ScrapedImage] = []
        let pattern = #"<img\s+[^>]*src="([^"]*)"[^>]*alt="([^"]*)"[^>]*>"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let nsString = html as NSString
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if let srcRange = Range(match.range(at: 1), in: html),
                   let altRange = Range(match.range(at: 2), in: html) {
                    let src = String(html[srcRange])
                    let alt = String(html[altRange])
                    if !src.isEmpty {
                        images.append(ScrapedImage(url: src, alt: alt))
                    }
                }
            }
        } catch {
            throw ScraperError.parsingFailed("Failed to extract images: \(error.localizedDescription)")
        }
        
        return images
    }
}
