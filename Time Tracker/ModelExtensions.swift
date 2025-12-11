//
//  ModelExtensions.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/11/25.
//

import SwiftUI
import CoreData

extension Category {
    public var wrappedName: String { name ?? "Unknown" }
    public var wrappedIcon: String { iconName ?? "questionmark" }
    
    // Convert the hex string back to a SwiftUI Color
    public var color: Color {
        guard let hex = colorHex else { return .gray }
        
        if hex == "007AFF" { return .blue }
        if hex == "34C759" { return .green }
        if hex == "FF3B30" { return .red }
        if hex == "AF52DE" { return .purple }
        return .gray // Fallback
    }
}

extension Activity {
    public var wrappedName: String { name ?? "Untitled" }
    
    // Helper to calculate duration
    public var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime ?? Date())
    }
}
