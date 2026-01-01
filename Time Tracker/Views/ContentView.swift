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
            ScrollView(showsIndicators: false) {
                VStack(alignment: .trailing, spacing: 3) {
                    ForEach(viewModel.processedActivityUIModels) { uiModel in
                        ActivityView(uiModel: uiModel)
                            .padding(.top, uiModel.topConnected ? 0 : 20)
                            .padding(.bottom, uiModel.bottomConnected ? 0 : 20)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
//            DailyCalendarView(activities: Array(activities))
            
            Spacer()
            
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
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ContentView(context: context)
        .environment(\.managedObjectContext, context)
}
