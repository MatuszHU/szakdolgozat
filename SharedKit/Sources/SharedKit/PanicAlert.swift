//
//  PanicAlert.swift
//  
//
//  Created by Majoros Máté on 2026. 06. 14..
//

import Foundation
import CoreLocation

public struct PanicAlert: Identifiable, Codable {
    public let id: UUID
    public let workerID: UUID
    public let timestamp: Date
    public var latitude: Double?
    public var longitude: Double?
    public var isAcknowledged: Bool
    public var acknowledgedByID: UUID?
    public var acknowledgedTimestamp: Date?
    
    public init(id: UUID = UUID(), workerID: UUID, timestamp: Date = Date(), latitude: Double? = nil, longitude: Double? = nil, isAcknowledged: Bool = false, acknowledgedByID: UUID? = nil, acknowledgedTimestamp: Date? = nil) {
        self.id = id
        self.workerID = workerID
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.isAcknowledged = isAcknowledged
        self.acknowledgedByID = acknowledgedByID
        self.acknowledgedTimestamp = acknowledgedTimestamp
    }
}
