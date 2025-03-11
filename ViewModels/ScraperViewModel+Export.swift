//
//  ScraperViewModel+Export.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import Foundation
import SwiftUI

extension ScraperViewModel {
    func exportScrapedContent(format: DataExporterService.ExportFormat) async -> URL? {
        let exporter = DataExporterService()
        
        var dataToExport: Data?
        var filename: String
        
        switch activeScrapingMode {
        case .general:
            guard let content = scrapedContent else { return nil }
            
            dataToExport = exporter.exportContent(
                content,
                sourceURL: url,
                format: format
            )
            
            let siteName = extractDomainName(from: url) ?? "website"
            filename = "swiftscraper-\(siteName)"
            
        case .selectors:
            let content = ScrapedContent(
                title: extractDomainName(from: url) ?? "Selector scrape results",
                headings: [],
                paragraphs: [],
                links: [],
                images: [],
                metadata: ["source_url": url]
            )
            
            dataToExport = exporter.exportContent(
                content,
                sourceURL: url,
                format: format,
                selectorResults: selectorResults
            )
            
            let siteName = extractDomainName(from: url) ?? "website"
            filename = "swiftscraper-selectors-\(siteName)"
        }
        
        guard let data = dataToExport else { return nil }
        
        let tempDir = FileManager.default.temporaryDirectory
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        let dateString = dateFormatter.string(from: Date())
        
        let fileURL = tempDir.appendingPathComponent("\(filename)-\(dateString).\(format.fileExtension)")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            Task { @MainActor in
                self.errorMessage = "Failed to create export file: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    private func extractDomainName(from urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return nil
        }
        
        let domain = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        
        if let dotIndex = domain.firstIndex(of: ".") {
            return String(domain[..<dotIndex])
        }
        
        return domain
    }
}
