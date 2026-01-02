//
//  ContentView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/11/25.
//

import SwiftUI
import CoreData
import ActivityKit

struct ContentView: View {
    @StateObject private var viewModel: TimeTrackerViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: TimeTrackerViewModel(viewContext: context))
    }
    
    @FetchRequest(
        entity: Activity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.startTime, ascending: true)],
        animation: .default
    )
    private var activities: FetchedResults<Activity>

    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>
    
    @State var selectedCategory: Category? = nil
    @State private var selectedDate: Date = Date()
    @State private var inputText: String = ""
    
    // Computed property to find running activity
    var currentActivity: Activity? {
        activities.first(where: { $0.endTime == nil })
    }

    // Computed property to find today's activities
    var todayActivities: [Activity] {
        let calendar = Calendar.current
        return activities.filter { calendar.isDateInToday($0.startTime ?? Date()) }
    }

    var body: some View {
        VStack {
            GeometryReader { scrollProxy in
                let visibleHeight = scrollProxy.size.height
                
                ActivityListView(viewModel: viewModel, visibleHeight: visibleHeight)
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
            
//            DailyCalendarView(activities: Array(activities))
            
            CategorySelectionWheel(categories: Array(categories), selected: $selectedCategory)
            
            HStack {
                TextField("What are you doing?", text: $inputText)
                    .lineLimit(1)
                    .textFieldStyle(.plain)
                Button {
                    
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                        .foregroundColor(inputText.isEmpty ? .gray.opacity(0.3) : .primary)
                }
            }
            .frame(maxWidth: .infinity)
            .bubbleStyle()
        }
        .padding()
        .onAppear {
            viewModel.updateModels(from: Array(activities))
        }
        .onChange(of: activities.map { $0.startTime }) { _ in
            viewModel.updateModels(from: Array(activities))
        }
        .onChange(of: activities.map { $0.endTime }) { _ in
            viewModel.updateModels(from: Array(activities))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activities.count)
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

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ContentView(context: context)
        .environment(\.managedObjectContext, context)
}
