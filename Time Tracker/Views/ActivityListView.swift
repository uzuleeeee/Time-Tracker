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
    }
}

//#Preview {
//    ActivityListView()
//}
