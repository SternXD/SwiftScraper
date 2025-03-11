//
//  SelectorEditorView.swift
//  SwiftScraper
//
//  Created by SternXD on 3/11/25.
//

import SwiftUI

struct SelectorEditorView: View {
    @EnvironmentObject private var viewModel: ScraperViewModel
    @State private var newRuleName = ""
    @State private var newSelector = ""
    @State private var newAttribute = ""
    @State private var editingRule: SelectorRule?
    @State private var showingHelp = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add New Selector")) {
                    TextField("Rule Name (e.g. 'Product Prices')", text: $newRuleName)
                    TextField("CSS Selector (e.g. '.price, div.cost')", text: $newSelector)
                    TextField("Extract Attribute (leave empty for text)", text: $newAttribute)
                    
                    Button(action: addRule) {
                        Text(editingRule != nil ? "Update Rule" : "Add Rule")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(newRuleName.isEmpty || newSelector.isEmpty)
                }
                
                Section(header: Text("Your Selector Rules")) {
                    if viewModel.selectorRules.isEmpty {
                        Text("No rules added yet")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(viewModel.selectorRules) { rule in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(rule.name)
                                        .font(.headline)
                                    Spacer()
                                    Toggle("", isOn: binding(for: rule))
                                        .labelsHidden()
                                }
                                
                                Text(rule.selector)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if let attr = rule.extractAttribute, !attr.isEmpty {
                                    Text("Extract: \(attr)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                } else {
                                    Text("Extract: text content")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .contextMenu {
                                Button(action: { editRule(rule) }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive, action: { deleteRule(rule) }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: deleteRules)
                    }
                }
                
                Section {
                    Button(action: loadExamples) {
                        Text("Load Example Selectors")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    Button(action: {
                        showingHelp = true
                    }) {
                        Text("CSS Selector Help & Tips")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationBarTitle("CSS Selectors", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingHelp) {
                SelectorHelpView()
            }
            .onChange(of: editingRule) { rule in
                if let rule = rule {
                    newRuleName = rule.name
                    newSelector = rule.selector
                    newAttribute = rule.extractAttribute ?? ""
                }
            }
        }
    }
    
    private func binding(for rule: SelectorRule) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                if let index = self.viewModel.selectorRules.firstIndex(where: { $0.id == rule.id }) {
                    return self.viewModel.selectorRules[index].isEnabled
                }
                return false
            },
            set: { newValue in
                if let index = self.viewModel.selectorRules.firstIndex(where: { $0.id == rule.id }) {
                    self.viewModel.selectorRules[index].isEnabled = newValue
                }
            }
        )
    }
    
    private func addRule() {
        if let editingRule = editingRule, let index = viewModel.selectorRules.firstIndex(where: { $0.id == editingRule.id }) {
            viewModel.selectorRules[index] = SelectorRule(
                id: editingRule.id,
                name: newRuleName,
                selector: newSelector,
                extractAttribute: newAttribute.isEmpty ? nil : newAttribute,
                isEnabled: editingRule.isEnabled
            )
            self.editingRule = nil
        } else {
            let newRule = SelectorRule(
                name: newRuleName,
                selector: newSelector,
                extractAttribute: newAttribute.isEmpty ? nil : newAttribute
            )
            viewModel.selectorRules.append(newRule)
        }
        
        newRuleName = ""
        newSelector = ""
        newAttribute = ""
    }
    
    private func editRule(_ rule: SelectorRule) {
        editingRule = rule
    }
    
    private func deleteRule(_ rule: SelectorRule) {
        viewModel.selectorRules.removeAll { $0.id == rule.id }
    }
    
    private func deleteRules(at offsets: IndexSet) {
        viewModel.selectorRules.remove(atOffsets: offsets)
    }
    
    private func loadExamples() {
        viewModel.loadExampleSelectors()
    }
}

struct SelectorHelpView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("CSS Selector Basics")
                            .font(.title)
                            .padding(.top)
                        
                        Text("CSS selectors allow you to target specific elements on a webpage. Here are some common selectors:")
                        
                        selectorExample(
                            selector: "h1", 
                            description: "Selects all <h1> elements"
                        )
                        
                        selectorExample(
                            selector: ".classname", 
                            description: "Selects elements with class='classname'"
                        )
                        
                        selectorExample(
                            selector: "#idname", 
                            description: "Selects the element with id='idname'"
                        )
                        
                        selectorExample(
                            selector: "div.product", 
                            description: "Selects <div> elements with class='product'"
                        )
                        
                        selectorExample(
                            selector: "ul li", 
                            description: "Selects all <li> elements inside <ul> elements"
                        )
                        
                        selectorExample(
                            selector: "a[href]", 
                            description: "Selects all <a> elements with an href attribute"
                        )
                    }
                    
                    Group {
                        Text("Attribute Extraction")
                            .font(.title)
                            .padding(.top)
                        
                        Text("To extract content, leave the attribute field empty to get the text content. Otherwise specify the attribute name to extract:")
                        
                        selectorExample(
                            selector: "img", 
                            description: "Use attribute: 'src' to get image URLs"
                        )
                        
                        selectorExample(
                            selector: "a", 
                            description: "Use attribute: 'href' to get link URLs"
                        )
                        
                        selectorExample(
                            selector: "meta[property='og:image']", 
                            description: "Use attribute: 'content' to get Open Graph image"
                        )
                    }
                    
                    Group {
                        Text("Tips")
                            .font(.title)
                            .padding(.top)
                        
                        Text("• Use browser developer tools to inspect elements and find appropriate selectors")
                        Text("• Separate multiple selectors with commas: '.price, span.price'")
                        Text("• Be specific to avoid too many matches")
                        Text("• Test your selectors thoroughly")
                    }
                }
                .padding()
            }
            .navigationBarTitle("CSS Selector Help", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                // Dismiss help sheet
            })
        }
    }
    
    private func selectorExample(selector: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(selector)
                .font(.system(.body, design: .monospaced))
                .padding(6)
                .background(Color(.systemGray6))
                .cornerRadius(4)
            
            Text(description)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
