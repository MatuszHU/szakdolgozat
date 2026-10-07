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

extension PanicAlert {

    /// Staff members who receive the alert: everyone on shift with a notified role, except the sender (K8).
    public static func recipients(for sender: WorkerUser,
                                  among staff: [WorkerUser],
                                  notifying roles: Set<WorkerRole> = [.security]) -> [UUID] {
        staff
            .filter { $0.id != sender.id && roles.contains($0.role) }
            .map(\.id)
    }

    /// Notification text: name, role and last known zone of the worker (K8).
    public static func message(for worker: WorkerUser, zone: Zone?) -> String {
        "\(worker.name) (\(worker.role.displayName)) – \(zone?.name ?? "unknown location")"
    }

    /// Records the first acknowledgement; later ones and the sender's own are ignored.
    public mutating func acknowledge(by responderID: UUID, at date: Date = Date()) -> Bool {
        guard !isAcknowledged, responderID != workerID else { return false }
        isAcknowledged = true
        acknowledgedByID = responderID
        acknowledgedTimestamp = date
        return true
    }
}
