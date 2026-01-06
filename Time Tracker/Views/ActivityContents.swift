//
//  ActivityBubble.swift
//  Time Tracker
//
//  Created by Mac-aroni on 1/1/26.
//

import SwiftUI

struct ActivityContents: View {
    let uiModel: ActivityUIModel
    
    var body: some View {
        HStack {
            if let description = uiModel.description {
                Text(description)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
            } else {
                Text(uiModel.category.name)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
            }
            
            Image(systemName: "circle.fill")
                .font(.system(size: 4))
                .foregroundStyle(.secondary)
            
            if let startTime = uiModel.startTime {
                if uiModel.endTime == nil {
                    HStack {
                        Text(startTime, style: .timer)
                        Button {
                            
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .bold()
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.bouncy)
                    }
                } else if let endTime = uiModel.endTime {
                    let duration = endTime.timeIntervalSince(startTime)
                    Text(TimeFormatter.format(duration: duration))
                }
            }
        }
        .lineLimit(1)
    }
}

#Preview {
    let activities = Activity.examples
    
    ZStack {
        Color(.systemBackground).edgesIgnoringSafeArea(.all)
        
        ScrollView(showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 15) {
                ForEach(activities) { activity in
                    ActivityContents(uiModel: activity.uiModel)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .coordinateSpace(name: "scroll")
        .padding()
    }
}
