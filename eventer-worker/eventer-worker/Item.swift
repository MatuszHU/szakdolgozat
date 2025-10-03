//
//  Item.swift
//  eventer-worker
//
//  Created by Majoros Máté on 2025. 10. 03..
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
