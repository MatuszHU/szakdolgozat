//
//  Shift.swift
//  
//
//  Created by Majoros Máté on 2026. 06. 14..
//


import Foundation

public struct Shift: Identifiable, Codable {
    public let id: UUID
    public var workerIDs: [UUID]      // több worker
    public var capacity: Int           // max létszám, default 1
    public var startTime: Date
    public var endTime: Date
    public var zoneID: UUID?
    public var tasks: [Task]

    public var isFull: Bool { workerIDs.count >= capacity }

    public init(id: UUID = UUID(), workerIDs: [UUID] = [], capacity: Int = 1,
                startTime: Date, endTime: Date, zoneID: UUID? = nil, tasks: [Task] = []) {
        self.id = id
        self.workerIDs = workerIDs
        self.capacity = capacity
        self.startTime = startTime
        self.endTime = endTime
        self.zoneID = zoneID
        self.tasks = tasks
    }

    public func overlaps(with other: Shift) -> Bool {
        startTime < other.endTime && endTime > other.startTime
    }

    public mutating func assign(workerID: UUID) -> Bool {
        guard !isFull && !workerIDs.contains(workerID) else { return false }
        workerIDs.append(workerID)
        return true
    }
    
}

public struct Schedule: Identifiable, Codable {
    public let id: UUID
    public let workerID: UUID
    public var shifts: [Shift]
    public var payPeriod: PayPeriod
    
    public init(id: UUID = UUID(), workerID: UUID, shifts: [Shift] = [], payPeriod: PayPeriod) {
        self.id = id
        self.workerID = workerID
        self.shifts = shifts
        self.payPeriod = payPeriod
    }
    
    public func hasConflict(for newShift: Shift, workerID: UUID) -> Bool {
        shifts.contains { $0.workerIDs.contains(workerID) && $0.overlaps(with: newShift) }
    }
}

