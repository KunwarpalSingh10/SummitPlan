import SwiftUI
import Foundation
import Combine



class CustomListViewModel: ObservableObject {
    @Published var items: [CustomItemModel] = [] {
        didSet {
            saveItems()
        }
    }
    
    init() {
        loadItems()
    }
    
    func addItems(symbol: String, name: String) {
        let newItem = CustomItemModel(
            symbol: symbol,
            name: name
        )
        
        items.append(newItem)
        
    }
    
    private func saveItems() {
        do {
            let encodedData = try JSONEncoder().encode(items)
            UserDefaults.standard.set(encodedData, forKey: "customTasks")
            UserDefaults.standard.synchronize() // For immediate testing
            print("Items saved successfully: \(items)")
        } catch {
            print("Failed to encode items: \(error)")
        }
    }

    private func loadItems() {
        if let savedData = UserDefaults.standard.data(forKey: "customTasks") {
            do {
                let decodedItems = try JSONDecoder().decode([CustomItemModel].self, from: savedData)
                items = decodedItems
                print("Items loaded successfully: \(items)")
            } catch {
                print("Failed to decode items: \(error)")
            }
        } else {
            print("No items found in UserDefaults.")
        }
    }

    
    

    
}
