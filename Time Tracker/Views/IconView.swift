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
        Group {
            if UIImage(systemName: uiModel.iconName) != nil {
                Image(systemName: uiModel.iconName)
                    .font(.title2)
                    .foregroundStyle(uiModel.color)
                    .padding(10)
                    .background(uiModel.color.opacity(0.2))
                    .clipShape(Circle())
            } else {
                Text(uiModel.iconName)
                    .font(.title2)
                    .padding(10)
                    .overlay (
                        Circle()
                            .strokeBorder(uiModel.color.opacity(0.8), lineWidth: 3)
                    )
            }
        }
        
        
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        VStack {
            IconView(
                uiModel: CategoryUIModel(
                    id: UUID(),
                    name: "Fitness",
                    iconName: "🏃‍♂️",
                    colorHex: "#008000")
            )
            .background(Color(.secondarySystemBackground))
            
            IconView(
                uiModel: .empty
            )
            .background(Color(.secondarySystemBackground))
        }
    }
}
