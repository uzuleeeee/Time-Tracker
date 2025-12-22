//
//  DailyCalendarView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/15/25.
//

import SwiftUI
import CoreData

struct DailyCalendarView: View {
    @Environment(\.locale) var locale
    
    var activities: [Activity]
    var selectedDate: Date = Date()
    
    let hours = Array(0..<24)
    let hourHeight: CGFloat = 120
    
    private let hourLabelWidth: CGFloat = 55
    private let horizontalSpacing: CGFloat = 8
    private var activityBlockIndent: CGFloat {
        hourLabelWidth + horizontalSpacing
    }
    
    enum TimeIndicatorPosition {
        case visible
        case up
        case down
    }
    @State private var timeIndicatorPosition: TimeIndicatorPosition = .visible
    
    private var selectedDateIsToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    var selectedDateActivities: [Activity] {
        activities.filter { activity in
            guard let start = activity.startTime else { return false }
            return Calendar.current.isDate(start, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: 0) {
                            ForEach(hours, id: \.self) { hour in
                                HStack(alignment: .top, spacing: horizontalSpacing) {
                                    // Hour label
                                    VStack {
                                        Text(formatHour(hour))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .minimumScaleFactor(0.8)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(width: hourLabelWidth, alignment: .trailing)
                                    .frame(height: 0)
                                    
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
                        
                        if selectedDateIsToday {
                            TimelineView(.everyMinute) { context in
                                TimeIndicator(
                                    date: context.date,
                                    hourHeight: hourHeight,
                                    hourLabelWidth: hourLabelWidth,
                                    leadingIndent: activityBlockIndent
                                )
                            }
                        }
                    }
                    .padding(.vertical)
                    .onAppear {
                        scrollToCurrentTime(proxy: proxy)
                    }
                    .onChange(of: selectedDate) { newDate in
                        if Calendar.current.isDateInToday(newDate) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                scrollToCurrentTime(proxy: proxy)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onPreferenceChange(ViewOffsetKey.self) { indicatorY in
                    let containerHeight = geometry.size.height
                    
                    if indicatorY < -20 {
                        timeIndicatorPosition = .up
                    } else if indicatorY > containerHeight + 20 {
                        timeIndicatorPosition = .down
                    } else {
                        timeIndicatorPosition = .visible
                    }
                }
                .overlay(alignment: timeIndicatorPosition == .up ? .topLeading : .bottomLeading) {
                    if selectedDateIsToday && timeIndicatorPosition != .visible {
                        floatingTimeIndicator(proxy: proxy)
                            .padding(.vertical, 16)
                            .transition(.opacity.combined(with: .move(edge: timeIndicatorPosition == .up ? .top : .bottom)))
                    }
                }
            }
        }
        .coordinateSpace(name: "scroll")
        .animation(.easeInOut, value: timeIndicatorPosition)
    }
    
    private func floatingTimeIndicator(proxy: ScrollViewProxy) -> some View {
        Button {
            scrollToCurrentTime(proxy: proxy)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: timeIndicatorPosition == .up ? "arrow.up" : "arrow.down")
                    .font(.caption2)
                
                TimelineView(.everyMinute) { context in
                    Text(formatTime(context.date))
                }
            }
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(.red))
            .shadow(radius: 4, y: 2)
        }
        .frame(width: activityBlockIndent, alignment: .trailing)
    }
    
    private func scrollToCurrentTime(proxy: ScrollViewProxy) {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        withAnimation {
            proxy.scrollTo(currentHour, anchor: .center)
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        let calendar = Calendar.current
        
        guard let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) else {
            return "\(hour):00"
        }
        
        let formatter = DateFormatter()
        formatter.locale = locale
        
        let formatString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale) ?? ""
        let is12Hour = formatString.contains("a")
        
        formatter.dateFormat = is12Hour ? "h a" : "H:mm"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        
        let formatString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale) ?? ""
        let is12Hour = formatString.contains("a")
        
        formatter.dateFormat = is12Hour ? "h:mm" : "H:mm"
        return formatter.string(from: date)
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

            Text("\(uiModel.startHour):\(String(format: "%02d", uiModel.startMinute)) - \(uiModel.endHour):\(String(format: "%02d", uiModel.endMinute))")
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

struct TimeIndicator: View {
    @Environment(\.locale) var locale
    
    let date: Date
    let hourHeight: CGFloat
    let hourLabelWidth: CGFloat
    let leadingIndent: CGFloat
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = locale
        
        let formatString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale) ?? ""
        let is12Hour = formatString.contains("a")
        
        if is12Hour {
            formatter.dateFormat = "h:mm"
        } else {
            formatter.dateFormat = "H:mm"
        }
        
        return formatter.string(from: date)
    }
    
    var body: some View {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        let offset = (CGFloat(hour) + CGFloat(minute) / 60.0) * hourHeight
        
        Color.clear
            .frame(height: offset)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ViewOffsetKey.self,
                            value: geo.frame(in: .named("scroll")).maxY
                        )
                }
            )
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 0) {
                    Text(formattedTime)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(.red))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: leadingIndent, alignment: .trailing)
                    
                    Rectangle()
                        .fill(.red)
                        .frame(height: 1)
                }
                .alignmentGuide(.bottom) { d in
                     d[VerticalAlignment.center]
                }
            }
            .allowsHitTesting(false)
    }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    let viewContext = PersistenceController(inMemory: true).container.viewContext

    let fixedDate = Date()
    
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
            of: fixedDate
        ) else {
            fatalError("Invalid date")
        }

        activity.startTime = start
        activity.endTime = Calendar.current.date(byAdding: .minute, value: duration, to: start)
        return activity
    }

    let a1 = createActivity(c1, 13, 0, 5)
    let a2 = createActivity(c2, 14, 0, 15)
    let a3 = createActivity(c3, 15, 0, 45)
    
    try? viewContext.save()
    
    return ZStack {
        Color.black.ignoresSafeArea()

        DailyCalendarView(
            activities: [a1, a2, a3],
            selectedDate: fixedDate
        )
        .environment(\.managedObjectContext, viewContext)
//        .environment(\.locale, .init(identifier: "en_GB"))
        .border(.red)
        .background(Color(.secondarySystemBackground))
        .environment(\.locale, .init(identifier: "en_US"))
    }
}
