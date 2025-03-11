//
//  DataExporterService.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import Foundation

class DataExporterService {
    enum ExportFormat: String, CaseIterable, Identifiable {
        case json = "JSON"
        case csv = "CSV"
        case text = "Plain Text"
        case html = "HTML"
        
        var id: String { self.rawValue }
        
        var fileExtension: String {
            switch self {
            case .json: return "json"
            case .csv: return "csv"
            case .text: return "txt"
            case .html: return "html"
            }
        }
        
        var mimeType: String {
            switch self {
            case .json: return "application/json"
            case .csv: return "text/csv"
            case .text: return "text/plain"
            case .html: return "text/html"
            }
        }
    }
    
    func exportContent(_ content: ScrapedContent, sourceURL: String, format: ExportFormat, selectorResults: [SelectorResult]? = nil) -> Data? {
        switch format {
        case .json:
            return exportAsJSON(content, sourceURL: sourceURL, selectorResults: selectorResults)
        case .csv:
            return exportAsCSV(content, sourceURL: sourceURL)
        case .text:
            return exportAsText(content, sourceURL: sourceURL, selectorResults: selectorResults)
        case .html:
            return exportAsHTML(content, sourceURL: sourceURL, selectorResults: selectorResults)
        }
    }
    
    // MARK: - Export Implementations
    
    private func exportAsJSON(_ content: ScrapedContent, sourceURL: String, selectorResults: [SelectorResult]?) -> Data? {
        var jsonDict: [String: Any] = [
            "source_url": sourceURL,
            "export_date": ISO8601DateFormatter().string(from: Date()),
            "title": content.title,
            "headings": content.headings,
            "paragraphs": content.paragraphs,
            "links": content.links.map { ["text": $0.text, "url": $0.url] },
            "images": content.images.map { ["alt": $0.alt, "url": $0.url] },
            "metadata": content.metadata
        ]
        
        if let selectorResults = selectorResults, !selectorResults.isEmpty {
            var selectorData: [[String: Any]] = []
            
            for result in selectorResults {
                var resultDict: [String: Any] = [
                    "rule_name": result.ruleName,
                    "selector": result.selector,
                    "count": result.elements.count
                ]
                
                let elements = result.elements.map { ["content": $0.content] }
                resultDict["elements"] = elements
                
                selectorData.append(resultDict)
            }
            
            jsonDict["selector_results"] = selectorData
        }
        
        return try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted])
    }
    
    private func exportAsCSV(_ content: ScrapedContent, sourceURL: String) -> Data? {
        var csvString = "Type,Content,URL\n"
        
        csvString += "Title,\"\(escapeCSV(content.title))\",\(sourceURL)\n"
        
        for heading in content.headings {
            csvString += "Heading,\"\(escapeCSV(heading))\",\n"
        }
        
        for link in content.links {
            csvString += "Link,\"\(escapeCSV(link.text))\",\(link.url)\n"
        }
        
        for image in content.images {
            csvString += "Image,\"\(escapeCSV(image.alt))\",\(image.url)\n" // Changed src to url
        }
        
        for paragraph in content.paragraphs {
            let truncated = paragraph.count > 100 ? paragraph.prefix(100) + "..." : paragraph
            csvString += "Paragraph,\"\(escapeCSV(String(truncated)))\",\n"
        }
        
        return csvString.data(using: .utf8)
    }
    
    private func exportAsText(_ content: ScrapedContent, sourceURL: String, selectorResults: [SelectorResult]?) -> Data? {
        var text = "Source: \(sourceURL)\n"
        text += "Exported on: \(formattedDate())\n\n"
        
        text += "TITLE:\n"
        text += "\(content.title)\n\n"
        
        if !content.headings.isEmpty {
            text += "HEADINGS:\n"
            for heading in content.headings {
                text += "• \(heading)\n"
            }
            text += "\n"
        }
        
        if !content.links.isEmpty {
            text += "LINKS:\n"
            for link in content.links {
                text += "• \(link.text): \(link.url)\n"
            }
            text += "\n"
        }
        
        if !content.images.isEmpty {
            text += "IMAGES:\n"
            for image in content.images {
                text += "• \(image.alt): \(image.url)\n"
            }
            text += "\n"
        }
        
        if !content.paragraphs.isEmpty {
            text += "CONTENT:\n"
            for paragraph in content.paragraphs {
                text += "\(paragraph)\n\n"
            }
        }
        
        if let results = selectorResults, !results.isEmpty {
            text += "CSS SELECTOR RESULTS:\n"
            for result in results {
                text += "[\(result.ruleName) - '\(result.selector)']\n"
                for (index, element) in result.elements.enumerated() {
                    text += "\(index + 1). \(element.content)\n"
                }
                text += "\n"
            }
        }
        
        return text.data(using: .utf8)
    }
    
    private func exportAsHTML(_ content: ScrapedContent, sourceURL: String, selectorResults: [SelectorResult]?) -> Data? {
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>SwiftScraper Export: \(content.title)</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; line-height: 1.6; padding: 20px; max-width: 800px; margin: 0 auto; }
                .section { margin-bottom: 20px; border-bottom: 1px solid #eee; padding-bottom: 20px; }
                h1 { color: #333; }
                h2 { color: #555; }
                .meta { color: #777; font-size: 0.9em; margin-bottom: 20px; }
                .content p { margin-bottom: 15px; }
                .links a, .images a { display: block; margin-bottom: 5px; color: #0066cc; text-decoration: none; }
                .links a:hover, .images a:hover { text-decoration: underline; }
                .selector-result { background: #f5f5f5; padding: 10px; margin-bottom: 10px; border-radius: 5px; }
                .element-item { margin: 5px 0; border-left: 3px solid #0066cc; padding-left: 10px; }
            </style>
        </head>
        <body>
            <h1>\(content.title)</h1>
            <div class="meta">
                <p>Source: <a href="\(sourceURL)">\(sourceURL)</a><br>
                Exported on: \(formattedDate())</p>
            </div>
        """
        
        if !content.headings.isEmpty {
            html += "<div class=\"section\">\n<h2>Headings</h2>\n<ul>\n"
            for heading in content.headings {
                html += "<li>\(heading)</li>\n"
            }
            html += "</ul>\n</div>\n"
        }
        
        if !content.links.isEmpty {
            html += "<div class=\"section\">\n<h2>Links</h2>\n<div class=\"links\">\n"
            for link in content.links {
                html += "<a href=\"\(link.url)\">\(link.text)</a>\n"
            }
            html += "</div>\n</div>\n"
        }
        
        if !content.images.isEmpty {
            html += "<div class=\"section\">\n<h2>Images</h2>\n<div class=\"images\">\n"
            for image in content.images {
                html += "<div><img src=\"\(image.url)\" alt=\"\(image.alt)\" style=\"max-width: 100%; max-height: 200px;\"><br>\(image.alt)</div>\n"
            }
            html += "</div>\n</div>\n"
        }
        
        if !content.paragraphs.isEmpty {
            html += "<div class=\"section\">\n<h2>Content</h2>\n<div class=\"content\">\n"
            for paragraph in content.paragraphs {
                html += "<p>\(paragraph)</p>\n"
            }
            html += "</div>\n</div>\n"
        }
        
        if let results = selectorResults, !results.isEmpty {
            html += "<div class=\"section\">\n<h2>CSS Selector Results</h2>\n"
            for result in results {
                html += "<div class=\"selector-result\">\n"
                html += "<h3>\(result.ruleName) <small>(\(result.selector))</small></h3>\n"
                html += "<div class=\"elements\">\n"
                for element in result.elements {
                    html += "<div class=\"element-item\">\(element.content)</div>\n"
                }
                html += "</div>\n</div>\n"
            }
            html += "</div>\n"
        }
        
        html += "</body>\n</html>"
        return html.data(using: .utf8)
    }
    
    // MARK: - Helper Methods
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: Date())
    }
    
    private func escapeCSV(_ string: String) -> String {
        return string.replacingOccurrences(of: "\"", with: "\"\"")
    }
}
