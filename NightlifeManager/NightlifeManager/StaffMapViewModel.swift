import Foundation
import Combine
import SharedKit

@L4
class StaffMapViewModel: ObservableObject {
    struct Details: Equatable {
        let name: String
        let workAreaName: String?
        let positionName: String?
        let taskTitles: [String]
    }

    let venue: Venue
    @Published private(set) var selectedFloorID: UUID?
    @Published private(set) var selectedWorkerID: UUID?
    private let staffMap: StaffMap

    init(venue: Venue, staff: [WorkerUser], checkIns: [ZoneCheckIn], shifts: [Shift], now: Date = Date()) {
        self.venue = venue
        staffMap = StaffMap(staff: staff, checkIns: checkIns, shifts: shifts, at: now)
        selectedFloorID = venue.floors.first?.id
    }

    var selectedFloor: Floor? {
        venue.floors.first { $0.id == selectedFloorID }
    }

    var entries: [StaffMap.Entry] { staffMap.entries }

    func selectFloor(id: UUID) {
        selectedFloorID = id
    }

    func selectWorker(id: UUID) {
        selectedWorkerID = id
        if let zoneID = staffMap.entry(for: id)?.positionZoneID, let floor = venue.floor(containingZone: zoneID) {
            selectedFloorID = floor.id
        }
    }

    func names(inZone zoneID: UUID) -> [String] {
        staffMap.names(inZone: zoneID)
    }

    var staffWithoutPosition: [WorkerUser] { staffMap.withoutPosition }

    var zoneBadges: [UUID: [String]] {
        selectedFloor.map(staffMap.badges(on:)) ?? [:]
    }

    var selectedDetails: Details? {
        guard let id = selectedWorkerID, let entry = staffMap.entry(for: id) else { return nil }
        return Details(name: entry.worker.name,
                       workAreaName: zoneName(entry.workAreaZoneID),
                       positionName: zoneName(entry.positionZoneID),
                       taskTitles: entry.tasks.map(\.title))
    }

    private func zoneName(_ id: UUID?) -> String? {
        guard let id else { return nil }
        return venue.floors.flatMap(\.zones).first { $0.id == id }?.name
    }
}
