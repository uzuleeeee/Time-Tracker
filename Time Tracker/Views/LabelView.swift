//
//  LabelView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/28/25.
//

import SwiftUI

struct LabelView: View {
    let uiModel: CategoryUIModel
    var borderColor: Color = .clear
    var borderWidth: CGFloat = 0
    var shadowColor: Color = .clear
    
    var body: some View {
        HStack {
            Text(uiModel.iconName)
            Text(uiModel.name)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(Color(.secondarySystemBackground))
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
        )
        .overlay(
            Capsule().strokeBorder(borderColor, lineWidth: borderWidth)
        )
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
