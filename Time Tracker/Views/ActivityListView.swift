//
//  ActivityListView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 1/1/26.
//

import SwiftUI

struct ActivityListView: View {
    @ObservedObject var viewModel: TimeTrackerViewModel
    let visibleHeight: CGFloat
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 3) {
                ForEach(viewModel.timelineItems) { item in
                    switch item {
                    case .activity(let uiModel):
                        ActivityView(uiModel: uiModel)
                            .background(
                                GeometryReader { geo in
                                    if uiModel.endTime == nil {
                                        Color.clear.preference(key: CurrentActivityPositionKey.self, value: geo.frame(in: .named("scroll")))
                                    }
                                }
                            )
                    case .gap(let uiModel):
                        GapView(uiModel: uiModel, visibleHeight: visibleHeight)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .coordinateSpace(name: "scroll")
        .overlayPreferenceValue(CurrentActivityPositionKey.self) { frame in
            let isFooterVisible = (frame?.minY ?? 0) > visibleHeight
            
            VStack {
                Spacer()
                
                if isFooterVisible, let liveModel = getCurrentActivityModel() {
                    HStack {
                        Spacer()
                        
                        ActivityContents(uiModel: liveModel)
                            .bubbleStyle(isSelected: true)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.easeInOut, value: isFooterVisible)
        }
    }
    
    private func getCurrentActivityModel() -> ActivityUIModel? {
        if let currentItem = viewModel.timelineItems.first(where: {
            if case .activity(let m) = $0, m.endTime == nil { return true }
            return false
        }), case .activity(let uiModel) = currentItem {
            return uiModel
        }
        return nil
    }
}

struct CurrentActivityPositionKey: PreferenceKey {
    static var defaultValue: CGRect? = nil
    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = value ?? nextValue()
    }
}

//#Preview {
//    ActivityListView()
//}
