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
    let color: Color
    
    // Default placeholder when category data is unavailable
    static let empty = CategoryUIModel(
        id: UUID(),
        name: "Unknown",
        iconName: "questionmark.circle.fill",
        color: .gray
    )
}
