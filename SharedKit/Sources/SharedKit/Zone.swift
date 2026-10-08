//
//  Zone.swift
//
//
//  Created by Majoros Máté on 2026. 10. 07..
//


import Foundation

public struct GridCell: Codable, Hashable, Sendable {
    public var row: Int
    public var column: Int

    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

public struct Zone: Identifiable, Codable, Hashable {
    public static let qrPrefix = "nightlife://zone/"

    public let id: UUID
    public var floorID: UUID?
    public var name: String
    public var cells: Set<GridCell>

    public var qrPayload: String { Zone.qrPrefix + id.uuidString }

    public init(id: UUID = UUID(), floorID: UUID? = nil, name: String, cells: Set<GridCell> = []) {
        self.id = id
        self.floorID = floorID
        self.name = name
        self.cells = cells
    }

    public static func zoneID(fromQRPayload payload: String) -> UUID? {
        guard payload.hasPrefix(qrPrefix) else { return nil }
        return UUID(uuidString: String(payload.dropFirst(qrPrefix.count)))
    }
}

public struct ZoneCheckIn: Identifiable, Codable {
    public let id: UUID
    public let workerID: UUID
    public let zoneID: UUID
    public let timestamp: Date

    public init(id: UUID = UUID(), workerID: UUID, zoneID: UUID, timestamp: Date = Date()) {
        self.id = id
        self.workerID = workerID
        self.zoneID = zoneID
        self.timestamp = timestamp
    }
}

public struct WorkerPosition {
    public enum CheckInError: Error, Equatable {
        case invalidCode
        case notOnShift
    }

    public let workerID: UUID
    public private(set) var isOnShift: Bool
    public private(set) var currentZoneID: UUID?
    public private(set) var checkIns: [ZoneCheckIn] = []

    public init(workerID: UUID, isOnShift: Bool) {
        self.workerID = workerID
        self.isOnShift = isOnShift
    }

    public mutating func checkIn(scanning payload: String, knownZoneIDs: Set<UUID>, at date: Date = Date()) throws {
        guard isOnShift else { throw CheckInError.notOnShift }
        guard let zoneID = Zone.zoneID(fromQRPayload: payload), knownZoneIDs.contains(zoneID) else {
            throw CheckInError.invalidCode
        }
        currentZoneID = zoneID
        checkIns.append(ZoneCheckIn(workerID: workerID, zoneID: zoneID, timestamp: date))
    }

    public mutating func endShift() {
        isOnShift = false
        currentZoneID = nil
    }
}
