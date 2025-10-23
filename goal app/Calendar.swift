//
//  Calendar.swift
//  goal app
//
//  Created by Kunwar Singh on 12/29/24.
//

import SwiftUI

import SwiftUI

struct Calen: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedSegment = 0
    private let segments = ["Today", "Overall"]
    @Binding var selectedDate: Date
    @StateObject private var viewModel = StreakViewModel()
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var SModel: StreakViewModel
    @State private var progress: Double = 0.0
    @State private var displayedMonth: Date = Date()
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    @State var noti: Bool
    @State var isRectangleVisible: Bool
    
    var body: some View {
        ZStack {
            GeometryReader { g in
                Color.gray.opacity(0.1) // Set the background color to light gray
                    .edgesIgnoringSafeArea(.bottom) // Extend the background to the bottom
                    .frame(maxHeight: g.size.height * 0.9855) // Adjust the height of the background
                VStack(spacing: 10) {
                    Spacer()
                        .frame(height: g.size.height * 0.017)
                    
                    // Calendar
                    VStack(spacing: g.size.height * 0.02) {
                        // Month and Year with navigation arrows
                        HStack {
                            Button(action: {
                                displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.black)
                            }
                            Spacer()
                            Text(dateFormatter.string(from: displayedMonth))
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.black)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Days of the week
                        let days = ["S", "M", "T", "W", "T", "F", "S"]
                        HStack {
                            ForEach(days, id: \.self) { day in
                                Text(day)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // Dates in the month
                        let gridItems = Array(repeating: GridItem(.flexible()), count: 7)
                        LazyVGrid(columns: gridItems, spacing: g.size.height * 0.0215) {
                            ForEach(generateDays(for: displayedMonth), id: \.0) { (date, isCurrentMonth) in
                                Text(String(calendar.component(.day, from: date)))
                                    .font(.body)
                                    .frame(width: g.size.width * 0.15, height: g.size.height * 0.06) // Fixed size for uniformity
                                    .background(isSelected(date: date) ? Color.black.opacity(0.1) : Color.clear)
                                    .foregroundColor(isCurrentMonth ? (isWeekend(date: date) ? .red : .black) : .gray)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        if isCurrentMonth {
                                            selectedDate = date
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .onAppear {
                        displayedMonth = calendar.startOfDay(for: selectedDate)
                    }
                    .padding(.top, g.size.height * 0.05)
                    .background(
                        Color.white
                            .cornerRadius(10)
                            .shadow(radius: 0)
                            .padding(.bottom, -14)
                    )
                    
                    HStack {
                        Today(selectedDate: $selectedDate)
                            .padding(.top, g.size.height * 0.06)
                        
                        records()
                            .padding(.top, g.size.width * 0.02)
                            .padding(.trailing, g.size.width * 0.07)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .onChange(of: selectedDate) { newValue in
                    print("Selected date updated to: \(newValue)")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: Settings()) {
                        Image(systemName: "gear.circle.fill")
                            .foregroundColor(.black)
                            .environmentObject(listViewModel)
                    }
                }
            }
            .sheet(isPresented: $isRectangleVisible) {
                VStack {
                    Text("Settings")
                        .bold()
                        .padding(.top, 20)
                        .font(.system(size: 20))
                    Settings()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    Spacer()
                }
            }
        }
        .navigationBarTitle("Calendar", displayMode: .inline)
        .preferredColorScheme(.light)
        .environmentObject(SModel)
        .environmentObject(listViewModel)
    }
    
    private func generateDays(for date: Date) -> [(Date, Bool)] {
        var days: [(Date, Bool)] = []
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return days }
        
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDay = calendar.date(from: components) else { return days }
        let weekday = calendar.component(.weekday, from: firstDay)
        
        // Add days from the previous month
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDay),
           let prevMonthRange = calendar.range(of: .day, in: .month, for: previousMonth) {
            let daysToAdd = weekday - 1
            let prevMonthStartDay = prevMonthRange.count - daysToAdd
            for day in prevMonthStartDay..<prevMonthRange.count {
                if let prevDay = calendar.date(byAdding: .day, value: day - prevMonthRange.count, to: previousMonth) {
                    days.append((prevDay, false))
                }
            }
        }
        
        // Add days in the current month
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append((dayDate, true))
            }
        }
        
        // Add days from the next month (only if remainingSlots is > 0)
        let remainingSlots = (7 - (days.count % 7)) % 7
        if remainingSlots > 0, let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDay) {
            for day in 1...remainingSlots {
                if let nextDay = calendar.date(byAdding: .day, value: day - 1, to: nextMonth) {
                    days.append((nextDay, false))
                }
            }
        }
        
        return days
    }



    
    private func isWeekend(date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }
    
    private func isSelected(date: Date) -> Bool {
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
}



import SwiftUI

//struct CustomCalendarView: View {
//    @Binding var selectedDate: Date
//    @State private var displayedMonth: Date = Date()
//    private let calendar = Calendar.current
//    private let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM yyyy"
//        return formatter
//    }()
//
//    var body: some View {
//        
//        VStack(spacing: 16) {
//            // Month and Year with navigation arrows
//            HStack {
//                Button(action: {
//                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
//                }) {
//                    Image(systemName: "chevron.left")
//                        .foregroundStyle(.black)
//                }
//                Spacer()
//                Text(dateFormatter.string(from: displayedMonth))
//                    .font(.headline)
//                Spacer()
//                Button(action: {
//                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
//                }) {
//                    Image(systemName: "chevron.right")
//                        .foregroundStyle(.black)
//                }
//            }
//            .padding(.horizontal)
//
//            // Days of the week
//            let days = ["S", "M", "T", "W", "T", "F", "S"]
//            HStack {
//                ForEach(days, id: \.self) { day in
//                    Text(day)
//                        .font(.subheadline)
//                        .frame(maxWidth: .infinity)
//                }
//            }
//
//            // Dates in the month
//            let gridItems = Array(repeating: GridItem(.flexible()), count: 7)
//            LazyVGrid(columns: gridItems, spacing: 10) {
//                ForEach(generateDays(for: displayedMonth), id: \.self) { date in
//                    if let date = date {
//                        Text(String(calendar.component(.day, from: date)))
//                            .font(.body)
//                            .frame(width: 40, height: 40) // Fixed size for uniformity
//                            .background(isSelected(date: date) ? Color.black.opacity(0.1) : Color.clear)
//                            .foregroundColor(isWeekend(date: date) ? Color.red : Color.black)
//                            .clipShape(Circle())
//                            .onTapGesture {
//                                selectedDate = date
//                            }
//                    } else {
//                        Spacer()
//                            .frame(width: 40, height: 40)
//                    }
//                }
//            }
//        }
//        .padding(.horizontal)
//        .onAppear {
//            // Ensure displayedMonth matches selectedDate on initial load
//            displayedMonth = calendar.startOfDay(for: selectedDate)
//        }
//    }

//    private func generateDays(for date: Date) -> [Date?] {
//        var days: [Date?] = []
//        guard let range = calendar.range(of: .day, in: .month, for: date) else { return days }
//        
//        let components = calendar.dateComponents([.year, .month], from: date)
//        guard let firstDay = calendar.date(from: components) else { return days }
//        let weekday = calendar.component(.weekday, from: firstDay)
//
//        // Add empty days for the start of the grid
//        for _ in 1..<weekday {
//            days.append(nil)
//        }
//
//        // Add days in the current month
//        for day in range {
//            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
//                days.append(dayDate)
//            }
//        }
//
//        // Add empty days to complete the last week of the grid
//        let totalDaysInGrid = (days.count + 6) / 7 * 7
//        while days.count < totalDaysInGrid {
//            days.append(nil)
//        }
//
//        return days
//    }
//
//
//    private func isWeekend(date: Date) -> Bool {
//        let weekday = calendar.component(.weekday, from: date)
//        return weekday == 1 || weekday == 7
//    }
//
//    private func isSelected(date: Date) -> Bool {
//        return calendar.isDate(date, inSameDayAs: selectedDate)
//    }




struct records: View {
    @StateObject private var viewModel = StreakViewModel()
    var body: some View {
        GeometryReader { g in
            VStack {
                List {
                    HStack {
                        Image("Streak")
                            .resizable()
                            .frame(width: g.size.width * 0.19, height: g.size.width * 0.19)
                        Text("Streak")
                            .bold()
                            .font(.system(size: g.size.width * 0.06))
                        Spacer()
                        Text("\(viewModel.streakCount) days")
                            .bold()
                            .font(.system(size: g.size.width * 0.06))
                            .foregroundStyle(.orange)
                    }
                    HStack {
                        Image("medal")
                            .resizable()
                            .frame(width: g.size.width * 0.19, height: g.size.width * 0.19)
//                            .padding(.horizontal, 0)
                        Text("Tasks Completed")
                            .bold()
                            .font(.system(size: g.size.width * 0.06))
                            .padding(.trailing, 10)
                        Spacer()
                        Text("\(ListViewModel().items.filter { $0.completion }.count) tasks")
                            .bold()
                            .font(.system(size: g.size.width * 0.06))
//                            .padding(.trailing, 10)
                            .foregroundStyle(.green)
                    }
//                    .frame(width: g.size.width * 1.2, height: g.size.height * 0.143)
                    HStack {
                        Image("compl")
                            .resizable()
                            .frame(width: g.size.width * 0.19, height: g.size.width * 0.19)
                        Text("Daily Average")
                            .bold()
                            .font(.system(size: g.size.width * 0.06))
                            .padding(.trailing, 10)
                        Spacer()
                        Text("\(ListViewModel().dailyAverage(), specifier: "%.1f") tasks")
                            .bold()
                            .font(.system(size: g.size.width * 0.06))
//                            .padding(.trailing, 10)
                            .foregroundStyle(.blue)
                    }
//                    .frame(width: g.size.width * 1.2, height: g.size.height * 0.143)
                    
                    
                    
                    
                }
                .frame(width: g.size.width * 1.37) // Set the frame
                .padding(.trailing, g.size.width * 0.09)

            }
            .frame(width: g.size.width * 1.2)
        }
        
    }
}



struct Today: View {
    @Binding var selectedDate: Date  // Change to @Binding
    @EnvironmentObject var listViewModel: ListViewModel
    @State private var progress: Double = 0.0

    var body: some View {
        VStack {
            // Circular Progress View
            HStack {
                Spacer()
                GeometryReader { g in
                    CircularProgressView(progress: progress)
                        .frame(width: g.size.width * 0.82, height: g.size.width * 1.2)
//                        .padding(.top, g.size.height * 0.07)
                        .padding(.leading, g.size.width * -0.02)
                        .onAppear {
                            updateProgress()  // Update when the view appears
                        }
                        .onChange(of: selectedDate) { _ in  // Listen for selectedDate changes
                            updateProgress()  // Update progress whenever the date changes
                        }
                        .onChange(of: listViewModel.items) { _ in
                            updateProgress()
                        }
                }
                Spacer()
            }
        }
//        .padding(.bottom)
    }

    private func updateProgress() {
        progress = listViewModel.progressForSelectedDate(selectedDate: selectedDate)
    }
}


struct CircularProgressView: View {
    var progress: Double

    var body: some View {
        GeometryReader { g in
            ZStack {
                Circle()
                    .stroke(lineWidth: g.size.width * 0.09)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: g.size.height * 0.1, lineCap: .round))
                    .foregroundColor(.black)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear, value: progress)
                
                
                VStack {
                    Text("\(Int(progress * 100))%")
                        .font(.largeTitle)
                        .bold()
                    Text("of Tasks Completed")
                        .font(.system(size: g.size.width * 0.08))
                }
                
            }
        }
    }
}








class StreakViewModel: ObservableObject {
    @Published var streakCount: Int = 0
    
    init() {
        calculateStreak()
    }
    
    func calculateStreak() {
        let userDefaults = UserDefaults.standard
        let calendar = Calendar.current
        
        // Load the saved streak count or default to 0
        streakCount = userDefaults.integer(forKey: "StreakCount")
        
        let today = calendar.startOfDay(for: Date())
        if let lastAccessedDate = userDefaults.object(forKey: "LastAccessedDate") as? Date {
            let daysBetween = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastAccessedDate), to: today).day ?? 0
            
            if daysBetween == 1 {
                // Increment streak if accessed on the next consecutive day
                streakCount += 1
            } else if daysBetween > 1 {
                // Reset streak if days are not consecutive
                streakCount = 1
            }
        } else {
            // First-time access
            streakCount = 1
        }
        
        // Update UserDefaults
        userDefaults.set(today, forKey: "LastAccessedDate")
        userDefaults.set(streakCount, forKey: "StreakCount")
    }
}





