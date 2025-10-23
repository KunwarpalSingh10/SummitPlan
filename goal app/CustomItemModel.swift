//
//  SwiftUIView.swift
//  goal app
//
//  Created by Kunwar Singh on 10/30/24.
//

import SwiftUI
import Foundation

struct CustomItemModel: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let symbol: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name
    }
    
    init(symbol: String, name: String) {
        self.id = UUID()
        self.symbol = symbol
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
    }
    
}


