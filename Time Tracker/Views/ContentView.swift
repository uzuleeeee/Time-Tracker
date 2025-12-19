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
    @StateObject private var viewModel = TimeTrackerViewModel()
    
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
                DailyCalendarView(activities: Array(activities), selectedDate: Date())
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
                    .buttonStyle(LargeButton())
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
            CategorySelectionView(
                categories: Array(categories),
                currentCategory: viewModel.selectedCategory,
                onSelect: { category in
                    viewModel.selectCategory(category, currentActivity: currentActivity)
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(.systemBackground))
        }
    }
}

struct LargeButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.accentColor)
            )
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(
                .interactiveSpring(response: 0.25, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
