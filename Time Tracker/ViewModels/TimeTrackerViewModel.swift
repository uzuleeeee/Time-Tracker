//
//  TimeTrackerViewModel.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/16/25.
//

import SwiftUI
import CoreData
import ActivityKit
internal import Combine

@MainActor
class TimeTrackerViewModel: ObservableObject {
    // Dependencies
    private let viewContext = PersistenceController.shared.container.viewContext
    
    // UI state
    @Published var selectedCategory: Category?
    @Published var activityName: String = ""
    
    // Live activity
    private var currentLiveActivity: ActivityKit.Activity<TimeTrackerWidgetAttributes>?
    
    // Actions
    
    func selectCategory(_ category: Category, currentActivity: Activity?) {
        print("Select category: \(category.uiModel.name)")
        
        self.selectedCategory = category
        
        let isSameCategory = currentActivity?.category == category
        
        if !isSameCategory {
            if let currentActivity {
                stopActivity(currentActivity)
            }
            
            startActivity(for: category)
        }
    }
    
    func startActivity(for category: Category) {
        print("Start activity: \(category.uiModel.name)")
        
        withAnimation {
            let newActivity = Activity(context: viewContext)
            newActivity.id = UUID()
            newActivity.startTime = Date()
            newActivity.category = category
            newActivity.name = activityName.isEmpty ? nil : activityName
            newActivity.endTime = nil // Explicitly nil implies running
            
            saveContext()
            
            startLiveActivity(newActivity)
            
            // Reset UI
            activityName = ""
        }
    }

    func stopActivity(_ activity: Activity) {
        print("Stop activity: \(activity.uiModel.category.name)")
        
        withAnimation {
            activity.endTime = Date()
            saveContext()
            
            stopLiveActivity()
        }
    }
    
    func deleteItems(offsets: IndexSet, activities: FetchedResults<Activity>) {
        print("Delete item")
        
        withAnimation {
            offsets.map { activities[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }

    // Internal helpers
    
    private func saveContext() {
        print("Save context")
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // Live Activity
    
    private func startLiveActivity(_ activity: Activity) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let uiModel = activity.uiModel
        
        let attributes = TimeTrackerWidgetAttributes(id: uiModel.id)
        let state = TimeTrackerWidgetAttributes.ContentState(
            categoryName: uiModel.category.name,
            description: uiModel.description,
            iconName: uiModel.category.iconName,
            startTime: uiModel.startTime,
            colorHex: uiModel.category.colorHex
        )
        
        do {
            let activity = try ActivityKit.Activity<TimeTrackerWidgetAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil)
            )
            
            self.currentLiveActivity = activity
            print("Live Activity started: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: ", error)
        }
    }
    
    private func stopLiveActivity() {
        guard let currentLiveActivity else { return }
        
        Task {
            await currentLiveActivity.end(nil, dismissalPolicy: .immediate)
            self.currentLiveActivity = nil
        }
    }
}
