//
//  VenueDesignerSteps.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

/// Keeps the saved venue in memory instead of a file.
final class InMemoryVenueStore: VenueStoring {
    private(set) var saved: Venue?

    func load() -> Venue? { saved }

    func save(_ venue: Venue) throws {
        saved = venue
    }
}

extension Cucumber {

    func setupVenueDesignerSteps() {
        var viewModel: VenueDesignerViewModel!
        var codeSheet: [ZoneCode] = []

        func floor(named name: String) -> Floor? {
            viewModel.venue.floors.first { $0.name == name }
        }

        func drawZone(_ match: Match) throws {
            let name = try match.first(\.string)
            let c = try match.allParameters(\.int)
            let floorID = try XCTUnwrap(viewModel.venue.floors.first?.id)
            viewModel.drawZone(named: name,
                               from: GridCell(row: c[1], column: c[0]),
                               to: GridCell(row: c[3], column: c[2]),
                               onFloor: floorID)
        }

        func poiKind(_ text: String) -> POIKind {
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

        Given("a venue {string} with the floor {string} at level {int} of {int} by {int} cells") { match, _ in
            let names = try match.allParameters(\.string)
            let numbers = try match.allParameters(\.int)
            viewModel = VenueDesignerViewModel(venue: Venue(name: names[0]), store: InMemoryVenueStore())
            codeSheet = []
            viewModel.addFloor(named: names[1], level: numbers[0], width: numbers[1], height: numbers[2])
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("the administrator drew the zone {string} from cell {int},{int} to cell {int},{int}") { match, _ in
            try drawZone(match)
            XCTAssertNil(viewModel.errorMessage)
        }

        When("the administrator draws the zone {string} from cell {int},{int} to cell {int},{int}") { match, _ in
            try drawZone(match)
        }

        When("the administrator places a {string} named {string} at cell {int},{int}") { match, _ in
            let texts = try match.allParameters(\.string)
            let c = try match.allParameters(\.int)
            let floorID = try XCTUnwrap(viewModel.venue.floors.first?.id)
            viewModel.placePointOfInterest(named: texts[1], kind: poiKind(texts[0]),
                                           at: GridCell(row: c[1], column: c[0]), onFloor: floorID)
        }

        When("the administrator adds the floor {string} at level {int} of {int} by {int} cells") { match, _ in
            let numbers = try match.allParameters(\.int)
            viewModel.addFloor(named: try match.first(\.string), level: numbers[0], width: numbers[1], height: numbers[2])
        }

        When("the administrator prints the zone codes") { _, _ in
            codeSheet = viewModel.zoneCodes
        }

        Then("the floor {string} has the zone {string} with {int} cells") { match, _ in
            let names = try match.allParameters(\.string)
            let zone = floor(named: names[0])?.zones.first { $0.name == names[1] }
            XCTAssertEqual(zone?.cells.count, try match.first(\.int))
        }

        Then("the floor {string} has no zone {string}") { match, _ in
            let names = try match.allParameters(\.string)
            XCTAssertNil(floor(named: names[0])?.zones.first { $0.name == names[1] })
        }

        Then("the floor {string} has the point of interest {string} at cell {int},{int}") { match, _ in
            let names = try match.allParameters(\.string)
            let c = try match.allParameters(\.int)
            let poi = floor(named: names[0])?.pointsOfInterest.first { $0.name == names[1] }
            XCTAssertEqual(poi?.cell, GridCell(row: c[1], column: c[0]))
        }

        Then("the designer shows {string}") { match, _ in
            XCTAssertEqual(viewModel.errorMessage, try match.first(\.string))
        }

        Then("the venue's floors are {string}") { match, _ in
            XCTAssertEqual(viewModel.venue.floors.map(\.name).joined(separator: ", "), try match.first(\.string))
        }

        Then("the code sheet lists {string} and {string}") { match, _ in
            XCTAssertEqual(codeSheet.map(\.label), try match.allParameters(\.string))
        }

        Then("every code on the sheet opens its own zone") { _, _ in
            let zones = viewModel.venue.floors.flatMap(\.zones)
            for code in codeSheet {
                let zoneID = Zone.zoneID(fromQRPayload: code.payload)
                XCTAssertEqual(zones.first { $0.id == zoneID }?.name, code.zoneName)
            }
            XCTAssertEqual(Set(codeSheet.map(\.payload)).count, codeSheet.count)
        }
    }
}
