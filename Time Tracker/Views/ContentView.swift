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
    
    @State private var selectedDate: Date = Date()
    @State private var inputText: String = ""
    @State private var configurationContext: ActivityConfigurationContext? = nil
    
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
            VStack(spacing: 0) {
                GeometryReader { scrollProxy in
                    let visibleHeight = scrollProxy.size.height
                    
                    ZStack(alignment: .topLeading) {
                        ActivityListView(viewModel: viewModel, visibleHeight: visibleHeight, currentActivity: currentActivity) { startTime, endTime in
                            configurationContext = ActivityConfigurationContext(startTime: startTime, endTime: endTime)
                            print(startTime, endTime)
                        }
                        
                        Button {
                            configurationContext = ActivityConfigurationContext(startTime: Date(), endTime: Date())
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.bouncy)
                    }
                    .clipShape(Rectangle())
                }
                
                VStack {
                    Divider()
                    
                    CategorySelectionWheel(categories: viewModel.getPredictedCategories().isEmpty ? Array(categories) : Array(viewModel.getPredictedCategories()), selected: $viewModel.selectedCategory)
                    
                    HStack {
                        TextField("What are you doing?", text: $viewModel.inputText)
                            .lineLimit(1)
                            .textFieldStyle(.plain)
                        Button {
                            if let selectedCategory = viewModel.selectedCategory {
                                if let currentActivity {
                                    viewModel.stopActivity(currentActivity)
                                }
                                viewModel.startActivity(for: selectedCategory)
                                viewModel.updateModels(from: Array(activities))
                            }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .bold()
                                .foregroundColor(viewModel.selectedCategory == nil ? .gray.opacity(0.3) : .primary)
                        }
                        .buttonStyle(.bouncy)
                    }
                    .frame(maxWidth: .infinity)
                    .bubbleStyle()
                }
                .background(Color(.systemBackground))
            }
            .padding(.horizontal)
            .onAppear {
                viewModel.updateModels(from: Array(activities))
                viewModel.syncCategories(categories: Array(categories))
            }
            .onChange(of: activities.map { $0.startTime }) { _ in
                viewModel.updateModels(from: Array(activities))
            }
            .onChange(of: activities.map { $0.endTime }) { _ in
                viewModel.updateModels(from: Array(activities))
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activities.count)
            .sheet(item: $configurationContext) { context in
                ActivityConfigurationView(startTime: context.startTime, endTime: context.endTime, categories: Array(categories), onSave: { name, selectedCategory, startTime, endTime in
                    viewModel.configureActivity(name: name, category: selectedCategory, startTime: startTime, endTime: endTime, activities: activities)
                })
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ContentView(context: context)
        .environment(\.managedObjectContext, context)
}
