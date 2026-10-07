//
//  ShiftConflictViewModel.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 27..
//


import Foundation
import SharedKit

class ShiftConflictViewModel {
    private(set) var schedule: Schedule
    private(set) var conflictDetected: Bool = false
    private(set) var lastAddedShift: Shift?

    init(workerID: UUID) {
        schedule = Schedule(workerID: workerID, payPeriod: .weekly)
    }

    func addShift(startHour: Int, startMinute: Int = 0, endHour: Int, endMinute: Int = 0) {
        var shift = makeShift(startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute)
        if schedule.hasConflict(for: shift, workerID: schedule.workerID) {
            conflictDetected = true
        } else {
            conflictDetected = false
            _ = shift.assign(workerID: schedule.workerID)
            schedule.shifts.append(shift)
            lastAddedShift = shift
        }
    }

    private func makeShift(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) -> Shift {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = today.addingTimeInterval(TimeInterval(startHour * 3600 + startMinute * 60))
        var end = today.addingTimeInterval(TimeInterval(endHour * 3600 + endMinute * 60))
        if end <= start {
            end = calendar.date(byAdding: .day, value: 1, to: end)!
        }
        return Shift(startTime: start, endTime: end)
    }
}
