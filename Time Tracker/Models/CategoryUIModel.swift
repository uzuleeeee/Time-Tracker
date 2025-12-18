//
//  CategoryUIModel.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/16/25.
//

import SwiftUI

struct CategoryUIModel: Identifiable, Equatable {
    let id: UUID
    let name: String
    let iconName: String
    let colorHex: String
    
    // Default placeholder when category data is unavailable
    static let empty = CategoryUIModel(
        id: UUID(),
        name: "Unknown",
        iconName: "questionmark.circle.fill",
        colorHex: "#808080"
    )
    
    var color: Color {
        Color(hex: colorHex)
    }
}
