//
//  TimeTrackerAttributes.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/18/25.
//

import SwiftUI
import ActivityKit

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
