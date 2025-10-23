import SwiftUI
import Foundation
import Combine
import UserNotifications // Import for scheduling notifications

class ListViewModel: ObservableObject {
    @Published var items: [ItemModel] = [] {
        didSet {
            saveItems()
        }
    }

    init() {
        loadItems()
        requestNotificationPermission() // Request notification permission
    }

    func addItems(category: String, name: String, description: String, selectedColor: Color, selectedDate: Date, selectedTime: Date, habit: Bool, noti: Bool, scheduled: Bool, completion: Bool, days: [String], duration: String) {
        let calendar = Calendar.current

        // Calculate the end date based on the selected duration
        let endDate: Date
        switch duration {
        case "1 Week":
            endDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate)!
        case "2 Weeks":
            endDate = calendar.date(byAdding: .weekOfYear, value: 2, to: selectedDate)!
        case "1 Month":
            endDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
        case "3 Months":
            endDate = calendar.date(byAdding: .month, value: 3, to: selectedDate)!
        case "1 Year":
            endDate = calendar.date(byAdding: .year, value: 1, to: selectedDate)!
        default:
            endDate = selectedDate
        }

        if habit {
            // Generate tasks for every matching day of the week within the specified duration
            var currentDate = selectedDate
            while currentDate <= endDate {
                let weekday = calendar.component(.weekday, from: currentDate)
                let weekdayLetter = weekdayLetter(for: weekday) // Get the letter representation of the weekday

                if days.contains(weekdayLetter) {
                    let newItem = ItemModel(
                        category: category,
                        name: name,
                        description: description,
                        selectedColor: selectedColor,
                        selectedDate: currentDate,
                        selectedTime: selectedTime,
                        habit: habit,
                        noti: noti,
                        scheduled: scheduled,
                        completion: false
                    )
                    items.append(newItem)

                    if noti {
                        scheduleNotification(for: newItem)
                    }
                }

                // Move to the next day
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        } else {
            // Add a single task
            let newItem = ItemModel(
                category: category,
                name: name,
                description: description,
                selectedColor: selectedColor,
                selectedDate: selectedDate,
                selectedTime: selectedTime,
                habit: habit,
                noti: noti,
                scheduled: scheduled,
                completion: false
            )
            items.append(newItem)

            if noti {
                scheduleNotification(for: newItem)
            }
        }
    }

    func cancelNotification(for item: ItemModel) {
        let identifier = "task-\(item.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier]) // Optional: Removes delivered notifications
        print("Notification canceled for task: \(item.name)") // Debug
    }

    
    private func weekdayLetter(for weekday: Int) -> String {
        switch weekday {
        case 1: return "S" // Sunday
        case 2: return "M" // Monday
        case 3: return "T" // Tuesday
        case 4: return "W" // Wednesday
        case 5: return "Th" // Thursday
        case 6: return "F" // Friday
        case 7: return "Sa" // Saturday
        default: return ""
        }
    }

    
    private func nextDate(for day: String, from referenceDate: Date) -> Date? {
        let calendar = Calendar.current
        guard let dayIndex = ["S", "M", "T", "W", "Th", "F", "Sa"].firstIndex(of: day) else {
            return nil
        }

        let weekday = (dayIndex + 1) % 7 // Adjust index to match Calendar weekday (1 for Sunday)
        let currentWeekday = calendar.component(.weekday, from: referenceDate)
        let daysUntil = (weekday - currentWeekday + 7) % 7

        return calendar.date(byAdding: .day, value: daysUntil, to: referenceDate)
    }

    


    
    func dailyAverage() -> Double {
        let completedTasks = items.filter { $0.completion }
        
        // Extract unique dates of completed tasks
        let uniqueDates = Set(completedTasks.map { Calendar.current.startOfDay(for: $0.selectedDate) })
        guard !uniqueDates.isEmpty else { return 0.0 }
        
        // Calculate daily average
        let average = Double(completedTasks.count) / Double(uniqueDates.count)
        
        // Return as an integer if the average is a whole number
        return average == floor(average) ? Double(Int(average)) : average
    }




    private func saveItems() {
        if let encodedData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encodedData, forKey: "savedItems")
        }
    }

    private func loadItems() {
        if let savedData = UserDefaults.standard.data(forKey: "savedItems"),
           let decodedItems = try? JSONDecoder().decode([ItemModel].self, from: savedData) {
            items = decodedItems
        }
    }

    func moveItem(from source: Int, to destination: Int) {
        let itemToMove = items.remove(at: source)
        items.insert(itemToMove, at: destination)
    }

    // Function to schedule a notification for the item
    func scheduleNotification(for item: ItemModel) {
        guard item.noti else { return }
        print("Scheduling notification for: \(item.name)") // Debug line
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Don't forget to complete your task: \(item.name)"
        content.sound = .default

        let calendar = Calendar.current
        var notificationTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: item.selectedDate)
        let selectedTimeComponents = calendar.dateComponents([.hour, .minute], from: item.selectedTime)
        notificationTimeComponents.hour = selectedTimeComponents.hour
        notificationTimeComponents.minute = selectedTimeComponents.minute

        guard let notificationDate = calendar.date(from: notificationTimeComponents) else {
            print("Invalid notification time components.") // Debug line
            return
        }

        // Create the trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationTimeComponents, repeats: false)
        let identifier = "task-\(item.id.uuidString)"

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for task: \(item.name) at \(notificationDate)")
            }
        }
    }


    // Request notification permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    
    
    func overallProgress() -> Double {
        guard !items.isEmpty else { return 0.0 }
        
        let completedTasks = items.filter { $0.completion }
        return Double(completedTasks.count) / Double(items.count)
    }
    
    func progressForSelectedDate(selectedDate: Date) -> Double {
        // Ensure selectedDate is valid and not in the future (optional but good practice)
//        guard selectedDate <= Date() else {
//            print("Selected date is in the future. Please select a valid date.")
//            return 0.0
//        }

        // Filter tasks based on the selected date
        let filteredItems = items.filter { item in
            // Ensure only the day part of the dates is compared
            Calendar.current.isDate(item.selectedDate, inSameDayAs: selectedDate)
        }
        
        // If no tasks found for the selected date, return 0.0 progress
        guard !filteredItems.isEmpty else { return 0.0 }
        
        // Filter out completed tasks
        let completedTasks = filteredItems.filter { $0.completion }
        
        // Return progress as the ratio of completed tasks to total tasks
        return Double(completedTasks.count) / Double(filteredItems.count)
    }



}

