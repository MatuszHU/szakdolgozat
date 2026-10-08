//
//  VenueMapSteps.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

extension Cucumber {

    func setupVenueMapSteps() {
        var venue = Venue(name: "Club Neon")
        var me: WorkerUser!
        var colleagues: [WorkerUser] = []
        var checkIns: [ZoneCheckIn] = []
        var assignedZoneID: UUID?
        var viewModel: VenueMapViewModel!
        var clock = Date(timeIntervalSince1970: 1_800_000_000)

        func zone(named name: String) -> Zone {
            guard let zone = venue.floors.flatMap(\.zones).first(where: { $0.name == name }) else {
                XCTFail("Unknown zone in scenario: \(name)")
                return Zone(name: name)
            }
            return zone
        }

        func person(named name: String) -> WorkerUser {
            guard let person = ([me] + colleagues).compactMap({ $0 }).first(where: { $0.name == name }) else {
                XCTFail("Unknown person in scenario: \(name)")
                return WorkerUser(appleID: name, name: name, role: .bartender, payPeriod: .weekly)
            }
            return person
        }

        BeforeScenario { _ in
            venue = Venue(name: "Club Neon")
            colleagues = []
            checkIns = []
            assignedZoneID = nil
            viewModel = nil
        }

        Given("the venue map has the floor {string} at level {int} with the zones {string} and {string}") { match, _ in
            let names = try match.allParameters(\.string)
            let floor = try venue.addFloor(named: names[0], level: try match.first(\.int), width: 10, height: 8)
            try venue.editFloor(id: floor.id) {
                try $0.addZone(named: names[1], cells: [GridCell(row: 0, column: 0)])
                try $0.addZone(named: names[2], cells: [GridCell(row: 1, column: 1)])
            }
        }

        Given("the floor {string} has a {string} named {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let floorID = try XCTUnwrap(venue.floors.first { $0.name == texts[0] }?.id)
            let kind: POIKind = texts[1] == "toilet" ? .toilet : .custom(texts[1])
            try venue.editFloor(id: floorID) {
                try $0.addPointOfInterest(named: texts[2], kind: kind, at: GridCell(row: 7, column: 9))
            }
        }

        Given("I am {string} and my colleagues are {string}, {string} and {string}") { match, _ in
            let names = try match.allParameters(\.string)
            me = WorkerUser(appleID: names[0], name: names[0], role: .bartender, payPeriod: .weekly)
            colleagues = names.dropFirst().map { WorkerUser(appleID: $0, name: $0, role: .bartender, payPeriod: .weekly) }
        }

        Given("my shift is assigned to the {string} zone") { match, _ in
            assignedZoneID = zone(named: try match.first(\.string)).id
        }

        Given("{string} checked in to the {string} zone") { match, _ in
            let names = try match.allParameters(\.string)
            clock = clock.addingTimeInterval(60)
            checkIns.append(ZoneCheckIn(workerID: person(named: names[0]).id, zoneID: zone(named: names[1]).id, timestamp: clock))
        }

        When("I open the venue map") { _, _ in
            viewModel = VenueMapViewModel(venue: venue, me: me, colleagues: colleagues,
                                          checkIns: checkIns, assignedZoneID: assignedZoneID)
        }

        When("I switch to the floor {string}") { match, _ in
            let name = try match.first(\.string)
            viewModel.selectFloor(id: try XCTUnwrap(venue.floors.first { $0.name == name }?.id))
        }

        Then("the map shows the floor {string}") { match, _ in
            XCTAssertEqual(viewModel.selectedFloor?.name, try match.first(\.string))
        }

        Then("the {string} zone is highlighted as my work area") { match, _ in
            XCTAssertEqual(viewModel.workAreaZoneID, zone(named: try match.first(\.string)).id)
        }

        Then("the map shows the zones {string}") { match, _ in
            XCTAssertEqual(viewModel.selectedFloor?.zones.map(\.name).joined(separator: ", "), try match.first(\.string))
        }

        Then("the map shows the point of interest {string}") { match, _ in
            XCTAssertEqual(viewModel.selectedFloor?.pointsOfInterest.map(\.name), [try match.first(\.string)])
        }

        Then("the {string} zone shows {string}") { match, _ in
            let names = try match.allParameters(\.string)
            XCTAssertEqual(viewModel.colleagueNames(inZone: zone(named: names[0]).id), [names[1]])
        }

        Then("{string} is listed as not checked in") { match, _ in
            XCTAssertEqual(viewModel.colleaguesWithoutPosition.map(\.name), [try match.first(\.string)])
        }
    }
}
