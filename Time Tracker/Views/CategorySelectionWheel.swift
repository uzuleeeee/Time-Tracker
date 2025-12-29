//
//  CategorySelectionWheel.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/28/25.
//

import SwiftUI

struct CategorySelectionWheel: View {
    var categories: [Category]
    @Binding var selected: Category?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories) { category in
                    let isSelected = selected?.id == category.id
                    
                    Button {
                        if selected?.id == category.id {
                            selected = nil
                        } else {
                            selected = category
                        }
                    } label: {
                        LabelView(
                            uiModel: category.uiModel,
                            borderColor: isSelected ? Color.primary.opacity(0.5) : Color.clear,
                            borderWidth: isSelected ? 2 : 0
                        )
                        .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        let categories = Category.examples
        @State var currentSelection: Category? = Category.examples.first
        
        var body: some View {
            CategorySelectionWheel(
                categories: categories,
                selected: $currentSelection
            )
            .padding()
            .padding(.vertical, 10)
        }
    }
    
    return PreviewWrapper()
}
