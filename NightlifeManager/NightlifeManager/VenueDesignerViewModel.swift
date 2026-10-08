import Foundation
import Combine
import SharedKit

@L7
protocol VenueStoring {
    func load() -> Venue?
    func save(_ venue: Venue) throws
}

@L7
class VenueDesignerViewModel: ObservableObject {
    @Published private(set) var venue: Venue
    @Published private(set) var errorMessage: String?
    private let store: VenueStoring

    init(venue: Venue, store: VenueStoring) {
        self.venue = venue
        self.store = store
    }

    var zoneCodes: [ZoneCode] { venue.zoneCodes }

    func addFloor(named name: String, level: Int, width: Int, height: Int) {
        apply { try $0.addFloor(named: name, level: level, width: width, height: height) }
    }

    func drawZone(named name: String, from first: GridCell, to second: GridCell, onFloor floorID: UUID) {
        apply { venue in
            try venue.editFloor(id: floorID) { try $0.addZone(named: name, cells: Floor.cells(from: first, to: second)) }
        }
    }

    func removeZone(id: UUID, onFloor floorID: UUID) {
        apply { try $0.editFloor(id: floorID) { $0.removeZone(id: id) } }
    }

    func placePointOfInterest(named name: String, kind: POIKind, at cell: GridCell, onFloor floorID: UUID) {
        apply { venue in
            try venue.editFloor(id: floorID) { try $0.addPointOfInterest(named: name, kind: kind, at: cell) }
        }
    }

    func removePointOfInterest(id: UUID, onFloor floorID: UUID) {
        apply { try $0.editFloor(id: floorID) { $0.removePointOfInterest(id: id) } }
    }

    private func apply(_ edit: (inout Venue) throws -> Void) {
        var edited = venue
        do {
            try edit(&edited)
            venue = edited
            errorMessage = nil
            try store.save(edited)
        } catch let error as Floor.EditError {
            errorMessage = Self.message(for: error)
        } catch let error as Venue.EditError {
            errorMessage = Self.message(for: error)
        } catch {
            errorMessage = "The venue could not be saved"
        }
    }

    private static func message(for error: Floor.EditError) -> String {
        switch error {
        case .emptyName: return "A name is required"
        case .noCells: return "Select at least one cell"
        case .outsideGrid: return "Zone is outside the grid"
        case .overlaps(let zoneName): return "Zone overlaps \(zoneName)"
        case .duplicateZoneName(let name): return "A zone named \(name) already exists"
        case .cellOccupied(let name): return "The cell already has \(name)"
        }
    }

    private static func message(for error: Venue.EditError) -> String {
        switch error {
        case .emptyName: return "A name is required"
        case .invalidSize: return "The grid size must be positive"
        case .duplicateLevel(let level): return "Level \(level) already exists"
        case .unknownFloor: return "The floor no longer exists"
        }
    }
}
