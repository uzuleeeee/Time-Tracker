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
    let currentActivity: Activity?
    
    var onAdd: ((Date, Date) -> Void)? = nil
    var onStop: (() -> Void)? = nil
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 2) {
                    ForEach(viewModel.timelineItems) { item in
                        switch item {
                        case .activity(let uiModel):
                            let isActive = uiModel.endTime == nil
                            
                            ActivityView(uiModel: uiModel, isActive: isActive, onStop: {
                                if let currentActivity = self.currentActivity, currentActivity.id == uiModel.id {
                                    viewModel.stopActivity(currentActivity)
                                }
                            })
                            .id(uiModel.id)
                            .background(
                                GeometryReader { geo in
                                    if uiModel.endTime == nil {
                                        Color.clear.preference(key: ScrollFramesKey.self, value: ["currentActivity": geo.frame(in: .named("scroll"))])
                                    }
                                }
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        case .gap(let uiModel):
                            let isLastItem = item.id == viewModel.timelineItems.last?.id
                            
                            GapView(uiModel: uiModel, visibleHeight: visibleHeight, isActive: isLastItem) {
                                onAdd?(uiModel.startTime, isLastItem ? Date() : uiModel.endTime)
                            }
                            .id(uiModel.id)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    
                    Text(Date(), style: .timer)
                        .frame(width: 0, height: 0)
                        .opacity(0)
                    
                    Color.clear
                        .frame(height: 1)
                        .id("Bottom")
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(key: ScrollFramesKey.self, value: ["bottom": geo.frame(in: .named("scroll"))])
                            }
                        )
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .coordinateSpace(name: "scroll")
            .overlayPreferenceValue(ScrollFramesKey.self) { frames in
                let currentActivityFrame = frames["currentActivity"]
                let isActivityBelowScreen = (currentActivityFrame?.minY ?? 0) > visibleHeight
                
                let bottomFrame = frames["bottom"]
                let isScrolledUp = (bottomFrame?.minY ?? 0) > (visibleHeight * 2)
                
                VStack {
                    Spacer()
                    
                    if isActivityBelowScreen, let currentUIModel = currentActivity?.uiModel {
                        HStack {
                            Spacer()
                            
                            Button {
                                scrollToBottom(proxy: proxy, scrollWithAnimation: true)
                            } label: {
                                ActivityContents(uiModel: currentUIModel)
                                    .bubbleStyle(isSelected: true)
                                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
                            }
                            .buttonStyle(.bouncy)
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else if isScrolledUp {
                        HStack {
                            Button {
                                scrollToBottom(proxy: proxy, scrollWithAnimation: true)
                            } label: {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.primary)
                                    .background(Material.regular) // Glassy look
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
                            }
                            .buttonStyle(.bouncy)
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.bottom, 6)
                .animation(.easeInOut, value: isActivityBelowScreen || isScrolledUp)
            }
            .onAppear {
                scrollToBottom(proxy: proxy, scrollWithAnimation: false)
            }
            .onReceive(viewModel.scrollSubject) { action in
                withAnimation {
                    switch action {
                    case .bottom:
                        proxy.scrollTo("Bottom", anchor: .bottom)
                    case .id(let id):
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, scrollWithAnimation: Bool) {
        DispatchQueue.main.async {
            if scrollWithAnimation {
                withAnimation {
                    proxy.scrollTo("Bottom", anchor: .bottom)
                }
            } else {
                proxy.scrollTo("Bottom", anchor: .bottom)
            }
        }
    }
}

struct ScrollFramesKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

//#Preview {
//    ActivityListView()
//}
