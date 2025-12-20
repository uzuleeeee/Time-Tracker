//
//  CategorySelectionView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/14/25.
//

import SwiftUI
import CoreData

struct CategorySelectionView: View {
    var categories: [Category]
    var currentCategory: Category?
    
    var onSelect: (Category) -> Void
    
    let columns = [GridItem(.adaptive(minimum: 90), spacing: 0)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(categories) { category in
                CategoryButton(
                    uiModel: category.uiModel,
                    isActive: currentCategory == category,
                    action: { onSelect(category)}
                )
            }
        }
    }
}

struct CategoryButton: View {
    let uiModel: CategoryUIModel
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                IconView(uiModel: uiModel)
                Text(uiModel.name)
                    .foregroundStyle(contentColor)
            }
        }
        .buttonStyle(.borderless)
        .scaleEffect(isActive ? 1.05 : 1.0)
    }
    
    private var contentColor: Color {
        isActive ? uiModel.color : .secondary
    }
}

#Preview {
    let categories = Category.examples
    
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        CategorySelectionView(
            categories: categories,
            currentCategory: categories.first(where: { $0.name == "Work" }),
            onSelect: { _ in }
        )
        .background(Color(.secondarySystemBackground))
    }
}
