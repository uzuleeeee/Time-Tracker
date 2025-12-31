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
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 15
        case .regular: return 20
        }
    }
}

struct BubbleModifier: ViewModifier {
    var size: BubbleSize = .regular
    var isSelected: Bool = false
    var roundTopRight: Bool = true
    var roundBottomRight: Bool = true
    
    var selectionColor: Color = Color.primary.opacity(0.5)
    
    func body(content: Content) -> some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: size.cornerRadius,
            bottomLeadingRadius: size.cornerRadius,
            bottomTrailingRadius: roundBottomRight ? size.cornerRadius : 0,
            topTrailingRadius: roundTopRight ? size.cornerRadius : 0,
            style: .continuous
        )
        
        content
            .font(size.font)
            .fontWeight(.medium)
            .monospacedDigit()
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                shape
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                shape
                    .strokeBorder(
                        isSelected ? selectionColor : .clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
    }
}

extension View {
    func bubbleStyle(
        size: BubbleSize = .regular,
        isSelected: Bool = false,
        roundTopRight: Bool = true,
        roundBottomRight: Bool = true
    ) -> some View {
        self.modifier(
            BubbleModifier(
                size: size,
                isSelected: isSelected,
                roundTopRight: roundTopRight,
                roundBottomRight: roundBottomRight
            )
        )
    }
}
