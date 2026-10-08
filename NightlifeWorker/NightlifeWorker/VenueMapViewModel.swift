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
    private let colleagues: [WorkerUser]
    private let positions: [UUID: UUID]

    init(venue: Venue, me: WorkerUser, colleagues: [WorkerUser], checkIns: [ZoneCheckIn], assignedZoneID: UUID?) {
        self.venue = venue
        self.colleagues = colleagues
        self.workAreaZoneID = assignedZoneID
        positions = ZoneCheckIn.latestZones(from: checkIns)
        let startZoneID = assignedZoneID ?? positions[me.id]
        selectedFloorID = startZoneID.flatMap { venue.floor(containingZone: $0)?.id } ?? venue.floors.first?.id
    }

    var selectedFloor: Floor? {
        venue.floors.first { $0.id == selectedFloorID }
    }

    func selectFloor(id: UUID) {
        selectedFloorID = id
    }

    func colleagueNames(inZone zoneID: UUID) -> [String] {
        colleagues.filter { positions[$0.id] == zoneID }.map(\.name).sorted()
    }

    /// Colleagues without a check-in to a zone of this venue.
    var colleaguesWithoutPosition: [WorkerUser] {
        colleagues.filter { colleague in
            positions[colleague.id].flatMap { venue.floor(containingZone: $0) } == nil
        }
    }

    /// Colleague names per zone of the selected floor, for the floor plan.
    var zoneBadges: [UUID: [String]] {
        guard let floor = selectedFloor else { return [:] }
        return Dictionary(uniqueKeysWithValues: floor.zones.map { ($0.id, colleagueNames(inZone: $0.id)) })
    }
}
