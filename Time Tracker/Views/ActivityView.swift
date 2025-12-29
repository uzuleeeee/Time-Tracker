//
//  ActivityView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/29/25.
//

import SwiftUI

struct ActivityView: View {
    let uiModel: ActivityUIModel
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Spacer()
                
                if let startTime = uiModel.startTime {
                    Text(startTime, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                }
                
                Group {
                    if let description = uiModel.description {
                        Text(description)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                    } else {
                        Text(uiModel.category.name)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                    }
                }
                .bubbleStyle()
                
                if let startTime = uiModel.startTime {
                    if uiModel.endTime == nil {
                        HStack {
                            
                            
                            HStack {
                                Text(startTime, style: .timer)
                                
                                Button {
                                    
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.primary)
                                }
                            }
                            .bubbleStyle()
                        }
                    } else if let endTime = uiModel.endTime {
                        let duration = endTime.timeIntervalSince(startTime)
                        
                        HStack(alignment: .bottom) {
                            Text(TimeFormatter.format(duration: duration))
                                .bubbleStyle()
                            
                            
                        }
                    }
                }
            }
            
            
        }
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
