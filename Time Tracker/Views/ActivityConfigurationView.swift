//
//  AddActivityView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 1/3/26.
//

import SwiftUI

struct ActivityConfigurationView: View {
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var inputText: String = ""
    @State var selectedCategory: Category? = nil
    @State private var duration: Int = 0
    
    var categories: [Category]
    
    private var isValid: Bool {
        !inputText.isEmpty && selectedCategory != nil
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
        .onChange(of: startTime) { newStartTime in
            if endTime < newStartTime {
                endTime = newStartTime
            }
        }
        .onChange(of: endTime) { newEndTime in
            if startTime > newEndTime {
                startTime = newEndTime
            }
        }
    }
}

#Preview {
    let categories = Category.examples
    
    ActivityConfigurationView(categories: categories)
}
