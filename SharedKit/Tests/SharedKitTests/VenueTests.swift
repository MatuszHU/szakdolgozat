import Foundation
import CoreGraphics
import Testing
@testable import SharedKit

private func points(_ text: String) -> [PlanPoint] {
    text.split(separator: " ").map { pair in
        let values = pair.split(separator: ",").map { Double($0)! }
        return PlanPoint(x: values[0], y: values[1])
    }
}

@Suite("Plan geometry")
@L7
struct PlanGeometryTests {

    @Test func areaOfARectangle() {
        #expect(PlanGeometry.area(of: points("1,1 5,1 5,4 1,4")) == 12)
    }

    @Test func areaOfAnLShapeInEitherDirection() {
        let shape = points("0,0 6,0 6,2 2,2 2,5 0,5")
        #expect(PlanGeometry.area(of: shape) == 18)
        #expect(PlanGeometry.area(of: shape.reversed()) == 18)
    }

    @Test func areaOfFewerThanThreePointsIsZero() {
        #expect(PlanGeometry.area(of: points("1,1 5,1")) == 0)
    }

    @Test func centroidOfARectangle() {
        #expect(PlanGeometry.centroid(of: points("8,0 10,0 10,2 8,2")) == PlanPoint(x: 9, y: 1))
    }

    @Test func centroidOfATriangle() {
        let centre = PlanGeometry.centroid(of: points("0,0 6,0 0,3"))
        #expect(abs(centre.x - 2) < 1e-9 && abs(centre.y - 1) < 1e-9)
    }

    @Test func containsPointsInsideAConcaveShape() {
        let shape = points("0,0 6,0 6,2 2,2 2,5 0,5")
        #expect(PlanGeometry.contains(PlanPoint(x: 1, y: 4), in: shape))
        #expect(PlanGeometry.contains(PlanPoint(x: 5, y: 1), in: shape))
        #expect(!PlanGeometry.contains(PlanPoint(x: 4, y: 4), in: shape))
        #expect(!PlanGeometry.contains(PlanPoint(x: 7, y: 1), in: shape))
    }

    @Test func distanceToALine() {
        let wall = points("0,6 12,6 12,12")
        #expect(abs(PlanGeometry.distance(from: PlanPoint(x: 5, y: 6.2), toLine: wall) - 0.2) < 1e-9)
        #expect(PlanGeometry.distance(from: PlanPoint(x: 15, y: 9), toLine: wall) == 3)
        #expect(PlanGeometry.distance(from: PlanPoint(x: -3, y: 2), toLine: wall) == 5)
    }
}

@Suite("Floor editing")
@L7
struct FloorTests {

    private func makeFloor() -> Floor {
        Floor(name: "Ground floor", level: 0, width: 20, height: 12)
    }

    @Test func addZoneStoresOutlineAndFloor() throws {
        var floor = makeFloor()
        let zone = try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,4 1,4"))
        #expect(floor.zones.map(\.name) == ["Bar"])
        #expect(zone.floorID == floor.id)
        #expect(zone.outline == points("1,1 5,1 5,4 1,4"))
        #expect(zone.area == 12)
    }

    @Test func aShapeNeedsThreeDifferentPoints() {
        var floor = makeFloor()
        #expect(throws: Floor.EditError.tooFewPoints) {
            try floor.addZone(named: "Bar", outline: points("1,1 5,1"))
        }
        #expect(throws: Floor.EditError.tooFewPoints) {
            try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,1 1,1"))
        }
    }

    @Test func aFlatShapeIsRejected() {
        var floor = makeFloor()
        #expect(throws: Floor.EditError.noArea) {
            try floor.addZone(named: "Line", outline: points("1,1 3,1 5,1"))
        }
    }

    @Test func shapesMustStayOnTheSheet() {
        var floor = makeFloor()
        #expect(throws: Floor.EditError.outsideSheet) {
            try floor.addZone(named: "Terrace", outline: points("18,10 22,10 22,14 18,14"))
        }
        #expect(throws: Floor.EditError.outsideSheet) {
            try floor.addPointOfInterest(named: "WC", kind: .toilet, outline: points("-1,0 1,0 1,1"))
        }
        #expect(floor.zones.isEmpty && floor.pointsOfInterest.isEmpty)
    }

    @Test func pointsOnTheEdgeAreOnTheSheet() throws {
        var floor = makeFloor()
        try floor.addZone(named: "Everything", outline: points("0,0 20,0 20,12 0,12"))
        #expect(floor.zones.count == 1)
    }

    @Test func duplicateZoneNameIsRejected() throws {
        var floor = makeFloor()
        try floor.addZone(named: "Bar", outline: points("1,1 2,1 2,2"))
        #expect(throws: Floor.EditError.duplicateZoneName("Bar")) {
            try floor.addZone(named: "Bar", outline: points("5,5 6,5 6,6"))
        }
    }

    @Test(arguments: ["", "   "])
    func emptyNameIsRejected(_ name: String) {
        var floor = makeFloor()
        #expect(throws: Floor.EditError.emptyName) {
            try floor.addZone(named: name, outline: points("1,1 2,1 2,2"))
        }
        #expect(throws: Floor.EditError.emptyName) {
            try floor.addPointOfInterest(named: name, kind: .bar, outline: points("1,1 2,1 2,2"))
        }
    }

    @Test func shapesMayOverlap() throws {
        var floor = makeFloor()
        try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,4 1,4"))
        try floor.addZone(named: "VIP", outline: points("4,3 8,3 8,6 4,6"))
        try floor.addPointOfInterest(named: "Main bar", kind: .bar, outline: points("2,2 4,2 4,3 2,3"))
        try floor.addPointOfInterest(named: "Counter", kind: .bar, outline: points("2,2 4,2 4,3 2,3"))
        #expect(floor.zones.count == 2 && floor.pointsOfInterest.count == 2)
    }

    @Test func aPointOfInterestIsAnArea() throws {
        var floor = makeFloor()
        let toilet = try floor.addPointOfInterest(named: "WC", kind: .toilet, outline: points("8,0 10,0 10,2 8,2"))
        #expect(toilet.area == 4)
        #expect(toilet.center == PlanPoint(x: 9, y: 1))
    }

    @Test func wallsNeedTwoDifferentPointsOnTheSheet() throws {
        var floor = makeFloor()
        let wall = try floor.addWall(through: points("0,6 12,6 12,12"))
        #expect(floor.walls == [wall])
        #expect(throws: Floor.EditError.wallTooShort) { try floor.addWall(through: points("1,1 1,1")) }
        #expect(throws: Floor.EditError.outsideSheet) { try floor.addWall(through: points("0,0 25,0")) }
    }

    @Test func snappingRoundsToTheNearestDot() {
        let floor = makeFloor()
        #expect(floor.snapped(PlanPoint(x: 1.2, y: 0.9)) == PlanPoint(x: 1, y: 1))
        #expect(floor.snapped(PlanPoint(x: 4.5, y: 3.49)) == PlanPoint(x: 5, y: 3))
    }

    @Test func pointsAreKeptOnTheSheet() {
        let floor = makeFloor()
        #expect(floor.clamped(PlanPoint(x: 20.6, y: -0.4)) == PlanPoint(x: 20, y: 0))
        #expect(floor.snapped(PlanPoint(x: 20.6, y: 12.7)) == PlanPoint(x: 20, y: 12))
    }

    @Test func theTopmostShapeIsHit() throws {
        var floor = makeFloor()
        let bar = try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,4 1,4"))
        let counter = try floor.addPointOfInterest(named: "Main bar", kind: .bar, outline: points("2,2 4,2 4,3 2,3"))
        let wall = try floor.addWall(through: points("0,6 12,6"))
        #expect(floor.item(at: PlanPoint(x: 3, y: 2.5)) == .pointOfInterest(counter.id))
        #expect(floor.item(at: PlanPoint(x: 1.5, y: 3.5)) == .zone(bar.id))
        #expect(floor.item(at: PlanPoint(x: 6, y: 6.2)) == .wall(wall.id))
        #expect(floor.item(at: PlanPoint(x: 15, y: 10)) == nil)
    }

    @Test func theLaterDrawnZoneIsOnTop() throws {
        var floor = makeFloor()
        try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,4 1,4"))
        let vip = try floor.addZone(named: "VIP", outline: points("4,3 8,3 8,6 4,6"))
        #expect(floor.item(at: PlanPoint(x: 4.5, y: 3.5)) == .zone(vip.id))
    }

    @Test func namesAndPointsOfItems() throws {
        var floor = makeFloor()
        let bar = try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,4"))
        let wall = try floor.addWall(through: points("0,6 12,6"))
        #expect(floor.name(of: .zone(bar.id)) == "Bar")
        #expect(floor.name(of: .wall(wall.id)) == "Wall")
        #expect(floor.points(of: .wall(wall.id)) == points("0,6 12,6"))
        #expect(floor.points(of: .zone(UUID())) == nil)
    }

    @Test func movingAShape() throws {
        var floor = makeFloor()
        let bar = try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,4 1,4"))
        try floor.move(.zone(bar.id), dx: 2, dy: 1)
        #expect(floor.zones.first?.outline == points("3,2 7,2 7,5 3,5"))
    }

    @Test func aShapeCannotBeMovedOffTheSheet() throws {
        var floor = makeFloor()
        let bar = try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,4 1,4"))
        #expect(throws: Floor.EditError.outsideSheet) { try floor.move(.zone(bar.id), dx: 18, dy: 0) }
        #expect(floor.zones.first?.outline == points("1,1 5,1 5,4 1,4"))
    }

    @Test func movingEveryKindOfShape() throws {
        var floor = makeFloor()
        let toilet = try floor.addPointOfInterest(named: "WC", kind: .toilet, outline: points("8,0 10,0 10,2"))
        let wall = try floor.addWall(through: points("0,6 12,6"))
        try floor.move(.pointOfInterest(toilet.id), dx: -1, dy: 1)
        try floor.move(.wall(wall.id), dx: 0, dy: 2)
        #expect(floor.pointsOfInterest.first?.outline == points("7,1 9,1 9,3"))
        #expect(floor.walls.first?.points == points("0,8 12,8"))
        #expect(throws: Floor.EditError.unknownShape) { try floor.move(.zone(UUID()), dx: 1, dy: 1) }
    }

    @Test func reshapingByDraggingAPoint() throws {
        var floor = makeFloor()
        let bar = try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,4 1,4"))
        try floor.movePoint(2, of: .zone(bar.id), to: PlanPoint(x: 7, y: 6))
        #expect(floor.zones.first?.outline == points("1,1 5,1 7,6 1,4"))
    }

    @Test func reshapingKeepsTheRules() throws {
        var floor = makeFloor()
        let bar = try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,4"))
        #expect(throws: Floor.EditError.noArea) { try floor.movePoint(2, of: .zone(bar.id), to: PlanPoint(x: 3, y: 1)) }
        #expect(throws: Floor.EditError.outsideSheet) { try floor.movePoint(2, of: .zone(bar.id), to: PlanPoint(x: 5, y: 13)) }
        #expect(throws: Floor.EditError.unknownShape) { try floor.movePoint(7, of: .zone(bar.id), to: PlanPoint(x: 5, y: 5)) }
        #expect(floor.zones.first?.outline == points("1,1 5,1 5,4"))
    }

    @Test func removingShapes() throws {
        var floor = makeFloor()
        let bar = try floor.addZone(named: "Bar", outline: points("1,1 5,1 5,4"))
        let toilet = try floor.addPointOfInterest(named: "WC", kind: .toilet, outline: points("8,0 10,0 10,2"))
        let wall = try floor.addWall(through: points("0,6 12,6"))
        floor.remove(.zone(bar.id))
        floor.remove(.pointOfInterest(toilet.id))
        floor.remove(.wall(wall.id))
        #expect(floor.zones.isEmpty && floor.pointsOfInterest.isEmpty && floor.walls.isEmpty)
    }

    @Test func aSavedGridPlanIsLoadedAsShapes() throws {
        let json = """
        {"id":"7F1C2C55-0C0B-4E48-9B4B-5B2E3E1D0A01","name":"Ground floor","level":0,"width":10,"height":8,
         "zones":[{"id":"7F1C2C55-0C0B-4E48-9B4B-5B2E3E1D0A02","name":"Bar",
                   "cells":[{"row":1,"column":1},{"row":2,"column":3},{"row":1,"column":3}]}],
         "pointsOfInterest":[{"id":"7F1C2C55-0C0B-4E48-9B4B-5B2E3E1D0A03","name":"WC","kind":{"toilet":{}},
                              "cell":{"row":0,"column":4}}]}
        """
        let floor = try JSONDecoder().decode(Floor.self, from: Data(json.utf8))
        #expect(floor.width == 10 && floor.height == 8)
        #expect(floor.zones.first?.outline == points("1,1 4,1 4,3 1,3"))
        #expect(floor.pointsOfInterest.first?.outline == points("4,0 5,0 5,1 4,1"))
        #expect(floor.walls.isEmpty)
    }
}

@Suite("Venue")
@L7
struct VenueTests {

    @Test func floorsAreOrderedByLevel() throws {
        var venue = Venue(name: "Club Neon")
        try venue.addFloor(named: "Gallery", level: 1, width: 20, height: 12)
        try venue.addFloor(named: "Basement", level: -1, width: 20, height: 12)
        try venue.addFloor(named: "Ground floor", level: 0, width: 20, height: 12)
        #expect(venue.floors.map(\.name) == ["Basement", "Ground floor", "Gallery"])
    }

    @Test func floorLevelsAreUnique() throws {
        var venue = Venue(name: "Club Neon")
        try venue.addFloor(named: "Ground floor", level: 0, width: 20, height: 12)
        #expect(throws: Venue.EditError.duplicateLevel(0)) {
            try venue.addFloor(named: "Basement", level: 0, width: 20, height: 12)
        }
    }

    @Test(arguments: [(0.0, 8.0), (10.0, 0.0), (-1.0, 5.0)])
    func floorSizeMustBePositive(width: Double, height: Double) {
        var venue = Venue(name: "Club Neon")
        #expect(throws: Venue.EditError.invalidSize) {
            try venue.addFloor(named: "Ground floor", level: 0, width: width, height: height)
        }
    }

    @Test func editingAFloorThroughTheVenue() throws {
        var venue = Venue(name: "Club Neon")
        let floor = try venue.addFloor(named: "Ground floor", level: 0, width: 20, height: 12)
        try venue.editFloor(id: floor.id) { try $0.addZone(named: "Bar", outline: points("1,1 2,1 2,2")) }
        #expect(venue.floors.first?.zones.map(\.name) == ["Bar"])
    }

    @Test func zoneCodesAreLabelledAndUnique() throws {
        var venue = Venue(name: "Club Neon")
        let ground = try venue.addFloor(named: "Ground floor", level: 0, width: 20, height: 12)
        let gallery = try venue.addFloor(named: "Gallery", level: 1, width: 20, height: 12)
        try venue.editFloor(id: gallery.id) { try $0.addZone(named: "Lounge", outline: points("0,0 1,0 1,1")) }
        try venue.editFloor(id: ground.id) {
            try $0.addZone(named: "Entrance", outline: points("0,10 2,10 2,12"))
            try $0.addZone(named: "Bar", outline: points("1,1 2,1 2,2"))
        }
        let codes = venue.zoneCodes
        #expect(codes.map(\.label) == ["Ground floor – Bar", "Ground floor – Entrance", "Gallery – Lounge"])
        #expect(Set(codes.map(\.payload)).count == 3)
        #expect(codes.allSatisfy { Zone.zoneID(fromQRPayload: $0.payload) != nil })
    }

    @Test func venueRoundTripsThroughJSON() throws {
        var venue = Venue(name: "Club Neon")
        let floor = try venue.addFloor(named: "Ground floor", level: 0, width: 20, height: 12)
        try venue.editFloor(id: floor.id) {
            try $0.addZone(named: "Bar", outline: points("1,1 2,1 2,2"))
            try $0.addPointOfInterest(named: "WC", kind: .toilet, outline: points("8,0 10,0 10,2"))
            try $0.addWall(through: points("0,6 12,6"))
        }
        let decoded = try JSONDecoder().decode(Venue.self, from: JSONEncoder().encode(venue))
        #expect(decoded == venue)
    }
}

@Suite("Floor plan view geometry")
@L7
struct FloorPlanViewGeometryTests {

    @Test func viewPointsAndPlanPointsConvert() {
        #expect(FloorPlanView.planPoint(at: CGPoint(x: 48, y: 12), scale: 24) == PlanPoint(x: 2, y: 0.5))
        #expect(FloorPlanView.viewPoint(for: PlanPoint(x: 2, y: 0.5), scale: 24) == CGPoint(x: 48, y: 12))
    }

    @Test func fittingScaleUsesTheNarrowerSide() {
        let floor = Floor(name: "Ground floor", level: 0, width: 20, height: 12)
        #expect(FloorPlanView.fittingScale(for: floor, in: CGSize(width: 400, height: 1000)) == 20)
        #expect(FloorPlanView.fittingScale(for: floor, in: CGSize(width: 400, height: 120)) == 10)
    }

    @Test func everyKindHasASymbol() {
        let kinds: [POIKind] = [.bar, .toilet, .stage, .entrance, .emergencyExit, .cloakroom, .custom("x")]
        #expect(kinds.allSatisfy { !$0.symbolName.isEmpty })
    }
}

@Suite("Map positions")
@K6 @L4
struct MapPositionTests {

    @Test func latestCheckInWinsPerWorker() {
        let anna = UUID(), bela = UUID(), bar = UUID(), entrance = UUID()
        let base = Date(timeIntervalSince1970: 1_800_000_000)
        let checkIns = [
            ZoneCheckIn(workerID: anna, zoneID: bar, timestamp: base.addingTimeInterval(120)),
            ZoneCheckIn(workerID: anna, zoneID: entrance, timestamp: base),
            ZoneCheckIn(workerID: bela, zoneID: entrance, timestamp: base.addingTimeInterval(60)),
        ]
        #expect(ZoneCheckIn.latestZones(from: checkIns) == [anna: bar, bela: entrance])
    }

    @Test func noCheckInsMeansNoPositions() {
        #expect(ZoneCheckIn.latestZones(from: []).isEmpty)
    }

    @Test func findsTheFloorOfAZone() throws {
        var venue = Venue(name: "Club Neon")
        let ground = try venue.addFloor(named: "Ground floor", level: 0, width: 4, height: 4)
        let gallery = try venue.addFloor(named: "Gallery", level: 1, width: 4, height: 4)
        var lounge: Zone!
        try venue.editFloor(id: gallery.id) { lounge = try $0.addZone(named: "Lounge", outline: points("0,0 1,0 1,1")) }
        #expect(venue.floor(containingZone: lounge.id)?.id == gallery.id)
        #expect(venue.floor(containingZone: UUID()) == nil)
        #expect(venue.floors.first?.id == ground.id)
    }
}
