//
//  ActivityView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/29/25.
//

import SwiftUI

struct ActivityView: View {
    let uiModel: ActivityUIModel
    var isActive: Bool = false

    var hourHeight: CGFloat = 80
    
    // State to track measurements for the sticky effect
    @State private var contentHeight: CGFloat = 0
    @State private var stickyOffset: CGFloat = 0
    
    var onStop: (() -> Void)? = nil
    
    var body: some View {
        let duration: TimeInterval = {
            if let end = uiModel.endTime, let start = uiModel.startTime {
                return end.timeIntervalSince(start)
            }
            if let start = uiModel.startTime {
                return Date().timeIntervalSince(start)
            }
            return 0
        }()
        
        let calculatedHeight = (duration / 3600.0) * hourHeight
        let displayHeight = max(calculatedHeight, contentHeight)
        
        HStack {
            VStack(alignment: .trailing) {
                if let startTime = uiModel.startTime {
                    Text(startTime, format: .dateTime.hour().minute())
                        .offset(y: stickyOffset)
                }
                
                Spacer()
                
                if !uiModel.bottomConnected {
                    if let endTime = uiModel.endTime {
                        Text(endTime, format: .dateTime.hour().minute())
                    } else {
                        TimelineView(.periodic(from: .now, by: 1.0)) { context in
                            HStack(spacing: 4) {
                                Text("Now")
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 4))
                                    .foregroundStyle(.secondary)
                                Text(context.date, format: .dateTime.hour().minute())
                            }
                        }
                    }
                }
            }
            .frame(height: displayHeight)
            .font(.caption2)
            .foregroundStyle(.secondary)
            
            VStack {
                ActivityContents(uiModel: uiModel, onStop: onStop)
                // Measure the text content height
                .background(
                    GeometryReader { contentGeo in
                        Color.clear.onAppear {
                            contentHeight = contentGeo.size.height
                        }
                    }
                )
            }
            // Apply the sticky offset to the text content
            .offset(y: stickyOffset)
            // Force the bubble to be the calculated time-height
            .frame(height: displayHeight, alignment: .top)
            // Use Background GeometryReader to track scroll position
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            updateOffset(geo: geo, displayHeight: displayHeight)
                        }
                        .onChange(of: geo.frame(in: .named("scroll")).minY) { _ in
                            updateOffset(geo: geo, displayHeight: displayHeight)
                        }
                }
            )
            .bubbleStyle(
                isSelected: isActive,
                roundTopRight: !uiModel.topConnected,
                roundBottomRight: !uiModel.bottomConnected
            )
        }
    }
    
    // Helper to calculate the sticky logic
    private func updateOffset(geo: GeometryProxy, displayHeight: CGFloat) {
        let minY = geo.frame(in: .named("scroll")).minY
        let availableSpace = displayHeight - contentHeight - 8
        // Clamp the offset
        stickyOffset = max(0, min(-minY, availableSpace))
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
        .coordinateSpace(name: "scroll")
        .padding()
    }
}
