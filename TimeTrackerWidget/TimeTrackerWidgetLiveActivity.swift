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
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TimeTrackerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimeTrackerWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

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
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TimeTrackerWidgetAttributes {
    fileprivate static var preview: TimeTrackerWidgetAttributes {
        TimeTrackerWidgetAttributes(name: "World")
    }
}

extension TimeTrackerWidgetAttributes.ContentState {
    fileprivate static var smiley: TimeTrackerWidgetAttributes.ContentState {
        TimeTrackerWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TimeTrackerWidgetAttributes.ContentState {
         TimeTrackerWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TimeTrackerWidgetAttributes.preview) {
   TimeTrackerWidgetLiveActivity()
} contentStates: {
    TimeTrackerWidgetAttributes.ContentState.smiley
    TimeTrackerWidgetAttributes.ContentState.starEyes
}
