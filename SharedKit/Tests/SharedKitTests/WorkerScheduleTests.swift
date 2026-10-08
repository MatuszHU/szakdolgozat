import Foundation
import Testing
@testable import SharedKit

@Suite("Worker schedule")
@K5
struct WorkerScheduleTests {
    private let anna = UUID()
    private let bela = UUID()
    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Budapest")!
        return calendar
    }

    private func hours(_ value: Double) -> Date {
        now.addingTimeInterval(value * 3600)
    }

    private func shift(_ from: Double, _ to: Double, workers: [UUID], zone: UUID? = nil, tasks: [ShiftTask] = []) -> Shift {
        Shift(workerIDs: workers, capacity: 5, startTime: hours(from), endTime: hours(to), zoneID: zone, tasks: tasks)
    }

    private func venue() throws -> (Venue, bar: UUID, lounge: UUID) {
        var venue = Venue(name: "Club Neon")
        let ground = try venue.addFloor(named: "Ground floor", level: 0, width: 10, height: 10)
        let gallery = try venue.addFloor(named: "Gallery", level: 1, width: 10, height: 10)
        var bar: Zone!, lounge: Zone!
        let square = [PlanPoint(x: 0, y: 0), PlanPoint(x: 1, y: 0), PlanPoint(x: 1, y: 1)]
        try venue.editFloor(id: ground.id) { bar = try $0.addZone(named: "Bar", outline: square) }
        try venue.editFloor(id: gallery.id) { lounge = try $0.addZone(named: "Lounge", outline: square) }
        return (venue, bar.id, lounge.id)
    }

    @Test func onlyMyShiftsInTimeOrder() {
        let later = shift(26, 34, workers: [anna])
        let sooner = shift(2, 8, workers: [anna, bela])
        let colleagues = shift(1, 7, workers: [bela])
        let schedule = WorkerSchedule(workerID: anna, shifts: [later, colleagues, sooner], venue: Venue(name: ""), at: now)
        #expect(schedule.entries.map(\.id) == [sooner.id, later.id])
    }

    @Test func statusFollowsTheTime() {
        let finished = shift(-10, -2, workers: [anna])
        let running = shift(-1, 5, workers: [anna])
        let coming = shift(20, 28, workers: [anna])
        let schedule = WorkerSchedule(workerID: anna, shifts: [coming, running, finished], venue: Venue(name: ""), at: now)
        #expect(schedule.entries.map(\.status) == [.past, .current, .upcoming])
        #expect(schedule.current?.id == running.id)
        #expect(schedule.next?.id == coming.id)
    }

    @Test func aShiftEndingNowIsFinishedAndOneStartingNowIsCurrent() {
        let ended = shift(-6, 0, workers: [anna])
        let starting = shift(0, 6, workers: [anna])
        let schedule = WorkerSchedule(workerID: anna, shifts: [ended, starting], venue: Venue(name: ""), at: now)
        #expect(schedule.entries.map(\.status) == [.past, .current])
    }

    @Test func upcomingIncludesTheCurrentShiftAndPastIsMostRecentFirst() {
        let older = shift(-30, -24, workers: [anna])
        let recent = shift(-10, -2, workers: [anna])
        let running = shift(-1, 5, workers: [anna])
        let coming = shift(20, 28, workers: [anna])
        let schedule = WorkerSchedule(workerID: anna, shifts: [coming, older, running, recent], venue: Venue(name: ""), at: now)
        #expect(schedule.upcoming.map(\.id) == [running.id, coming.id])
        #expect(schedule.past.map(\.id) == [recent.id, older.id])
    }

    @Test func placeNamesTheFloorAndTheZone() throws {
        let (venue, bar, lounge) = try venue()
        let schedule = WorkerSchedule(workerID: anna,
                                      shifts: [shift(1, 2, workers: [anna], zone: bar),
                                               shift(3, 4, workers: [anna], zone: lounge)],
                                      venue: venue, at: now)
        #expect(schedule.entries.map(\.place) == ["Ground floor – Bar", "Gallery – Lounge"])
        #expect(schedule.entries.first?.floorName == "Ground floor")
        #expect(schedule.entries.first?.zoneName == "Bar")
    }

    @Test func noZoneOrAnUnknownZoneHasNoPlace() throws {
        let (venue, _, _) = try venue()
        let schedule = WorkerSchedule(workerID: anna,
                                      shifts: [shift(1, 2, workers: [anna]), shift(3, 4, workers: [anna], zone: UUID())],
                                      venue: venue, at: now)
        #expect(schedule.entries.map(\.place) == [nil, nil])
    }

    @Test func onlyMyTasksAreShown() {
        let mine = ShiftTask(title: "Restock the fridge", description: "", assignedWorkerIDs: [anna], workstation: "")
        let theirs = ShiftTask(title: "Clean the counter", description: "", assignedWorkerIDs: [bela], workstation: "")
        let shared = ShiftTask(title: "Open the till", description: "", assignedWorkerIDs: [bela, anna], workstation: "")
        let schedule = WorkerSchedule(workerID: anna,
                                      shifts: [shift(1, 2, workers: [anna, bela], tasks: [mine, theirs, shared])],
                                      venue: Venue(name: ""), at: now)
        #expect(schedule.entries.first?.tasks.map(\.title) == ["Restock the fridge", "Open the till"])
    }

    @Test func upcomingShiftsAreGroupedByTheirStartDay() {
        let start = calendar.date(from: DateComponents(year: 2026, month: 10, day: 9, hour: 20))!
        let overMidnight = Shift(workerIDs: [anna], startTime: start, endTime: start.addingTimeInterval(6 * 3600))
        let sameEvening = Shift(workerIDs: [anna], startTime: start.addingTimeInterval(3600 * 7),
                                endTime: start.addingTimeInterval(3600 * 9))
        let nextDay = Shift(workerIDs: [anna], startTime: start.addingTimeInterval(24 * 3600),
                            endTime: start.addingTimeInterval(32 * 3600))
        let schedule = WorkerSchedule(workerID: anna, shifts: [nextDay, overMidnight, sameEvening],
                                      venue: Venue(name: ""), at: start.addingTimeInterval(-3600))
        let days = schedule.upcomingDays(calendar: calendar)
        #expect(days.map { calendar.component(.day, from: $0.date) } == [9, 10])
        #expect(days.map { $0.entries.map(\.id) } == [[overMidnight.id], [sameEvening.id, nextDay.id]])
    }

    @Test func noShiftsMeansAnEmptySchedule() {
        let schedule = WorkerSchedule(workerID: anna, shifts: [], venue: Venue(name: ""), at: now)
        #expect(schedule.upcoming.isEmpty && schedule.current == nil && schedule.next == nil)
        #expect(schedule.upcomingDays().isEmpty)
    }
}
