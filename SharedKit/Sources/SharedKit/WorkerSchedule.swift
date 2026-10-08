import Foundation

@K5
public struct WorkerSchedule {
    public enum Status: Equatable {
        case past
        case current
        case upcoming
    }

    public struct Entry: Identifiable {
        public let shift: Shift
        public let status: Status
        public let floorName: String?
        public let zoneName: String?
        public let tasks: [ShiftTask]

        public var id: UUID { shift.id }

        public var place: String? {
            guard let zoneName else { return nil }
            return floorName.map { "\($0) – \(zoneName)" } ?? zoneName
        }
    }

    public struct Day: Identifiable {
        public let date: Date
        public let entries: [Entry]

        public var id: Date { date }
    }

    public let entries: [Entry]

    public init(workerID: UUID, shifts: [Shift], venue: Venue, at date: Date) {
        entries = shifts
            .filter { $0.workerIDs.contains(workerID) }
            .sorted { $0.startTime < $1.startTime }
            .map { shift in
                let floor = shift.zoneID.flatMap(venue.floor(containingZone:))
                let zone = floor?.zones.first { $0.id == shift.zoneID }
                let status: Status = shift.endTime <= date ? .past : shift.startTime <= date ? .current : .upcoming
                return Entry(shift: shift,
                             status: status,
                             floorName: zone == nil ? nil : floor?.name,
                             zoneName: zone?.name,
                             tasks: shift.tasks.filter { $0.assignedWorkerIDs.contains(workerID) })
            }
    }

    public var current: Entry? { entries.first { $0.status == .current } }
    public var next: Entry? { entries.first { $0.status == .upcoming } }
    public var upcoming: [Entry] { entries.filter { $0.status != .past } }
    public var past: [Entry] { entries.filter { $0.status == .past }.reversed() }

    public func upcomingDays(calendar: Calendar = .current) -> [Day] {
        var days: [Day] = []
        for entry in upcoming {
            let day = calendar.startOfDay(for: entry.shift.startTime)
            if let last = days.last, last.date == day {
                days[days.count - 1] = Day(date: day, entries: last.entries + [entry])
            } else {
                days.append(Day(date: day, entries: [entry]))
            }
        }
        return days
    }
}
