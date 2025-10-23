//
//  ItemModel.swift
//  goal app
//
//  Created by Kunwar Singh on 8/7/24.
//
import SwiftUI
import Foundation

extension Color {
    init?(hexa: String) {
        guard let rgb = Int(hexa.dropFirst(), radix: 16) else {
            return nil
        }
        self.init(
            .sRGB,
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}


struct ItemModel: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let category: String
    let name: String
    let description: String
    let selectedColor: Color
    let selectedDate: Date
    let selectedTime: Date
    var habit: Bool
    var noti: Bool
    var scheduled: Bool
    var completion: Bool
    
    static func ==(lhs: ItemModel, rhs: ItemModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id, category, name, description, selectedColorHex, selectedDate, selectedTime, habit, noti, scheduled, completion
    }

    // Convert Color to hex string for encoding
    var selectedColorHex: String? {
        return selectedColor.toHexa()
    }

    init(category: String, name: String, description: String, selectedColor: Color, selectedDate: Date, selectedTime: Date, habit: Bool, noti: Bool, scheduled: Bool, completion: Bool) {
        self.id = UUID()
        self.category = category
        self.name = name
        self.description = description
        self.selectedColor = selectedColor
        self.completion = completion
        self.selectedDate = selectedDate
        self.selectedTime = selectedTime
        self.habit = habit
        self.noti = noti
        self.scheduled = scheduled
        self.completion = completion
    }

    // Custom decoder to handle Color from hex string
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        category = try container.decode(String.self, forKey: .category)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        completion = try container.decode(Bool.self, forKey: .completion)
        selectedDate = try container.decode(Date.self, forKey: .selectedDate)
        selectedTime = try container.decode(Date.self, forKey: .selectedTime)
        habit = try container.decode(Bool.self, forKey: .habit)
        noti = try container.decode(Bool.self, forKey: .noti)
        scheduled = try container.decode(Bool.self, forKey: .scheduled)
        completion = try container.decode(Bool.self, forKey: .completion)

        let selectedColorHex = try container.decode(String.self, forKey: .selectedColorHex)
        self.selectedColor = Color(hex: selectedColorHex)
    }
    


    // Custom encoder to handle Color as hex string
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(selectedDate, forKey: .selectedDate)
        try container.encode(selectedTime, forKey: .selectedTime)
        try container.encode(habit, forKey: .habit)
        try container.encode(noti, forKey: .noti)
        try container.encode(scheduled, forKey: .scheduled)
        try container.encode(completion, forKey: .completion)
        try container.encode(selectedColorHex, forKey: .selectedColorHex)
    }
}



