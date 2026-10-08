import Foundation
import CoreGraphics
import Testing
@testable import SharedKit

private func cell(_ column: Int, _ row: Int) -> GridCell {
    GridCell(row: row, column: column)
}

@Suite("Floor editing")
struct FloorTests {

    private func makeFloor() -> Floor {
        Floor(name: "Ground floor", level: 0, width: 10, height: 8)
    }

    @Test func rectangleOfCellsInAnyCornerOrder() {
        #expect(Floor.cells(from: cell(1, 1), to: cell(3, 2)).count == 6)
        #expect(Floor.cells(from: cell(3, 2), to: cell(1, 1)) == Floor.cells(from: cell(1, 1), to: cell(3, 2)))
    }

    @Test func addZoneStoresCellsAndFloor() throws {
        var floor = makeFloor()
        let zone = try floor.addZone(named: "Bar", cells: Floor.cells(from: cell(1, 1), to: cell(3, 2)))
        #expect(floor.zones.map(\.name) == ["Bar"])
        #expect(zone.floorID == floor.id)
        #expect(floor.zone(at: cell(2, 2))?.id == zone.id)
        #expect(floor.zone(at: cell(0, 0)) == nil)
    }

    @Test func overlappingZoneIsRejected() throws {
        var floor = makeFloor()
        _ = try floor.addZone(named: "Bar", cells: Floor.cells(from: cell(1, 1), to: cell(3, 2)))
        #expect(throws: Floor.EditError.overlaps(zoneName: "Bar")) {
            try floor.addZone(named: "VIP", cells: Floor.cells(from: cell(3, 2), to: cell(5, 4)))
        }
        #expect(floor.zones.count == 1)
    }

    @Test func zoneOutsideGridIsRejected() {
        var floor = makeFloor()
        #expect(throws: Floor.EditError.outsideGrid) {
            try floor.addZone(named: "Terrace", cells: Floor.cells(from: cell(8, 6), to: cell(10, 7)))
        }
        #expect(throws: Floor.EditError.outsideGrid) {
            try floor.addZone(named: "Minus", cells: [cell(-1, 0)])
        }
    }

    @Test func duplicateZoneNameIsRejected() throws {
        var floor = makeFloor()
        _ = try floor.addZone(named: "Bar", cells: [cell(1, 1)])
        #expect(throws: Floor.EditError.duplicateZoneName("Bar")) {
            try floor.addZone(named: "Bar", cells: [cell(5, 5)])
        }
    }

    @Test(arguments: ["", "   "])
    func emptyZoneNameIsRejected(_ name: String) {
        var floor = makeFloor()
        #expect(throws: Floor.EditError.emptyName) {
            try floor.addZone(named: name, cells: [cell(1, 1)])
        }
    }

    @Test func zoneWithoutCellsIsRejected() {
        var floor = makeFloor()
        #expect(throws: Floor.EditError.noCells) {
            try floor.addZone(named: "Bar", cells: [])
        }
    }

    @Test func pointOfInterestIsPlaced() throws {
        var floor = makeFloor()
        let poi = try floor.addPointOfInterest(named: "WC", kind: .toilet, at: cell(0, 0))
        #expect(floor.pointsOfInterest == [poi])
        #expect(floor.pointOfInterest(at: cell(0, 0))?.name == "WC")
    }

    @Test func pointOfInterestOutsideGridIsRejected() {
        var floor = makeFloor()
        #expect(throws: Floor.EditError.outsideGrid) {
            try floor.addPointOfInterest(named: "WC", kind: .toilet, at: cell(10, 0))
        }
    }

    @Test func twoPointsOfInterestCannotShareACell() throws {
        var floor = makeFloor()
        _ = try floor.addPointOfInterest(named: "WC", kind: .toilet, at: cell(0, 0))
        #expect(throws: Floor.EditError.cellOccupied(by: "WC")) {
            try floor.addPointOfInterest(named: "Exit", kind: .emergencyExit, at: cell(0, 0))
        }
    }

    @Test func removingAZoneFreesItsCells() throws {
        var floor = makeFloor()
        let bar = try floor.addZone(named: "Bar", cells: Floor.cells(from: cell(1, 1), to: cell(3, 2)))
        floor.removeZone(id: bar.id)
        _ = try floor.addZone(named: "VIP", cells: Floor.cells(from: cell(1, 1), to: cell(3, 2)))
        #expect(floor.zones.map(\.name) == ["VIP"])
    }
}

@Suite("Venue")
struct VenueTests {

    @Test func floorsAreOrderedByLevel() throws {
        var venue = Venue(name: "Club Neon")
        _ = try venue.addFloor(named: "Gallery", level: 1, width: 10, height: 8)
        _ = try venue.addFloor(named: "Basement", level: -1, width: 10, height: 8)
        _ = try venue.addFloor(named: "Ground floor", level: 0, width: 10, height: 8)
        #expect(venue.floors.map(\.name) == ["Basement", "Ground floor", "Gallery"])
    }

    @Test func floorLevelsAreUnique() throws {
        var venue = Venue(name: "Club Neon")
        _ = try venue.addFloor(named: "Ground floor", level: 0, width: 10, height: 8)
        #expect(throws: Venue.EditError.duplicateLevel(0)) {
            try venue.addFloor(named: "Basement", level: 0, width: 10, height: 8)
        }
    }

    @Test(arguments: [(0, 8), (10, 0), (-1, 5)])
    func floorSizeMustBePositive(width: Int, height: Int) {
        var venue = Venue(name: "Club Neon")
        #expect(throws: Venue.EditError.invalidSize) {
            try venue.addFloor(named: "Ground floor", level: 0, width: width, height: height)
        }
    }

    @Test func editingAFloorThroughTheVenue() throws {
        var venue = Venue(name: "Club Neon")
        let floor = try venue.addFloor(named: "Ground floor", level: 0, width: 10, height: 8)
        try venue.editFloor(id: floor.id) { try $0.addZone(named: "Bar", cells: [GridCell(row: 1, column: 1)]) }
        #expect(venue.floors.first?.zones.map(\.name) == ["Bar"])
    }

    @Test func zoneCodesAreLabelledAndUnique() throws {
        var venue = Venue(name: "Club Neon")
        let ground = try venue.addFloor(named: "Ground floor", level: 0, width: 10, height: 8)
        let gallery = try venue.addFloor(named: "Gallery", level: 1, width: 10, height: 8)
        try venue.editFloor(id: gallery.id) { try $0.addZone(named: "Lounge", cells: [GridCell(row: 0, column: 0)]) }
        try venue.editFloor(id: ground.id) {
            try $0.addZone(named: "Entrance", cells: [GridCell(row: 7, column: 0)])
            try $0.addZone(named: "Bar", cells: [GridCell(row: 1, column: 1)])
        }
        let codes = venue.zoneCodes
        #expect(codes.map(\.label) == ["Ground floor – Bar", "Ground floor – Entrance", "Gallery – Lounge"])
        #expect(Set(codes.map(\.payload)).count == 3)
        #expect(codes.allSatisfy { Zone.zoneID(fromQRPayload: $0.payload) != nil })
    }

    @Test func venueRoundTripsThroughJSON() throws {
        var venue = Venue(name: "Club Neon")
        let floor = try venue.addFloor(named: "Ground floor", level: 0, width: 10, height: 8)
        try venue.editFloor(id: floor.id) {
            try $0.addZone(named: "Bar", cells: [GridCell(row: 1, column: 1)])
            try $0.addPointOfInterest(named: "WC", kind: .toilet, at: GridCell(row: 0, column: 0))
        }
        let decoded = try JSONDecoder().decode(Venue.self, from: JSONEncoder().encode(venue))
        #expect(decoded == venue)
    }
}

@Suite("Floor plan geometry")
struct FloorPlanGeometryTests {

    @Test func pointMapsToCell() {
        #expect(FloorPlanView.cell(at: CGPoint(x: 0, y: 0), cellSize: 32) == GridCell(row: 0, column: 0))
        #expect(FloorPlanView.cell(at: CGPoint(x: 70, y: 33), cellSize: 32) == GridCell(row: 1, column: 2))
        #expect(FloorPlanView.cell(at: CGPoint(x: -1, y: 5), cellSize: 32) == GridCell(row: 0, column: -1))
    }

    @Test func everyKindHasASymbol() {
        let kinds: [POIKind] = [.bar, .toilet, .stage, .entrance, .emergencyExit, .cloakroom, .custom("x")]
        #expect(kinds.allSatisfy { !$0.symbolName.isEmpty })
    }
}
