//
//  Category+UIExtensions.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/16/25.
//

import CoreData
import SwiftUI

extension Category {
    var uiModel: CategoryUIModel {
        CategoryUIModel(
            id: self.id ?? UUID(),
            name: self.name ?? "Unknown",
            iconName: self.iconName ?? "questionmark.circle.fill",
            colorHex: self.colorHex ?? "808080"
        )
    }
}
