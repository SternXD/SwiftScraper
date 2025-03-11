//
//  ScrapedContent.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//


import Foundation

struct ScrapedContent: Codable {
    var title: String = ""
    var headings: [String] = []
    var paragraphs: [String] = []
    var links: [Link] = []
    var images: [ScrapedImage] = []
    var metadata: [String: String] = [:]
}

struct Link: Identifiable, Hashable, Codable {
    var id = UUID()
    var url: String
    var text: String
}

struct ScrapedImage: Identifiable, Hashable, Codable {
    var id = UUID()
    var url: String
    var alt: String
}
