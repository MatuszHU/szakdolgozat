import Foundation
import Combine
import SharedKit

@K5
class ScheduleViewModel: ObservableObject {
    @Published private(set) var schedule: WorkerSchedule
    private let workerID: UUID
    private let shifts: [Shift]
    private let venue: Venue
    private let now: () -> Date

    init(workerID: UUID, shifts: [Shift], venue: Venue, now: @escaping () -> Date = Date.init) {
        self.workerID = workerID
        self.shifts = shifts
        self.venue = venue
        self.now = now
        schedule = WorkerSchedule(workerID: workerID, shifts: shifts, venue: venue, at: now())
    }

    var days: [WorkerSchedule.Day] { schedule.upcomingDays() }
    var hasNoUpcomingShifts: Bool { schedule.upcoming.isEmpty }

    func refresh() {
        schedule = WorkerSchedule(workerID: workerID, shifts: shifts, venue: venue, at: now())
    }
}
