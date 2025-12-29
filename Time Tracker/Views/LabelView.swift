//
//  LabelView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/28/25.
//

import SwiftUI

struct LabelView: View {
    let uiModel: CategoryUIModel
    
    var body: some View {
        HStack {
            Text(uiModel.iconName)
            Text(uiModel.name)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
