//
//  GapView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/31/25.
//

import SwiftUI

struct GapView: View {
    let uiModel: GapUIModel
    var hourHeight: CGFloat = 80
    var visibleHeight: CGFloat
    var onAdd: ((Date, Date) -> Void)? = nil
    
    @State private var contentHeight: CGFloat = 0
    @State private var stickyOffset: CGFloat = 0
    
    var body: some View {
        let calculatedHeight = (uiModel.duration / 3600.0) * hourHeight
        let displayHeight = max(calculatedHeight, contentHeight)
        
        ZStack(alignment: .center) {
            HStack {
                Spacer()
                
                HStack(spacing: 8) {
                    Text(TimeFormatter.format(duration: uiModel.duration))
                        .font(.system(.footnote, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        onAdd?(uiModel.startTime, uiModel.endTime)
                    } label: {
                        Image(systemName: "plus")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.bouncy)
                }
                .padding(.trailing, 16)
            }
            .background(
                GeometryReader { contentGeo in
                    Color.clear.onAppear {
                        contentHeight = contentGeo.size.height
                    }
                }
            )
            .offset(y: stickyOffset)
        }
        .frame(height: displayHeight)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        updateOffset(geo: geo, displayHeight: displayHeight)
                    }
                    .onChange(of: geo.frame(in: .named("scroll")).minY) { _ in
                        updateOffset(geo: geo, displayHeight: displayHeight)
                    }
            }
        )
        .padding(.vertical, 4)
    }
    
    private func updateOffset(geo: GeometryProxy, displayHeight: CGFloat) {
        let frame = geo.frame(in: .named("scroll"))
        let minY = frame.minY
        
        let halfContent = contentHeight / 2
        let safeTop = halfContent
        let safeBottom = visibleHeight - halfContent
        
        let naturalCenterY = displayHeight / 2
        let currentGlobalCenterY = minY + naturalCenterY
        let targetGlobalCenterY = min(max(currentGlobalCenterY, safeTop), safeBottom)
        
        let proposedOffset = targetGlobalCenterY - currentGlobalCenterY
        
        let maxTravel = (displayHeight - contentHeight) / 2
        
        if maxTravel > 0 {
            stickyOffset = min(max(proposedOffset, -maxTravel), maxTravel)
        } else {
            stickyOffset = 0
        }
    }
}

#Preview {
    ZStack {
        Color(.systemBackground).edgesIgnoringSafeArea(.all)
        
        VStack {
            GapView(uiModel: GapUIModel(id: "a", duration: 15 * 60, startTime: Date(), endTime: Date()), visibleHeight: 800)
            
            GapView(uiModel: GapUIModel(id: "b", duration: 2 * 3600, startTime: Date(), endTime: Date()), visibleHeight: 800)
                .background(Color.blue.opacity(0.3))
        }
    }
}
