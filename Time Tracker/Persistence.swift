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
        let sleep       = createCategory("Sleep", "🛌", "5856D6")
        let morning     = createCategory("Morning Routine", "🌅", "FFD60A")
        let work        = createCategory("Work", "💼", "007AFF")
        let coding      = createCategory("Coding", "💻", "AF52DE")
        let meeting     = createCategory("Meeting", "👥", "5AC8FA")
        let breakCat    = createCategory("Break", "☕️", "FFA500")
        let lunch       = createCategory("Lunch / Dinner", "🍽️", "FF9F0A")
        let errands     = createCategory("Errands", "🛒", "FF3B30")
        let fitness     = createCategory("Fitness", "🏃‍♂️", "34C759")
        let study       = createCategory("Study", "📚", "FFD60A")
        let leisure     = createCategory("Leisure", "🎮", "FF2D55")
        let meditation  = createCategory("Meditation", "🧘‍♂️", "5AC8FA")

        // Activities
        createActivity(sleep, 0, 0, 420, "Zzz")
        createActivity(morning, 7, 0, 30, "Coffee")
        createActivity(fitness, 7, 30, 45, "Gym")
        createActivity(breakCat, 8, 15, 15, "Scroll")

        createActivity(work, 8, 30, 90, "Emails")
        createActivity(meeting, 10, 0, 30, nil)
        createActivity(coding, 10, 30, 5, "Fixing bugs")

        createActivity(lunch, 12, 0, 45, "Food")
        createActivity(errands, 12, 45, 30, "Groceries")
        createActivity(breakCat, 13, 15, 15, "Coffee refill")

        createActivity(work, 13, 30, 60, "Admin")
        createActivity(coding, 14, 30, 90, "New feature")
        createActivity(meeting, 16, 0, 30, nil)
        createActivity(work, 16, 30, 60, "Wrap up")

        createActivity(fitness, 18, 0, 45, "Run")
        createActivity(lunch, 19, 0, 45, "Dinner")
        createActivity(leisure, 20, 0, 90, "Gaming")
        createActivity(study, 21, 30, nil, "Reading")
        
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
            ("Work", "💼", "007AFF"),
            ("Fitness", "🏃‍♂️", "34C759"),
            ("Coding", "💻", "AF52DE"),
            ("Break", "☕️", "FFA500"),
            ("Study", "📚", "FFD60A"),
            ("Meditation", "🧘‍♂️", "5AC8FA"),
            ("Errands", "🛒", "FF3B30")
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
