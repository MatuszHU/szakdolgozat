//
//  PanicAlert.swift
//  
//
//  Created by Majoros Máté on 2026. 06. 14..
//

import Foundation

public struct PanicAlert: Identifiable, Codable {
    public let id: UUID
    public let workerID: UUID
    public let timestamp: Date
    public var zoneID: UUID?
    public var isAcknowledged: Bool
    public var acknowledgedByID: UUID?
    public var acknowledgedTimestamp: Date?
    
    public init(id: UUID = UUID(), workerID: UUID, timestamp: Date = Date(), zoneID: UUID? = nil, isAcknowledged: Bool = false, acknowledgedByID: UUID? = nil, acknowledgedTimestamp: Date? = nil) {
        self.id = id
        self.workerID = workerID
        self.timestamp = timestamp
        self.zoneID = zoneID
        self.isAcknowledged = isAcknowledged
        self.acknowledgedByID = acknowledgedByID
        self.acknowledgedTimestamp = acknowledgedTimestamp
    }
}
