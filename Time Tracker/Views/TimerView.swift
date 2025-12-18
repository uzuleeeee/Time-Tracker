//
//  TimerView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/14/25.
//

import SwiftUI

struct TimerView: View {
    let uiModel: ActivityUIModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            IconView(uiModel: uiModel.category)
            
            // Text Details
            VStack(alignment: .leading) {
                Text(uiModel.category.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                if let description = uiModel.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if let startTime = uiModel.startTime {
                Text(startTime, style: .timer)
                    .font(.system(.title, design: .monospaced))
                    .bold()
                    .foregroundStyle(uiModel.category.color)
                    .frame(minWidth: 90, alignment: .trailing)
                    .layoutPriority(1)
            } else {
                Text("--:--")
                    .font(.system(.title, design: .monospaced))
                    .bold()
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        VStack {
            TimerView(
                uiModel: ActivityUIModel(
                    id: UUID(),
                    category: CategoryUIModel(
                        id: UUID(),
                        name: "Sleep",
                        iconName: "powersleep",
                        colorHex: "007AFF"),
                    startTime: Date().addingTimeInterval(-40000),
                    endTime: nil,
                    description: nil
                )
            )
            .background(Color(.secondarySystemBackground))
            
            TimerView(
                uiModel: ActivityUIModel(
                    id: UUID(),
                    category: CategoryUIModel(
                        id: UUID(),
                        name: "Fitness",
                        iconName: "figure.run",
                        colorHex: "008000"),
                    startTime: Date().addingTimeInterval(-1200),
                    endTime: nil,
                    description: "Marathon Training"
                )
            )
            .background(Color(.secondarySystemBackground))
            
            TimerView(uiModel: .empty)
                .background(Color(.secondarySystemBackground))
        }
    }
}
