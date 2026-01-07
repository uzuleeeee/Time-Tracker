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

enum ScrollAction {
    case bottom
    case id(UUID)
}

@MainActor
class TimeTrackerViewModel: ObservableObject {
    // Scorer
    private let scorer: Scorer
    private var cancellables = Set<AnyCancellable>()
    
    @Published var inputText = ""
    @Published var scorerIsReady = false
    @Published var predictedCategories: [(Category, Float)] = []
    
    // Core Data
    let viewContext: NSManagedObjectContext
    
    // Initialize
    init(viewContext: NSManagedObjectContext) {
        // Core Data
        self.viewContext = viewContext
        
        // Scorer
        self.scorer = Scorer.shared
        
        if scorer.isReady {
            self.scorerIsReady = true
        }
        
        // Listen for ready notification
        NotificationCenter.default.publisher(for: .modelReady)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.scorerIsReady = true
            }
            .store(in: &cancellables)
        
        $inputText
            .dropFirst()
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.predict(text)
            }
            .store(in: &cancellables)
    }
    
    // UI state
    @Published var selectedCategory: Category?
    @Published var timelineItems: [TimelineItem] = []
    
    let scrollSubject = PassthroughSubject<ScrollAction, Never>()
    
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
            newActivity.name = inputText.isEmpty ? nil : inputText
            newActivity.endTime = nil // Explicitly nil implies running
            
            saveContext()
            
            startLiveActivity(newActivity)
            
            if let categoryName = category.name {
                scorer.updateDescriptions(label: categoryName, description: inputText.isEmpty ? inputText : "")
            }
            
            scrollSubject.send(.bottom)
            
            // Reset UI
            inputText = ""
            selectedCategory = nil
        }
    }

    func stopActivity(_ activity: Activity) {
        print("Stop activity: \(activity.uiModel.category.name)")
        
        withAnimation {
            activity.endTime = Date()
            
            if let startTime = activity.startTime, let endTime = activity.endTime {
                let duration = endTime.timeIntervalSince(startTime)
                
                if duration < 3 || startTime > endTime {
                    print("Deleting invalid activity (Duration: \(duration)")
                    viewContext.delete(activity)
                }
            } else {
                viewContext.delete(activity)
            }
            
            saveContext()
            
            stopLiveActivity()
        }
    }
    
    func configureActivity(name: String, category: Category, startTime: Date, endTime: Date, activities: FetchedResults<Activity>) {
        print("Configure activity: \(name) \(category.uiModel.name) \(startTime) \(endTime)")
        
        guard startTime < endTime else { return }
        guard endTime <= Date().addingTimeInterval(10) else { return }
        
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
            
            if let newActivityID = newActivity.id {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.scrollSubject.send(.id(newActivityID))
                }
            }
        }
    }
    
    func deleteItems(offsets: IndexSet, activities: FetchedResults<Activity>) {
        print("Delete item")
        
        withAnimation {
            offsets.map { activities[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    // Timeline Update

    func updateModels(from activities: [Activity]) {
        let sortedActivities = activities.sorted { $0.startTime ?? Date.distantPast < $1.startTime ?? Date.distantPast }
        
        var timelineItems: [TimelineItem] = []
        
        for index in sortedActivities.indices {
            let currentActivity = sortedActivities[index]
            var currentUIModel = currentActivity.uiModel
            
            print(currentUIModel.startTime, currentUIModel.endTime)
            
            if index > 0 {
                let prevActivity = sortedActivities[index - 1]
                if areConnected(prev: prevActivity, curr: currentActivity) {
                    currentUIModel.topConnected = true
                } else {
                    if let prevEnd = prevActivity.endTime, let currStart = currentActivity.startTime {
                        let gapDuration = currStart.timeIntervalSince(prevEnd)
                        if gapDuration > 60 {
                            timelineItems.append(.gap(GapUIModel(id: "\(prevActivity.uiModel.id)-\(currentActivity.uiModel.id)", duration: gapDuration, startTime: prevEnd, endTime: currStart)))
                            print(prevEnd, currStart)
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
    
    // Scorer
    
    func predict(_ text: String) {
        if text.isEmpty {
            self.predictedCategories = []
            self.selectedCategory = nil
            return
        }
        
        if !scorerIsReady {
            self.predictedCategories = []
            return
        }
        
        let currentText = text
        
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            let newResults = scorer.predict(text: currentText)
            
            await MainActor.run {
                self.setCategoriesFromResults(from: newResults)
            }
        }
    }
    
    func syncCategories(categories: [Category]) {
        let names = categories.compactMap { $0.name }
        
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            await self.scorer.setup() // Ensure model is loaded
            
            // Loop through every category in Core Data
            for name in names {
                self.scorer.createCategory(label: name)
            }
        }
    }
    
    func getPredictedCategories() -> [Category] {
        return predictedCategories.map { $0.0 }
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
    
    // Internal helpers - Scorer
    
    private func setCategoriesFromResults(from results: [(String, Float)]) {
        // Initialize array to store mapped categories
        var mappedCategories: [(Category, Float)] = []
        
        // Get names from results
        let names = results.map { $0.0 }
        
        // Fetch actual Category objects from Core Data
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name in %@", names)
        request.returnsObjectsAsFaults = false
        
        do {
            let matches = try viewContext.fetch(request)
            
            for (name, score) in results {
                if let match = matches.first(where: { $0.name == name }) {
                    mappedCategories.append((match, score))
                }
            }
            
            self.predictedCategories = mappedCategories
            
            if let topMatch = mappedCategories.first {
                self.selectedCategory = topMatch.0
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            self.predictedCategories = []
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
