//
//  DailyCalendarView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/15/25.
//

import SwiftUI
import CoreData

struct DailyCalendarView: View {
    var activities: [Activity]
    var selectedDate: Date = Date()
    
    let hours = Array(0..<24)
    let hourHeight: CGFloat = 120
    
    var selectedDateActivities: [Activity] {
        activities.filter { activity in
            guard let start = activity.startTime else { return false }
            return Calendar.current.isDate(start, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        HStack(alignment: .top, spacing: 8) {
                            // Hour label
                            VStack {
                                Text("\(hour):00")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 40, height: 0, alignment: .trailing)
                            
                            // Horizontal line
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .frame(height: hourHeight, alignment: .top)
                    }
                }
                
                ForEach(selectedDateActivities) { activity in
                    ActivityBlock(
                        uiModel: activity.uiModel,
                        hourHeight: hourHeight
                    )
                    .padding(.leading, 60)
                }
            }
            .padding(.vertical)
        }
    }
}

struct ActivityBlock: View {
    var uiModel: ActivityUIModel
    var hourHeight: CGFloat
    
    let minimumHeight: CGFloat = 0
    
    var body: some View {
        let topOffset = (CGFloat(uiModel.startHour) + CGFloat(uiModel.startMinute) / 60.0) * hourHeight
        let height = CGFloat(uiModel.durationMinutes) / 60 * hourHeight
        
        let displayHeight = max(height, minimumHeight)
        
        RoundedRectangle(cornerRadius: 8)
            .frame(height: displayHeight)
            .foregroundStyle(uiModel.category.color.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(uiModel.category.color, lineWidth: 2)
            )
            .overlay(alignment: .topLeading) {
                ViewThatFits(in: .vertical) {
                    FullContent(uiModel: uiModel)
                        .fixedSize(horizontal: false, vertical: true)
                    CompactContent(uiModel: uiModel)
                        .fixedSize(horizontal: false, vertical: true)
                    MinimalContent()
                }
            }
            .clipped()
            .offset(y: topOffset)
            .contentShape(Rectangle())
    }
}

struct FullContent: View {
    let uiModel: ActivityUIModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(uiModel.category.name)
                .font(.caption)
                .bold()

            Text("\(uiModel.startHour):\(String(format: "%02d", uiModel.startMinute)) ~ \(uiModel.endHour):\(String(format: "%02d", uiModel.endMinute))")
                .font(.caption2)
        }
        .padding(6)
        .foregroundStyle(uiModel.category.color)
    }
}

struct CompactContent: View {
    let uiModel: ActivityUIModel

    var body: some View {
        Text(uiModel.category.name)
            .font(.caption)
            .bold()
            .lineLimit(1)
            .padding(6)
            .foregroundStyle(uiModel.category.color)
    }
}

struct MinimalContent: View {
    var body: some View {
        Text("")
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        DailyCalendarView(
            activities: Activity.examples,
            selectedDate: Date()
        )
        .background(Color(.secondarySystemBackground))
    }
}
