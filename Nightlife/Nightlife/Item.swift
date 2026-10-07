//
//  Item.swift
//  Nightlife
//
//  Created by Majoros Máté on 2026. 06. 14..
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
