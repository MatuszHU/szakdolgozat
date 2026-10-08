//
//  StaffMap.swift
//
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation

/// Where the staff are (latest check-in) and what they should do (active shift), at a moment (K6, L4).
public struct StaffMap {
    public struct Entry {
        public let worker: WorkerUser
        public let positionZoneID: UUID?
        public let workAreaZoneID: UUID?
        public let tasks: [Task]
    }

    public let entries: [Entry]

    public init(staff: [WorkerUser], checkIns: [ZoneCheckIn], shifts: [Shift], at date: Date) {
        let positions = ZoneCheckIn.latestZones(from: checkIns)
        entries = staff
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            .map { worker in
                let shift = shifts.first {
                    $0.workerIDs.contains(worker.id) && $0.startTime <= date && date < $0.endTime
                }
                return Entry(worker: worker,
                             positionZoneID: positions[worker.id],
                             workAreaZoneID: shift?.zoneID,
                             tasks: shift?.tasks.filter { $0.assignedWorkerIDs.contains(worker.id) } ?? [])
            }
    }

    public func entry(for workerID: UUID) -> Entry? {
        entries.first { $0.worker.id == workerID }
    }

    public func names(inZone zoneID: UUID) -> [String] {
        entries.filter { $0.positionZoneID == zoneID }.map(\.worker.name)
    }

    /// Staff who have not checked in to any zone yet.
    public var withoutPosition: [WorkerUser] {
        entries.filter { $0.positionZoneID == nil }.map(\.worker)
    }

    /// Names per zone of a floor, for the floor plan badges.
    public func badges(on floor: Floor) -> [UUID: [String]] {
        Dictionary(uniqueKeysWithValues: floor.zones.map { ($0.id, names(inZone: $0.id)) })
    }
}
