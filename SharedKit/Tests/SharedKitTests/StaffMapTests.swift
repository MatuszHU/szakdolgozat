import Foundation
import Testing
@testable import SharedKit

@Suite("StaffMap")
@K6 @L4
struct StaffMapTests {

    private let tonight = Date(timeIntervalSince1970: 1_800_000_000)
    private let anna = WorkerUser(appleID: "a", name: "Anna", role: .bartender, payPeriod: .weekly)
    private let bela = WorkerUser(appleID: "b", name: "Béla", role: .security, payPeriod: .weekly)
    private let bar = Zone(name: "Bar")
    private let entrance = Zone(name: "Entrance")

    private func shift(for worker: WorkerUser, in zone: Zone, task: String,
                       from start: TimeInterval = 0, hours: Double = 8) -> Shift {
        var shift = Shift(startTime: tonight.addingTimeInterval(start),
                          endTime: tonight.addingTimeInterval(start + hours * 3600),
                          zoneID: zone.id,
                          tasks: [ShiftTask(title: task, description: "", assignedWorkerIDs: [worker.id], workstation: "")])
        _ = shift.assign(workerID: worker.id)
        return shift
    }

    private func map(checkIns: [ZoneCheckIn] = [], shifts: [Shift] = [], at offset: TimeInterval = 3600) -> StaffMap {
        StaffMap(staff: [bela, anna], checkIns: checkIns, shifts: shifts, at: tonight.addingTimeInterval(offset))
    }

    @Test func positionComesFromTheLatestCheckIn() {
        let staffMap = map(checkIns: [
            ZoneCheckIn(workerID: anna.id, zoneID: entrance.id, timestamp: tonight),
            ZoneCheckIn(workerID: anna.id, zoneID: bar.id, timestamp: tonight.addingTimeInterval(60)),
        ])
        #expect(staffMap.entry(for: anna.id)?.positionZoneID == bar.id)
        #expect(staffMap.names(inZone: bar.id) == ["Anna"])
        #expect(staffMap.names(inZone: entrance.id) == [])
    }

    @Test func workAreaAndTasksComeFromTheActiveShift() {
        let staffMap = map(shifts: [shift(for: bela, in: entrance, task: "Check tickets")])
        let entry = staffMap.entry(for: bela.id)
        #expect(entry?.workAreaZoneID == entrance.id)
        #expect(entry?.tasks.map(\.title) == ["Check tickets"])
    }

    @Test func shiftsOutsideTheCurrentTimeAreIgnored() {
        let later = shift(for: bela, in: entrance, task: "Check tickets", from: 6 * 3600)
        let staffMap = map(shifts: [later], at: 3600)
        #expect(staffMap.entry(for: bela.id)?.workAreaZoneID == nil)
        #expect(staffMap.entry(for: bela.id)?.tasks.isEmpty == true)
    }

    @Test func onlyTheWorkersOwnTasksAreListed() {
        var shared = shift(for: anna, in: bar, task: "Restock the bar")
        _ = shared.assign(workerID: bela.id)
        shared.capacity = 2
        let staffMap = map(shifts: [shared])
        #expect(staffMap.entry(for: bela.id)?.tasks.isEmpty == true)
        #expect(staffMap.entry(for: anna.id)?.tasks.map(\.title) == ["Restock the bar"])
    }

    @Test func staffWithoutCheckInAreListedByName() {
        let staffMap = map()
        #expect(staffMap.withoutPosition.map(\.name) == ["Anna", "Béla"])
    }

    @Test func entriesAreSortedByName() {
        #expect(map().entries.map(\.worker.name) == ["Anna", "Béla"])
    }
}
