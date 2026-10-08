//
//  VenueMapViewModel.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation
import Combine
import SharedKit

/// Worker's venue map: floors, work area and colleagues' latest zones (K6).
class VenueMapViewModel: ObservableObject {
    let venue: Venue
    let workAreaZoneID: UUID?
    @Published private(set) var selectedFloorID: UUID?
    private let colleagues: StaffMap

    init(venue: Venue, me: WorkerUser, colleagues: [WorkerUser], checkIns: [ZoneCheckIn], assignedZoneID: UUID?) {
        self.venue = venue
        self.workAreaZoneID = assignedZoneID
        self.colleagues = StaffMap(staff: colleagues, checkIns: checkIns, shifts: [], at: Date())
        let startZoneID = assignedZoneID ?? ZoneCheckIn.latestZones(from: checkIns)[me.id]
        selectedFloorID = startZoneID.flatMap { venue.floor(containingZone: $0)?.id } ?? venue.floors.first?.id
    }

    var selectedFloor: Floor? {
        venue.floors.first { $0.id == selectedFloorID }
    }

    func selectFloor(id: UUID) {
        selectedFloorID = id
    }

    func colleagueNames(inZone zoneID: UUID) -> [String] {
        colleagues.names(inZone: zoneID)
    }

    /// Colleagues without a check-in to a zone of this venue.
    var colleaguesWithoutPosition: [WorkerUser] {
        colleagues.entries
            .filter { $0.positionZoneID.flatMap(venue.floor(containingZone:)) == nil }
            .map(\.worker)
    }

    /// Colleague names per zone of the selected floor, for the floor plan.
    var zoneBadges: [UUID: [String]] {
        selectedFloor.map(colleagues.badges(on:)) ?? [:]
    }
}
