//
//  ShiftPlannerViewModel.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation
import Combine
import SharedKit

/// Persists the staff and shift plan (production: CloudKit; until then a local file).
protocol ShiftPlanStoring {
    func load() -> ShiftPlan?
    func save(_ plan: ShiftPlan) throws
}

/// Staff, shifts, assignments and tasks (L3).
class ShiftPlannerViewModel: ObservableObject {
    @Published private(set) var plan: ShiftPlan
    @Published private(set) var errorMessage: String?
    private let store: ShiftPlanStoring

    init(plan: ShiftPlan, store: ShiftPlanStoring) {
        self.plan = plan
        self.store = store
    }

    func addWorker(named name: String, role: WorkerRole) {
        apply { try $0.addWorker(named: name, role: role) }
    }

    @discardableResult
    func createShift(from start: Date, to end: Date, zoneID: UUID?, capacity: Int) -> Shift? {
        var created: Shift?
        apply { created = try $0.createShift(from: start, to: end, zoneID: zoneID, capacity: capacity) }
        return created
    }

    func removeShift(id: UUID) {
        apply { $0.removeShift(id: id) }
    }

    func assign(workerID: UUID, toShift shiftID: UUID) {
        apply { try $0.assign(workerID: workerID, toShift: shiftID) }
    }

    func unassign(workerID: UUID, fromShift shiftID: UUID) {
        apply { $0.unassign(workerID: workerID, fromShift: shiftID) }
    }

    func addTask(titled title: String, toShift shiftID: UUID, for workerID: UUID) {
        apply { try $0.addTask(titled: title, toShift: shiftID, for: workerID) }
    }

    /// Runs an edit on a copy; publishes and saves it only if it succeeds.
    private func apply(_ edit: (inout ShiftPlan) throws -> Void) {
        var edited = plan
        do {
            try edit(&edited)
            plan = edited
            errorMessage = nil
            try store.save(edited)
        } catch let error as ShiftPlan.PlanError {
            errorMessage = Self.message(for: error)
        } catch {
            errorMessage = "The plan could not be saved"
        }
    }

    private static func message(for error: ShiftPlan.PlanError) -> String {
        switch error {
        case .emptyName: return "A name is required"
        case .emptyTitle: return "A task title is required"
        case .invalidTime: return "The shift must end after it starts"
        case .invalidCapacity: return "A shift needs at least one place"
        case .unknownWorker: return "The worker no longer exists"
        case .unknownShift: return "The shift no longer exists"
        case .shiftFull: return "The shift is full"
        case .alreadyAssigned: return "The worker is already on this shift"
        case .overlappingShift(let name): return "\(name) already has an overlapping shift"
        case .workerNotOnShift(let name): return "\(name) is not on this shift"
        }
    }
}
