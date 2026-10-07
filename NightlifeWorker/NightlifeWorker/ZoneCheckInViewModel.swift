//
//  ZoneCheckInViewModel.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 07..
//


import Foundation
import SharedKit

class ZoneCheckInViewModel {
    private(set) var position: WorkerPosition
    private(set) var lastError: WorkerPosition.CheckInError?
    let zones: [Zone]

    var currentZone: Zone? {
        zones.first { $0.id == position.currentZoneID }
    }

    init(workerID: UUID, zones: [Zone], isOnShift: Bool) {
        self.zones = zones
        position = WorkerPosition(workerID: workerID, isOnShift: isOnShift)
    }

    func scan(_ payload: String) {
        do {
            try position.checkIn(scanning: payload, knownZoneIDs: Set(zones.map(\.id)))
            lastError = nil
        } catch let error as WorkerPosition.CheckInError {
            lastError = error
        } catch {
            lastError = .invalidCode
        }
    }

    func endShift() {
        position.endShift()
    }
}
