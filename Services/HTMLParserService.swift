//
//  HTMLParserService.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//


import Foundation
import SwiftSoup

class HTMLParserService {
    
    func parseHTML(htmlContent: String, baseURL: String) -> ScrapedContent {
        var content = ScrapedContent()
        
        do {
            let doc: Document = try SwiftSoup.parse(htmlContent)
            
            content.title = try doc.title()
            
            for i in 1...6 {
                let headings = try doc.select("h\(i)")
                for heading in headings {
                    if let headingText = try? heading.text(), !headingText.isEmpty {
                        content.headings.append(headingText)
                    }
                }
            }
            
            let paragraphs = try doc.select("p")
            for paragraph in paragraphs {
                if let paragraphText = try? paragraph.text(), !paragraphText.isEmpty {
                    content.paragraphs.append(paragraphText)
                }
            }
            
            let links = try doc.select("a[href]")
            for link in links {
                if let href = try? link.attr("href"), !href.isEmpty {
                    let absoluteURL = makeAbsoluteURL(href, baseURL: baseURL)
                    let linkText = try link.text()
                    content.links.append(Link(url: absoluteURL, text: linkText))
                }
            }
            
            let images = try doc.select("img[src]")
            for image in images {
                if let src = try? image.attr("src"), !src.isEmpty {
                    let absoluteURL = makeAbsoluteURL(src, baseURL: baseURL)
                    let alt = try image.attr("alt")
                    content.images.append(ScrapedImage(url: absoluteURL, alt: alt))
                }
            }
            
            let metaTags = try doc.select("meta")
            var metaData: [String: String] = [:]
            for meta in metaTags {
                if let name = try? meta.attr("name"), !name.isEmpty, 
                   let content = try? meta.attr("content"), !content.isEmpty {
                    metaData[name] = content
                }
                
                if let property = try? meta.attr("property"), property.starts(with: "og:"),
                   let content = try? meta.attr("content"), !content.isEmpty {
                    metaData[property] = content
                }
            }
            content.metadata = metaData
            
        } catch let error {
            print("Error parsing HTML: \(error)")
        }
        
        return content
    }
    
    private func makeAbsoluteURL(_ url: String, baseURL: String) -> String {
        if url.starts(with: "http://") || url.starts(with: "https://") {
            return url
        }
        
        guard var baseComponents = URLComponents(string: baseURL) else {
            return url
        }
        
        if url.starts(with: "//") {
            return "\(baseComponents.scheme ?? "https"):\(url)"
        }
        
        if url.starts(with: "/") {
            baseComponents.path = ""
            guard let baseWithoutPath = baseComponents.url?.absoluteString else {
                return url
            }
            return baseWithoutPath + url
        }
        
        let basePath = baseComponents.path
        let baseDir = basePath.isEmpty || basePath == "/" ? "" : 
                    (basePath as NSString).deletingLastPathComponent
        
        baseComponents.path = baseDir
        guard let baseWithoutFile = baseComponents.url?.absoluteString else {
            return url
        }
        
        return baseWithoutFile + (baseDir.isEmpty || baseDir.hasSuffix("/") ? "" : "/") + url
    }
}
