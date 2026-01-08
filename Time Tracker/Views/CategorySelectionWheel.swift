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
    var onAdd: (() -> Void)? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button {
                    onAdd?()
                } label: {
                    Image(systemName: "plus")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .padding(4)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                }
                .buttonStyle(.bouncy)
                
                ForEach(categories) { category in
                    let isSelected = selected?.id == category.id
                    
                    Button {
                        if isSelected {
                            selected = nil
                        } else {
                            selected = category
                        }
                    } label: {
                        LabelView(
                            uiModel: category.uiModel,
                            isSelected: isSelected
                        )
                        .tint(.primary)
                    }
                    .buttonStyle(.bouncy)
                    .id(category.id)
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .padding(4)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                }
                .buttonStyle(.bouncy)
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
