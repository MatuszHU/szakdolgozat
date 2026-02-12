//
//  Item.swift
//  worker
//
//  Created by Majoros Máté on 2026. 01. 05..
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
