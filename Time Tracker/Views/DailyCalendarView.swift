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
    
    private let hourLabelWidth: CGFloat = 40
    private let horizontalSpacing: CGFloat = 8
    private var activityBlockIndent: CGFloat {
        hourLabelWidth + horizontalSpacing
    }
    
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
                        HStack(alignment: .top, spacing: horizontalSpacing) {
                            // Hour label
                            VStack {
                                Text("\(hour):00")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: hourLabelWidth, height: 0, alignment: .trailing)
                            
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
                    .padding(.leading, activityBlockIndent)
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
    let viewContext = PersistenceController(inMemory: true).container.viewContext

    let c1 = Category(context: viewContext)
    c1.id = UUID()
    c1.name = "Sleep"
    c1.iconName = "😴"
    c1.colorHex = "#5856D6"
    
    let c2 = Category(context: viewContext)
    c2.id = UUID()
    c2.name = "Sleep"
    c2.iconName = "😴"
    c2.colorHex = "#5856D6"
    
    let c3 = Category(context: viewContext)
    c3.id = UUID()
    c3.name = "Sleep"
    c3.iconName = "😴"
    c3.colorHex = "#5856D6"
    
    let c4 = Category(context: viewContext)
    c4.id = UUID()
    c4.name = "Sleep"
    c4.iconName = "😴"
    c4.colorHex = "#5856D6"

    func createActivity(_ category: Category, _ h: Int, _ m: Int, _ duration: Int) -> Activity {
        let activity = Activity(context: viewContext)
        activity.id = UUID()
        activity.category = category

        guard let start = Calendar.current.date(
            bySettingHour: h,
            minute: m,
            second: 0,
            of: Date()
        ) else {
            fatalError("Invalid date")
        }

        activity.startTime = start
        activity.endTime = Calendar.current.date(byAdding: .minute, value: duration, to: start)
        return activity
    }

    let a1 = createActivity(c1, 0, 0, 5)
    let a2 = createActivity(c2, 1, 0, 15)
    let a3 = createActivity(c3, 2, 0, 45)
    
    
    try? viewContext.save()

    return ZStack {
        Color.black.ignoresSafeArea()

        DailyCalendarView(
            activities: [a1, a2, a3],
            selectedDate: Date()
        )
        .border(.red)
        .background(Color(.secondarySystemBackground))
    }
}
