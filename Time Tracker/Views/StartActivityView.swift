//
//  StartActivityView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/19/25.
//

import SwiftUI

struct StartActivityView: View {
    var categories: [Category]
    var currentCategory: Category?
    
    var onStart: (Category, String) -> Void
    var onCancel: () -> Void
    
    @State private var selectedCategory: Category?
    @State private var descriptionText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CategorySelectionView(
                        categories: Array(categories),
                        currentCategory: selectedCategory ?? currentCategory,
                        onSelect: { category in
                            selectedCategory = category
                        }
                    )
                }
                
                Section {
                    TextField("Description (Optional)", text: $descriptionText)
                }
            }
            .navigationTitle(Text("New Activity"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .keyboard) {
                    Button("Done") { isFocused = false }
                }
            }
            
            Button("Start Activity") {
                guard let category = selectedCategory else { return }
                onStart(category, descriptionText)
            }
            .buttonStyle(LargeButton())
            .disabled(selectedCategory == nil)
            .opacity(selectedCategory == nil ? 0.5 : 1.0)
            .padding()
        }
    }
}

#Preview {
    let categories = Category.examples
    
    StartActivityView(
        categories: categories,
        currentCategory: categories.first,
        onStart: { category, description in
            print("Start \(category.name ?? "Unknown") with description: \(description)")
        },
        onCancel: {
            print("Cancel start activity")
        }
    )
}
