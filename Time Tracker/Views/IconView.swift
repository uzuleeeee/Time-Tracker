//
//  IconView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/14/25.
//

import SwiftUI

struct IconView: View {
    let uiModel: CategoryUIModel
    
    var body: some View {
        Image(systemName: uiModel.iconName)
            .font(.title2)
            .foregroundStyle(uiModel.color)
            .padding(10)
            .background(uiModel.color.opacity(0.2))
            .clipShape(Circle())
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        IconView(
            uiModel: CategoryUIModel(
                id: UUID(),
                name: "Fitness",
                iconName: "figure.run",
                colorHex: "#008000")
        )
        .background(Color(.secondarySystemBackground))
    }
}
