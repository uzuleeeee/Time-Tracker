//
//  ViewModifiers.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/29/25.
//

import SwiftUI

enum BubbleSize {
    case small
    case regular
    
    var font: Font {
        switch self {
        case .small: return .system(.subheadline, design: .rounded)
        case .regular: return .system(.body, design: .rounded)
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return 4
        case .regular: return 8
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 8
        case .regular: return 16
        }
    }
}

struct BubbleModifier: ViewModifier {
    var size: BubbleSize = .regular
    var isSelected: Bool = false
    
    var selectionColor: Color = Color.primary.opacity(0.5)
    
    func body(content: Content) -> some View {
        content
            .font(size.font)
            .fontWeight(.medium)
            .monospacedDigit()
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                Capsule()
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? selectionColor : .clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
    }
}

extension View {
    func bubbleStyle(size: BubbleSize = .regular, isSelected: Bool = false) -> some View {
        self.modifier(BubbleModifier(size: size, isSelected: isSelected))
    }
}
