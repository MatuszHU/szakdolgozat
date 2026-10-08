import Foundation
import Testing
@testable import SharedKit

@Suite("ShiftPlan")
struct ShiftPlanTests {

    private let evening = Date(timeIntervalSince1970: 1_800_000_000)

    private func hours(_ value: Double) -> Date { evening.addingTimeInterval(value * 3600) }

    private func planWithAnna() throws -> (ShiftPlan, WorkerUser) {
        var plan = ShiftPlan()
        let anna = try plan.addWorker(named: "Anna", role: .bartender)
        return (plan, anna)
    }

    @Test func addsWorkersInOrder() throws {
        var plan = ShiftPlan()
        try plan.addWorker(named: "Anna", role: .bartender)
        try plan.addWorker(named: " Béla ", role: .security)
        #expect(plan.staff.map(\.name) == ["Anna", "Béla"])
        #expect(plan.staff.last?.role == .security)
    }

    @Test func workerNeedsAName() {
        var plan = ShiftPlan()
        #expect(throws: ShiftPlan.PlanError.emptyName) { try plan.addWorker(named: "  ", role: .bartender) }
    }

    @Test func createsAShift() throws {
        var plan = ShiftPlan()
        let zone = UUID()
        let shift = try plan.createShift(from: hours(0), to: hours(6), zoneID: zone, capacity: 2)
        #expect(plan.shifts.map(\.id) == [shift.id])
        #expect(shift.zoneID == zone)
        #expect(shift.freePlaces == 2)
    }

    @Test func shiftMustEndAfterItStarts() {
        var plan = ShiftPlan()
        #expect(throws: ShiftPlan.PlanError.invalidTime) { try plan.createShift(from: hours(2), to: hours(2), zoneID: nil, capacity: 1) }
        #expect(throws: ShiftPlan.PlanError.invalidTime) { try plan.createShift(from: hours(2), to: hours(1), zoneID: nil, capacity: 1) }
    }

    @Test func capacityMustBePositive() {
        var plan = ShiftPlan()
        #expect(throws: ShiftPlan.PlanError.invalidCapacity) { try plan.createShift(from: hours(0), to: hours(1), zoneID: nil, capacity: 0) }
    }

    @Test func assignsAWorker() throws {
        var (plan, anna) = try planWithAnna()
        let shift = try plan.createShift(from: hours(0), to: hours(6), zoneID: nil, capacity: 2)
        try plan.assign(workerID: anna.id, toShift: shift.id)
        #expect(plan.shifts.first?.workerIDs == [anna.id])
        #expect(plan.shifts(for: anna.id).map(\.id) == [shift.id])
    }

    @Test func fullShiftRejectsWorkers() throws {
        var (plan, anna) = try planWithAnna()
        let bela = try plan.addWorker(named: "Béla", role: .security)
        let shift = try plan.createShift(from: hours(0), to: hours(6), zoneID: nil, capacity: 1)
        try plan.assign(workerID: anna.id, toShift: shift.id)
        #expect(throws: ShiftPlan.PlanError.shiftFull) { try plan.assign(workerID: bela.id, toShift: shift.id) }
    }

    @Test func sameWorkerCannotBeAssignedTwice() throws {
        var (plan, anna) = try planWithAnna()
        let shift = try plan.createShift(from: hours(0), to: hours(6), zoneID: nil, capacity: 2)
        try plan.assign(workerID: anna.id, toShift: shift.id)
        #expect(throws: ShiftPlan.PlanError.alreadyAssigned) { try plan.assign(workerID: anna.id, toShift: shift.id) }
    }

    @Test func overlappingShiftIsRejected() throws {
        var (plan, anna) = try planWithAnna()
        let first = try plan.createShift(from: hours(0), to: hours(6), zoneID: nil, capacity: 1)
        let second = try plan.createShift(from: hours(3), to: hours(7), zoneID: nil, capacity: 1)
        try plan.assign(workerID: anna.id, toShift: first.id)
        #expect(throws: ShiftPlan.PlanError.overlappingShift(workerName: "Anna")) {
            try plan.assign(workerID: anna.id, toShift: second.id)
        }
    }

    @Test func backToBackShiftsAreAllowed() throws {
        var (plan, anna) = try planWithAnna()
        let first = try plan.createShift(from: hours(0), to: hours(2), zoneID: nil, capacity: 1)
        let second = try plan.createShift(from: hours(2), to: hours(4), zoneID: nil, capacity: 1)
        try plan.assign(workerID: anna.id, toShift: first.id)
        try plan.assign(workerID: anna.id, toShift: second.id)
        #expect(plan.shifts(for: anna.id).count == 2)
    }

    @Test func unknownWorkerOrShiftIsRejected() throws {
        var (plan, anna) = try planWithAnna()
        let shift = try plan.createShift(from: hours(0), to: hours(1), zoneID: nil, capacity: 1)
        #expect(throws: ShiftPlan.PlanError.unknownWorker) { try plan.assign(workerID: UUID(), toShift: shift.id) }
        #expect(throws: ShiftPlan.PlanError.unknownShift) { try plan.assign(workerID: anna.id, toShift: UUID()) }
    }

    @Test func taskGoesToAWorkerOnTheShift() throws {
        var (plan, anna) = try planWithAnna()
        let shift = try plan.createShift(from: hours(0), to: hours(6), zoneID: nil, capacity: 2)
        try plan.assign(workerID: anna.id, toShift: shift.id)
        try plan.addTask(titled: "Restock the bar", toShift: shift.id, for: anna.id)
        #expect(plan.shifts.first?.tasks.map(\.title) == ["Restock the bar"])
        #expect(plan.shifts.first?.tasks.first?.assignedWorkerIDs == [anna.id])
    }

    @Test func taskForWorkerNotOnShiftIsRejected() throws {
        var (plan, anna) = try planWithAnna()
        let shift = try plan.createShift(from: hours(0), to: hours(6), zoneID: nil, capacity: 2)
        #expect(throws: ShiftPlan.PlanError.workerNotOnShift(workerName: "Anna")) {
            try plan.addTask(titled: "Restock the bar", toShift: shift.id, for: anna.id)
        }
    }

    @Test func taskNeedsATitle() throws {
        var (plan, anna) = try planWithAnna()
        let shift = try plan.createShift(from: hours(0), to: hours(6), zoneID: nil, capacity: 2)
        try plan.assign(workerID: anna.id, toShift: shift.id)
        #expect(throws: ShiftPlan.PlanError.emptyTitle) { try plan.addTask(titled: " ", toShift: shift.id, for: anna.id) }
    }

    @Test func unassigningRemovesWorkerFromShiftAndTasks() throws {
        var (plan, anna) = try planWithAnna()
        let shift = try plan.createShift(from: hours(0), to: hours(6), zoneID: nil, capacity: 2)
        try plan.assign(workerID: anna.id, toShift: shift.id)
        try plan.addTask(titled: "Restock the bar", toShift: shift.id, for: anna.id)
        plan.unassign(workerID: anna.id, fromShift: shift.id)
        #expect(plan.shifts.first?.workerIDs.isEmpty == true)
        #expect(plan.shifts.first?.tasks.first?.assignedWorkerIDs.isEmpty == true)
    }

    @Test func scheduleForAWorkerIsSortedByStart() throws {
        var (plan, anna) = try planWithAnna()
        let later = try plan.createShift(from: hours(24), to: hours(30), zoneID: nil, capacity: 1)
        let earlier = try plan.createShift(from: hours(0), to: hours(6), zoneID: nil, capacity: 1)
        try plan.assign(workerID: anna.id, toShift: later.id)
        try plan.assign(workerID: anna.id, toShift: earlier.id)
        #expect(plan.shifts(for: anna.id).map(\.id) == [earlier.id, later.id])
    }

    @Test func planRoundTripsThroughJSON() throws {
        var (plan, anna) = try planWithAnna()
        let shift = try plan.createShift(from: hours(0), to: hours(6), zoneID: UUID(), capacity: 2)
        try plan.assign(workerID: anna.id, toShift: shift.id)
        let decoded = try JSONDecoder().decode(ShiftPlan.self, from: JSONEncoder().encode(plan))
        #expect(decoded.staff.map(\.id) == plan.staff.map(\.id))
        #expect(decoded.shifts.map(\.workerIDs) == plan.shifts.map(\.workerIDs))
    }
}
