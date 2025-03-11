# WebScraper

A Swift iOS application that allows users to scrape and analyze web content directly from their mobile device.

## Overview

WebScraper is a lightweight, user-friendly iOS application built with Swift and SwiftUI that enables users to extract and view structured data from websites. The app can identify and extract titles, headings, paragraphs, links, and images from any web page for easy browsing and analysis.

## Features

- **Simple URL Input**: Enter any website URL and scrape its content with a single tap
- **Structured Content Extraction**: Automatically identifies and categorizes web page elements
- **Content Categories**:
  - Page Title
  - Headings (H1, H2, H3)
  - Links (with URL and display text)
  - Images (with URL and alt text)
  - Paragraphs
- **Navigation View**: Easily browse different types of extracted content
- **Async Image Loading**: View images from the scraped website directly in the app

## Requirements

- iOS 15.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later

## How to Use

1. Launch the WebScraper app on your iOS device
2. Enter a complete URL (including https://) in the text field at the top of the screen
3. Tap the "Scrape" button to start the scraping process
4. Once scraping is complete, you'll see the page title and summary information
5. Tap any of the category links to view more detailed information:
   - "View X Links" - Shows all links found on the page
   - "View X Images" - Shows all images with their alt text
   - "View X Paragraphs" - Shows the text content from paragraph elements

## Technical Implementation

WebScraper is built using:
- **SwiftUI**: For the user interface
- **Async/Await**: Modern Swift concurrency for network requests
- **Regular Expressions**: For parsing HTML content
- **MVVM Architecture**: Clear separation of concerns with ScraperViewModel

### Key Components:

- **ScraperViewModel**: Manages the web scraping process and data
- **HTMLProcessor**: Parses HTML content using regular expressions
- **ContentView**: Main interface for user interaction
- **Detail Views**: Specialized views for displaying different content types

## Limitations

- The app uses regular expressions for HTML parsing, which works well for simple websites but may have limitations with complex, dynamically generated content
- JavaScript-rendered content may not be fully captured as the app accesses raw HTML
- Some websites may block scraping attempts

## License

This project is licensed under the GPLv3 License - see the LICENSE file for details.