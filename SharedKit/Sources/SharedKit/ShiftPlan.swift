//
//  ShiftPlan.swift
//
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation

extension Shift {
    public var freePlaces: Int { max(capacity - workerIDs.count, 0) }
}

/// The administrator's staff and shift plan with its assignment rules (L3).
public struct ShiftPlan: Codable, Hashable {
    public enum PlanError: Error, Equatable {
        case emptyName
        case emptyTitle
        case invalidTime
        case invalidCapacity
        case unknownWorker
        case unknownShift
        case shiftFull
        case alreadyAssigned
        case overlappingShift(workerName: String)
        case workerNotOnShift(workerName: String)
    }

    public private(set) var staff: [WorkerUser]
    public private(set) var shifts: [Shift]

    public init(staff: [WorkerUser] = [], shifts: [Shift] = []) {
        self.staff = staff
        self.shifts = shifts
    }

    @discardableResult
    public mutating func addWorker(named name: String, role: WorkerRole, payPeriod: PayPeriod = .weekly) throws -> WorkerUser {
        let name = name.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { throw PlanError.emptyName }
        let worker = WorkerUser(appleID: "", name: name, role: role, payPeriod: payPeriod)
        staff.append(worker)
        return worker
    }

    @discardableResult
    public mutating func createShift(from start: Date, to end: Date, zoneID: UUID?, capacity: Int) throws -> Shift {
        guard start < end else { throw PlanError.invalidTime }
        guard capacity > 0 else { throw PlanError.invalidCapacity }
        let shift = Shift(capacity: capacity, startTime: start, endTime: end, zoneID: zoneID)
        shifts.append(shift)
        return shift
    }

    public mutating func removeShift(id: UUID) {
        shifts.removeAll { $0.id == id }
    }

    public mutating func assign(workerID: UUID, toShift shiftID: UUID) throws {
        guard let worker = staff.first(where: { $0.id == workerID }) else { throw PlanError.unknownWorker }
        guard let index = shifts.firstIndex(where: { $0.id == shiftID }) else { throw PlanError.unknownShift }
        let shift = shifts[index]
        guard !shift.workerIDs.contains(workerID) else { throw PlanError.alreadyAssigned }
        guard !shift.isFull else { throw PlanError.shiftFull }
        if shifts(for: workerID).contains(where: { $0.overlaps(with: shift) }) {
            throw PlanError.overlappingShift(workerName: worker.name)
        }
        _ = shifts[index].assign(workerID: workerID)
    }

    /// Removes the worker from the shift and from its tasks.
    public mutating func unassign(workerID: UUID, fromShift shiftID: UUID) {
        guard let index = shifts.firstIndex(where: { $0.id == shiftID }) else { return }
        shifts[index].workerIDs.removeAll { $0 == workerID }
        for task in shifts[index].tasks.indices {
            shifts[index].tasks[task].assignedWorkerIDs.removeAll { $0 == workerID }
        }
    }

    @discardableResult
    public mutating func addTask(titled title: String, toShift shiftID: UUID, for workerID: UUID) throws -> Task {
        let title = title.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { throw PlanError.emptyTitle }
        guard let worker = staff.first(where: { $0.id == workerID }) else { throw PlanError.unknownWorker }
        guard let index = shifts.firstIndex(where: { $0.id == shiftID }) else { throw PlanError.unknownShift }
        guard shifts[index].workerIDs.contains(workerID) else { throw PlanError.workerNotOnShift(workerName: worker.name) }
        let task = Task(title: title, description: "", assignedWorkerIDs: [workerID], workstation: "")
        shifts[index].tasks.append(task)
        return task
    }

    /// A worker's shifts, earliest first.
    public func shifts(for workerID: UUID) -> [Shift] {
        shifts.filter { $0.workerIDs.contains(workerID) }.sorted { $0.startTime < $1.startTime }
    }
}
