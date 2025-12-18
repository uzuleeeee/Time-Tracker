//
//  ActivityContent.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/16/25.
//

import SwiftUI

struct ActivityUIModel: Identifiable, Equatable {
    let id: UUID
    let category: CategoryUIModel
    
    let startTime: Date?
    let endTime: Date?
    let description: String?
    
    // Default placeholder when activity data is unavailable
    static let empty = ActivityUIModel(
        id: UUID(),
        category: .empty,
        startTime: nil,
        endTime: nil,
        description: nil)
    
    // Computed variables
    var startHour: Int {
        Calendar.current.component(.hour, from: startTime ?? Date())
    }
    
    var startMinute: Int {
        Calendar.current.component(.minute, from: startTime ?? Date())
    }
    
    var endHour: Int {
        Calendar.current.component(.hour, from: endTime ?? Date())
    }
    
    var endMinute: Int {
        Calendar.current.component(.minute, from: endTime ?? Date())
    }
    
    var durationMinutes: Double {
        let start = startTime ?? Date()
        let end = endTime ?? Date()
        
        return end.timeIntervalSince(start) / 60.0
    }
}
