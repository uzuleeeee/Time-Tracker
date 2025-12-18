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
    @StateObject private var viewModel = TimeTrackerViewModel()
    
    @FetchRequest(
        entity: Activity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.startTime, ascending: false)],
        animation: .default
    )
    private var activities: FetchedResults<Activity>

    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>
    
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
        NavigationStack {
            VStack {
                DailyCalendarView(activities: Array(activities), selectedDate: Date())
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        TimerView(uiModel: currentActivity?.uiModel ?? .empty)
                        
                        if let currentActivity {
                            Button {
                                viewModel.stopActivity(currentActivity)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.red)
                                    .padding(.trailing)
                            }
                        }
                    }
                    .id(currentActivity?.id)
                    .transition(.opacity.animation(.default))
                    
                    Divider()
                        .padding(.horizontal)
                    
                    CategorySelectionView(
                        categories: Array(categories),
                        currentCategory: viewModel.selectedCategory,
                        onSelect: { category in
                            viewModel.selectCategory(category, currentActivity: currentActivity)
                        }
                    )
                    .padding(.vertical)
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
