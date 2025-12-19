//
//  Item.swift
//  worker
//
//  Created by Majoros Máté on 2025. 12. 18..
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
