import Foundation
import Testing
@testable import SharedKit

private func square(_ x: Double, _ y: Double) -> [PlanPoint] {
    [PlanPoint(x: x, y: y), PlanPoint(x: x + 1, y: y), PlanPoint(x: x + 1, y: y + 1), PlanPoint(x: x, y: y + 1)]
}

@Suite("Guest venue")
@M5
struct GuestVenueTests {

    private func venue() throws -> Venue {
        var venue = Venue(name: "Club Neon")
        let basement = try venue.addFloor(named: "Basement", level: -1, width: 6, height: 6)
        let ground = try venue.addFloor(named: "Ground floor", level: 0, width: 6, height: 6)
        try venue.editFloor(id: ground.id) {
            try $0.addZone(named: "Staff room", outline: square(5, 5))
            try $0.addPointOfInterest(named: "WC", kind: .toilet, outline: square(0, 0))
            try $0.addPointOfInterest(named: "Main bar", kind: .bar, outline: square(1, 0))
            try $0.addPointOfInterest(named: "Storage", kind: .custom("storage"), outline: square(2, 0))
            try $0.addWall(through: [PlanPoint(x: 0, y: 3), PlanPoint(x: 6, y: 3)])
        }
        try venue.editFloor(id: basement.id) {
            try $0.addPointOfInterest(named: "Fire exit", kind: .emergencyExit, outline: square(0, 0))
        }
        return venue
    }

    @Test(arguments: [POIKind.bar, .toilet, .stage, .entrance, .emergencyExit, .cloakroom])
    func listedKindsAreForGuests(_ kind: POIKind) {
        #expect(kind.isGuestRelevant)
    }

    @Test func customPlacesAreNotForGuests() {
        #expect(!POIKind.custom("storage").isGuestRelevant)
    }

    @Test func guestFloorHasNoZonesAndNoCustomPlaces() throws {
        let ground = try #require(try venue().forGuests.floors.first { $0.name == "Ground floor" })
        #expect(ground.zones.isEmpty)
        #expect(ground.pointsOfInterest.map(\.name).sorted() == ["Main bar", "WC"])
    }

    @Test func guestFloorKeepsTheWalls() throws {
        let ground = try #require(try venue().forGuests.floors.first { $0.name == "Ground floor" })
        #expect(ground.walls.count == 1)
    }

    @Test func guestVenueKeepsAllFloors() throws {
        #expect(try venue().forGuests.floors.map(\.name) == ["Basement", "Ground floor"])
    }

    @Test func groundFloorIsLevelZero() throws {
        #expect(try venue().groundFloor?.name == "Ground floor")
    }

    @Test func groundFloorFallsBackToTheLevelClosestToZero() throws {
        var venue = Venue(name: "Club Neon")
        try venue.addFloor(named: "Rooftop", level: 3, width: 2, height: 2)
        try venue.addFloor(named: "Gallery", level: 1, width: 2, height: 2)
        #expect(venue.groundFloor?.name == "Gallery")
        #expect(Venue(name: "Empty").groundFloor == nil)
    }
}
