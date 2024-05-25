//
//  Item.swift
//  Animation Playground
//
//  Created by Morris Richman on 5/25/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
