//
//  Persistence.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/11/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let today = Date()
        let calendar = Calendar.current
        
        func createCategory(_ name: String, _ iconName: String, _ colorHex: String) -> Category {
            let category = Category(context: viewContext)
            category.id = UUID()
            category.name = name
            category.iconName = iconName
            category.colorHex = colorHex
            return category
        }
        
        func createActivity(_ category: Category, _ h: Int, _ m: Int, _ duration: Int?, _ name: String?) {
            let activity = Activity(context: viewContext)
            activity.id = UUID()
            activity.category = category
            
            if let name = name {
                activity.name = name
            }
                
            guard let start = calendar.date(bySettingHour: h, minute: m, second: 0, of: today) else { return }
            activity.startTime = start
            
            if let duration = duration {
                let end = calendar.date(byAdding: .minute, value: duration, to: start)
                activity.endTime = end
            }
        }
        
        // Categories
        let sleep           = createCategory("Sleep", "🛌", "5856D6")       // Purple
        let eat             = createCategory("Eat", "🍽️", "FF9F0A")         // Orange
        let work            = createCategory("Work", "💼", "007AFF")        // Blue
        let study           = createCategory("Study", "📚", "FFD60A")       // Yellow
        let commute         = createCategory("Commute", "🚗", "30B0C7")     // Teal
        let entertainment   = createCategory("Entertainment", "🎮", "FF2D55") // Pink
        let chores          = createCategory("Chores", "🏠", "8E8E93")      // Gray
        let exercise        = createCategory("Exercise", "🏃‍♂️", "34C759")    // Green
        let social          = createCategory("Social", "👥", "AF52DE")      // Purple
        let breakCat        = createCategory("Break", "☕️", "FFA500")      // Orange
        let selfCare        = createCategory("Self Care", "🧘‍♂️", "5AC8FA")   // Light Blue
        let hobby           = createCategory("Hobby", "🎨", "FF3B30")       // Red

        // MARK: - Sample Timeline
        // 12:00 AM - 7:00 AM: Sleep
        createActivity(sleep, 0, 0, 420, "Sleep")
        
        // 7:00 AM - 7:30 AM: Morning Routine -> Self Care
        createActivity(selfCare, 7, 0, 30, "Morning Routine")
        
        // 7:30 AM - 8:15 AM: Gym -> Exercise
        createActivity(exercise, 7, 30, 45, "Gym")
        
        // 8:15 AM - 8:45 AM: Breakfast -> Eat
        createActivity(eat, 8, 15, 30, "Breakfast")
        
        // 8:45 AM - 9:15 AM: Commute
        createActivity(commute, 8, 45, 30, "Drive to work")

        // 9:15 AM - 12:00 PM: Work
        createActivity(work, 9, 15, 165, "Work")
        
        // 12:00 PM - 12:45 PM: Lunch -> Eat
        createActivity(eat, 12, 0, 45, "Lunch")
        
        // 12:45 PM - 1:00 PM: Social
//        createActivity(social, 12, 45, 15, "Chat with coworkers")
        
        // 1:00 PM - 3:00 PM: Work
        createActivity(work, 13, 0, 120, "Meetings")
        
        // 3:00 PM - 3:15 PM: Break
        createActivity(breakCat, 15, 0, 15, "Coffee break")

        // 3:15 PM - 5:00 PM: Work
        createActivity(work, 15, 15, 105, "Wrap up")

        // 5:00 PM - 5:45 PM: Commute
        createActivity(commute, 17, 0, 45, "Drive home")
        
        // 5:45 PM - 6:30 PM: Chores
        createActivity(chores, 17, 45, nil, "Groceries")

        // 6:30 PM - 7:30 PM: Dinner -> Eat
        createActivity(eat, 18, 30, 60, "Dinner")
        
        // 7:30 PM - 8:30 PM: Hobby
        createActivity(hobby, 19, 30, 60, "Guitar")
        
        // 8:30 PM - 9:30 PM: Entertainment
        createActivity(entertainment, 20, 30, 60, "Gaming")
        
        // 9:30 PM - 10:30 PM: Study
        createActivity(study, 21, 30, 60, "Reading")
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Time_Tracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    func seedDefaultCategoriesIfNeeded() {
        let viewContext = container.viewContext
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let count = (try? viewContext.count(for: fetchRequest)) ?? 0
        guard count == 0 else {
            return
        }
        
        let defaults: [(String, String, String)] = [
            ("Sleep", "🛌", "5856D6"),
            ("Eat", "🍽️", "FF9F0A"),
            ("Work", "💼", "007AFF"),
            ("Study", "📚", "FFD60A"),
            ("Commute", "🚗", "30B0C7"),
            ("Entertainment", "🎮", "FF2D55"),
            ("Chores", "🧹", "8E8E93"),
            ("Exercise", "🏃‍♂️", "34C759"),
            ("Social", "👥", "AF52DE"),
            ("Break", "☕️", "FFA500"),
            ("Self Care", "🧘‍♂️", "5AC8FA"),
            ("Hobby", "🎨", "FF3B30")
        ]
        
        for (name, icon, hex) in defaults {
            let category = Category(context: viewContext)
            category.id = UUID()
            category.name = name
            category.iconName = icon
            category.colorHex = hex
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension Activity {
    static var examples: [Activity] {
        let context = PersistenceController.preview.container.viewContext
        let request = Activity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Activity.startTime, ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
}

extension Category {
    static var examples: [Category] {
        let context = PersistenceController.preview.container.viewContext
        let request = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
}
