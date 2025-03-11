//
//  ContentView.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ContentView: View {
    @EnvironmentObject private var viewModel: ScraperViewModel
    @State private var isProcessing = false
    @State private var showingSaveConfirmation = false
    @State private var showingSearchFilters = false
    @State private var filter = ContentFilter()
    @State private var isShowingFiltered = false
    @StateObject private var savedContentManager = SavedContentManager()
    
    @State private var showingExportOptions = false
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    
    var body: some View {
        NavigationView {
            VStack {
                modeSelectorView
                urlInputView
                
                if viewModel.activeScrapingMode == .selectors {
                    selectorConfigInfoView
                }
                
                loadingAndErrorView
                

                if viewModel.activeScrapingMode == .general {
                    generalModeContentView
                } else {

                    SelectorResultsView()
                        .environmentObject(viewModel)
                }
            }
            .navigationBarTitle(navigationTitle)
            .navigationBarItems(
                leading: NavigationLink(destination: SavedContentListView()) {
                    Image(systemName: "folder")
                        .imageScale(.large)
                },
                trailing: trailingNavButtons
            )
            .overlay(
                saveConfirmationToast
                    .opacity(showingSaveConfirmation ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: showingSaveConfirmation)
                    .onChange(of: showingSaveConfirmation) { newValue in
                        if newValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showingSaveConfirmation = false
                            }
                        }
                    }
                , alignment: .bottom
            )
            .sheet(isPresented: $showingSearchFilters) {
                SearchFilterView(filter: $filter)
            }
            .sheet(isPresented: $viewModel.showingSelectorEditor) {
                SelectorEditorView().environmentObject(viewModel)
            }
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsView(onExport: { format in
                    Task {
                        if let fileURL = await exportContent(format: format) {
                            exportURL = fileURL
                            showingShareSheet = true
                        }
                    }
                })
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    // MARK: - Component Views
    
    private var modeSelectorView: some View {
        Picker("Scraping Mode", selection: $viewModel.activeScrapingMode) {
            ForEach(ScraperViewModel.ScrapingMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    private var urlInputView: some View {
        HStack {
            TextField("Enter website URL", text: $viewModel.url)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.URL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if viewModel.activeScrapingMode == .general {
                Button(action: {
                    dismissKeyboard()
                    isProcessing = true
                    
                    Task {
                        await viewModel.scrapeWebsite()
                        isProcessing = false
                        filter = ContentFilter()
                        isShowingFiltered = false
                    }
                }) {
                    Text("Scrape")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.url.isEmpty || isProcessing)
            } else {
                selectorScrapeButton
            }
        }
        .padding()
    }
    
    private var selectorConfigInfoView: some View {
        HStack {
            Text("\(viewModel.selectorRules.count) selectors configured")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                viewModel.showingSelectorEditor = true
            }) {
                Label("Edit Selectors", systemImage: "pencil")
            }
        }
        .padding(.horizontal)
    }
    
    private var loadingAndErrorView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Scraping...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private var generalModeContentView: some View {
        Group {
            if let displayContent = isShowingFiltered ? viewModel.filteredContent(using: filter) : viewModel.scrapedContent {
                VStack {
                    searchView
                    
                    contentScrollView(displayContent: displayContent)
                }
            } else {
                Spacer()
                Text("Enter a URL and tap 'Scrape' to begin")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
    
    private var searchView: some View {
        Group {
            if !isShowingFiltered {
                HStack {
                    TextField("Search in content", text: $filter.searchTerm)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                    
                    Button(action: {
                        showingSearchFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .imageScale(.large)
                    }
                    .padding(.trailing)
                    
                    Button(action: {
                        dismissKeyboard()
                        isShowingFiltered = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                    }
                    .padding(.trailing)
                    .disabled(!filter.hasValidSearchTerm || !filter.isSearchActive)
                }
            } else {
                HStack {
                    Text("Filtered results for: \"\(filter.searchTerm)\"")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingFiltered = false
                    }) {
                        Text("Clear Filter")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func contentScrollView(displayContent: ScrapedContent) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Page Title")
                        .font(.headline)
                    Text(displayContent.title)
                }
                
                if !displayContent.headings.isEmpty {
                    Divider()
                    Text("Headings")
                        .font(.headline)
                    ForEach(displayContent.headings, id: \.self) { heading in
                        if isShowingFiltered {
                            Text(viewModel.highlightMatches(in: heading, searchTerm: filter.searchTerm, caseSensitive: filter.caseSensitive))
                        } else {
                            Text(heading)
                        }
                    }
                }
                
                linksSection(displayContent)
                
                imagesSection(displayContent)
                
                paragraphsSection(displayContent)
                
                metadataSection(displayContent)
            }
            .padding()
        }
    }
    
    private func linksSection(_ displayContent: ScrapedContent) -> some View {
        Group {
            if !displayContent.links.isEmpty {
                Divider()
                NavigationLink(
                    destination: LinksListView(links: displayContent.links, filter: isShowingFiltered ? filter : nil),
                    label: {
                        Text("View \(displayContent.links.count) Links")
                            .font(.headline)
                    }
                )
            }
        }
    }
    
    private func imagesSection(_ displayContent: ScrapedContent) -> some View {
        Group {
            if !displayContent.images.isEmpty {
                Divider()
                NavigationLink(
                    destination: ImagesListView(images: displayContent.images, filter: isShowingFiltered ? filter : nil),
                    label: {
                        Text("View \(displayContent.images.count) Images")
                            .font(.headline)
                    }
                )
            }
        }
    }
    
    private func paragraphsSection(_ displayContent: ScrapedContent) -> some View {
        Group {
            if !displayContent.paragraphs.isEmpty {
                Divider()
                NavigationLink(
                    destination: ParagraphsView(paragraphs: displayContent.paragraphs, filter: isShowingFiltered ? filter : nil),
                    label: {
                        Text("View \(displayContent.paragraphs.count) Paragraphs")
                            .font(.headline)
                    }
                )
            }
        }
    }
    
    private func metadataSection(_ displayContent: ScrapedContent) -> some View {
        Group {
            if !displayContent.metadata.isEmpty {
                Divider()
                NavigationLink(
                    destination: MetadataView(metadata: displayContent.metadata),
                    label: {
                        Text("View Page Metadata")
                            .font(.headline)
                    }
                )
            }
        }
    }
    
    private var trailingNavButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                showingExportOptions = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
            }
            .disabled((viewModel.activeScrapingMode == .general && viewModel.scrapedContent == nil) ||
                     (viewModel.activeScrapingMode == .selectors && viewModel.selectorResults.isEmpty))
            
            Button(action: {
                if viewModel.activeScrapingMode == .general, let content = viewModel.scrapedContent {
                    savedContentManager.saveContent(content, from: viewModel.url)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    showingSaveConfirmation = true
                }
            }) {
                Image(systemName: "square.and.arrow.down")
                    .imageScale(.large)
            }
            .disabled(viewModel.activeScrapingMode == .selectors || viewModel.scrapedContent == nil)
        }
    }
    
    private func exportContent(format: DataExporterService.ExportFormat) async -> URL? {
        let exporter = DataExporterService()
        
        var dataToExport: Data?
        var filename: String
        
        switch viewModel.activeScrapingMode {
        case .general:
            guard let content = viewModel.scrapedContent else { return nil }
            
            dataToExport = exporter.exportContent(
                content,
                sourceURL: viewModel.url,
                format: format
            )
            
            let siteName = extractDomainName(from: viewModel.url) ?? "website"
            filename = "swiftscraper-\(siteName)"
            
        case .selectors:
            let content = ScrapedContent(
                title: extractDomainName(from: viewModel.url) ?? "Selector scrape results",
                headings: [],
                paragraphs: [],
                links: [],
                images: [],
                metadata: ["source_url": viewModel.url]
            )
            
            dataToExport = exporter.exportContent(
                content,
                sourceURL: viewModel.url,
                format: format,
                selectorResults: viewModel.selectorResults
            )
            
            let siteName = extractDomainName(from: viewModel.url) ?? "website"
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
            await MainActor.run {
                viewModel.errorMessage = "Failed to create export file: \(error.localizedDescription)"
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
    
    private var navigationTitle: String {
        if isShowingFiltered {
            return "Search Results"
        } else if viewModel.activeScrapingMode == .general {
            return "SwiftScraper"
        } else {
            return "CSS Selector Scraper"
        }
    }
    
    private var selectorScrapeButton: some View {
        Button(action: {
            dismissKeyboard()
            isProcessing = true
            
            Task {
                await viewModel.scrapeWithSelectors()
                isProcessing = false
            }
        }) {
            Text("Scrape with Selectors")
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(viewModel.url.isEmpty || isProcessing || viewModel.selectorRules.isEmpty)
    }
    
    private var saveConfirmationToast: some View {
        Text("Content saved!")
            .padding()
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(10)
            .padding(.bottom, 30)
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                       to: nil, from: nil, for: nil)
    }
}
