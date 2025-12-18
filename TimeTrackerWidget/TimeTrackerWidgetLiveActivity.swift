//
//  TimeTrackerWidgetLiveActivity.swift
//  TimeTrackerWidget
//
//  Created by Mac-aroni on 12/17/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimeTrackerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        let categoryName: String
        let description: String?
        let iconName: String
        let startTime: Date?
        let colorHex: String
    }

    // Fixed non-changing properties about your activity go here!
    let id: UUID
}

struct TimeTrackerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimeTrackerWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack(spacing: 12) {
                // Icon
                Image(systemName: context.state.iconName)
                    .font(.title2)
                    .foregroundStyle(Color(hex: context.state.colorHex))
                    .padding(10)
                    .background(Color(hex: context.state.colorHex).opacity(0.2))
                    .clipShape(Circle())
                
                // Text Details
                VStack(alignment: .leading) {
                    Text(context.state.categoryName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if let description = context.state.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if let startTime = context.state.startTime {
                    Text(startTime, style: .timer)
                        .font(.system(.title, design: .monospaced))
                        .bold()
                        .foregroundStyle(Color(hex: context.state.colorHex))
                        .multilineTextAlignment(.trailing)
                        .frame(alignment: .trailing)
                } else {
                    Text("--:--")
                        .font(.system(.title, design: .monospaced))
                        .bold()
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("M")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TimeTrackerWidgetAttributes {
    fileprivate static var preview: TimeTrackerWidgetAttributes {
        TimeTrackerWidgetAttributes(
            id: UUID()
        )
    }
}

extension TimeTrackerWidgetAttributes.ContentState {
    fileprivate static var running: TimeTrackerWidgetAttributes.ContentState {
        TimeTrackerWidgetAttributes.ContentState(
            categoryName: "Work",
            description: nil,
            iconName: "briefcase.fill",
            startTime: Date().addingTimeInterval(-900),
            colorHex: "007AFF"
        )
    }
}

#Preview("Notification", as: .content, using: TimeTrackerWidgetAttributes.preview) {
   TimeTrackerWidgetLiveActivity()
} contentStates: {
    .running
}
