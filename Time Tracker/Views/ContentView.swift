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
    
    @State private var sheetHeight: CGFloat = 0
    @State var presentSheet = false
    @State private var selectedDate: Date = Date()
    
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
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    DateSelectionView(selectedDate: $selectedDate)
                        .padding(.top, 10)
                    
                    Divider()
                    
                    DailyCalendarView(activities: Array(activities), selectedDate: selectedDate)
                        .padding(.trailing)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: sheetHeight + 10)
                }
                
                VStack {
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
                    
                    Button("Start New Activity") {
                        presentSheet.toggle()
                    }
                    .buttonStyle(LargeButtonStyle())
                    .padding([.horizontal, .bottom], 16)
                }
                .background {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 24
                    )
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -5)
                }
                .background(
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            self.sheetHeight = geo.size.height
                        }
                        return Color.clear
                    }
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $presentSheet) {
            StartActivityView(
                categories: Array(categories),
                onStart: { category, description in
                    viewModel.activityName = description
                    viewModel.selectCategory(category, currentActivity: currentActivity)
                    
                    presentSheet = false
                },
                onCancel: {
                    presentSheet = false
                }
            )
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(.systemBackground))
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ContentView(context: context)
        .environment(\.managedObjectContext, context)
}
