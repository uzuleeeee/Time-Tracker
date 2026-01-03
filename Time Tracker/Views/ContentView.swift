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
                
                ActivityListView(viewModel: viewModel, visibleHeight: visibleHeight, currentActivity: currentActivity)
            }
            
//            DailyCalendarView(activities: Array(activities))
            
            VStack {
                Divider()
                
                CategorySelectionWheel(categories: Array(categories), selected: $selectedCategory)
                
                HStack {
                    TextField("What are you doing?", text: $inputText)
                        .lineLimit(1)
                        .textFieldStyle(.plain)
                    Button {
                        
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(inputText.isEmpty ? .gray.opacity(0.3) : .primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .bubbleStyle()
            }
            .background(Color(.systemBackground))
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
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ContentView(context: context)
        .environment(\.managedObjectContext, context)
}
