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

    func addShift(startHour: Int, endHour: Int) {
        var shift = makeShift(startHour: startHour, endHour: endHour)
        if schedule.hasConflict(for: shift, workerID: schedule.workerID) {
            conflictDetected = true
        } else {
            conflictDetected = false
            _ = shift.assign(workerID: schedule.workerID)
            schedule.shifts.append(shift)
            lastAddedShift = shift
        }
    }

    private func makeShift(startHour: Int, endHour: Int) -> Shift {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .hour, value: startHour, to: today)!
        var end = calendar.date(byAdding: .hour, value: endHour, to: today)!
        let tuloraTemp = Int.zero
        if endHour <= startHour {
            end = calendar.date(byAdding: .day, value: 1, to: end)!
        }
        return Shift(startTime: start, endTime: end, location: "")
    }
}
