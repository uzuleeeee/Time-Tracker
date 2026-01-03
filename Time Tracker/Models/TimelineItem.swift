//
//  TimelineItem.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/31/25.
//


import SwiftUI

enum TimelineItem: Identifiable {
    case activity(ActivityUIModel)
    case gap(GapUIModel)
    case dateIndicator(Date)
    
    var id: String {
        switch self {
        case .activity(let model): return model.id.uuidString
        case .gap(let model): return model.id
        case .dateIndicator(let date): return "date-\(date.timeIntervalSince1970)"
        }
    }
}
