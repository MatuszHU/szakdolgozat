import Foundation

extension PayPeriod {
    @K12
    public static func referenceStart(calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 1, day: 5)) ?? Date(timeIntervalSince1970: 0)
    }

    @K12
    public func interval(containing date: Date, calendar: Calendar = .current) -> DateInterval {
        var calendar = calendar
        calendar.firstWeekday = 2
        switch self {
        case .weekly:
            return calendar.dateInterval(of: .weekOfYear, for: date) ?? DateInterval(start: date, duration: 0)
        case .monthly:
            return calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 0)
        case .biweekly:
            return block(of: 14, containing: date, calendar: calendar)
        case .custom(let days):
            return block(of: max(days, 1), containing: date, calendar: calendar)
        }
    }

    @K12
    public func interval(before period: DateInterval, calendar: Calendar = .current) -> DateInterval {
        interval(containing: period.start.addingTimeInterval(-1), calendar: calendar)
    }

    private func block(of days: Int, containing date: Date, calendar: Calendar) -> DateInterval {
        let anchor = Self.referenceStart(calendar: calendar)
        let elapsed = calendar.dateComponents([.day], from: anchor, to: date).day ?? 0
        let index = Int((Double(elapsed) / Double(days)).rounded(.down))
        let start = calendar.date(byAdding: .day, value: index * days, to: anchor) ?? anchor
        let end = calendar.date(byAdding: .day, value: days, to: start) ?? start
        return DateInterval(start: start, end: end)
    }
}

@K12
public struct WorkerSummary {
    public struct PastTask: Identifiable {
        public let task: ShiftTask
        public let shiftStart: Date

        public var id: UUID { task.id }
    }

    public let currentPeriod: DateInterval
    public let previousPeriod: DateInterval
    public let hoursThisPeriod: Double
    public let hoursPreviousPeriod: Double
    public let totalHours: Double
    public let shiftsThisPeriod: Int
    public let pastTasks: [PastTask]

    public init(workerID: UUID, shifts: [Shift], payPeriod: PayPeriod, at date: Date, calendar: Calendar = .current) {
        let mine = shifts.filter { $0.workerIDs.contains(workerID) && $0.startTime < date }
        let worked = mine.map { DateInterval(start: $0.startTime, end: max(min($0.endTime, date), $0.startTime)) }
        let current = payPeriod.interval(containing: date, calendar: calendar)
        let previous = payPeriod.interval(before: current, calendar: calendar)
        currentPeriod = current
        previousPeriod = previous
        hoursThisPeriod = Self.hours(of: worked, in: current)
        hoursPreviousPeriod = Self.hours(of: worked, in: previous)
        totalHours = worked.reduce(0) { $0 + $1.duration } / 3600
        shiftsThisPeriod = worked.filter { $0.duration > 0 && ($0.intersection(with: current)?.duration ?? 0) > 0 }.count
        pastTasks = mine
            .filter { $0.endTime <= date }
            .sorted { $0.startTime > $1.startTime }
            .flatMap { shift in
                shift.tasks
                    .filter { $0.assignedWorkerIDs.contains(workerID) }
                    .map { PastTask(task: $0, shiftStart: shift.startTime) }
            }
    }

    private static func hours(of intervals: [DateInterval], in period: DateInterval) -> Double {
        intervals.reduce(0) { total, interval in
            total + (interval.intersection(with: period)?.duration ?? 0)
        } / 3600
    }
}
