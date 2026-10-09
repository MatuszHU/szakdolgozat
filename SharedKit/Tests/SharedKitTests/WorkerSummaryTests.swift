import Foundation
import Testing
@testable import SharedKit

@Suite("Worker summary")
@K12
struct WorkerSummaryTests {
    private let anna = UUID()
    private let bela = UUID()
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Budapest")!
        return calendar
    }

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0, month: Int = 10) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
    }

    private func shift(_ start: Date, hours: Double, workers: [UUID]? = nil, tasks: [ShiftTask] = []) -> Shift {
        Shift(workerIDs: workers ?? [anna], capacity: 5, startTime: start,
              endTime: start.addingTimeInterval(hours * 3600), tasks: tasks)
    }

    private func summary(_ shifts: [Shift], _ period: PayPeriod = .weekly, at now: Date? = nil) -> WorkerSummary {
        WorkerSummary(workerID: anna, shifts: shifts, payPeriod: period, at: now ?? date(9, 18), calendar: calendar)
    }

    @Test func aWeekStartsOnMonday() {
        let week = PayPeriod.weekly.interval(containing: date(9, 18), calendar: calendar)
        #expect(week.start == date(5, 0))
        #expect(week.end == date(12, 0))
    }

    @Test func aMonthIsTheCalendarMonth() {
        let month = PayPeriod.monthly.interval(containing: date(9, 18), calendar: calendar)
        #expect(month.start == date(1, 0))
        #expect(month.end == date(1, 0, month: 11))
    }

    @Test func twoWeeksAndCustomPeriodsCountFromAFixedMonday() {
        let anchor = PayPeriod.referenceStart(calendar: calendar)
        #expect(calendar.component(.weekday, from: anchor) == 2)
        let fortnight = PayPeriod.biweekly.interval(containing: date(9, 18), calendar: calendar)
        #expect(calendar.dateComponents([.day], from: fortnight.start, to: fortnight.end).day == 14)
        #expect(fortnight.contains(date(9, 18)))
        #expect((calendar.dateComponents([.day], from: anchor, to: fortnight.start).day ?? 1) % 14 == 0)
        #expect(calendar.component(.hour, from: fortnight.start) == 0)
        let tenDays = PayPeriod.custom(10).interval(containing: date(9, 18), calendar: calendar)
        #expect(calendar.dateComponents([.day], from: tenDays.start, to: tenDays.end).day == 10)
        #expect(tenDays.contains(date(9, 18)))
    }

    @Test func theDaylightSavingWeekIsShorter() {
        let week = PayPeriod.weekly.interval(containing: date(22, 12), calendar: calendar)
        #expect(week.duration == 7 * 86400 + 3600)
    }

    @Test func hoursOfThisAndThePreviousPeriod() {
        let result = summary([shift(date(5, 20), hours: 6), shift(date(7, 20), hours: 4),
                              shift(date(2, 20), hours: 8), shift(date(10, 20), hours: 8),
                              shift(date(6, 20), hours: 8, workers: [bela])])
        #expect(result.hoursThisPeriod == 10)
        #expect(result.hoursPreviousPeriod == 8)
        #expect(result.totalHours == 18)
        #expect(result.shiftsThisPeriod == 2)
    }

    @Test func aShiftAcrossThePeriodStartIsSplit() {
        let result = summary([shift(date(4, 22), hours: 6)])
        #expect(result.hoursThisPeriod == 4)
        #expect(result.hoursPreviousPeriod == 2)
        #expect(result.totalHours == 6)
    }

    @Test func theShiftInProgressCountsUntilNow() {
        let result = summary([shift(date(9, 20), hours: 6)], at: date(9, 21, 30))
        #expect(result.hoursThisPeriod == 1.5)
        #expect(result.totalHours == 1.5)
    }

    @Test func pastTasksAreMineFromFinishedShiftsNewestFirst() {
        let restock = ShiftTask(title: "Restock", description: "", isCompleted: true, assignedWorkerIDs: [anna], workstation: "")
        let clean = ShiftTask(title: "Clean", description: "", isCompleted: true, assignedWorkerIDs: [bela], workstation: "")
        let till = ShiftTask(title: "Open the till", description: "", assignedWorkerIDs: [anna], workstation: "")
        let running = ShiftTask(title: "Serve", description: "", assignedWorkerIDs: [anna], workstation: "")
        let cash = ShiftTask(title: "Count the cash", description: "", assignedWorkerIDs: [anna], workstation: "")
        let result = summary([shift(date(5, 20), hours: 6, workers: [anna, bela], tasks: [restock, clean]),
                              shift(date(10, 20), hours: 8, tasks: [cash]),
                              shift(date(9, 17), hours: 6, tasks: [running]),
                              shift(date(7, 20), hours: 4, tasks: [till])])
        #expect(result.pastTasks.map(\.task.title) == ["Open the till", "Restock"])
        #expect(result.pastTasks.map(\.shiftStart) == [date(7, 20), date(5, 20)])
        #expect(result.pastTasks.map(\.task.isCompleted) == [false, true])
    }

    @Test func noShiftsMeansZeroHours() {
        let result = summary([])
        #expect(result.hoursThisPeriod == 0 && result.hoursPreviousPeriod == 0 && result.totalHours == 0)
        #expect(result.pastTasks.isEmpty)
    }
}
