//
//  LabelView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/28/25.
//

import SwiftUI

struct LabelView: View {
    let uiModel: CategoryUIModel
    var isSelected: Bool = false
    
    var body: some View {
        Text("\(uiModel.iconName) \(uiModel.name)")
            .bubbleStyle(size: .small, isSelected: isSelected)
    }
}

#Preview {
    let categories = Category.examples
    
    ZStack {
        Color(.systemBackground).edgesIgnoringSafeArea(.all)
        
        VStack {
            ForEach(categories) { category in
                LabelView(uiModel: category.uiModel)
            }
        }
    }
}
