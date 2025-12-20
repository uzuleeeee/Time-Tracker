//
//  DateSelectionView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 12/20/25.
//

import SwiftUI

struct DateSelectionView: View {
    @Binding var selectedDate: Date
    @State private var showCalendar = false
    
    private var dateString: String {
        let calendar = Calendar.current
        
        if selectedDateIsToday {
            return "Today"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            
            return formatter.string(from: selectedDate)
        }
    }
    
    private var selectedDateIsToday: Bool {
        return Calendar.current.isDateInToday(selectedDate)
    }
    
    var body: some View {
        HStack {
            Button {
                shiftDate(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .padding(8)
                    .contentShape(Rectangle())
            }
            
            Spacer()
            
            Button {
                showCalendar.toggle()
            } label: {
                HStack {
                    Image(systemName: "calendar")
                    Text(dateString)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
            }
            .popover(isPresented: $showCalendar) {
                VStack {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                }
                .frame(width: 320)
                .padding()
                .presentationCompactAdaptation(.popover)
            }
            
            Spacer()
            
            Button {
                shiftDate(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .disabled(selectedDateIsToday)
            .opacity(selectedDateIsToday ? 0.3 : 1.0)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func shiftDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            withAnimation {
                selectedDate = newDate
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var currentDate = Date()
        
        var body: some View {
            DateSelectionView(selectedDate: $currentDate)
        }
    }

    return PreviewWrapper()
}
