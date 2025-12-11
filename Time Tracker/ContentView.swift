//
//  ContentView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/11/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch all logs sorted by start time
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.startTime, ascending: false)],
        animation: .default)
    private var activities: FetchedResults<Activity>
    
    // Fetch categories to populate the picker
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>

    // UI State
    @State private var selectedCategory: Category?
    @State private var activityName: String = ""
    
    // Computed property to find the currently running timer
    var currentActivity: Activity? {
        activities.first(where: { $0.endTime == nil })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Current Activity
                VStack {
                    if let active = currentActivity {
                        // Stop Timer View
                        VStack(spacing: 15) {
                            Text("Current Activity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: active.category?.wrappedIcon ?? "")
                                Text(active.category?.wrappedName ?? "")
                            }
                            .font(.title2)
                            .bold()
                            .foregroundColor(active.category?.color)
                            
                            if let name = active.name, !name.isEmpty {
                                Text(name).font(.headline)
                            }
                            
                            Text("Started at: " + (active.startTime?.formatted(date: .omitted, time: .shortened) ?? ""))
                                .font(.monospacedDigit(.body)())
                            
                            Button(action: stopActivity) {
                                Text("Stop Timer")
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        
                    } else {
                        // Start Timer View
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Start New Activity").font(.headline)
                            
                            // Category Picker
                            if categories.isEmpty {
                                Button("Create Default Categories (Dev Only)") {
                                    seedCategories()
                                }
                            } else {
                                Picker("Category", selection: $selectedCategory) {
                                    Text("Select Category").tag(nil as Category?)
                                    ForEach(categories) { category in
                                        HStack {
                                            Image(systemName: category.wrappedIcon)
                                            Text(category.wrappedName)
                                        }
                                        .tag(category as Category?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .background(Color(.tertiarySystemFill))
                                .cornerRadius(8)
                            }
                            
                            // Optional Name
                            TextField("Description (Optional)", text: $activityName)
                                .textFieldStyle(.roundedBorder)
                            
                            Button(action: startActivity) {
                                Text("Start Timer")
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedCategory == nil ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(selectedCategory == nil)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Log List
                List {
                    ForEach(activities) { activity in
                        HStack {
                            Image(systemName: activity.category?.wrappedIcon ?? "circle")
                                .foregroundColor(activity.category?.color)
                            
                            VStack(alignment: .leading) {
                                Text(activity.category?.wrappedName ?? "No Category")
                                    .font(.headline)
                                if let name = activity.name, !name.isEmpty {
                                    Text(name).font(.caption).foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(activity.startTime ?? Date(), style: .time)
                                if let end = activity.endTime {
                                    Text(end, style: .time)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Running...")
                                        .foregroundColor(.green)
                                        .bold()
                                }
                            }
                            .font(.caption)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Time Tracker")
        }
    }
    
    // Logic
    private func startActivity() {
        guard let category = selectedCategory else { return }
        
        withAnimation {
            let newActivity = Activity(context: viewContext)
            newActivity.id = UUID()
            newActivity.startTime = Date()
            newActivity.category = category
            newActivity.name = activityName.isEmpty ? nil : activityName
            newActivity.endTime = nil // Explicitly nil implies running
            
            saveContext()
            
            // Reset UI
            activityName = ""
        }
    }

    private func stopActivity() {
        guard let active = currentActivity else { return }
        
        withAnimation {
            active.endTime = Date()
            saveContext()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { activities[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // Helper to add data if app is empty
    private func seedCategories() {
        let names = ["Coding", "Reading", "Exercise", "Gaming"]
        let icons = ["laptopcomputer", "book.fill", "figure.run", "gamecontroller.fill"]
        let colors = ["007AFF", "AF52DE", "34C759", "FF3B30"]
        
        for i in 0..<names.count {
            let cat = Category(context: viewContext)
            cat.id = UUID()
            cat.name = names[i]
            cat.iconName = icons[i]
            cat.colorHex = colors[i]
        }
        saveContext()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
