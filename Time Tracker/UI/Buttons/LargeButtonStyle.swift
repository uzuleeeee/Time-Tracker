//
//  LargeButtonStyle.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/19/25.
//

import SwiftUI

struct LargeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.accentColor)
            )
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(
                .interactiveSpring(response: 0.25, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}
