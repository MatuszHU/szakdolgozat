import Foundation
import Testing
@testable import SharedKit

private let base = Date(timeIntervalSince1970: 1_800_000_000)

private func makeShift(fromHour start: Double, toHour end: Double, capacity: Int = 1, zoneID: UUID? = nil) -> Shift {
    Shift(capacity: capacity,
          startTime: base.addingTimeInterval(start * 3600),
          endTime: base.addingTimeInterval(end * 3600),
          zoneID: zoneID)
}

@Suite("Shift")
@L3
struct ShiftTests {

    @Test func overlappingShiftsOverlap() {
        #expect(makeShift(fromHour: 20, toHour: 26).overlaps(with: makeShift(fromHour: 21, toHour: 23)))
    }

    @Test func adjacentShiftsDoNotOverlap() {
        #expect(!makeShift(fromHour: 20, toHour: 22).overlaps(with: makeShift(fromHour: 22, toHour: 24)))
    }

    @Test func disjointShiftsDoNotOverlap() {
        #expect(!makeShift(fromHour: 20, toHour: 22).overlaps(with: makeShift(fromHour: 23, toHour: 25)))
    }

    @Test func assignAddsWorker() {
        var shift = makeShift(fromHour: 20, toHour: 22)
        let worker = UUID()
        let added = shift.assign(workerID: worker)
        #expect(added)
        #expect(shift.workerIDs == [worker])
    }

    @Test func assignRejectsSameWorkerTwice() {
        var shift = makeShift(fromHour: 20, toHour: 22, capacity: 2)
        let worker = UUID()
        _ = shift.assign(workerID: worker)
        let addedAgain = shift.assign(workerID: worker)
        #expect(!addedAgain)
        #expect(shift.workerIDs.count == 1)
    }

    @Test func assignRejectsWhenFull() {
        var shift = makeShift(fromHour: 20, toHour: 22, capacity: 1)
        _ = shift.assign(workerID: UUID())
        #expect(shift.isFull)
        let added = shift.assign(workerID: UUID())
        #expect(!added)
    }

    @Test func shiftReferencesZone() {
        let zone = UUID()
        #expect(makeShift(fromHour: 20, toHour: 22, zoneID: zone).zoneID == zone)
    }
}

@Suite("Schedule")
@L3
struct ScheduleTests {

    private func schedule(with existing: Shift, assigned: Bool = true) -> Schedule {
        let worker = UUID()
        var shift = existing
        if assigned { _ = shift.assign(workerID: worker) }
        return Schedule(workerID: worker, shifts: [shift], payPeriod: .weekly)
    }

    @Test func overlappingAssignedShiftConflicts() {
        let s = schedule(with: makeShift(fromHour: 20, toHour: 26))
        #expect(s.hasConflict(for: makeShift(fromHour: 21, toHour: 23), workerID: s.workerID))
    }

    @Test func adjacentShiftDoesNotConflict() {
        let s = schedule(with: makeShift(fromHour: 20, toHour: 22))
        #expect(!s.hasConflict(for: makeShift(fromHour: 22, toHour: 24), workerID: s.workerID))
    }

    @Test func overlapWithUnassignedShiftDoesNotConflict() {
        let s = schedule(with: makeShift(fromHour: 20, toHour: 26), assigned: false)
        #expect(!s.hasConflict(for: makeShift(fromHour: 21, toHour: 23), workerID: s.workerID))
    }
}

@Suite("PanicAlert")
@K8
struct PanicAlertTests {

    @Test func storesLastKnownZone() {
        let zone = UUID()
        let alert = PanicAlert(workerID: UUID(), zoneID: zone)
        #expect(alert.zoneID == zone)
        #expect(!alert.isAcknowledged)
    }
}

@Suite("Users")
@L1 @L3
struct UserTests {

    @Test func adminDefaultsToAppleSignIn() {
        let admin = AdminUser(username: "anna", name: "Anna", role: .owner)
        #expect(admin.signInMethod == .apple)
    }

    @Test func adminCanUsePasswordSignIn() {
        let admin = AdminUser(username: "anna", name: "Anna", role: .userAdmin, signInMethod: .password)
        #expect(admin.signInMethod == .password)
    }

    @Test func workerHasNoDuplicatedShiftList() {
        let worker = WorkerUser(appleID: "apple-id", name: "Béla", role: .bartender, payPeriod: .weekly)
        #expect(worker.workedHours == 0)
    }
}
