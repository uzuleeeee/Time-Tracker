//
//  ActivityView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/29/25.
//

import SwiftUI

struct ActivityView: View {
    let uiModel: ActivityUIModel
    var borderColor: Color = .clear
    var borderWidth: CGFloat = 0
    var shadowColor: Color = .clear
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            
            HStack(alignment: .bottom) {
                Spacer()
                
                if let startTime = uiModel.startTime {
                    Text(startTime, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                }
                
                HStack {
//                    Text(uiModel.category.iconName)
//                        .font(.system(.body, design: .rounded))
//                        .fontWeight(.medium)
//                        .padding(.vertical, 4)
//                        .padding(.horizontal, 8)
//                        .background(Color.primary.opacity(0.05))
//                        .cornerRadius(8)
                    
                    
                    if let description = uiModel.description {
                        Text(description)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                    }
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
            
            HStack(alignment: .bottom) {
                if let startTime = uiModel.startTime {
                    Group {
                        if uiModel.endTime == nil {
                            TimelineView(.periodic(from: .now, by: 60.0)) { context in
                                let duration = context.date.timeIntervalSince(startTime)
                                Text(TimeFormatter.format(duration: duration))
                            }
                        }
                        else if let endTime = uiModel.endTime {
                            let duration = endTime.timeIntervalSince(startTime)
                            Text(TimeFormatter.format(duration: duration))
                        }
                    }
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .monospacedDigit()
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
                
                if let endTime = uiModel.endTime {
                    Text(endTime, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                }
                
                Spacer()
            }
        }
//        .frame(maxWidth: .infinity)
    }
}

struct TimeFormatter {
    static func format(duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    let activities = Activity.examples
    
    ZStack {
        Color(.systemBackground).edgesIgnoringSafeArea(.all)
        
        ScrollView(showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 15) {
                ForEach(activities) { activity in
                    ActivityView(uiModel: activity.uiModel)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
    }
}
