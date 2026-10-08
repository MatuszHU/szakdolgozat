import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import Nightlife

extension Cucumber {

    @M5
    func setupVenueGuideSteps() {
        var venue = Venue(name: "Club Neon")
        var viewModel: GuestMapViewModel!

        func kind(_ text: String) -> POIKind {
            switch text {
            case "bar": return .bar
            case "toilet": return .toilet
            case "stage": return .stage
            case "entrance": return .entrance
            case "emergency exit": return .emergencyExit
            case "cloakroom": return .cloakroom
            default: return .custom(text)
            }
        }

        BeforeScenario { _ in
            venue = Venue(name: "Club Neon")
            viewModel = nil
        }

        Given("the guest venue has the floor {string} at level {int} with these places:") { match, step in
            let floor = try venue.addFloor(named: try match.first(\.string), level: try match.first(\.int), width: 10, height: 8)
            let rows = Array(step.dataTable?.rows.dropFirst() ?? [])
            try venue.editFloor(id: floor.id) { plan in
                for (index, row) in rows.enumerated() {
                    try plan.addPointOfInterest(named: row[0], kind: kind(row[1]), outline: [PlanPoint(x: Double(index), y: 0), PlanPoint(x: Double(index) + 1, y: 0), PlanPoint(x: Double(index) + 1, y: 1), PlanPoint(x: Double(index), y: 1)])
                }
            }
        }

        Given("the floor {string} has the staff zone {string}") { match, _ in
            let names = try match.allParameters(\.string)
            let floorID = try XCTUnwrap(venue.floors.first { $0.name == names[0] }?.id)
            try venue.editFloor(id: floorID) { try $0.addZone(named: names[1], outline: [PlanPoint(x: 5, y: 5), PlanPoint(x: 6, y: 5), PlanPoint(x: 6, y: 6), PlanPoint(x: 5, y: 6)]) }
        }

        Given("the venue has no floor plan yet") { _, _ in
            venue = Venue(name: "Club Neon")
        }

        When("the guest opens the venue guide") { _, _ in
            viewModel = GuestMapViewModel(venue: venue)
        }

        When("the guest switches to the floor {string}") { match, _ in
            let name = try match.first(\.string)
            viewModel.selectFloor(id: try XCTUnwrap(viewModel.floors.first { $0.name == name }?.id))
        }

        Then("the guide shows the floor {string}") { match, _ in
            XCTAssertEqual(viewModel.selectedFloor?.name, try match.first(\.string))
        }

        Then("the guide lists {string}") { match, _ in
            XCTAssertEqual(viewModel.places.map(\.name).joined(separator: ", "), try match.first(\.string))
        }

        Then("the guide does not show {string}") { match, _ in
            let name = try match.first(\.string)
            XCTAssertFalse(viewModel.floors.flatMap(\.pointsOfInterest).contains { $0.name == name })
        }

        Then("the guide shows no staff zones") { _, _ in
            XCTAssertTrue(viewModel.floors.allSatisfy { $0.zones.isEmpty })
        }

        Then("the guest is told that the map is not available yet") { _, _ in
            XCTAssertFalse(viewModel.hasMap)
            XCTAssertNil(viewModel.selectedFloor)
        }
    }
}
