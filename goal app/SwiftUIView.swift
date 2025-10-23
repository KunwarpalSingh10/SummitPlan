//
//  SwiftUIView.swift
//  goal app
//
//  Created by Kunwar Singh on 10/30/24.
//

import SwiftUI
import Foundation

struct CustomAdd: Identifiable, Codable {
    let symbol: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case symbol, name
    }
    
    init(symbol: String, name: String) {
        self.symbol = symbol
        self.name = symbol
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: name)
    }
    
}


