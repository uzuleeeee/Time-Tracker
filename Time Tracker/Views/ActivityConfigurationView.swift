//
//  AddActivityView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 1/3/26.
//

import SwiftUI

struct ActivityConfigurationView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var inputText: String = ""
    @State var selectedCategory: Category? = nil
    
    @State var startTime: Date
    @State var endTime: Date
    
    var categories: [Category]
    var onSave: ((String, Category, Date, Date) -> Void)?
    
    @State private var predictedCategories: [Category] = []
    
    private var isValid: Bool {
        selectedCategory != nil && startTime < endTime && endTime <= Date()
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $inputText)
                    .lineLimit(1)
                    .textFieldStyle(.plain)
                    .onChange(of: inputText) { newText in
                        predict(newText)
                    }
                    .tint(.primary)
                
                CategorySelectionWheel(categories: predictedCategories.isEmpty ? Array(categories) : predictedCategories, selected: $selectedCategory)
            }
            
            Section {
                DatePicker("Start: ", selection: $startTime)
                
                DatePicker("End: ", selection: $endTime)
            }
            
            Button {
                if let selectedCategory {
                    onSave?(inputText, selectedCategory, startTime, endTime)
                }
                
                dismiss()
            } label: {
                Image(systemName: "plus")
                    .padding()
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(isValid ? Color(.systemBackground) : Color(.systemBackground).opacity(0.7))
                    .background(isValid ? Color(uiColor: .label) : .gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.borderless)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .disabled(!isValid)
        }
    }
    
    private func predict(_ text: String) {
        if text.isEmpty {
            self.predictedCategories = []
            self.selectedCategory = nil
            return
        }
        
        if !Scorer.shared.isReady {
            self.predictedCategories = []
            return
        }
        
        let currentText = text
        
        Task.detached(priority: .userInitiated) {            
            let newResults = Scorer.shared.predict(text: currentText)
            
            await MainActor.run {
                setCategoriesFromResults(from: newResults)
            }
        }
    }
    
    private func setCategoriesFromResults(from results: [(String, Float)]) {
        // Initialize array to store mapped categories
        var mappedCategories: [Category] = []
        
        for (name, _) in results {
            if let match = categories.first(where: { $0.name == name }) {
                mappedCategories.append(match)
            }
        }
        
        predictedCategories = mappedCategories
        
        if let topMatch = predictedCategories.first {
            selectedCategory = topMatch
        }
    }
}

#Preview {
    let categories = Category.examples
    
    ActivityConfigurationView(startTime: Date(), endTime: Date(), categories: categories)
}
