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
    let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    // UI state
    @Published var selectedCategory: Category?
    @Published var activityName: String = ""
    @Published var timelineItems: [TimelineItem] = []
    
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
    
    func configureActivity(name: String, category: Category, startTime: Date, endTime: Date, activities: FetchedResults<Activity>) {
        print("Configure activity: \(name) \(category.uiModel.name) \(startTime) \(endTime)")
        
        withAnimation {
            let newActivity = Activity(context: viewContext)
            newActivity.id = UUID()
            newActivity.name = name.isEmpty ? nil : name
            newActivity.category = category
            newActivity.startTime = startTime
            newActivity.endTime = endTime
            
            for activity in activities {
                let currentStart = activity.startTime ?? Date.distantPast
                let currentEnd = activity.endTime ?? Date.distantPast
                
                // Check for overlap
                if (currentStart < endTime) && (currentEnd > startTime) {
                    if (currentStart >= startTime) && (currentEnd <= endTime) {
                        // Delete
                        viewContext.delete(activity)
                    } else if (currentStart < startTime) && (currentEnd > endTime) {
                        // Split
                        
                        // First half
                        let firstHalf = Activity(context: viewContext)
                        firstHalf.id = UUID()
                        firstHalf.name = activity.name
                        firstHalf.category = activity.category
                        firstHalf.startTime = activity.startTime
                        firstHalf.endTime = startTime
                        
                        // Second half
                        activity.startTime = endTime
                    } else if currentStart < startTime {
                        // Trim tail
                        activity.endTime = startTime
                    } else {
                        // Trim head
                        activity.startTime = endTime
                    }
                }
            }
            
            saveContext()
        }
    }
    
    func deleteItems(offsets: IndexSet, activities: FetchedResults<Activity>) {
        print("Delete item")
        
        withAnimation {
            offsets.map { activities[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }

    func updateModels(from activities: [Activity]) {
        let sortedActivities = activities.sorted { $0.startTime ?? Date.distantPast < $1.startTime ?? Date.distantPast }
        
        var timelineItems: [TimelineItem] = []
        
        for index in sortedActivities.indices {
            let currentActivity = sortedActivities[index]
            var currentUIModel = currentActivity.uiModel
            
            if index > 0 {
                let prevActivity = sortedActivities[index - 1]
                if areConnected(prev: prevActivity, curr: currentActivity) {
                    currentUIModel.topConnected = true
                } else {
                    if let prevEnd = prevActivity.endTime, let currStart = currentActivity.startTime {
                        let gapDuration = currStart.timeIntervalSince(prevEnd)
                        if gapDuration > 60 {
                            timelineItems.append(.gap(GapUIModel(id: "\(prevActivity.uiModel.id)-\(currentActivity.uiModel.id)", duration: gapDuration)))
                        }
                    }
                }
            }
            
            if index < sortedActivities.count - 1, areConnected(prev: currentActivity, curr: sortedActivities[index + 1]) {
                currentUIModel.bottomConnected = true
            }
            
            timelineItems.append(.activity(currentUIModel))
        }
        
        self.timelineItems = timelineItems
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
    
    private func areConnected(prev: Activity, curr: Activity) -> Bool {
        guard let prevEnd = prev.endTime, let currStart = curr.startTime else { return false }
        return abs(currStart.timeIntervalSince(prevEnd)) < 60
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
            print("Live Activity started: \(activity.content.state.categoryName)")
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
