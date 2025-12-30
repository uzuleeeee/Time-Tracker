//
//  Time_TrackerApp.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/11/25.
//

import SwiftUI
import CoreData

@main
struct Time_TrackerApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        persistenceController.seedDefaultCategoriesIfNeeded()
        
        Task {
            await Scorer.shared.setup()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
