//
//  Activity+UIExtensions.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/16/25.
//

import CoreData
import SwiftUI

extension Activity {
    var uiModel: ActivityUIModel {
        ActivityUIModel(
            id: self.id ?? UUID(),
            category: self.category?.uiModel ?? .empty,
            startTime: self.startTime,
            endTime: self.endTime,
            description: self.name
        )
    }
}
