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
    
    private var isValid: Bool {
        !inputText.isEmpty && selectedCategory != nil && startTime < endTime
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $inputText)
                    .lineLimit(1)
                    .textFieldStyle(.plain)
                CategorySelectionWheel(categories: Array(categories), selected: $selectedCategory)
            }
            
            Section {
                DatePicker("Start: ", selection: $startTime, in: ...Date())
                
                DatePicker("End: ", selection: $endTime, in: ...Date())
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
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .buttonStyle(.borderless)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .disabled(!isValid)
        }
    }
}

#Preview {
    let categories = Category.examples
    
    ActivityConfigurationView(startTime: Date(), endTime: Date(), categories: categories)
}
