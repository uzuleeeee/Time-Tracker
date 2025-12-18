//
//  TimeTrackerWidgetBundle.swift
//  TimeTrackerWidget
//
//  Created by Mac-aroni on 12/17/25.
//

import WidgetKit
import SwiftUI

@main
struct TimeTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimeTrackerWidget()
        TimeTrackerWidgetControl()
        TimeTrackerWidgetLiveActivity()
    }
}
