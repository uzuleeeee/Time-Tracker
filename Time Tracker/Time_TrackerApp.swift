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
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
