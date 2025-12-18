//
//  Color+Hex.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/16/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let hexCode = cleanHex.hasPrefix("#") ? String(cleanHex.dropFirst()) : cleanHex
        
        var rgb: UInt64 = 0
        Scanner(string: hexCode).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
