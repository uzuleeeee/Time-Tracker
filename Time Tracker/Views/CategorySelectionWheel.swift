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
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button {
                        onAdd?()
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .padding(4)
                            .background(Color(.tertiarySystemFill))
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
                        onAdd?()
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .padding(4)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.bouncy)
                }
            }
            .onChange(of: selected) { newCategory in
                if let newCategory {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        proxy.scrollTo(newCategory.id, anchor: .center)
                    }
                }
            }
            .onAppear {
                if let category = selected {
                    proxy.scrollTo(category.id, anchor: .center)
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
            .border(.red)
            .padding()
            .padding(.vertical, 10)
        }
    }
    
    return PreviewWrapper()
}
