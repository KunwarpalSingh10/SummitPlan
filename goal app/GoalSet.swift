//
//  GoalSet.swift
//  goal app
//
//  Created by Kunwar Singh on 8/6/24.
//

import SwiftUI
import Foundation
import UserNotifications





struct GoalSet: View {
    
    @Binding var selectedDate: Date
    @Binding var isRectangleVisible: Bool
    @Binding var isTrashcanVisible: Bool
    @State private var currentSelectedDate: Date?
    
    @State private var selectedPageIndex: Int
    @State private var selectedTime: Date

    @State private var noti: Bool
    @State private var habit: Bool
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    @EnvironmentObject var SModel: StreakViewModel

    init(selectedDate: Binding<Date>, selectedTime: Date? = nil, noti: Bool? = nil, habit: Bool, isRectangleVisible: Binding<Bool>, isTrashcanVisible: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isRectangleVisible = isRectangleVisible
        self._isTrashcanVisible = isTrashcanVisible
  
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -365, to: today) ?? today
        let pageIndex = (calendar.dateComponents([.day], from: startDate, to: today).day ?? 0) / 7
        
        _selectedPageIndex = State(initialValue: pageIndex)
        _selectedTime = State(initialValue: selectedTime ?? today)

        _noti = State(initialValue: noti ?? false)
        _habit = State(initialValue: habit ?? false)
        requestNotificationPermission()

        
    }
    
    
    var body: some View {
        
        GeometryReader { g in
            
            ZStack {
                
                VStack(spacing: 0) {
                    
                    TopDateBar(selectedPageIndex: $selectedPageIndex, selectedDate: $selectedDate)
                        .frame(height: g.size.height * 0.26)
                        .background(.white)
                    
                    //               CalendarTaskBar(selectedDate: selectedDate, selectedTime: selectedTime, priority: priority, noti: noti)
                    //                    .cornerRadius(20)
                    
                    ZStack {
                        Color.gray.opacity(0.1) // Set the background color to light gray
                            .edgesIgnoringSafeArea(.bottom) // Only ignore bottom safe area
                        ClassictaskBar(selectedDate: selectedDate, selectedTime: selectedTime, noti: noti)
                    }
                    
                    //test()
                    Spacer()
                    
                }
                .sheet(isPresented: $isRectangleVisible) {
                    Text("Settings")
                        .bold()
                        .padding(.top,20)
                        .font(.system(size: 20))
                    Settings()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    
                }
                .sheet(isPresented: $isTrashcanVisible) {
                    Text("Habits")
                        .bold()
                        .padding(.vertical,20)
                        .font(.system(size: 20))
                    let uniqueByName = Array(
                        Dictionary(grouping: listViewModel.items.filter { $0.habit }, by: { $0.name })
                            .compactMap { $0.value.first }
                    )
                    
                    let uniqueByCategory = Array(
                        Dictionary(grouping: listViewModel.items.filter { $0.habit }, by: { $0.category })
                            .compactMap { $0.value.first }
                    )
                    
                    // Combine the two lists and remove duplicates
                    let combinedUniqueItems = Array(
                        Dictionary(grouping: uniqueByName + uniqueByCategory, by: { $0.id })
                            .compactMap { $0.value.first }
                    )
                    
                    //                    Color.gray.opacity(0.1) // Set the background color to light gray
                    //                        .edgesIgnoringSafeArea(.bottom) // Only ignore bottom safe area
                    if (listViewModel.items.filter { $0.habit }.count) == 0 {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("No Habits Created")
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                        }
                        .bold()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                    } else {
                        ScrollView {
                            VStack {
                                ForEach(combinedUniqueItems, id: \.id) { item in
                                    taskView(for: item, screenWidth: 400)
                                }
                                .padding(.bottom, 10)
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                        }
                        
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                }
                
                .navigationBarBackButtonHidden(true)
                .edgesIgnoringSafeArea(.top)
                .navigationBarBackButtonHidden(true)
                .environmentObject(listViewModel)
                .environmentObject(CustomListViewModel)
                .environmentObject(SModel)
                .onChange(of: selectedDate) { newDate in
                    // Update the selectedPageIndex based on the new selectedDate
                    selectedPageIndex = pageIndex(for: newDate)
                }
                .preferredColorScheme(.light)
                .onAppear {
                    print("Requesting notification permission")
                    requestNotificationPermission()
                }
            }
            .navigationBarBackButtonHidden(true)
            .environmentObject(CustomListViewModel)
            
            
        }
        
    }
    
    private func formattedMonthYear(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func pageIndex(for date: Date) -> Int {
        let calendar = Calendar.current
        let daysFromStartDate = calendar.dateComponents([.day], from: Calendar.current.date(byAdding: .day, value: -366, to: Date()) ?? Date(), to: date).day ?? 0
        return daysFromStartDate / 7
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func taskView(for item: ItemModel, screenWidth: CGFloat) -> some View {
        let isBackgroundDark = item.selectedColor.cgColor?.components?.reduce(0, +) ?? 0 < 2
        
        return RoundedRectangle(cornerRadius: 10)
            .fill(item.completion ? item.selectedColor.opacity(0.2) : item.selectedColor.opacity(1))
            .shadow(color: item.selectedColor.opacity(1), radius: 5)
            .overlay(
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(String(item.category.prefix(1)))
                                .font(.system(size: screenWidth * 0.12))
                            
                            
                            VStack(alignment: .leading) {
                                Spacer()
                                
                                Text(item.name.isEmpty ? String(item.category.dropFirst()) : item.name)
                                    .font(.system(size: screenWidth * 0.039))
                                    .foregroundColor(isBackgroundDark ? .white : .black)
                                
                                if !item.description.isEmpty {
                                    Text("  " + item.description)
                                        .foregroundColor(isBackgroundDark ? .white : .black)
                                        .font(.system(size: screenWidth * 0.03))
                                }
                                
//                                Text("  Time: \(formattedTime(from: item.selectedTime ?? Date()))")
//                                    .foregroundColor(isBackgroundDark ? .white : .black)
//                                    .font(.system(size: screenWidth * 0.03))
                                
                                Spacer()
                            }

                            Spacer()
                            ZStack {
                                Button(action: {
                                    // Filter the items to be removed
                                    let itemsToRemove = listViewModel.items.filter {
                                        ($0.name == item.name && $0.category == item.category) && $0.habit
                                    }

                                    // Update `noti` to `false` and cancel notifications for each task
                                    for task in itemsToRemove {
                                        if let index = listViewModel.items.firstIndex(where: { $0.id == task.id }) {
                                            listViewModel.items[index].noti = false
                                            listViewModel.cancelNotification(for: task)
                                        }
                                    }

                                    // Remove the filtered items from the list
                                    listViewModel.items.removeAll {
                                        ($0.name == item.name && $0.category == item.category) && $0.habit
                                    }
                                }, label: {
                                    Rectangle()
                                        .fill(Color.red) // Sets the background color of the Rectangle to red
                                        .cornerRadius(10)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "trash")
                                                .foregroundStyle(.white) // Makes the trash icon white
                                        )
                                })




                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            )
            .frame(width: screenWidth * 0.8, height: 60) // Adjust width and height as needed

    }
    
    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    

}





struct TopDateBar: View {
    let calendar = Calendar.current
    
    let startDate: Date
    let endDate: Date
    
    @Binding var selectedPageIndex: Int
    @Binding var selectedDate: Date
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    
    init(selectedPageIndex: Binding<Int>, selectedDate: Binding<Date>) {
        let today = Calendar.current.startOfDay(for: Date())
        self.startDate = Calendar.current.date(byAdding: .day, value: -365, to: today) ?? today
        self.endDate = Calendar.current.date(byAdding: .day, value: 365, to: today) ?? today
        self._selectedPageIndex = selectedPageIndex
        self._selectedDate = selectedDate
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selectedPageIndex) {
                ForEach(startDateIndex..<endDateIndex) { pageIndex in
                    HStack {
                        ForEach(0..<7) { circleIndex in
                            Button(action: {
                                let date = date(for: pageIndex, circleIndex: circleIndex)
                                selectedDate = date
                            }) {
                                VStack {
                                    ZStack {
                                        CircularProgressBar(progress: taskCompletionRate(for: date(for: pageIndex, circleIndex: circleIndex)))
                                            .frame(width: circleSize(for: geometry.size.width), height: circleSize(for: geometry.size.width))
                                        
                                        Circle()
                                            .frame(width: circleSize(for: geometry.size.width) - 2, height: circleSize(for: geometry.size.width) - 2)
                                            .padding(2)
                                            .foregroundColor(self.isDateSelected(date: date(for: pageIndex, circleIndex: circleIndex)) ? .blue : .black)
                                        
                                        Text(dateNumber(for: pageIndex, circleIndex: circleIndex))
                                            .foregroundColor(.white)
                                            .bold()
                                    }
                                    Text(dayAbbreviation(for: pageIndex, circleIndex: circleIndex))
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .tag(pageIndex)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .onAppear {
                selectedPageIndex = pageIndex(for: selectedDate)
            }
        }
        .environmentObject(CustomListViewModel)
    }
    
    private func circleSize(for width: CGFloat) -> CGFloat {
        return width / 7 * 0.83 // Adjust this multiplier for desired circle size
    }
    
    private func taskCompletionRate(for date: Date) -> Double {
        let tasksForDate = listViewModel.items.filter {
            Calendar.current.isDate($0.selectedDate, inSameDayAs: date)
        }
        let completedTasks = tasksForDate.filter { $0.completion }.count
        let totalTasks = tasksForDate.count
        return totalTasks == 0 ? 0 : Double(completedTasks) / Double(totalTasks)
    }
    
    private func date(for pageIndex: Int, circleIndex: Int) -> Date {
        let daysToAdd = (pageIndex * 7) + circleIndex
        return calendar.date(byAdding: .day, value: daysToAdd, to: startDate) ?? Date()
    }
    
    private func isDateSelected(date: Date) -> Bool {
        return Calendar.current.isDate(selectedDate, inSameDayAs: date)
    }

    private func dateNumber(for pageIndex: Int, circleIndex: Int) -> String {
        let dayNumber = calendar.component(.day, from: date(for: pageIndex, circleIndex: circleIndex))
        return "\(dayNumber)"
    }
    
    private func dayAbbreviation(for pageIndex: Int, circleIndex: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let weekdayName = dateFormatter.string(from: date(for: pageIndex, circleIndex: circleIndex))
        return weekdayName
    }
    
    private var startDateIndex: Int {
        return pageIndex(for: startDate)
    }
    
    private var endDateIndex: Int {
        return pageIndex(for: endDate) + 1
    }
    
    private func pageIndex(for date: Date) -> Int {
        let daysFromStartDate = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        return daysFromStartDate / 7
    }
}



struct CircularProgressBar: View {
    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    var progress: Double
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Circle()
                    .stroke(lineWidth: g.size.width * 0.118)
                    .opacity(0.4)
                    .foregroundColor(Color.blue)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 4.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
            }
            .environmentObject(CustomListViewModel)
        }
    }
}








struct ClassictaskBar: View {
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var customListViewModel: CustomListViewModel
    let selectedDate: Date?
    let selectedTime: Date

    let noti: Bool
    
    // Track the current date to detect changes
    @State private var currentSelectedDate: Date?


    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            let filteredItems = listViewModel.items
                .filter { item in
                    Calendar.current.isDate(item.selectedDate, inSameDayAs: selectedDate ?? Date())
                }
                .sorted { lhs, rhs in
                    if lhs.completion != rhs.completion {
                        return !lhs.completion && rhs.completion
                    } else {
                        return lhs.selectedTime ?? Date() < rhs.selectedTime ?? Date()
                    }
                }


            VStack(spacing: 0) {
                if filteredItems.isEmpty {
                    HStack {
                        Spacer()
                        VStack {
                            Image("main")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: screenWidth * 0.79, height: screenHeight * 0.3)
                            Text("No Tasks")
                                .font(.system(size: screenHeight * 0.03))
                                .padding(.top, 5)
                                .foregroundStyle(.black)
                                .bold()
                            Text("Press \"+\" Button to Add a Task")
                                .font(.system(size: screenHeight * 0.03))
                                .foregroundStyle(.black)
                                .bold()
                        }
                        Spacer()
                    }
                } else {
                    List(filteredItems) { item in
                        let isNewTask = item.completion && item.id == listViewModel.items.last?.id
                        let isBackgroundDark = item.selectedColor.cgColor?.components?.reduce(0, +) ?? 0 < 2
                        
                        SwipeItem(
                            content: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(item.completion ? item.selectedColor.opacity(0.2) : item.selectedColor.opacity(1))

                                    .shadow(color: item.selectedColor.opacity(1), radius: 7)
                                    .overlay(
                                        HStack {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text(String(item.category.prefix(1)))
                                                        .font(.system(size: screenWidth * 0.12))
                                                    VStack(alignment: .leading) {
                                                        Spacer()
                                                        Text(item.name.isEmpty ? String(item.category.dropFirst()) : item.name)
                                                            .font(.system(size: screenWidth * 0.039))
                                                            .foregroundColor(isBackgroundDark ? .white : .black)
                                                        if !item.description.isEmpty {
                                                            Text("  " + item.description)
                                                                .foregroundColor(isBackgroundDark ? .white : .black)
                                                                .font(.system(size: screenWidth * 0.03))
                                                        }
                                                        Text("  Time: \(formattedTime(from: item.selectedTime ?? Date()))")
                                                            .foregroundColor(isBackgroundDark ? .white : .black)
                                                            .font(.system(size: screenWidth * 0.03))
                                                        Spacer()
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                            Spacer()
                                            
                                            // Completion button
                                            Button(action: {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    if let index = listViewModel.items.firstIndex(where: { $0.id == item.id }) {
                                                        listViewModel.items[index].completion.toggle()
                                                    }
                                                }
                                            }) {
                                                Image(systemName: item.completion ? "checkmark.square" : "square")
                                                    .resizable()
                                                    .frame(width: screenWidth * 0.053, height: screenWidth * 0.053)
                                                    .foregroundColor(isBackgroundDark ? .white : .black)
                                                    .padding()
                                            }
                                            
                                        }
                                        .padding(.horizontal, 16)  // Add horizontal padding to the HStack


                                    )
                                    .frame(width: screenWidth * 0.91, height: screenHeight * 0.11)

                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            if let index = listViewModel.items.firstIndex(where: { $0.id == item.id }) {
                                                listViewModel.items[index].completion.toggle()
                                            }
                                        }
                                    }
                            },
                            left: {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                            if let index = listViewModel.items.firstIndex(where: { $0.id == item.id }) {
                                                // Update `noti` to `false` for the task before deleting it
                                                listViewModel.items[index].noti = false
                                                
                                                // Cancel the notification for the task
                                                let taskToRemove = listViewModel.items[index]
                                                listViewModel.cancelNotification(for: taskToRemove)
                                                
                                                // Remove the task from the list
                                                listViewModel.items.remove(at: index)
                                            }
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.red)
                                            .cornerRadius(8)
                                    }

                                }
                            },
                            right: {

                            },
                            itemHeight: screenHeight * 0.18
                                
                        )
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.5), value: listViewModel.items) // Ensure animation applies when list updates
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets()) // Remove row insets
                        .listRowBackground(Color.clear)
                        .padding(.bottom, -25)         ///here1
                        
                    }
                    .scrollIndicators(.hidden)
                    
                    .listStyle(PlainListStyle())
                }
            }
            .frame(maxHeight: .infinity)
            .environmentObject(customListViewModel)
            .onChange(of: selectedDate) { newDate in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentSelectedDate = newDate
                }
            }
        }
    }

    private func formattedTime(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
}

struct TimeChartView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { // Adjust spacing as needed
                ForEach(1..<13) { hour in
                    HStack {
                        Text("\(hour) AM")
                            .foregroundColor(.black) // Adjust text color to match the chart
                            .font(.system(size: 14)) // Adjust font size
                        
                        Divider() // Horizontal line
                            .background(Color.gray.opacity(0.5))
                            .frame(height: 1)
                            .padding(.leading, 10)
                            .bold()
                        Spacer()
                    }
                    Divider()
                        .background(Color.black) // Line color
                }
                
                ForEach(1..<13) { hour in
                    HStack {
                        Text("\(hour) PM")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                        
                    }
                    Divider()
                        .background(Color.black) // Line color
                }
            }
            .padding()
            .background(Color.white) // Background to match the image
        }
    }
}









//struct test: View {
//    var body: some View {
//        Text("Hi")
//            .overlay (
//                Rectangle()
//                    .overlay (
//                        Text
//                    )
//            )
//    }
//}














extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date? {
        return self.date(from: self.dateComponents([.year, .month], from: date))
    }
}


struct SwipeItem<Content: View, Left: View, Right: View>: View {
    var content: () -> Content
    var left: () -> Left
    var right: () -> Right
    var itemHeight: CGFloat
    
    @State private var hoffset: CGFloat = 0
    @State private var anchor: CGFloat = 0
    
    let screenWidth = UIScreen.main.bounds.width
    var anchorWidth: CGFloat { screenWidth / 3 }
    var swipeThreshold: CGFloat { screenWidth / 15 }
    
//    @State private var rightPast = false
    @State private var leftPast = false
    
    init(@ViewBuilder content: @escaping () -> Content,
         @ViewBuilder left: @escaping () -> Left,
         @ViewBuilder right: @escaping () -> Right,
         itemHeight: CGFloat) {
        self.content = content
        self.left = left
        self.right = right
        self.itemHeight = itemHeight
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 20) // Adjust sensitivity
            .onChanged { value in
                // Check if the drag is predominantly horizontal
                if abs(value.translation.width) > abs(value.translation.height) {
                    withAnimation {
                        hoffset = anchor + value.translation.width
                        
                        if abs(hoffset) > anchorWidth {
                            hoffset = hoffset > 0 ? anchorWidth : -anchorWidth
                        }
                        
                        leftPast = hoffset > swipeThreshold
                    }
                }
            }
            .onEnded { value in
                // Check if the drag was predominantly horizontal
                if abs(value.translation.width) > abs(value.translation.height) {
                    withAnimation {
                        if leftPast {
                            anchor = anchorWidth
                        } else {
                            anchor = 0
                        }
                        
                        hoffset = anchor
                        leftPast = false
                    }
                }
            }
    }

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                left()
                    .frame(width: anchorWidth)
                    .opacity(hoffset > 0 ? 1 : 0)
                    .clipped()
                
                Spacer()
            }
            
            content()
                .offset(x: hoffset)
        }
        .frame(height: itemHeight)
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    // Check if the drag is predominantly horizontal
                    if abs(value.translation.width) > abs(value.translation.height) {
                        withAnimation {
                            hoffset = anchor + value.translation.width
                            
                            if abs(hoffset) > anchorWidth {
                                hoffset = hoffset > 0 ? anchorWidth : -anchorWidth
                            }
                            
                            leftPast = hoffset > swipeThreshold
                        }
                    }
                }
                .onEnded { value in
                    // Only handle if it was a horizontal drag
                    if abs(value.translation.width) > abs(value.translation.height) {
                        withAnimation {
                            if leftPast {
                                anchor = anchorWidth
                            } else {
                                anchor = 0
                            }
                            
                            hoffset = anchor
                            leftPast = false
                        }
                    }
                }
        )
        .clipped()
    }
}





//#Preview {
//    GoalSet(selectedDate: Date(), )
//
//        .environmentObject(ListViewModel())
//        .environmentObject(CustomListViewModel())
//}
